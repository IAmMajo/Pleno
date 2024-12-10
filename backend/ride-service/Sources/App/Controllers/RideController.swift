import Fluent
import Vapor
import Models
import JWT

struct RideController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {

        let rideRoutes = routes.grouped("rides")
        let adminRideRoutes = rideRoutes.grouped(AdminMiddleware())
        rideRoutes.get("", use: getAllRides)
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
        guard let participateDTO = try? req.content.decode(ParticipationDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected ParticipateDTO.")
        }
        
        // validate DTO
        if !participateDTO.isValid() {
            throw Abort(.badRequest, reason: "ParticipateDTO is not valid!")
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
        let participant = Participant(rideId: ride_id, userId: req.jwtPayload.userID, driver: participateDTO.driver, passengers_count: participateDTO.passengers_count, latitude: participateDTO.latitude, longitude: participateDTO.longitude)
        
        // save participant
        try await participant.save(on: req.db)
        
        return .ok
    }
    
    @Sendable
    func patchParticipation(req: Request) async throws -> HTTPStatus {
        // parse DTO
        guard let patchParticipateDTO = try? req.content.decode(PatchParticipationDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected PatchParticipateDTO.")
        }
        
        // parse ride id as UUID
        guard let ride_id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing ride ID")
        }
        
        // get participant
        guard let participat = try await Participant.query(on: req.db)
            .filter(\.$user.$id == req.jwtPayload.userID)
            .filter(\.$ride.$id == ride_id)
            .first()
        else {
            throw Abort(.notFound, reason: "No participation found!")
        }
        
        // try to update Participant
        try participat.patchWithDTO(dto: patchParticipateDTO)
        
        // save changes
        try await participat.update(on: req.db)
        
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
