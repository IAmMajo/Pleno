import Fluent
import Vapor
import Models
import VaporToOpenAPI
import RideServiceDTOs


struct EventController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let eventRoutes = routes.grouped("events")
        let adminEventRoutes = eventRoutes.grouped(AdminMiddleware())
        
        eventRoutes.get("", use: getAllPlenoEvents)
        eventRoutes.get(":id", use: getPlenoEvent)
        adminEventRoutes.post("", use: newPlenoEvent)
        adminEventRoutes.patch(":id", use: patchPlenoEvent)
        adminEventRoutes.delete(":id", use: deletePlenoEvent)
    }
    
    @Sendable
    func getAllPlenoEvents(req: Request) async throws -> [GetEventDTO] {
        // query all events and convert to GetEventDTO
        let plenoEvents = try await PlenoEvent.query(on: req.db).all().map{ plenoEvent in
            let event_id = try plenoEvent.requireID()
            return GetEventDTO(
                id: event_id,
                name: plenoEvent.name,
                starts: plenoEvent.starts,
                ends: plenoEvent.ends
            )
        }
        return plenoEvents
    }
    
    @Sendable
    func getPlenoEvent(req: Request) async throws -> GetEventDetailDTO {
        // query event by id
        guard let plenoEvent = try await PlenoEvent.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // convert event to GetEventDetailDTO
        let event_id = try plenoEvent.requireID()
        let getEventDetailDTO = GetEventDetailDTO(
            id: event_id,
            name: plenoEvent.name,
            description: plenoEvent.description,
            starts: plenoEvent.starts,
            ends: plenoEvent.ends,
            latitude: plenoEvent.latitude,
            longitude: plenoEvent.longitude
        )
        
        return getEventDetailDTO
    }
    
    @Sendable
    func newPlenoEvent(req: Request) async throws -> Response {
        //parse DTO
        guard let createEventDTO = try? req.content.decode(CreateEventDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected CreateEventDTO.")
        }
        
        // create new event
        let plenoEvent = PlenoEvent(
            name: createEventDTO.name,
            description: createEventDTO.description,
            starts: createEventDTO.starts,
            ends: createEventDTO.ends,
            latitude: createEventDTO.latitude,
            longitude: createEventDTO.latitude
        )
        
        // save new event
        try await plenoEvent.save(on: req.db)
        
        // create reponse DTO
        let event_id = try plenoEvent.requireID()
        let getEventDetailDTO = GetEventDetailDTO(
            id: event_id,
            name: plenoEvent.name,
            description: plenoEvent.description,
            starts: plenoEvent.starts,
            ends: plenoEvent.ends,
            latitude: plenoEvent.latitude,
            longitude: plenoEvent.longitude
        )
        
        return try await getEventDetailDTO.encodeResponse(status: .created, for: req)
    }
    
    @Sendable
    func patchPlenoEvent(req: Request) async throws -> GetEventDetailDTO {
        // query event by id
        guard let plenoEvent = try await PlenoEvent.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // parse DTO
        guard let patchEventDTO = try? req.content.decode(PatchEventDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected PatchEventDTO.")
        }
        
        // patch event
        plenoEvent.patchWithDTO(dto: patchEventDTO)
        
        // save changes
        try await plenoEvent.save(on: req.db)
        
        // create reponse DTO
        let event_id = try plenoEvent.requireID()
        let getEventDetailDTO = GetEventDetailDTO(
            id: event_id,
            name: plenoEvent.name,
            description: plenoEvent.description,
            starts: plenoEvent.starts,
            ends: plenoEvent.ends,
            latitude: plenoEvent.latitude,
            longitude: plenoEvent.longitude
        )
        
        return getEventDetailDTO
    }
    
    @Sendable
    func deletePlenoEvent(req: Request) async throws -> HTTPStatus {
        // query event by id
        guard let plenoEvent = try await PlenoEvent.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        // delete event
        try await plenoEvent.delete(on: req.db)
        
        return .noContent
    }
}
