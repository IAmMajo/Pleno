import Fluent
import Vapor
import Models
import JWT

struct RideController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {

        let rideRoutes = routes.grouped("rides")
        let adminRideRoutes = rideRoutes.grouped(AdminMiddleware())
        rideRoutes.get("", use: getAllRides)
        rideRoutes.get(":id", use: getRide)
        rideRoutes.get(":id", "participation", use: getParticipation)
        rideRoutes.post(":id", "participation", use: newParticipation)
        rideRoutes.patch(":id", "participation", use: patchParticipation)
        rideRoutes.delete(":id", "participation", use: deleteParticipation)
        adminRideRoutes.post("", use: newRide)
        
    }
    
    @Sendable
    func getAllRides(req: Request) async throws -> [GetRideOverviewDTO] {
        let rides = try await Ride.query(on: req.db).all().map{ ride in
            try ride.toGetRideOverviewDTO()
        }
        
        return rides
    }
    
    @Sendable
    func getRide(req: Request) async throws -> GetRideDetailDTO {
        guard let ride = try await Ride.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }

        let ride_id = try ride.requireID()
        
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
        
        return GetRideDetailDTO(name: ride.name, starts: ride.starts, participants: participants, latitude: ride.latitude, longitude: ride.longitude, participantsSum: participants.count, seatsSum: seatsSum, passengersSum: passengersSum)

    }
    
    @Sendable
    func newRide(req: Request) async throws -> HTTPStatus {
        
        // parse DTO
        guard let createRideDTO = try? req.content.decode(CreateRideDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected CreateRideDTO.")
        }
        
        // create new ride
        let ride = Ride(name: createRideDTO.name, description: createRideDTO.description, starts: createRideDTO.starts, latitude: createRideDTO.latitude, longitude: createRideDTO.longitude, organizerId: req.jwtPayload.userID)
        
        // save ride in database
        try await ride.save(on: req.db)
        
        return .ok
    }
    
    @Sendable
    func getParticipation(req: Request) async throws -> ParticipationDTO {
        // parse ride id as UUID
        guard let ride_id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing ride ID")
        }
        
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
    func newParticipation(req: Request) async throws -> HTTPStatus {
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
        
        return .ok
    }
    
    @Sendable
    func patchParticipation(req: Request) async throws -> HTTPStatus {
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
        
        return .ok
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
        
        return .ok
    }
}
