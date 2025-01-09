import Fluent
import Vapor
import Models
//import VaporToOpenAPI
import RideServiceDTOs

/**
 TODO
 
 GET /specialrides/:id/requests ?? notwendig?
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
        
        specialRideRoutes.post(":id", "request", use: newRequestToSpecialRide)
    }
    
    @Sendable
    func getAllSpecialRides(req: Request) async throws -> [GetSpecialRideDTO] {
        let specialRides = try await SpecialRide.query(on: req.db).all()
        
        var responseRides: [GetSpecialRideDTO] = []
        
        for specialRide in specialRides {
            if let ride_id = specialRide.id {
                let allocatedSeats = try await SpecialRideRequest.query(on: req.db)
                    .filter(\.$ride.$id == ride_id)
                    .filter(\.$accepted == true)
                    .count()
                
                var usersState = usersSpecialRideState.nothing
                if specialRide.$user.id == req.jwtPayload.userID {
                    usersState = usersSpecialRideState.driver
                } else {
                    let request = try await SpecialRideRequest.query(on: req.db)
                        .filter(\.$ride.$id == ride_id)
                        .filter(\.$user.$id == req.jwtPayload.userID)
                        .first()
                    
                    if let request = request {
                        if request.accepted {
                            usersState = usersSpecialRideState.accepted
                        } else {
                            usersState = usersSpecialRideState.requested
                        }
                    }
                }
                
                responseRides.append(
                    GetSpecialRideDTO(
                    id: specialRide.id,
                    name: specialRide.name,
                    starts: specialRide.starts,
                    ends: specialRide.ends,
                    emptySeats: specialRide.emptySeats,
                    allocatedSeats: UInt8(allocatedSeats),
                    myState: usersState)
                )
            }
        }
        
        return responseRides
    }
    
    @Sendable
    func getSpecialRide(req: Request) async throws -> GetSpecialRideDetailDTO {
        // get ride by id
        guard let specialRide = try await SpecialRide.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }

        // extract ride id
        let ride_id = try specialRide.requireID()
        
        // get riders
        let riders = try await SpecialRideRequest.query(on: req.db)
            .filter(\.$ride.$id == ride_id)
            .join(User.self, on: \SpecialRideRequest.$user.$id == \User.$id)
            .join(Identity.self, on: \User.$identity.$id == \Identity.$id)
            .all()
            .map{ rider in
                let rider_id = try rider.requireID()
                let identity = try rider.joined(Identity.self)
                let username = identity.name
                
                return GetRiderDTO(
                    id: rider_id,
                    username: username,
                    latitude: rider.latitude,
                    longitude: rider.longitude,
                    istMe: rider.$user.id == req.jwtPayload.userID,
                    accepted: rider.accepted
                )
            }
        
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
            riders: riders
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
        
        // extract ride id
        let ride_id = try specialRide.requireID()
        
        // delete all requests to this ride
        try await SpecialRideRequest.query(on: req.db)
            .filter(\.$ride.$id == ride_id)
            .delete()
        
        // delete specialride
        try await specialRide.delete(on: req.db)
        
        return .noContent
    }
    
    @Sendable
    func newRequestToSpecialRide(req: Request) async throws -> Response {
        // get ride by id
        guard let specialRide = try await SpecialRide.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // parse DTO
        guard let createSpecialRideRequestDTO = try? req.content.decode(CreateSpecialRideRequestDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected CreateSpecialRideRequestDTO.")
        }
        
        // extract ride id
        let ride_id = try specialRide.requireID()
        
        // check if already requested
        let count = try await SpecialRideRequest.query(on: req.db)
            .filter(\.$user.$id == req.jwtPayload.userID)
            .filter(\.$ride.$id == ride_id)
            .count()
        
        if count != 0 {
            throw Abort(.badRequest, reason: "You already requested this ride!")
        }
        
        // check if user is driver from this ride
        if specialRide.$user.id == req.jwtPayload.userID {
            throw Abort(.badRequest, reason: "You cannot request your own ride!")
        }
        
        // create request
        let request = SpecialRideRequest(
            userID: req.jwtPayload.userID,
            rideID: ride_id,
            accepted: false,
            latitude: createSpecialRideRequestDTO.latitude,
            longitude: createSpecialRideRequestDTO.longitude
        )
        
        // save request
        try await request.save(on: req.db)
        
        // query data for reponse
        let rider_id = try request.requireID()
        let username = try await User.query(on: req.db)
            .filter(\.$id == req.jwtPayload.userID)
            .with(\.$identity)
            .first()
            .map { user in
                user.identity.name
            }
        
        // build response dto
        let getRiderDTO = GetRiderDTO(
            id: rider_id,
            username: username ?? "",
            latitude: request.latitude,
            longitude: request.longitude,
            istMe: true,
            accepted: request.accepted)
        
        return try await getRiderDTO.encodeResponse(status: .created, for: req)
    }
}
