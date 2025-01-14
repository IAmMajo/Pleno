import Fluent
import Vapor
import Models
import VaporToOpenAPI
import RideServiceDTOs


struct EventController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let eventRoutes = routes.grouped("events")
        let adminEventRoutes = eventRoutes.grouped(AdminMiddleware())
        
        eventRoutes.get("", use: getAllPlenoEvents)
        eventRoutes.get(":id", use: getPlenoEvent)
        adminEventRoutes.post("", use: newPlenoEvent)
        adminEventRoutes.patch(":id", use: patchPlenoEvent)
        adminEventRoutes.delete(":id", use: deletePlenoEvent)
        
        eventRoutes.post(":id", "participations", use: newParticipation)
        eventRoutes.patch("participations", ":participant_id", use: patchParticipation)
        eventRoutes.delete("participations", ":participant_id", use: deleteParticipation)
    }
    
    /*
    *
    *   Events
    *
    */
    
    @Sendable
    func getAllPlenoEvents(req: Request) async throws -> [GetEventDTO] {
        // query all events and convert to GetEventDTO
        let plenoEvents = try await PlenoEvent.query(on: req.db).all().map{ plenoEvent in
            let event_id = try plenoEvent.requireID()
            return GetEventDTO(
                id: event_id,
                name: plenoEvent.name,
                starts: plenoEvent.starts,
                ends: plenoEvent.ends
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
        
        // convert event to GetEventDetailDTO
        let event_id = try plenoEvent.requireID()
        let getEventDetailDTO = GetEventDetailDTO(
            id: event_id,
            name: plenoEvent.name,
            description: plenoEvent.description,
            starts: plenoEvent.starts,
            ends: plenoEvent.ends,
            latitude: plenoEvent.latitude,
            longitude: plenoEvent.longitude
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
            longitude: createEventDTO.latitude
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
            longitude: plenoEvent.longitude
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
        let getEventDetailDTO = GetEventDetailDTO(
            id: event_id,
            name: plenoEvent.name,
            description: plenoEvent.description,
            starts: plenoEvent.starts,
            ends: plenoEvent.ends,
            latitude: plenoEvent.latitude,
            longitude: plenoEvent.longitude
        )
        
        return getEventDetailDTO
    }
    
    @Sendable
    func deletePlenoEvent(req: Request) async throws -> HTTPStatus {
        // query event by id
        guard let plenoEvent = try await PlenoEvent.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // delete event
        try await plenoEvent.delete(on: req.db)
        
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
        let getEventParticipationDTO = GetEventParticipationDTO(
            id: participantID,
            name: username,
            itsMe: true,
            participates: participant.participates
        )
        
        return try await getEventParticipationDTO.encodeResponse(status: .created, for: req)
    }
    
    @Sendable
    func patchParticipation(req: Request) async throws -> GetEventParticipationDTO {
        // query participant by id
        guard let participant = try await EventParticipant.find(req.parameters.get("participant_id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // check if user is participant
        if participant.$user.id != req.jwtPayload.userID {
            throw Abort(.forbidden, reason: "You are not allowed to modify the participation!")
        }
        
        // parse DTO
        guard let patchEventParticipationDTO = try? req.content.decode(PatchEventParticipationDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected PatchEventParticipationDTO.")
        }
        
        // patch
        participant.patchWithDTO(dto: patchEventParticipationDTO)
        
        // save changes
        try await participant.save(on: req.db)
        
        // create response
        let username = try await usernameByUserID(userID: participant.$user.id, db: req.db)
        let participantID = try participant.requireID()
        let getEventParticipationDTO = GetEventParticipationDTO(
            id: participantID,
            name: username,
            itsMe: true,
            participates: participant.participates
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
}
