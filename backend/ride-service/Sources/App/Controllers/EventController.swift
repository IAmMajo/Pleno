// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Fluent
import Vapor
import Models
import VaporToOpenAPI
import RideServiceDTOs


struct EventController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let openAPITag = TagObject(name: "Events")
        
        let eventRoutes = routes.grouped("events")
        let adminEventRoutes = eventRoutes.grouped(AdminMiddleware())
        
        // GET /events/
        eventRoutes.get("", use: getAllPlenoEvents)
            .openAPI(
                tags: openAPITag,
                summary: "Übersicht der Events abfragen.",
                response: .type([GetEventDTO].self),
                responseContentType: .application(.json),
                statusCode: .ok,
                auth: AuthMiddleware.schemeObject
            )
        // GET /events/:id
        eventRoutes.get(":id", use: getPlenoEvent)
            .openAPI(
                tags: openAPITag,
                summary: "Details eines Events abfragen.",
                path: .type(PlenoEvent.IDValue.self),
                response: .type(GetEventDetailDTO.self),
                responseContentType: .application(.json),
                statusCode: .ok,
                auth: AuthMiddleware.schemeObject
            )
        // POST /events/
        adminEventRoutes.post("", use: newPlenoEvent)
            .openAPI(
                tags: openAPITag,
                summary: "Neues Event anlegen.",
                body: .type(CreateEventDTO.self),
                contentType: .application(.json),
                response: .type(GetEventDetailDTO.self),
                responseContentType: .application(.json),
                statusCode: .created,
                auth: AdminMiddleware.schemeObject
            )
        // PATCH /events/:id
        adminEventRoutes.patch(":id", use: patchPlenoEvent)
            .openAPI(
                tags: openAPITag,
                summary: "Ein Event anpassen.",
                path: .type(PlenoEvent.IDValue.self),
                body: .type(PatchEventDTO.self),
                contentType: .application(.json),
                response: .type(GetEventDetailDTO.self),
                responseContentType: .application(.json),
                statusCode: .ok,
                auth: AdminMiddleware.schemeObject
            )
        // DELETE /events/:id
        adminEventRoutes.delete(":id", use: deletePlenoEvent)
            .openAPI(
                tags: openAPITag,
                summary: "Ein Event löschen.",
                path: .type(PlenoEvent.IDValue.self),
                statusCode: .noContent,
                auth: AdminMiddleware.schemeObject
            )
        // POST /events/:id/participations
        eventRoutes.post(":id", "participations", use: newParticipation)
            .openAPI(
                tags: openAPITag,
                summary: "Rückmeldung zu einem Event geben (zusagen/absagen)",
                path: .type(PlenoEvent.IDValue.self),
                body: .type(CreateEventParticipationDTO.self),
                contentType: .application(.json),
                response: .type(GetEventParticipationDTO.self),
                responseContentType: .application(.json),
                statusCode: .created,
                auth: AuthMiddleware.schemeObject
            )
        // PATCH /events/participations/:id
        eventRoutes.patch("participations", ":participant_id", use: patchParticipation)
            .openAPI(
                tags: openAPITag,
                summary: "Rückmeldung zu einem Event anpassen.",
                path: .type(EventParticipant.IDValue.self),
                body: .type(PatchEventParticipationDTO.self),
                contentType: .application(.json),
                response: .type(GetEventParticipationDTO.self),
                responseContentType: .application(.json),
                statusCode: .ok,
                auth: AuthMiddleware.schemeObject
            )
        // DELETE /events/participations/:id
        eventRoutes.delete("participations", ":participant_id", use: deleteParticipation)
            .openAPI(
                tags: openAPITag,
                summary: "Rückmeldung zu einem Event löschen.",
                path: .type(SpecialRideRequest.IDValue.self),
                statusCode: .noContent,
                auth: AuthMiddleware.schemeObject
            )
    }
    
    /*
    *
    *   Events
    *
    */
    
    @Sendable
    func getAllPlenoEvents(req: Request) async throws -> [GetEventDTO] {
        // query my participations
        let participations = try await EventParticipant.query(on: req.db)
            .filter(\.$user.$id == req.jwtPayload.userID)
            .all()
        
        // query all events and convert to GetEventDTO
        let plenoEvents = try await PlenoEvent.query(on: req.db).all().map{ plenoEvent in
            let event_id = try plenoEvent.requireID()
            
            var myState = UsersEventState.nothing
            if let participation = participations.first(where: { $0.$event.id == event_id }) {
                if participation.participates {
                    myState = UsersEventState.present
                } else {
                    myState = UsersEventState.absent
                }
            }
            
            return GetEventDTO(
                id: event_id,
                name: plenoEvent.name,
                starts: plenoEvent.starts,
                ends: plenoEvent.ends,
                myState: myState
            )
        }
        return plenoEvents
    }
    
    @Sendable
    func getPlenoEvent(req: Request) async throws -> GetEventDetailDTO {
        // query event by id
        guard let plenoEvent = try await PlenoEvent.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // query all participations
        let event_id = try plenoEvent.requireID()
        let (participations, userIDs) = try await allParticipationsForEvent(event_id: event_id, user_id: req.jwtPayload.userID, db: req.db)
        
        // query users without feedback
        let usersWithoutFeedback = try await getUsersWithoutFeedback(user_id: req.jwtPayload.userID, participants: userIDs, db: req.db)
        
        // query countRideInterested
        let countRideInterested = try await getCountRideInterested(eventID: event_id, db: req.db)
        
        // query countEmptySeats
        let countEmptySeats = try await getCountEmptySeats(eventID: event_id, db: req.db)
        
        // convert event to GetEventDetailDTO
        let getEventDetailDTO = GetEventDetailDTO(
            id: event_id,
            name: plenoEvent.name,
            description: plenoEvent.description,
            starts: plenoEvent.starts,
            ends: plenoEvent.ends,
            latitude: plenoEvent.latitude,
            longitude: plenoEvent.longitude,
            participations: participations,
            userWithoutFeedback: usersWithoutFeedback,
            countRideInterested: countRideInterested,
            countEmptySeats: countEmptySeats
        )
        
        return getEventDetailDTO
    }
    
    @Sendable
    func newPlenoEvent(req: Request) async throws -> Response {
        //parse DTO
        guard let createEventDTO = try? req.content.decode(CreateEventDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected CreateEventDTO.")
        }
        
        // create new event
        let plenoEvent = PlenoEvent(
            name: createEventDTO.name,
            description: createEventDTO.description,
            starts: createEventDTO.starts,
            ends: createEventDTO.ends,
            latitude: createEventDTO.latitude,
            longitude: createEventDTO.longitude
        )
        
        // save new event
        try await plenoEvent.save(on: req.db)
        
        // create reponse DTO
        let event_id = try plenoEvent.requireID()
        let getEventDetailDTO = GetEventDetailDTO(
            id: event_id,
            name: plenoEvent.name,
            description: plenoEvent.description,
            starts: plenoEvent.starts,
            ends: plenoEvent.ends,
            latitude: plenoEvent.latitude,
            longitude: plenoEvent.longitude,
            participations: [],
            userWithoutFeedback: [],
            countRideInterested: 0,
            countEmptySeats: 0
        )
        
        return try await getEventDetailDTO.encodeResponse(status: .created, for: req)
    }
    
    @Sendable
    func patchPlenoEvent(req: Request) async throws -> GetEventDetailDTO {
        // query event by id
        guard let plenoEvent = try await PlenoEvent.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // parse DTO
        guard let patchEventDTO = try? req.content.decode(PatchEventDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected PatchEventDTO.")
        }
        
        // patch event
        plenoEvent.patchWithDTO(dto: patchEventDTO)
        
        // save changes
        try await plenoEvent.save(on: req.db)
        
        // create reponse DTO
        let event_id = try plenoEvent.requireID()
        let (participations, userIDs) = try await allParticipationsForEvent(event_id: event_id, user_id: req.jwtPayload.userID, db: req.db)
        let usersWithoutFeedback = try await getUsersWithoutFeedback(user_id: req.jwtPayload.userID, participants: userIDs, db: req.db)
        let countRideInterested = try await getCountRideInterested(eventID: event_id, db: req.db)
        let countEmptySeats = try await getCountEmptySeats(eventID: event_id, db: req.db)
        let getEventDetailDTO = GetEventDetailDTO(
            id: event_id,
            name: plenoEvent.name,
            description: plenoEvent.description,
            starts: plenoEvent.starts,
            ends: plenoEvent.ends,
            latitude: plenoEvent.latitude,
            longitude: plenoEvent.longitude,
            participations: participations,
            userWithoutFeedback: usersWithoutFeedback,
            countRideInterested: countRideInterested,
            countEmptySeats: countEmptySeats
        )
        
        return getEventDetailDTO
    }
    
    @Sendable
    func deletePlenoEvent(req: Request) async throws -> HTTPStatus {
        // query event by id
        guard let plenoEvent = try await PlenoEvent.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // delete in transaction
        let eventID = try plenoEvent.requireID()
        try await req.db.transaction{ db in
            // delete participants
            try await EventParticipant.query(on: db)
                .filter(\.$event.$id == eventID)
                .delete()
            
            // delete event
            try await plenoEvent.delete(on: db)
        }
        
        return .noContent
    }
    
    /*
    *
    *   Participations
    *
    */
    
    @Sendable
    func newParticipation(req: Request) async throws -> Response {
        // query event by id
        guard let plenoEvent = try await PlenoEvent.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // parse DTO
        guard let createEventParticipationDTO = try? req.content.decode(CreateEventParticipationDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected CreateEventParticipationDTO.")
        }
        
        // check if user is already participated
        let event_id = try plenoEvent.requireID()
        let count = try await EventParticipant.query(on: req.db)
            .filter(\.$user.$id == req.jwtPayload.userID)
            .filter(\.$event.$id == event_id)
            .count()
        
        if count != 0 {
            throw Abort(.badRequest, reason: "You already particpate to this event!")
        }
        
        // create participant
        let participant = EventParticipant(
            eventID: event_id,
            userID: req.jwtPayload.userID,
            participates: createEventParticipationDTO.participates
        )
        
        // save participant
        try await participant.save(on: req.db)
        
        // create response
        let username = try await usernameByUserID(userID: participant.$user.id, db: req.db)
        let participantID = try participant.requireID()
        let state = participant.participates ? UsersParticipationState.present : UsersParticipationState.absent
        let getEventParticipationDTO = GetEventParticipationDTO(
            id: participantID,
            name: username,
            itsMe: true,
            participates: state
        )
        
        return try await getEventParticipationDTO.encodeResponse(status: .created, for: req)
    }
    
    @Sendable
    func patchParticipation(req: Request) async throws -> GetEventParticipationDTO {
        // query participant by id
        guard let participant = try await EventParticipant.find(req.parameters.get("participant_id"), on: req.db) else {
            throw Abort(.notFound)
        }
        let participantID = try participant.requireID()
        
        // check if user is participant
        if participant.$user.id != req.jwtPayload.userID {
            throw Abort(.forbidden, reason: "You are not allowed to modify the participation!")
        }
        
        // parse DTO
        guard let patchEventParticipationDTO = try? req.content.decode(PatchEventParticipationDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected PatchEventParticipationDTO.")
        }
        
        // if new state is absent
        var isNewAbsent = false
        if patchEventParticipationDTO.participates == false && participant.participates == true {
            isNewAbsent = true
        }
        
        // patch
        participant.patchWithDTO(dto: patchEventParticipationDTO)
        
        // save and delete
        if isNewAbsent {
            try await req.db.transaction { db in
                // save changes
                try await participant.save(on: db)
                
                // delete rides and interesed parties for this participant
                try await EventRide.query(on: db)
                    .filter(\.$participant.$id == participantID)
                    .delete()
                
                try await EventRideInterestedParty.query(on: db)
                    .filter(\.$participant.$id == participantID)
                    .delete()
            }
        } else {
            // save only changes
            try await participant.save(on: req.db)
        }
        
        // create response
        let username = try await usernameByUserID(userID: participant.$user.id, db: req.db)
        let state = participant.participates ? UsersParticipationState.present : UsersParticipationState.absent
        let getEventParticipationDTO = GetEventParticipationDTO(
            id: participantID,
            name: username,
            itsMe: true,
            participates: state
        )
        
        return getEventParticipationDTO
    }
    
    @Sendable
    func deleteParticipation(req: Request) async throws -> HTTPStatus {
        // query participant by id
        guard let participant = try await EventParticipant.find(req.parameters.get("participant_id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // check if user is participant
        if participant.$user.id != req.jwtPayload.userID {
            throw Abort(.forbidden, reason: "You are not allowed to delete the participation!")
        }
        
        // delete participant
        try await participant.delete(on: req.db)
        
        return .noContent
    }
    
    /*
    *
    *   Helper
    *
    */
    
    func usernameByUserID(userID: UUID, db: Database) async throws -> String {
        let username = try await User.query(on: db)
            .filter(\.$id == userID)
            .with(\.$identity)
            .first()
            .map { user in
                user.identity.name
            }
        return username ?? ""
    }
    
    func allParticipationsForEvent(event_id: UUID, user_id: UUID, db: Database) async throws -> ([GetEventParticipationDTO], [UUID]) {
        var userIDs: [UUID] = []
        let participants = try await EventParticipant.query(on: db)
            .filter(\.$event.$id == event_id)
            .join(User.self, on: \EventParticipant.$user.$id == \User.$id)
            .join(Identity.self, on: \User.$identity.$id == \Identity.$id)
            .all()
            .map{ participant in
                let id = try participant.requireID()
                let identity = try participant.joined(Identity.self)
                let username = identity.name
                
                var state = UsersParticipationState.absent
                if participant.participates {
                    state = UsersParticipationState.present
                }
                
                userIDs.append(participant.$user.id)
                
                return GetEventParticipationDTO(
                    id: id,
                    name: username,
                    itsMe: participant.$user.id == user_id,
                    participates: state
                )
            }
        
        return (participants, userIDs)
    }
    
    func getUsersWithoutFeedback(user_id: UUID, participants: [UUID], db: Database) async throws -> [GetUserWithoutFeedbackDTO] {
        try await User.query(on: db)
            .filter(\.$id !~ participants)
            .join(Identity.self, on: \User.$identity.$id == \Identity.$id)
            .all()
            .map{ user in
                let userID = try user.requireID()
                let identity = try user.joined(Identity.self)
                return GetUserWithoutFeedbackDTO(
                    name: identity.name,
                    itsMe: userID == user_id
                )
            }
    }
    
    func getCountRideInterested(eventID: UUID, db: Database) async throws -> Int {
        return try await EventRideInterestedParty.query(on: db)
            .join(EventParticipant.self, on: \EventRideInterestedParty.$participant.$id == \EventParticipant.$id)
            .filter(EventParticipant.self, \.$event.$id == eventID)
            .count()
    }
    
    func getCountEmptySeats(eventID: UUID, db: Database) async throws -> Int {
        let seats = try await EventRide.query(on: db)
            .filter(\.$event.$id == eventID)
            .all()
            .map { ride in
                return Int(ride.emptySeats)
            }
        
        return seats.reduce(0, +)
    }
}
