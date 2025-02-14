import Fluent
import Vapor
import Models
import PollServiceDTOs
import SwiftOpenAPI

struct PollController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let openAPITag = TagObject(name: "Umfragen")
        let adminMiddleware = AdminMiddleware()
        
        routes.get(use: getAllPolls)
            .openAPI(tags: openAPITag, summary: "Alle Umfragen abfragen", response: .type([GetPollDTO].self), responseContentType: .application(.json), statusCode: .ok, auth: AuthMiddleware.schemeObject)
        
        routes.post(use: createPoll)
            .openAPI(tags: openAPITag, summary: "Umfrage erstellen", body: .type(CreatePollDTO.self), contentType: .application(.json), response: .type(GetPollDTO.self), responseContentType: .application(.json), statusCode: .created, auth: AuthMiddleware.schemeObject)
        
        routes.group(":id") { singlePollRoutes in
            singlePollRoutes.get(use: getSinglePoll)
                .openAPI(tags: openAPITag, summary: "Eine Umfrage abfragen", path: .type(Poll.IDValue.self), response: .type(GetPollDTO.self), responseContentType: .application(.json), statusCode: .ok, auth: AuthMiddleware.schemeObject)
            
            singlePollRoutes.get("results", use: getPollResults)
                .openAPI(tags: openAPITag, summary: "Aktuelle Ergebnisse einer Umfrage abfragen", path: .type(Poll.IDValue.self), response: .type(GetPollResultsDTO.self), responseContentType: .application(.json), statusCode: .ok, auth: AuthMiddleware.schemeObject)
            
            singlePollRoutes.patch(use: updatePoll)
                .openAPI(tags: openAPITag, summary: "Eine Umfrage updaten", description: "Umfragen können nicht geupdatet werden, da sie nach ihrer Erstellung live sind.", path: .type(Poll.IDValue.self), statusCode: .notImplemented, auth: AuthMiddleware.schemeObject)
            
            singlePollRoutes.group(adminMiddleware) { adminRoutes in
                
                adminRoutes.delete(use: deletePoll)
                    .openAPI(tags: openAPITag, summary: "Eine Umfrage löschen", description: "Umfragen könne nur durch einen Admin gelöscht werden. Löscht ebenfalls alle zugehörigen Optionen und Stimmen.", path: .type(Poll.IDValue.self), statusCode: .noContent, auth: AdminMiddleware.schemeObject)
            }
            singlePollRoutes.put("vote", ":index", use: voteOnPoll)
                .openAPI(tags: openAPITag, summary: "Für eine Option bei einer Umfrage abstimmen.", description: "Wenn die Umfrage mehrere Stimmen erlaubt, können diese in der Form `.../vote/1,3,4` abgegeben werden.", path: .all(of: .type(Poll.IDValue.self), .type(String.self)), response: .type(GetPollResultsDTO.self), responseContentType: .application(.json), statusCode: .ok, auth: AuthMiddleware.schemeObject)
        }
    }
    
    /// **GET** `/polls`
    @Sendable func getAllPolls(req: Request) async throws -> [GetPollDTO] {
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        return try await Poll.query(on: req.db)
            .with(\.$votingOptions) { option in
                option.with(\.$votes)
            }
            .all()
            .toGetPollDTOs(db: req.db, userId: userId)
    }
    
    /// **POST** `/polls`
    @Sendable func createPoll(req: Request) async throws -> Response { // -> GetPollDTO
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        guard let createPollDTO = try? req.content.decode(CreatePollDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected CreatePollDTO.")
        }
        try CreatePollDTO.validate(content: req)
        guard createPollDTO.closedAt > .now else {
            throw Abort(.badRequest, reason: "ClosedAt must be in the future.")
        }
        let poll = Poll(question: createPollDTO.question, description: createPollDTO.description ?? "", closedAt: createPollDTO.closedAt, anonymous: createPollDTO.anonymous, multiSelect: createPollDTO.multiSelect)
        try await req.db.transaction { db in
            try await poll.create(on: db)
            for option in createPollDTO.options {
                let votingOption = try PollVotingOption(id: .init(poll: poll, index: option.index ), text: option.text)
                try await votingOption.create(on: db)
            }
        }
        return try await poll.toGetPollDTO(db: req.db, userId: userId).encodeResponse(status: .created, for: req)
    }
    
    /// **GET** `/polls/{id}`
    @Sendable func getSinglePoll(req: Request) async throws -> GetPollDTO {
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        guard let poll = try await Poll.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await poll.toGetPollDTO(db: req.db, userId: userId)
    }
    
    /// **GET** `/polls/{id}/results`
    @Sendable func getPollResults(req: Request) async throws -> GetPollResultsDTO {
        guard let poll = try await Poll.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        return try await poll.toGetPollResultsDTO(db: req.db, userId: userId)
    }
    
    /// **PATCH** `/polls/{id}`
    @Sendable func updatePoll(req: Request) async throws -> Response {
        throw Abort(.notImplemented, reason: "Polls cannot be updated since they are live right after creation.")
    }
    
    /// **DELETE** `/polls/{id}`
    @Sendable func deletePoll(req: Request) async throws -> HTTPStatus {
        guard let poll = try await Poll.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await poll.delete(on: req.db) // Relies on cascading to delete corresponding options and votes
        
        return .noContent
    }
    
    /// **PUT** `/polls/{id}/vote/{index}`
    @Sendable func voteOnPoll(req: Request) async throws -> GetPollResultsDTO {
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        guard let poll = try await Poll.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await poll.$votingOptions.load(on: req.db)
        guard let indexParam = req.parameters.get("index"),
              let indices = try? indexParam.split(separator: ",").map({ indexString in
                  guard let index = UInt8(indexString) else {
                      throw Abort(.badRequest)
                  }
                  return index
              }),
              try indices.allSatisfy({ index in
                  try poll.votingOptions.contains(where: { votingOption in
                      try votingOption.requireID().index == index
                  })
              }) else {
            throw Abort(.notFound, reason: "Invalid index/indices '\(req.parameters.get("index") ?? "nil")'.")
        }
        guard poll.isOpen else {
            throw Abort(.badRequest, reason: "You can only vote on polls which are currently open.")
        }
        guard poll.multiSelect || indices.count == 1 else {
            throw Abort(.badRequest, reason: "You can only vote for one option on this poll.")
        }
        let identity = try await Identity.byUserId(userId, req.db)
        guard try await poll.getMyVotes(db: req.db, userId: userId).isEmpty else {
            throw Abort(.badRequest, reason: "You have already voted on this poll.")
        }
        
        try await req.db.transaction { db in
            for index in indices {
                let vote = try PollVote(id: .init(poll: poll, index: index, identity: identity))
                try await vote.create(on: db)
            }
        }
        // Fetches the poll anew to reload all relations.
        return try await Poll.find(req.parameters.get("id"), on: req.db)!.toGetPollResultsDTO(db: req.db, userId: userId)
    }
}
