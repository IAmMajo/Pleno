import Fluent
import Vapor
import Models
import VaporToOpenAPI

struct RideController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let openAPITag = TagObject(name: "Rides")

        let rideRoutes = routes.grouped("rides")
        let adminRideRoutes = rideRoutes.grouped(AdminMiddleware())
        rideRoutes.get("", use: getAllRides)
            .openAPI(tags: openAPITag, summary: "Alle Rides abfragen", response: .type([GetRideOverviewDTO].self), responseContentType: .application(.json), statusCode: .ok, auth: AuthMiddleware.schemeObject)
        rideRoutes.get(":id", use: getRide)
            .openAPI(tags: openAPITag, summary: "Einzelnen Rides abfragen", path: .type(Ride.IDValue.self), response: .type(GetRideDetailDTO.self), responseContentType: .application(.json), statusCode: .ok, auth: AuthMiddleware.schemeObject)
        rideRoutes.get(":id", "participation", use: getParticipation)
            .openAPI(tags: openAPITag, summary: "Teilnahme zu einem Ride abfragen", path: .type(Ride.IDValue.self), response: .type(ParticipationDTO.self), responseContentType: .application(.json), statusCode: .ok, auth: AuthMiddleware.schemeObject)
        rideRoutes.post(":id", "participation", use: newParticipation)
            .openAPI(tags: openAPITag, summary: "An einem Ride teilnehmen", path: .type(Ride.IDValue.self), body: .type(ParticipationDTO.self), contentType: .application(.json), response: .type(GetParticipantDTO.self), responseContentType: .application(.json), statusCode: .created, auth: AuthMiddleware.schemeObject)
        rideRoutes.patch(":id", "participation", use: patchParticipation)
            .openAPI(tags: openAPITag, summary: "Teilnahme zu einem Ride ändern", path: .type(Ride.IDValue.self), body: .type(PatchParticipationDTO.self), contentType: .application(.json), response: .type(GetParticipantDTO.self), responseContentType: .application(.json), statusCode: .ok, auth: AuthMiddleware.schemeObject)
        rideRoutes.delete(":id", "participation", use: deleteParticipation)
            .openAPI(tags: openAPITag, summary: "Teilnahme zu einem Ride entfernen", path: .type(Ride.IDValue.self), statusCode: .noContent, auth: AuthMiddleware.schemeObject)
        adminRideRoutes.post("", use: newRide)
            .openAPI(tags: openAPITag, summary: "Neuen Ride erstellen", body: .type(CreateRideDTO.self), contentType: .application(.json), response: .type(GetRideOverviewDTO.self), responseContentType: .application(.json), statusCode: .created, auth: AdminMiddleware.schemeObject)
        adminRideRoutes.patch(":id", use: patchRide)
            .openAPI(tags: openAPITag, summary: "Ride anpassen", body: .type(PatchRideDTO.self), contentType: .application(.json), response: .type(GetRideOverviewDTO.self), responseContentType: .application(.json), statusCode: .ok, auth: AdminMiddleware.schemeObject)
        adminRideRoutes.delete(":id", use: deleteRide)
            .openAPI(tags: openAPITag, summary: "Ride löschen", statusCode: .noContent, auth: AdminMiddleware.schemeObject)
    }
    
    @Sendable
    func getAllRides(req: Request) async throws -> [GetRideOverviewDTO] {
        // query all ride and convert to GetRideOverviewDTO
        let rides = try await Ride.query(on: req.db).all().map{ ride in
            ride.toGetRideOverviewDTO()
        }
        
        return rides
    }
    
    @Sendable
    func getRide(req: Request) async throws -> GetRideDetailDTO {
        // get ride by id
        guard let ride = try await Ride.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }

        // extract ride id
        let ride_id = try ride.requireID()
        
        // query all data for reponse
        var seatsSum = 0
        var passengersSum = 0
        let participants = try await Participant.query(on: req.db)
            .filter(\.$ride.$id == ride_id)
            .join(User.self, on: \Participant.$user.$id == \User.$id)
            .join(Identity.self, on: \User.$identity.$id == \Identity.$id)
            .all()
            .map{ participant in
                if participant.driver {
                    seatsSum += participant.passengers_count!
                } else {
                    passengersSum += 1
                }
                let participantID = try participant.requireID()
                let userID = try participant.joined(User.self).requireID()
                let identity = try participant.joined(Identity.self)
                let itsMe = userID == req.jwtPayload.userID
                return GetParticipantDTO(id: participantID, name: identity.name, driver: participant.driver, passengers_count: participant.passengers_count, latitude: participant.latitude, longitude: participant.longitude, itsMe: itsMe)
            }
        
        // build response dto
        return GetRideDetailDTO(name: ride.name, starts: ride.starts, participants: participants, latitude: ride.latitude, longitude: ride.longitude, participantsSum: participants.count, seatsSum: seatsSum, passengersSum: passengersSum)

    }
    
    @Sendable
    func newRide(req: Request) async throws -> Response {
        
        // parse DTO
        guard let createRideDTO = try? req.content.decode(CreateRideDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected CreateRideDTO.")
        }
        
        // create new ride
        let ride = Ride(name: createRideDTO.name, description: createRideDTO.description, starts: createRideDTO.starts, latitude: createRideDTO.latitude, longitude: createRideDTO.longitude, organizerId: req.jwtPayload.userID)
        
        // save ride in database
        try await ride.save(on: req.db)
        
        return try await ride.toGetRideOverviewDTO().encodeResponse(status: .created, for: req)
    }
    
    @Sendable
    func patchRide(req: Request) async throws -> GetRideOverviewDTO {
        // query ride by id
        guard let ride = try await Ride.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // parse DTO
        guard let patchRideDTO = try? req.content.decode(PatchRideDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected PatchRideDTO.")
        }
        
        // patch ride
        ride.patchWithDTO(dto: patchRideDTO)
        
        // save changes
        try await ride.update(on: req.db)
        
        return ride.toGetRideOverviewDTO()
    }
    
    @Sendable
    func deleteRide(req: Request) async throws -> HTTPStatus {
        // query ride id
        guard let ride = try await Ride.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // extract ride id
        let ride_id = try ride.requireID()
        
        // delete all participants for ride
        try await Participant.query(on: req.db)
            .filter(\.$ride.$id == ride_id)
            .delete()
        
        // delete ride
        try await ride.delete(on: req.db)
        
        return .noContent
    }
    
    @Sendable
    func getParticipation(req: Request) async throws -> ParticipationDTO {
        // parse ride id as UUID
        guard let ride_id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing ride ID")
        }
        
        // get participant by userID and rideID
        guard let participat = try await Participant.query(on: req.db)
            .filter(\.$user.$id == req.jwtPayload.userID)
            .filter(\.$ride.$id == ride_id)
            .first()
        else {
            throw Abort(.notFound, reason: "No participation found!")
        }
        
        return participat.toParticipationDTO()
    }
    
    @Sendable
    func newParticipation(req: Request) async throws -> Response {
        // parse DTO
        guard let participationDTO = try? req.content.decode(ParticipationDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected ParticipationDTO.")
        }
        
        // validate DTO
        if !participationDTO.isValid() {
            throw Abort(.badRequest, reason: "ParticipationDTO is not valid!")
        }
        
        // parse ride id as UUID
        guard let ride_id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing ride ID")
        }
        
        // check if ride exists
        guard let _ = try await Ride.find(ride_id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        // check if already participating
        let count = try await Participant.query(on: req.db)
            .filter(\.$user.$id == req.jwtPayload.userID)
            .filter(\.$ride.$id == ride_id)
            .count()
        
        if count != 0 {
            throw Abort(.forbidden, reason: "User is already participating in this ride!")
        }
        
        // create participant
        let participant = Participant(rideId: ride_id, userId: req.jwtPayload.userID, driver: participationDTO.driver, passengers_count: participationDTO.passengers_count, latitude: participationDTO.latitude, longitude: participationDTO.longitude)
        
        // save participant
        try await participant.save(on: req.db)
        
        // query data for response
        let participantID = try participant.requireID()
        let username = try await User.query(on: req.db)
            .filter(\.$id == req.jwtPayload.userID)
            .with(\.$identity)
            .first()
            .map { user in
                user.identity.name
            }
        
        return try await GetParticipantDTO(id: participantID, name: username ?? "", driver: participant.driver, passengers_count: participant.passengers_count, latitude: participant.latitude, longitude: participant.longitude, itsMe: true).encodeResponse(status: .created, for: req)
    }
    
    @Sendable
    func patchParticipation(req: Request) async throws -> GetParticipantDTO {
        
        // parse DTO
        guard let patchParticipationDTO = try? req.content.decode(PatchParticipationDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected PatchParticipationDTO.")
        }
        
        // parse ride id as UUID
        guard let ride_id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing ride ID")
        }
        
        // get participant
        guard let participant = try await Participant.query(on: req.db)
            .filter(\.$user.$id == req.jwtPayload.userID)
            .filter(\.$ride.$id == ride_id)
            .first()
        else {
            throw Abort(.notFound, reason: "No participation found!")
        }
        // try to update Participant
        try participant.patchWithDTO(dto: patchParticipationDTO)
        
        // save changes
        try await participant.update(on: req.db)
        
        // query data for response
        let participantID = try participant.requireID()
        let username = try await User.query(on: req.db)
            .filter(\.$id == req.jwtPayload.userID)
            .with(\.$identity)
            .first()
            .map { user in
                user.identity.name
            }
        
        return GetParticipantDTO(id: participantID, name: username ?? "", driver: participant.driver, passengers_count: participant.passengers_count, latitude: participant.latitude, longitude: participant.longitude, itsMe: true)
    }
    
    @Sendable
    func deleteParticipation(req: Request) async throws -> HTTPStatus {
        // parse ride id as UUID
        guard let ride_id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing ride ID")
        }
        
        // delete participant
        try await Participant.query(on: req.db)
            .filter(\.$user.$id == req.jwtPayload.userID)
            .filter(\.$ride.$id == ride_id)
            .delete()
        
        return .noContent
    }
}
