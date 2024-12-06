import Fluent
import Vapor
import Models
import JWT

struct RideController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // auth middleware
        let jwtSigner = JWTSigner.hs256(key: "Ganzgeheimespasswort")
        let authMiddleware = AuthMiddleware(jwtSigner: jwtSigner, payloadType: JWTPayloadDTO.self)
        
        // admin middleware
//        let adminMiddleware = AdminMiddleware()
        
        let rideRoutes = routes.grouped("rides")
        let protectedRoutes = rideRoutes.grouped(authMiddleware)
        rideRoutes.get("", use: getAllRides)
        protectedRoutes.post("", use: newRide)
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
        
        // make sure that user id is present
        guard let userID = req.jwtPayload?.userID else {
            throw Abort(.badRequest, reason: "No user id found!")
        }
        
        // create new ride
        let ride = Ride(name: createRideDTO.name, description: createRideDTO.description, starts: createRideDTO.starts, latitude: createRideDTO.latitude, longitude: createRideDTO.longitude, organizerId: userID)
        
        // save ride in database
        try await ride.save(on: req.db)
        
        return .ok
    }
    
}
