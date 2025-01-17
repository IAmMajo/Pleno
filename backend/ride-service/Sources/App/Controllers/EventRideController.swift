import Fluent
import Vapor
import Models
import VaporToOpenAPI
import RideServiceDTOs


struct EventRideController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let eventRideRoutes = routes.grouped("eventrides")
        
        eventRideRoutes.get("interested", use: getInterestedParties)
        eventRideRoutes.post("interested", use: newInterestedParty)
        eventRideRoutes.patch("interested", "party_id", use: patchInterestedParty)
        eventRideRoutes.delete("interested", "party_id", use: deleteInterestedParty)
    }
    
    /*
    *
    *   Interested Party
    *
    */
    
    @Sendable
    func getInterestedParties(req: Request) async throws -> [GetInterestedPartyDTO] {
        let parties = try await EventRideInteresedParty.query(on: req.db)
            .join(EventParticipant.self, on: \EventRideInteresedParty.$participant.$id == \EventParticipant.$id)
            .join(PlenoEvent.self, on: \EventParticipant.$event.$id == \PlenoEvent.$id)
            .filter(EventParticipant.self, \.$user.$id == req.jwtPayload.userID)
            .all()
            .map{ party in
                let participant = try party.joined(EventParticipant.self)
                let plenoEvent = try participant.joined(PlenoEvent.self)
                let partyID = try party.requireID()
                return GetInterestedPartyDTO(
                    id: partyID,
                    eventName: plenoEvent.name,
                    latitude: party.latitude,
                    longitude: party.longitude)
            }
        
        return parties
    }
    
    @Sendable
    func newInterestedParty(req: Request) async throws -> Response {
        // parse DTO
        guard let createInterestedPartyDTO = try? req.content.decode(CreateInterestedPartyDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected CreateInterestedPartyDTO.")
        }
        
        // check if user is participant
        let participant = try await checkIfUserParticipatesToEvent(eventID: createInterestedPartyDTO.eventID, userID: req.jwtPayload.userID, db: req.db)
        
        // create interested party
        let participantID = try participant.requireID()
        let party = EventRideInteresedParty(
            participantID: participantID,
            latitude: createInterestedPartyDTO.latitude,
            longitude: createInterestedPartyDTO.longitude
        )
        
        // save interested party
        try await party.save(on: req.db)
        
        // create reponse
        let eventName = try await getEventNameByID(eventID: createInterestedPartyDTO.eventID, db: req.db)
        let partyID = try party.requireID()
        let getInteresedPartyDTO = GetInterestedPartyDTO(
            id: partyID,
            eventName: eventName,
            latitude: party.latitude,
            longitude: party.longitude
        )
        
        return try await getInteresedPartyDTO.encodeResponse(status: .created, for: req)
        
    }
    
    @Sendable
    func patchInterestedParty(req: Request) async throws -> GetInterestedPartyDTO {
        // query interested party
        guard let party = try await EventRideInteresedParty.find(req.parameters.get("party_id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // check if current user is allowed to patch
        guard let participant = try await EventParticipant.find(party.$participant.id, on: req.db) else {
            throw Abort(.notFound)
        }
        if participant.$user.id != req.jwtPayload.userID {
            throw Abort(.forbidden, reason: "You are not allowed to patch!")
        }
        
        // parse DTO
        guard let patchInterestedPartyDTO = try? req.content.decode(PatchInterestedPartyDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected PatchInterestedPartyDTO.")
        }
        
        // patch
        party.patchWithDTO(dto: patchInterestedPartyDTO)
        
        // save changes
        try await party.save(on: req.db)
        
        // create response
        let eventName = try await getEventNameByID(eventID: participant.$event.id, db: req.db)
        let partyID = try party.requireID()
        let getInteresedPartyDTO = GetInterestedPartyDTO(
            id: partyID,
            eventName: eventName,
            latitude: party.latitude,
            longitude: party.longitude
        )
        
        return getInteresedPartyDTO
    }
    
    @Sendable
    func deleteInterestedParty(req: Request) async throws -> HTTPStatus {
        // query interested party
        guard let party = try await EventRideInteresedParty.find(req.parameters.get("party_id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // check if current user is allowed to delete
        guard let participant = try await EventParticipant.find(party.$participant.id, on: req.db) else {
            throw Abort(.notFound)
        }
        if participant.$user.id != req.jwtPayload.userID {
            throw Abort(.forbidden, reason: "You are not allowed to patch!")
        }
        
        // delete party
        try await party.delete(on: req.db)
        
        return .noContent
    }
    
    /*
    *
    *   Helper
    *
    */
    
    // return a EventParticipant if a participant exists and accepted to the event
    func checkIfUserParticipatesToEvent(eventID: UUID, userID: UUID, db: Database) async throws -> EventParticipant {
        // check if participant exists
        guard let participant = try await EventParticipant.query(on: db)
            .filter(\.$event.$id == eventID)
            .filter(\.$user.$id == userID)
            .first() else {
            throw Abort(.badRequest, reason: "You are not a participant of the event")
        }
        
        // check if participant accepted
        if !participant.participates {
            throw Abort(.badRequest, reason: "You have not accepted the event")
        }
        
        return participant
    }
    
    // return the name of an event if it exists
    func getEventNameByID(eventID: UUID, db: Database) async throws -> String {
        guard let event = try await PlenoEvent.find(eventID, on: db) else {
            throw Abort(.notFound)
        }
        
        return event.name
    }
}
