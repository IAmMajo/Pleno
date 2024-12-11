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
    
    app.group("info") { route in
        route.get("briefkasten") { req async throws -> Response in
            guard let uuidString = req.headers.first(name: "id"), let uuid = UUID(uuidString: uuidString),
                  let victim = try await Victim.find(uuid, on: req.db) else {
                throw Abort(.unauthorized)
            }
            var fool = try Fool(victim: victim)
            try await fool.create(on: req.db)
            return req.fileio.streamFile(at: "Resources/aufklaerung-briefkasten.html")
        }
        route.get("labyrinth") { req async throws -> Response in
            guard let uuidString = req.headers.first(name: "id"), let uuid = UUID(uuidString: uuidString) else {
                throw Abort(.unauthorized)
            }
            var victim: Victim
            if let existingVictim = try await Victim.find(uuid, on: req.db) {
                victim = existingVictim
            } else {
                victim = Victim(id: uuid, experiment: .labyrinth)
                try await victim.create(on: req.db)
            }
            var fool = try Fool(victim: victim)
            try await fool.create(on: req.db)
            return req.fileio.streamFile(at: "Resources/aufklaerung-labyrinth.html")
        }
    }
    
    // Protected routes
    
    protected.group("victims") { route in
        route.get { req -> [GetVictimDTO] in
            try await Victim.query(on: req.db)
                .with(\.$fools)
                .all()
                .toGetVictimDTO()
        }
        
        route.get(":id") { req -> GetVictimDTO in
            guard let victim = try await Victim.find(req.parameters.get("id"), on: req.db) else {
                throw Abort(.notFound)
            }
            try await victim.$fools.load(on: req.db)
            return try victim.toGetVictimDTO()
        }
        
        route.post("briefkasten") { req in
            var victim = Victim(experiment: .briefkasten)
            try await victim.create(on: req.db)
            return try await victim.requireID().uuidString.encodeResponse(status: .created, for: req)
        }
    }
}
