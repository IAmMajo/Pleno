import Fluent
import Vapor
import Models
import JWT

struct RideController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {

        let rideRoutes = routes.grouped("rides")
        let adminRideRoutes = rideRoutes.grouped(AdminMiddleware())
        rideRoutes.get("", use: getAllRides)
        adminRideRoutes.post("", use: newRide)
        
    }
    
    @Sendable
    func getAllRides(req: Request) async throws -> HTTPStatus {
        return .ok
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
    
}
