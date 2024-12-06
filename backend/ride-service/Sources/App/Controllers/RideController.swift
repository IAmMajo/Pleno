import Fluent
import Vapor
import Models

struct RideController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let rideRoutes = routes.grouped("rides")
        rideRoutes.get("", use: getAllRides)
    }
    
    @Sendable
    func getAllRides(req: Request) async throws -> HTTPStatus {
        return .ok
    }
    
}
