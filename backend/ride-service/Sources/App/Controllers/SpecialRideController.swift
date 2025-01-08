import Fluent
import Vapor
import Models
//import VaporToOpenAPI
import RideServiceDTOs

/**
 TODO
 
 GET /specialrides/:id/requests
 POST /specialrides/:id/requests
 PATCH /specialrides/:id/requests
 DELETE /specialrides/:id/requests
 */

struct SpecialRideController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let specialRideRoutes = routes.grouped("specialrides")
        specialRideRoutes.get("", use: getAllSpecialRides)
        specialRideRoutes.get(":id", use: getSpecialRide)
        specialRideRoutes.post("", use: newSpecialRide)
        specialRideRoutes.patch(":id", use: patchSpecialRide)
        specialRideRoutes.delete(":id", use: deleteSpecialRide)
    }
    
    @Sendable
    func getAllSpecialRides(req: Request) async throws -> [GetSpecialRideDTO] {
        let specialRides = try await SpecialRide.query(on: req.db).all().map{ specialRide in
            GetSpecialRideDTO(
                id: specialRide.id,
                name: specialRide.name,
                starts: specialRide.starts,
                ends: specialRide.ends,
                emptySeats: specialRide.emptySeats,
                allocatedSeats: 0,
                isSelfDriver: specialRide.$user.id == req.jwtPayload.userID,
                isSelfAccepted: false)
        }
        
        return specialRides
    }
    
    @Sendable
    func getSpecialRide(req: Request) async throws -> GetSpecialRideDetailDTO {
        // get ride by id
        guard let specialRide = try await SpecialRide.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }

        // extract ride id
        let ride_id = try specialRide.requireID()
        
        let drivername = try await User.query(on: req.db)
            .filter(\.$id == specialRide.$user.id)
            .with(\.$identity)
            .first()
            .map { user in
                user.identity.name
            }
        let specialRideDetailDTO = GetSpecialRideDetailDTO(
            id: ride_id,
            driverName: drivername ?? "",
            isSelfDriver: specialRide.$user.id == req.jwtPayload.userID,
            name: specialRide.name,
            description: specialRide.description,
            vehicleDescription: specialRide.vehicleDescription,
            starts: specialRide.starts,
            ends: specialRide.ends,
            startLatitude: specialRide.startLatitude,
            startLongitude: specialRide.startLongitude,
            destinationLatitude: specialRide.destinationLatitude,
            destinationLongitude: specialRide.destinationLongitude,
            emptySeats: specialRide.emptySeats,
            riders: []
        )
        
        return specialRideDetailDTO
        
    }
    
    @Sendable
    func newSpecialRide(req: Request) async throws -> Response {
        //parse DTO
        guard let createSpecialRideDTO = try? req.content.decode(CreateSpecialRideDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected CreateSpecialRideDTO.")
        }
        
        // create new special ride
        let specialRide = SpecialRide(
            userID: req.jwtPayload.userID,
            name: createSpecialRideDTO.name,
            description: createSpecialRideDTO.description,
            vehicleDescription: createSpecialRideDTO.vehicleDescription,
            starts: createSpecialRideDTO.starts,
            ends: createSpecialRideDTO.ends,
            startLatitude: createSpecialRideDTO.startLatitude,
            startLongitude: createSpecialRideDTO.startLongitude,
            destinationLatitude: createSpecialRideDTO.destinationLatitude,
            destinationLongitude: createSpecialRideDTO.destinationLongitude,
            emptySeats: createSpecialRideDTO.emptySeats
        )
        
        // save specialride
        try await specialRide.save(on: req.db)
        
        // create response DTO
        let ride_id = try specialRide.requireID()
        let drivername = try await User.query(on: req.db)
            .filter(\.$id == req.jwtPayload.userID)
            .with(\.$identity)
            .first()
            .map { user in
                user.identity.name
            }
        let specialRideDetailDTO = GetSpecialRideDetailDTO(
            id: ride_id,
            driverName: drivername ?? "",
            isSelfDriver: true,
            name: specialRide.name,
            description: specialRide.description,
            vehicleDescription: specialRide.vehicleDescription,
            starts: specialRide.starts,
            ends: specialRide.ends,
            startLatitude: specialRide.startLatitude,
            startLongitude: specialRide.startLongitude,
            destinationLatitude: specialRide.destinationLatitude,
            destinationLongitude: specialRide.destinationLongitude,
            emptySeats: specialRide.emptySeats,
            riders: []
        )
        
        return try await specialRideDetailDTO.encodeResponse(status: .created, for: req)
    }
    
    @Sendable
    func patchSpecialRide(req: Request) async throws -> GetSpecialRideDetailDTO {
        // get ride by id
        guard let specialRide = try await SpecialRide.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // check if user is driver
        if specialRide.$user.id != req.jwtPayload.userID {
            throw Abort(.forbidden, reason: "you are not the driver")
        }
        
        //parse DTO
        guard let patchSpecialRideDTO = try? req.content.decode(PatchSpecialRideDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected PatchSpecialRideDTO.")
        }
        
        // patch specialRide
        specialRide.patchWithDTO(dto: patchSpecialRideDTO)
        
        // save changes
        try await specialRide.update(on: req.db)
        
        // create response DTO
        let ride_id = try specialRide.requireID()
        let drivername = try await User.query(on: req.db)
            .filter(\.$id == req.jwtPayload.userID)
            .with(\.$identity)
            .first()
            .map { user in
                user.identity.name
            }
        let specialRideDetailDTO = GetSpecialRideDetailDTO(
            id: ride_id,
            driverName: drivername ?? "",
            isSelfDriver: true,
            name: specialRide.name,
            description: specialRide.description,
            vehicleDescription: specialRide.vehicleDescription,
            starts: specialRide.starts,
            ends: specialRide.ends,
            startLatitude: specialRide.startLatitude,
            startLongitude: specialRide.startLongitude,
            destinationLatitude: specialRide.destinationLatitude,
            destinationLongitude: specialRide.destinationLongitude,
            emptySeats: specialRide.emptySeats,
            riders: []
        )
        
        return specialRideDetailDTO
    }
    
    @Sendable
    func deleteSpecialRide(req: Request) async throws -> HTTPStatus {
        // get ride by id
        guard let specialRide = try await SpecialRide.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // check if user is driver
        if specialRide.$user.id != req.jwtPayload.userID {
            throw Abort(.forbidden, reason: "you are not the driver")
        }
        
        // delete specialride
        try await specialRide.delete(on: req.db)
        
        return .noContent
    }
}
