import Fluent
import Vapor

func routes(_ app: Application) throws {
    let protected = app.grouped(UserAuthenticator())
        .grouped(User.guardMiddleware())
    
    // Presentation routes
    
    app.get { req in
        req.redirect(to: "/homepage/de")
    }
    
    app.get("**") { req in
        req.redirect(to: "/homepage/de")
    }
    
    app.group("homepage") { route in
        route.get("de") { req async -> Response in
            req.fileio.streamFile(at: "Resources/homepage-de.html")
        }
        route.get("en") { req async -> Response in
            req.fileio.streamFile(at: "Resources/homepage-en.html")
        }
    }
    
    // Victim routes
    
    app.group("aufklaerung") { route in
        route.get("briefkasten") { req async -> Response in
            req.fileio.streamFile(at: "Resources/aufklaerung-briefkasten.html")
        }
        route.get("mensa") { req async -> Response in
            req.fileio.streamFile(at: "Resources/aufklaerung-mensa.html")
        }
        route.get("weihnachtsmarkt") { req async -> Response in
            req.fileio.streamFile(at: "Resources/aufklaerung-weihnachtsmarkt.html")
        }
    }
    
    app.group("info", ":id") { route in
        route.get { req -> HTTPStatus in
            try await increaseVictimCount(req)
            return .ok
        }
        route.get("briefkasten") { req async throws -> Response in
            try await increaseVictimCount(req)
            return req.fileio.streamFile(at: "Resources/aufklaerung-briefkasten.html")
        }
        route.get("mensa") { req async throws -> Response in
            try await increaseVictimCount(req)
            return req.fileio.streamFile(at: "Resources/aufklaerung-mensa.html")
        }
        route.get("weihnachtsmarkt") { req async throws -> Response in
            try await increaseVictimCount(req)
            return req.fileio.streamFile(at: "Resources/aufklaerung-weihnachtsmarkt.html")
        }
    }
    
    // Protected routes
    
    protected.group("create", "victim") { route in
        route.post("briefkasten") { req in
            let victim = Victim(experiment: .briefkasten)
            try await victim.create(on: req.db)
            return try await victim.requireID().uuidString.encodeResponse(status: .created, for: req)
        }
        route.post("mensa") { req in
            let victim = Victim(experiment: .mensa)
            try await victim.create(on: req.db)
            return try await victim.requireID().uuidString.encodeResponse(status: .created, for: req)
        }
        route.post("weihnachtsmarkt") { req in
            let victim = Victim(experiment: .weihnachtsmarkt)
            try await victim.create(on: req.db)
            return try await victim.requireID().uuidString.encodeResponse(status: .created, for: req)
        }
        route.post("test") { req in
            UUID().uuidString.encodeResponse(status: .ok, for: req)
        }
    }
    
    protected.put("mark-unused", ":id") { req -> HTTPStatus in
        guard let uuidString = req.parameters.get("id"), let id = UUID(uuidString: uuidString), let victim = try await Victim.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Invalid UUID.")
        }
        guard victim.count == 0 else {
            throw Abort(.badRequest, reason: "Victim ('\(uuidString)') cannot be marked unused: Count is not 0 (it's \(victim.count).")
        }
        guard !victim.unused else {
            throw Abort(.badRequest, reason: "Victim ('\(uuidString)') cannot be marked unused: It's already marked unused.")
        }
        
        victim.unused = true
        try await victim.update(on: req.db)
        return .ok
    }
    
    @Sendable func increaseVictimCount(_ req: Request) async throws {
        guard let uuidString = req.parameters.get("id"), let id = UUID(uuidString: uuidString), let victim = try await Victim.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Invalid UUID.")
        }
        
        victim.count += 1
        try await victim.update(on: req.db)
    }
}
