import Fluent
import Vapor
import Models
import VaporToOpenAPI
import RideServiceDTOs


struct SpecialRideController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let openAPITag = TagObject(name: "Sonderfahrten")
        
        let specialRideRoutes = routes.grouped("specialrides")
        // GET /specialrides/
        specialRideRoutes.get("", use: getAllSpecialRides)
            .openAPI(
                tags: openAPITag,
                summary: "Übersicht der Sonderfahrten abfragen.",
                response: .type([GetSpecialRideDTO].self),
                responseContentType: .application(.json),
                statusCode: .ok,
                auth: AuthMiddleware.schemeObject
            )
        // GET /specialrides/:id
        specialRideRoutes.get(":id", use: getSpecialRide)
            .openAPI(
                tags: openAPITag,
                summary: "Details einer Sonderfahrten abfragen.",
                description: "Hinweis: Der Fahrer bekommt alle Details zu den Teilnehmern, alle anderen bekomme nur die bestätigten Teilnehmer.",
                path: .type(SpecialRide.IDValue.self),
                response: .type(GetSpecialRideDetailDTO.self),
                responseContentType: .application(.json),
                statusCode: .ok,
                auth: AuthMiddleware.schemeObject
            )
        // POST /specialrides/
        specialRideRoutes.post("", use: newSpecialRide)
            .openAPI(
                tags: openAPITag,
                summary: "Neue Sonderfahrten anbieten.",
                body: .type(CreateSpecialRideDTO.self),
                contentType: .application(.json),
                response: .type(GetSpecialRideDetailDTO.self),
                responseContentType: .application(.json),
                statusCode: .created,
                auth: AuthMiddleware.schemeObject
            )
        // PATCH /specialrides/:id
        specialRideRoutes.patch(":id", use: patchSpecialRide)
            .openAPI(
                tags: openAPITag,
                summary: "Eine Sonderfahrten anpassen.",
                description: "Hinweis: Die Fahrt kann nur der Fahrer anpassen.",
                path: .type(SpecialRide.IDValue.self),
                body: .type(PatchSpecialRideDTO.self),
                contentType: .application(.json),
                response: .type(GetSpecialRideDetailDTO.self),
                responseContentType: .application(.json),
                statusCode: .ok,
                auth: AuthMiddleware.schemeObject
            )
        // DELETE /specialrides/:id
        specialRideRoutes.delete(":id", use: deleteSpecialRide)
            .openAPI(
                tags: openAPITag,
                summary: "Eine Sonderfahrten löschen.",
                description: "Hinweis: Die Fahrt kann nur der Fahrer löschen.",
                path: .type(SpecialRide.IDValue.self),
                statusCode: .noContent,
                auth: AuthMiddleware.schemeObject
            )
        
        // POST /specialrides/:id/requests
        specialRideRoutes.post(":id", "requests", use: newRequestToSpecialRide)
            .openAPI(
                tags: openAPITag,
                summary: "Mitnahme bei einer Sonderfahrten anfragen.",
                path: .type(SpecialRide.IDValue.self),
                body: .type(CreateSpecialRideRequestDTO.self),
                contentType: .application(.json),
                response: .type(GetRiderDTO.self),
                responseContentType: .application(.json),
                statusCode: .created,
                auth: AuthMiddleware.schemeObject
            )
        // PATCH /specialrides/requests/:request_id
        specialRideRoutes.patch("requests", ":request_id", use: patchSpecialRideRequest)
            .openAPI(
                tags: openAPITag,
                summary: "Mitnahme bei einer Sonderfahrten bearbeiten.",
                description: "Hinweis: Der Fahrer kann über diese Route die Mitnahme bestätigen, der Mitfahrer kann nur die Location anpassen.",
                path: .type(SpecialRideRequest.IDValue.self),
                body: .type(PatchSpecialRideRequestDTO.self),
                contentType: .application(.json),
                response: .type(GetRiderDTO.self),
                responseContentType: .application(.json),
                statusCode: .ok,
                auth: AuthMiddleware.schemeObject
            )
        // DELETE /specialrides/requests/:request_id
        specialRideRoutes.delete("requests", ":request_id",use: deleteSpecialRideRequest)
            .openAPI(
                tags: openAPITag,
                summary: "Mitnahme bei einer Sonderfahrten löschen.",
                path: .type(SpecialRideRequest.IDValue.self),
                statusCode: .noContent,
                auth: AuthMiddleware.schemeObject
            )
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
                
                var openRequests: Int? = nil
                var usersState = UsersRideState.nothing
                
                if specialRide.$user.id == req.jwtPayload.userID {
                    usersState = UsersRideState.driver
                    openRequests = try await getCountOpenRequests(rideID: ride_id, db: req.db)
                } else {
                    let request = try await SpecialRideRequest.query(on: req.db)
                        .filter(\.$ride.$id == ride_id)
                        .filter(\.$user.$id == req.jwtPayload.userID)
                        .first()
                    
                    if let request = request {
                        if request.accepted {
                            usersState = UsersRideState.accepted
                        } else {
                            usersState = UsersRideState.requested
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
                    myState: usersState,
                    openRequests: openRequests
                    )
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
        var riders = try await SpecialRideRequest.query(on: req.db)
            .filter(\.$ride.$id == ride_id)
            .join(User.self, on: \SpecialRideRequest.$user.$id == \User.$id)
            .join(Identity.self, on: \User.$identity.$id == \Identity.$id)
            .all()
            .map{ rider in
                let rider_id = try rider.requireID()
                let identity = try rider.joined(Identity.self)
                let user = try rider.joined(User.self)
                let userID = try user.requireID()

                return GetRiderDTO(
                    id: rider_id,
                    userID: userID,
                    username: identity.name,
                    latitude: rider.latitude,
                    longitude: rider.longitude,
                    itsMe: rider.$user.id == req.jwtPayload.userID,
                    accepted: rider.accepted
                )
            }
        
        // delete all open requests, if user is not the driver
        if specialRide.$user.id != req.jwtPayload.userID {
            riders.removeAll{ $0.accepted == false && $0.itsMe == false }
        }
        
        guard let driver = try await User.query(on: req.db)
            .filter(\.$id == specialRide.$user.id)
            .with(\.$identity)
            .first() else {
            throw Abort(.notFound)
        }
        let driverID = try driver.requireID()
        let specialRideDetailDTO = GetSpecialRideDetailDTO(
            id: ride_id,
            driverName: driver.identity.name,
            driverID: driverID,
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
        guard let driver = try await User.query(on: req.db)
            .filter(\.$id == specialRide.$user.id)
            .with(\.$identity)
            .first() else {
            throw Abort(.notFound)
        }
        let driverID = try driver.requireID()
        let specialRideDetailDTO = GetSpecialRideDetailDTO(
            id: ride_id,
            driverName: driver.identity.name,
            driverID: driverID,
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
        let riders = try await SpecialRideRequest.query(on: req.db)
            .filter(\.$ride.$id == ride_id)
            .join(User.self, on: \SpecialRideRequest.$user.$id == \User.$id)
            .join(Identity.self, on: \User.$identity.$id == \Identity.$id)
            .all()
            .map{ rider in
                let rider_id = try rider.requireID()
                let identity = try rider.joined(Identity.self)
                let user = try rider.joined(User.self)
                let userID = try user.requireID()
                
                return GetRiderDTO(
                    id: rider_id,
                    userID: userID,
                    username: identity.name,
                    latitude: rider.latitude,
                    longitude: rider.longitude,
                    itsMe: rider.$user.id == req.jwtPayload.userID,
                    accepted: rider.accepted
                )
            }
        
        guard let driver = try await User.query(on: req.db)
            .filter(\.$id == specialRide.$user.id)
            .with(\.$identity)
            .first() else {
            throw Abort(.notFound)
        }
        let driverID = try driver.requireID()
        let specialRideDetailDTO = GetSpecialRideDetailDTO(
            id: ride_id,
            driverName: driver.identity.name,
            driverID: driverID,
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
            riders: riders
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
        
        // check if ride is full
        let countAccepted = try await SpecialRideRequest.query(on: req.db)
            .filter(\.$ride.$id == ride_id)
            .filter(\.$accepted == true)
            .count()
        if countAccepted >= specialRide.emptySeats {
            throw Abort(.badRequest, reason: "This ride is full!")
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
            userID: req.jwtPayload.userID,
            username: username ?? "",
            latitude: request.latitude,
            longitude: request.longitude,
            itsMe: true,
            accepted: request.accepted)
        
        return try await getRiderDTO.encodeResponse(status: .created, for: req)
    }
    
    @Sendable
    func patchSpecialRideRequest(req: Request) async throws -> GetRiderDTO {
        
        // get request by id
        guard let specialRideRequest = try await SpecialRideRequest.find(req.parameters.get("request_id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // get ride by id
        let ride_id = specialRideRequest.$ride.id
        guard let specialRide = try await SpecialRide.find(ride_id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        //parse DTO
        guard let patchSpecialRideRequestDTO = try? req.content.decode(PatchSpecialRideRequestDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected PatchSpecialRideRequestDTO.")
        }
        
        // save isNewRider state
        var isFullWithNewRider = false
        
        // check if user is allowed to patch
        if specialRide.$user.id == req.jwtPayload.userID {
            
            // if driver wants to accept a new rider
            if patchSpecialRideRequestDTO.accepted == true && specialRideRequest.accepted == false {
                // check if ride is full
                let countAccepted = try await SpecialRideRequest.query(on: req.db)
                    .filter(\.$ride.$id == ride_id)
                    .filter(\.$accepted == true)
                    .count()
                if countAccepted >= specialRide.emptySeats {
                    throw Abort(.badRequest, reason: "This ride is full!")
                }
                
                // check if ride is full with a new rider
                if countAccepted + 1 >= specialRide.emptySeats {
                    isFullWithNewRider = true
                }
            }
            // patch rider
            specialRideRequest.patchWithDTO(dto: patchSpecialRideRequestDTO, isDriver: true)
            
        } else if specialRideRequest.$user.id == req.jwtPayload.userID {
            specialRideRequest.patchWithDTO(dto: patchSpecialRideRequestDTO, isDriver: false)
        } else {
            throw Abort(.forbidden, reason: "You are not allowed to change the request!")
        }
        
        // if isFullWithNewRider save changes in a transaction
        if isFullWithNewRider == true {
            try await req.db.transaction{ db in
                // save changes in request
                try await specialRideRequest.update(on: db)
                
                // delete all open requests, if ride is full
                try await SpecialRideRequest.query(on: db)
                    .filter(\.$ride.$id == ride_id)
                    .filter(\.$accepted == false)
                    .delete()
            }
        } else {
            // save changes in request
            try await specialRideRequest.update(on: req.db)
        }
        
        // query data for reponse
        let rider_id = try specialRideRequest.requireID()
        
        let username = try await User.query(on: req.db)
            .filter(\.$id == specialRideRequest.$user.id)
            .with(\.$identity)
            .first()
            .map { user in
                user.identity.name
            }
        
        // build response dto
        let getRiderDTO = GetRiderDTO(
            id: rider_id,
            userID: specialRideRequest.$user.id,
            username: username ?? "",
            latitude: specialRideRequest.latitude,
            longitude: specialRideRequest.longitude,
            itsMe: specialRideRequest.$user.id == req.jwtPayload.userID,
            accepted: specialRideRequest.accepted)
        
        return getRiderDTO
        
    }
    
    @Sendable
    func deleteSpecialRideRequest(req: Request) async throws -> HTTPStatus {
        // get request by id
        guard let specialRideRequest = try await SpecialRideRequest.find(req.parameters.get("request_id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // check if user is allowed to delete
        if specialRideRequest.$user.id != req.jwtPayload.userID {
            throw Abort(.forbidden, reason: "You are not allowed to delete this request!")
        }
        
        // delete request
        try await specialRideRequest.delete(on: req.db)
        
        return .noContent
    }
    
    /*
     *
     *   Helper
     *
     */
    
    func getCountOpenRequests(rideID: UUID, db: Database) async throws -> Int {
        return try await SpecialRideRequest.query(on: db)
            .filter(\.$ride.$id == rideID)
            .filter(\.$accepted == false)
            .count()
    }
    
}
