import Fluent
import Vapor
import Models
import MeetingServiceDTOs

struct MeetingController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let adminMiddleware = AdminMiddleware()
        let adminRoutes = routes.grouped(adminMiddleware)
        routes.get(use: getAllMeetings)
        routes.get(":id", use: getSingleMeeting)
        adminRoutes.post(use: createMeeting)
        adminRoutes.group(":id") { meetingRoutes in
            meetingRoutes.patch(use: updateMeeting)
            meetingRoutes.delete(use: deleteMeeting)
            meetingRoutes.put("begin", use: beginMeeting)
            meetingRoutes.put("end", use: endMeeting)
        }
        routes.group("locations") { locationRoutes in
            locationRoutes.get(use: getAllLocations)
            locationRoutes.get(":id", use: getSingleLocation)
        }
    }
    
    /// **GET** `/meetings`
    @Sendable func getAllMeetings(req: Request) async throws -> [GetMeetingDTO] {
        let isAdmin = req.jwtPayload?.isAdmin ?? false
        let meetings = try await Meeting.query(on: req.db)
            .with(\.$chair)
            .with(\.$location) {location in
                location.with(\.$place)
            }.all()
        return try meetings.map { meeting in
            return try meeting.toGetMeetingDTO(showCode: isAdmin)
        }
    }
    
    /// **GET** `/meetings/{id}`
    @Sendable func getSingleMeeting(req: Request) async throws -> GetMeetingDTO {
        let isAdmin = req.jwtPayload?.isAdmin ?? false
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await meeting.$chair.load(on: req.db)
        try await meeting.$location.load(on: req.db)
        try await meeting.location?.$place.load(on: req.db)
        return try meeting.toGetMeetingDTO(showCode: isAdmin)
    }
    
    /// **POST** `/meetings/`
    @Sendable func createMeeting(req: Request) async throws -> Response { // -> GetMeetingDTO
        guard let createMeetingDTO = try? req.content.decode(CreateMeetingDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected CreateMeetingDTO.")
        }
        let meeting = try await req.db.transaction { db in
            let locationId: Location.IDValue;
            if createMeetingDTO.locationId != nil {
                locationId = createMeetingDTO.locationId!
            } else if let createLocationDTO = createMeetingDTO.location {
                locationId = try await tryCreateLocation(createLocationDTO, db).location.requireID()
            } else {
                throw Abort(.badRequest, reason: "Invalid request body! Either CreateMeetingDTO.locationId or CreateMeetingDTO.location must be provided.")
            }
            let meeting: Meeting = .init(name: createMeetingDTO.name, description: createMeetingDTO.description ?? "", status: .scheduled, start: createMeetingDTO.start, duration: createMeetingDTO.duration, locationId: locationId)
            try await meeting.create(on: db)
            try await meeting.$location.load(on: db)
            try await meeting.location?.$place.load(on: db)
            return meeting
        }
        return try await meeting.toGetMeetingDTO().encodeResponse(status: .created, for: req)
    }
    
    /// **PATCH** `/meetings/{id}`
    @Sendable func updateMeeting(req: Request) async throws -> GetMeetingDTO {
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let patchMeetingDTO = try? req.content.decode(PatchMeetingDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected PatchMeetingDTO.")
        }
        guard meeting.status == .scheduled else {
            throw Abort(.badRequest, reason: "Updating a meeting after it has \(meeting.status == .inSession ? "started" : "ended") is not allowed.")
        }
        if let name = patchMeetingDTO.name {
            meeting.name = name
        }
        if let description = patchMeetingDTO.description {
            meeting.description = description
        }
        if let start = patchMeetingDTO.start {
            meeting.start = start
        }
        if let duration = patchMeetingDTO.duration {
            meeting.duration = duration
        }
        try await req.db.transaction { db in
            var oldLocationId: Location.IDValue? = nil // If the location is updated, oldLocationId is not going to be nil
            if let locationId = patchMeetingDTO.locationId {
                oldLocationId = try await meeting.$location.get(on: db)?.requireID()
                meeting.$location.id = locationId
            } else if let createLocationDTO = patchMeetingDTO.location {
                oldLocationId = try await meeting.$location.get(on: db)?.requireID()
                let result = try await tryCreateLocation(createLocationDTO, db)
                meeting.$location.id = try result.location.requireID()
            }
            
            // Remove old location if it is no longer used
            if let oldLocationId = oldLocationId,
               oldLocationId != meeting.$location.id,
               try await Meeting.query(on: db)
                .filter(\.$id != meeting.requireID())
                .filter(\.$location.$id == oldLocationId)
                .first() == nil {
                try await Location.find(oldLocationId, on: db)?.delete(on: db)
            }
            
            // Check if changes were made
            guard meeting.hasChanges else {
                throw Abort(.conflict, reason: "No changes were made.")
            }
            
            // Update meeting
            try await meeting.update(on: db)
            try await meeting.$location.load(on: db)
            try await meeting.location?.$place.load(on: db)
            
        }
        return try meeting.toGetMeetingDTO()
    }
    
    /// **DELETE** `/meetings/{id}`
    @Sendable func deleteMeeting(req: Request) async throws -> HTTPStatus {
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard meeting.status == .scheduled else {
            throw Abort(.badRequest, reason: "Cannot delete meeting that is not scheduled (status is '\(meeting.status)').")
        }
        try await req.db.transaction { db in
            try await meeting.$attendances.get(on: db).delete(on: db)
            try await meeting.$votings.get(on: db).delete(on: db) // cascades through voting_options and votes
            try await meeting.delete(on: db)
        }
        return .noContent
    }
    
    /// **PUT** `/meetings/{id}/begin`
    @Sendable func beginMeeting(req: Request) async throws -> GetMeetingDTO {
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard meeting.status == .scheduled else {
            throw Abort(.badRequest, reason: "Cannot start meeting that is not scheduled (status is '\(meeting.status)').")
        }
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        let identityId = try await Identity.byUserId(userId, req.db).requireID()
        meeting.status = .inSession
        meeting.start = .now
        meeting.$chair.id = identityId
        meeting.code = String(Int.random(in: 100000...999999))
        
        try await req.db.transaction { db in
            try await meeting.update(on: db)
            
            let record = Record(id: try .init(meeting: meeting, lang: "DE"), identityId: identityId, status: .underway)
            try await record.create(on: db)
            
            if let attendance = try await Attendance.find(.init(meeting: meeting, identityId: identityId), on: db) {
                attendance.status = .present
                try await attendance.update(on: db)
            } else {
                let attendance = try Attendance(id: .init(meeting: meeting, identityId: identityId), status: .present)
                try await attendance.create(on: db)
            }
            
            try await meeting.$chair.load(on: db)
            try await meeting.$location.load(on: db)
            try await meeting.location?.$place.load(on: db)
        }
        
        return try meeting.toGetMeetingDTO(showCode: true)
    }
    
    /// **PUT** `/meetings/{id}/end`
    @Sendable func endMeeting(req: Request) async throws -> GetMeetingDTO {
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        let meetingId = try meeting.requireID()
        guard meeting.status == .inSession else {
            throw Abort(.badRequest, reason: "Cannot end meeting that is not in session (status is '\(meeting.status)').")
        }
        if let voting = try await meeting.$votings.query(on: req.db)
            .group(.or, { group in
                group.filter(\.$startedAt == nil)
                    .filter(\.$closedAt == nil)
            })
                .first() {
            throw Abort(.badRequest, reason: "Cannot end meeting with unfinished votings ('\(voting.question)').")
        }
        
        meeting.status = .completed
        meeting.duration = UInt16((meeting.start.distance(to: .now) / 60).rounded(.up))
        try await req.db.transaction { db in
            try await meeting.$attendances.query(on: db)
                .filter(\.$status != .present)
                .delete()
            let attendees = try await meeting.$attendances.query(on: db)
                .with(\.$id.$identity)
                .field(\.$id.$identity.$id)
                .all()
                .map { attendance in
                    try attendance.requireID().identity.requireID()
                }
            let absentees = try await Identity.query(on: db)
                .filter(\.$id !~ attendees)
                .field(\.$id)
                .all()
                .map { identity in
                    try identity.requireID()
                }
            for identityId in absentees {
                try await Attendance(id: .init(meetingId: meetingId, identityId: identityId), status: .absent).create(on: db)
            }
            try await meeting.update(on: db)
            try await meeting.$chair.load(on: db)
            try await meeting.$location.load(on: db)
            try await meeting.location?.$place.load(on: db)
        }
        return try meeting.toGetMeetingDTO(showCode: true)
    }
    
    /// **GET** `/meetings/locations`
    @Sendable func getAllLocations(req: Request) async throws -> [GetLocationDTO] {
        try await Location.query(on: req.db).all().map { location in
            try location.toGetLocationDTO()
        }
    }
    
    /// **GET** `/meetings/locations/{id}`
    @Sendable func getSingleLocation(req: Request) async throws -> GetLocationDTO {
        guard let location = try await Location.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try location.toGetLocationDTO()
    }
    
    func tryCreateLocation(_ createLocationDTO: CreateLocationDTO, _ db: Database) async throws -> (location: Location, createdNewLocation: Bool) {
        guard (createLocationDTO.postalCode != nil) == (createLocationDTO.place != nil) else { // XNOR
            throw Abort(.badRequest, reason: "Either CreateLocationDTO.postalCode and CreateLocationDTO.place or none of them must be provided.")
        }
        guard !createLocationDTO.name.isEmpty else {
            throw Abort(.badRequest, reason: "CreateLocationDTO.name cannot be empty.")
        }
        var placeId: Place.IDValue? = nil
        if let postalCode = createLocationDTO.postalCode, let place = createLocationDTO.place { // If this executes, placeId is not going to be nil
            do {
                placeId = try await Place.query(on: db).filter(\.$postalCode == postalCode).filter(\.$place == place).first()!.requireID()
            } catch {
                let placeModel: Place = .init(postalCode: postalCode, place: place)
                try await placeModel.create(on: db)
                placeId = try placeModel.requireID()
            }
        }
        let location: Location = .init(name: createLocationDTO.name, street: createLocationDTO.street ?? "", number: createLocationDTO.number ?? "", letter: createLocationDTO.letter ?? "", placeId: placeId)
        if let existingLocation = try await Location.query(on: db)
            .filter(\.$name == location.name)
            .filter(\.$street == location.street)
            .filter(\.$number == location.number)
            .filter(\.$letter == location.letter)
            .filter(\.$place.$id == location.place?.id)
            .first() {
            return (existingLocation, false)
        } else {
            try await location.create(on: db)
            return (location, true)
        }
        
    }
}
