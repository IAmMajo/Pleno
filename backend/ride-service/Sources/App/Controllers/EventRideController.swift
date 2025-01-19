import Fluent
import Vapor
import Models
//import VaporToOpenAPI
import RideServiceDTOs


struct EventRideController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let eventRideRoutes = routes.grouped("eventrides")
        
        eventRideRoutes.get("", use: getAllEventRides)
        eventRideRoutes.get(":id", use: getEventRide)
        eventRideRoutes.post("", use: newEventRide)
        eventRideRoutes.patch(":id", use: patchEventRide)
        eventRideRoutes.delete(":id", use: deleteEventRide)
        
        eventRideRoutes.post(":id", "requests", use: newRequestToEventRide)
        eventRideRoutes.patch("requests", ":request_id", use: patchEventRideRequest)
        eventRideRoutes.delete("requests", ":request_id", use: deleteEventRideRequest)
        
        eventRideRoutes.get("interested", use: getInterestedParties)
        eventRideRoutes.post("interested", use: newInterestedParty)
        eventRideRoutes.patch("interested", ":party_id", use: patchInterestedParty)
        eventRideRoutes.delete("interested", ":party_id", use: deleteInterestedParty)
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
     *   Eventrides
     *
     */
    
    @Sendable
    func getAllEventRides(req: Request) async throws -> [GetEventRideDTO] {
        let eventRides = try await EventRide.query(on: req.db).all()
        var responseRides: [GetEventRideDTO] = []
        
        for eventRide in eventRides {
            if let rideID = eventRide.id {
                let allocatedSeats = try await EventRideRequest.query(on: req.db)
                    .filter(\.$ride.$id == rideID)
                    .filter(\.$accepted == true)
                    .count()
                
                let participant = try await EventParticipant.query(on: req.db)
                    .filter(\.$event.$id == eventRide.$event.id)
                    .filter(\.$user.$id == req.jwtPayload.userID)
                    .first()
                
                var usersState = UsersEventRideState.nothing
                if let participant = participant {
                    let participantID = try participant.requireID()
                    
                    if eventRide.$participant.id == participantID {
                        usersState = UsersEventRideState.driver
                    } else {
                        let request = try await EventRideRequest.query(on: req.db)
                            .filter(\.$ride.$id == rideID)
                            .join(EventRideInteresedParty.self, on: \EventRideRequest.$interestedParty.$id == \EventRideInteresedParty.$id)
                            .join(EventParticipant.self, on: \EventRideInteresedParty.$participant.$id == \EventParticipant.$id)
                            .filter(EventParticipant.self, \.$user.$id == req.jwtPayload.userID)
                            .first()
                        
                        if let request = request {
                            if request.accepted {
                                usersState = UsersEventRideState.accepted
                            } else {
                                usersState = UsersEventRideState.requested
                            }
                        }
                    }
                }
                
                let eventName = try await getEventNameByID(eventID: eventRide.$event.id, db: req.db)
                responseRides.append(
                    GetEventRideDTO(
                        id: rideID,
                        eventID: eventRide.$event.id,
                        eventName: eventName,
                        starts: eventRide.starts,
                        emptySeats: eventRide.emptySeats,
                        allocatedSeats: UInt8(allocatedSeats),
                        myState: usersState
                    )
                )
            }
        }
        
        return responseRides
    }
    
    @Sendable
    func getEventRide(req: Request) async throws -> GetEventRideDetailDTO {
        // get ride by id
        guard let rideID = UUID(uuidString: req.parameters.get("id") ?? "") else {
            throw Abort(.badRequest)
        }
        guard let eventRide = try await EventRide.query(on: req.db)
            .filter(\.$id == rideID)
            .with(\.$participant)
            .with(\.$event)
            .first() else {
            throw Abort(.notFound)
        }
        
        // get riders
        var riders = try await EventRideRequest.query(on: req.db)
            .filter(\.$ride.$id == rideID)
            .with(\.$interestedParty) { party in
                party.with(\.$participant) { participant in
                    participant.with(\.$user) { user in
                        user.with(\.$identity)
                    }
                }
            }
            .all()
            .map { rider in
                let riderID = try rider.requireID()
                
                return GetRiderDTO(
                    id: riderID,
                    username: rider.interestedParty.participant.user.identity.name,
                    latitude: rider.interestedParty.latitude,
                    longitude: rider.interestedParty.longitude,
                    itsMe: rider.interestedParty.participant.user.id == req.jwtPayload.userID,
                    accepted: rider.accepted)
            }
        
        // delete all open requests, if user is not the driver
        if eventRide.participant.$user.id != req.jwtPayload.userID {
            riders.removeAll{ $0.accepted == false && $0.itsMe == false }
        }
        
        // create response DTO
        let drivername = try await User.query(on: req.db)
            .filter(\.$id == eventRide.participant.$user.id)
            .with(\.$identity)
            .first()
            .map { user in
                user.identity.name
            }
        let eventRideDetailDTO = GetEventRideDetailDTO(
            id: rideID,
            eventID: eventRide.$event.id,
            eventName: eventRide.event.name,
            driverName: drivername ?? "",
            isSelfDriver: eventRide.participant.$user.id == req.jwtPayload.userID,
            description: eventRide.description,
            vehicleDescription: eventRide.vehicleDescription,
            starts: eventRide.starts,
            latitude: eventRide.latitude,
            longitude: eventRide.longitude,
            emptySeats: eventRide.emptySeats,
            riders: riders
        )
        
        return eventRideDetailDTO
    }
    
    @Sendable
    func newEventRide(req: Request) async throws -> Response {
        // parse DTO
        guard let createEventRideDTO = try? req.content.decode(CreateEventRideDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected CreateEventRideDTO.")
        }
        
        // check if current user is participant
        let participant = try await checkIfUserParticipatesToEvent(eventID: createEventRideDTO.eventID, userID: req.jwtPayload.userID, db: req.db)
        
        // TODO check if current user has already a ride
        
        // create new event ride
        let participantID = try participant.requireID()
        let eventRide = EventRide(
            eventID: createEventRideDTO.eventID,
            participantID: participantID,
            starts: createEventRideDTO.starts,
            latitude: createEventRideDTO.latitude,
            longitude: createEventRideDTO.longitude,
            emptySeats: createEventRideDTO.emptySeats,
            description: createEventRideDTO.description,
            vehicleDescription: createEventRideDTO.vehicleDescription
        )
        
        // save ride
        try await eventRide.save(on: req.db)
        
        // TODO delete interested parties
        
        
        // create response
        let rideID = try eventRide.requireID()
        let eventName = try await getEventNameByID(eventID: eventRide.$event.id, db: req.db)
        let drivername = try await User.query(on: req.db)
            .filter(\.$id == req.jwtPayload.userID)
            .with(\.$identity)
            .first()
            .map { user in
                user.identity.name
            }
        let getEventRideDetailDTO = GetEventRideDetailDTO(
            id: rideID,
            eventID: eventRide.$event.id,
            eventName: eventName,
            driverName: drivername ?? "",
            isSelfDriver: true,
            description: eventRide.description,
            vehicleDescription: eventRide.vehicleDescription,
            starts: eventRide.starts,
            latitude: eventRide.latitude,
            longitude: eventRide.longitude,
            emptySeats: eventRide.emptySeats,
            riders: []
        )
        
        return try await getEventRideDetailDTO.encodeResponse(status: .created, for: req)
    }
    
    @Sendable
    func patchEventRide(req: Request) async throws -> GetEventRideDetailDTO {
        // get ride by id
        guard let rideID = UUID(uuidString: req.parameters.get("id") ?? "") else {
            throw Abort(.badRequest)
        }
        guard let eventRide = try await EventRide.query(on: req.db)
            .filter(\.$id == rideID)
            .with(\.$participant)
            .with(\.$event)
            .first() else {
            throw Abort(.notFound)
        }
        
        // check if current user is driver
        if eventRide.participant.$user.id != req.jwtPayload.userID {
            throw Abort(.forbidden, reason: "You are not the driver!")
        }
        
        //parse DTO
        guard let patchEventRideDTO = try? req.content.decode(PatchEventRideDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected PatchEventRideDTO.")
        }
        
        // patch ride
        eventRide.patchWithDTO(dto: patchEventRideDTO)
        
        // save changes
        try await eventRide.save(on: req.db)
        
        // create response
        let riders = try await EventRideRequest.query(on: req.db)
            .filter(\.$ride.$id == rideID)
            .with(\.$interestedParty) { party in
                party.with(\.$participant) { participant in
                    participant.with(\.$user) { user in
                        user.with(\.$identity)
                    }
                }
            }
            .all()
            .map { rider in
                let riderID = try rider.requireID()
                
                return GetRiderDTO(
                    id: riderID,
                    username: rider.interestedParty.participant.user.identity.name,
                    latitude: rider.interestedParty.latitude,
                    longitude: rider.interestedParty.longitude,
                    itsMe: rider.interestedParty.participant.user.id == req.jwtPayload.userID,
                    accepted: rider.accepted)
            }
        let drivername = try await User.query(on: req.db)
            .filter(\.$id == req.jwtPayload.userID)
            .with(\.$identity)
            .first()
            .map { user in
                user.identity.name
            }
        let eventRideDetailDTO = GetEventRideDetailDTO(
            id: rideID,
            eventID: eventRide.$event.id,
            eventName: eventRide.event.name,
            driverName: drivername ?? "",
            isSelfDriver: eventRide.participant.$user.id == req.jwtPayload.userID,
            description: eventRide.description,
            vehicleDescription: eventRide.vehicleDescription,
            starts: eventRide.starts,
            latitude: eventRide.latitude,
            longitude: eventRide.longitude,
            emptySeats: eventRide.emptySeats,
            riders: riders
        )
        
        return eventRideDetailDTO
    }
    
    @Sendable
    func deleteEventRide(req: Request) async throws -> HTTPStatus {
        // get ride by id
        guard let rideID = UUID(uuidString: req.parameters.get("id") ?? "") else {
            throw Abort(.badRequest)
        }
        guard let eventRide = try await EventRide.query(on: req.db)
            .filter(\.$id == rideID)
            .with(\.$participant)
            .first() else {
            throw Abort(.notFound)
        }
        
        // check if current user is driver
        if eventRide.participant.$user.id != req.jwtPayload.userID {
            throw Abort(.forbidden, reason: "You are not the driver!")
        }
        
        // delete ride
        try await eventRide.delete(on: req.db)
        
        return .noContent
    }
    
    /*
     *
     *   EventRideRequests
     *
     */
    
    @Sendable
    func newRequestToEventRide(req: Request) async throws -> Response {
        // get ride by id
        guard let rideID = UUID(uuidString: req.parameters.get("id") ?? "") else {
            throw Abort(.badRequest)
        }
        guard let eventRide = try await EventRide.query(on: req.db)
            .filter(\.$id == rideID)
            .with(\.$participant)
            .first() else {
            throw Abort(.notFound)
        }
        
        // check if current user is in interested party
        guard let party = try await EventRideInteresedParty.query(on: req.db)
            .with(\.$participant)
            .join(EventParticipant.self, on: \EventRideInteresedParty.$participant.$id == \EventParticipant.$id)
            .filter(EventParticipant.self, \.$user.$id == req.jwtPayload.userID)
            .filter(EventParticipant.self, \.$event.$id == eventRide.$event.id)
            .first() else {
            throw Abort(.notFound, reason: "No interested party found!")
        }
        
        // check if current user already requested to this ride
        let partyID = try party.requireID()
        let count = try await EventRideRequest.query(on: req.db)
            .filter(\.$ride.$id == rideID)
            .filter(\.$interestedParty.$id == partyID)
            .count()
        
        if count != 0 {
            throw Abort(.badRequest, reason: "You already requested this ride!")
        }
        
        // check if current user is driver of this ride
        if eventRide.$participant.id == party.$participant.id {
            throw Abort(.badRequest, reason: "You cannot request your own ride!")
        }
        
        // check if ride is full
        let countAccepted = try await EventRideRequest.query(on: req.db)
            .filter(\.$ride.$id == rideID)
            .filter(\.$accepted == true)
            .count()
        
        if countAccepted >= eventRide.emptySeats {
            throw Abort(.badRequest, reason: "This ride is full!")
        }
        
        // create request
        let request = EventRideRequest(
            rideID: rideID,
            interestedPartyID: partyID,
            accepted: false
        )
        
        // save request
        try await request.save(on: req.db)
        
        // create response
        let rider_id = try request.requireID()
        let username = try await User.query(on: req.db)
            .filter(\.$id == req.jwtPayload.userID)
            .with(\.$identity)
            .first()
            .map { user in
                user.identity.name
            }
        let getRiderDTO = GetRiderDTO(
            id: rider_id,
            username: username ?? "",
            latitude: party.latitude,
            longitude: party.longitude,
            itsMe: true,
            accepted: request.accepted
        )
        
        return try await getRiderDTO.encodeResponse(status: .created, for: req)
    }
    
    @Sendable
    func patchEventRideRequest(req: Request) async throws -> GetRiderDTO {
        // get request by id
        guard let requestID = UUID(uuidString: req.parameters.get("request_id") ?? "" ) else {
            throw Abort(.badRequest)
        }
        let request = try await EventRideRequest.query(on: req.db)
            .filter(\.$id == requestID)
            .with(\.$interestedParty) { party in
                party.with(\.$participant) { participant in
                    participant.with(\.$user) { user in
                        user.with(\.$identity)
                    }
                }
            }
            .first()
        
        guard let request = request else {
            throw Abort(.notFound)
        }
        
        // get ride by id
        let rideID = request.$ride.id
        let eventRide = try await EventRide.query(on: req.db)
            .filter(\.$id == rideID)
            .with(\.$participant) { participant in
                participant.with(\.$user)
            }
            .first()
        guard let eventRide = eventRide else {
            throw Abort(.notFound)
        }
        
        //parse DTO
        guard let patchEventRideRequestDTO = try? req.content.decode(PatchEventRideRequestDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected PatchEventRideRequestDTO.")
        }
        
        // check if current user is driver
        if eventRide.participant.user.id != req.jwtPayload.userID {
            throw Abort(.forbidden, reason: "You are not allowed to change the request!")
        }
        
        // check if current accepted == new accepted
        if patchEventRideRequestDTO.accepted == request.accepted {
            throw Abort(.badRequest, reason: "There is nothing to patch!")
        }
        
        // save isNewRider state
        var isFullWithNewRider = false
        
        // check if driver wants to accept a new rider
        if patchEventRideRequestDTO.accepted == true {
            // check if ride is full
            let countAccepted = try await EventRideRequest.query(on: req.db)
                .filter(\.$ride.$id == rideID)
                .filter(\.$accepted == true)
                .count()
            
            if countAccepted >= eventRide.emptySeats {
                throw Abort(.badRequest, reason: "This ride is full!")
            }
    
            // check if ride is now full - delete all open requests
            if countAccepted + 1 >= eventRide.emptySeats {
                isFullWithNewRider = true
            }
        }
        
        // patch
        request.patchWithDTO(dto: patchEventRideRequestDTO)
        
        // save changes
        // if isFullWithNewRider save changes in a transaction
        if isFullWithNewRider == true {
            try await req.db.transaction{ db in
                // save changes in request
                try await request.update(on: db)
                
                // delete all open requests
                try await EventRideRequest.query(on: db)
                    .filter(\.$ride.$id == rideID)
                    .filter(\.$accepted == false)
                    .delete()
            }
        } else {
            // save changes in request
            try await request.update(on: req.db)
        }
        
        // create response
        let rider_id = try request.requireID()
        let username = try await User.query(on: req.db)
            .filter(\.$id == request.interestedParty.participant.$user.id)
            .with(\.$identity)
            .first()
            .map { user in
                user.identity.name
            }
        guard let party = try await EventRideInteresedParty.query(on: req.db)
            .join(EventParticipant.self, on: \EventRideInteresedParty.$participant.$id == \EventParticipant.$id)
            .with(\.$participant)
            .filter(EventParticipant.self, \.$user.$id == request.interestedParty.participant.$user.id)
            .filter(EventParticipant.self, \.$event.$id == eventRide.$event.id)
            .first() else {
            throw Abort(.notFound)
        }
        let getRiderDTO = GetRiderDTO(
            id: rider_id,
            username: username ?? "",
            latitude: party.latitude,
            longitude: party.longitude,
            itsMe: request.interestedParty.participant.$user.id == req.jwtPayload.userID,
            accepted: request.accepted
        )
        
        return getRiderDTO
    }
    
    @Sendable
    func deleteEventRideRequest(req: Request) async throws -> HTTPStatus {
        // get request by id
        guard let requestID = UUID(uuidString: req.parameters.get("request_id") ?? "" ) else {
            throw Abort(.badRequest)
        }
        let request = try await EventRideRequest.query(on: req.db)
            .filter(\.$id == requestID)
            .with(\.$interestedParty) { party in
                party.with(\.$participant) { participant in
                    participant.with(\.$user) { user in
                        user.with(\.$identity)
                    }
                }
            }
            .first()
        
        guard let request = request else {
            throw Abort(.notFound)
        }
        
        // check if user is allowed to delete
        if request.interestedParty.participant.$user.id != req.jwtPayload.userID {
            throw Abort(.forbidden, reason: "You are not allowed to delete this request!")
        }
        
        // delete request
        try await request.delete(on: req.db)
        
        return .noContent
    }
    
    /*
     *
     *   Helper
     *
     */
    
    // return an EventParticipant if a participant exists and accepted to the event
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
