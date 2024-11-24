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
    
    @Sendable func getAllMeetings(req: Request) async throws -> [GetMeetingDTO] {
        let isAdmin = req.jwtPayload?.isAdmin ?? false
        let meetings = try await Meeting.query(on: req.db).with(\.$location) {location in
            location.with(\.$place)
        }.all()
        return try meetings.map { meeting in
            return try meeting.toGetMeetingDTO(showCode: isAdmin)
        }
    }
    
    @Sendable func getSingleMeeting(req: Request) async throws -> GetMeetingDTO {
        let isAdmin = req.jwtPayload?.isAdmin ?? false
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try meeting.toGetMeetingDTO(showCode: isAdmin)
    }
    
    @Sendable func createMeeting(req: Request) async throws -> GetMeetingDTO { // TODO: Encapsulate both creations in one transaction (if possible)
        guard let createMeetingDTO = try? req.content.decode(CreateMeetingDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected CreateMeetingDTO.")
        }
        let locationId: Location.IDValue;
        if createMeetingDTO.locationId != nil {
            locationId = createMeetingDTO.locationId!
        } else if let createLocationDTO = createMeetingDTO.location {
            locationId = try await tryCreateLocation(createLocationDTO, req.db).location.requireID()
        } else {
            throw Abort(.badRequest, reason: "Invalid request body! Either CreateMeetingDTO.locationId or CreateMeetingDTO.location must be provided.")
        }
        let meeting: Meeting = .init(name: createMeetingDTO.name, description: createMeetingDTO.description ?? "", status: .scheduled, start: createMeetingDTO.start, duration: createMeetingDTO.duration, locationId: locationId)
        try await meeting.create(on: req.db)
        try await meeting.$location.load(on: req.db)
        return try meeting.toGetMeetingDTO()
    }
    
    @Sendable func updateMeeting(req: Request) async throws -> GetMeetingDTO { // TODO: Encapsulate both creation and update in one transaction (if possible)
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
        var oldLocationId: Location.IDValue? = nil // If the location is updated, oldLocationId is not going to be nil
        if let locationId = patchMeetingDTO.locationId {
            oldLocationId = try meeting.location?.requireID()
            meeting.$location.id = locationId
        } else if let createLocationDTO = patchMeetingDTO.location {
            oldLocationId = try meeting.location?.requireID()
            let result = try await tryCreateLocation(createLocationDTO, req.db)
            meeting.$location.id = try result.location.requireID()
        }
        
        // Remove old location if it is no longer used
        if let oldLocationId = oldLocationId,
           try oldLocationId != meeting.location!.requireID(),
           try await Meeting.query(on: req.db)
            .filter(\.$id != meeting.requireID())
            .filter(\.$location.$id == oldLocationId)
            .first() == nil {
            try await meeting.location!.delete(on: req.db)
        }
        
        // Check if changes were made
        guard meeting.hasChanges else {
            throw Abort(.conflict, reason: "No changes were made.")
        }
        
        // Update meeting
        try await meeting.update(on: req.db)
        try await meeting.$location.load(on: req.db)
        return try meeting.toGetMeetingDTO()
    }
    
    @Sendable func deleteMeeting(req: Request) async throws -> HTTPStatus {
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard meeting.status == .scheduled else {
            throw Abort(.badRequest, reason: "Cannot delete meeting that is not scheduled (status is '\(meeting.status)').")
        }
        try await req.db.transaction { db in
            try await meeting.delete(on: db)
            try await Attendance.query(on: db).filter(\.$id.$meeting.$id == meeting.requireID()).delete()
            try await Voting.query(on: db).filter(\.$meeting.$id == meeting.requireID()).delete() // cascades through voting_options and votes
        }
        return .noContent
    }
    
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
        try await meeting.update(on: req.db)
        
        let record = Record(id: try .init(meeting: meeting, lang: "DE"), identityId: identityId, status: .underway)
        try await record.create(on: req.db)
        
        return try meeting.toGetMeetingDTO(showCode: true)
    }
    
    @Sendable func endMeeting(req: Request) async throws -> GetMeetingDTO {
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        let meetingId = try meeting.requireID()
        guard meeting.status == .inSession else {
            throw Abort(.badRequest, reason: "Cannot end meeting that is not in session (status is '\(meeting.status)').")
        }
        if let voting = try await Voting.query(on: req.db)
            .filter(\.$meeting.$id == meetingId)
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
            try await Attendance.query(on: db)
                .filter(\.$id.$meeting.$id == meeting.requireID())
                .filter(\.$status != .present)
                .delete()
            let attendees = try await Attendance.query(on: db)
                .filter(\.$id.$meeting.$id == meeting.requireID())
                .field(\.$id.$identity.$id)
                .all()
                .map { attendance in
                    try attendance.requireID().identity.requireID()
//                    return attendance.$id.$identity.id
                }
            for identityId in attendees {
                try await Attendance(id: .init(meetingId: meetingId, identityId: identityId), status: .absent).create(on: db)
            }
            try await meeting.update(on: db)
        }
        return try meeting.toGetMeetingDTO(showCode: true)
    }
    
    @Sendable func getAllLocations(req: Request) async throws -> [GetLocationDTO] {
        try await Location.query(on: req.db).all().map { location in
            try location.toGetLocationDTO()
        }
    }
    
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
