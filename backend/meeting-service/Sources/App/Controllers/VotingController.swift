import Fluent
import Vapor
import Models
import MeetingServiceDTOs

struct VotingController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let adminMiddleware = AdminMiddleware()
        
        routes.get(":id", "votings", use: getVotingsOfMeeting)
        routes.group("votings") { votingRoutes in
            votingRoutes.get(use: getAllVotings)
            votingRoutes.grouped(adminMiddleware).post(use: createVoting)
            votingRoutes.group(":id") { singleVotingRoutes in
                singleVotingRoutes.get(use: getSingleVoting)
                singleVotingRoutes.get(use: getVotingResults)
                singleVotingRoutes.group(adminMiddleware) { adminRoutes in
                    adminRoutes.patch(use: updateVoting)
                    adminRoutes.delete(use: deleteVoting)
                    adminRoutes.put("open", use: openVoting)
                    adminRoutes.put("close", use: closeVoting)
                }
                singleVotingRoutes.put("vote", ":index", use: voteOnVoting)
            }
        }
    }
    
    @Sendable func getVotingsOfMeeting(req: Request) async throws -> [GetVotingDTO] {
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        return try await Voting.query(on: req.db)
            .with(\.$votingOptions)
            .filter(\.$meeting.$id == meeting.requireID())
            .all()
            .map { voting in
                try voting.toGetVotingDTO()
            }
    }
    
    @Sendable func getAllVotings(req: Request) async throws -> [GetVotingDTO] {
        return try await Voting.query(on: req.db)
            .with(\.$votingOptions)
            .all()
            .map { voting in
                try voting.toGetVotingDTO()
            }
    }
    
    @Sendable func createVoting(req: Request) async throws -> GetVotingDTO {
        guard let createVotingDTO = try? req.content.decode(CreateVotingDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected CreateVotingDTO.")
        }
        try CreateVotingDTO.validate(content: req)
        guard let meeting = try await Meeting.find(createVotingDTO.meetingId, on: req.db) else {
            throw Abort(.notFound)
        }
        guard meeting.status != .completed else {
            throw Abort(.badRequest, reason: "Meeting is already completed.")
        }
        let voting = try Voting(meetingId: meeting.requireID(), description: createVotingDTO.description ?? "", question: createVotingDTO.question, isOpen: false, anonymous: createVotingDTO.anonymous)
        try await req.db.transaction { db in
            try await voting.create(on: db)
            for option in createVotingDTO.options {
                let votingOption = try VotingOption(id: .init(voting: voting, index: option.index ), text: option.text)
                try await votingOption.create(on: db)
            }
            try await voting.$votingOptions.load(on: db)
        }
        return try voting.toGetVotingDTO()
    }
    
    @Sendable func getSingleVoting(req: Request) async throws -> GetVotingDTO {
        guard let voting = try await Voting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await voting.$votingOptions.load(on: req.db)
        return try voting.toGetVotingDTO()
    }
    
    @Sendable func getVotingResults(req: Request) async throws -> GetVotingResultsDTO {
        guard let voting = try await Voting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        let identityIds = try await IdentityHistory.byUserId(userId, req.db).map { identityHistory in
            try identityHistory.identity.requireID()
        }
        guard !voting.isOpen && voting.startedAt != nil && voting.closedAt != nil else {
            throw Abort(.locked, reason: "The voting has not closed yet")
        }
        
        let votingOptions = try await voting.$votingOptions.get(on: req.db)
        var getVotingResultsDTO = try GetVotingResultsDTO(votingId: voting.requireID(), myVote: nil, results: [])
        
        if let myVote = try await Vote.query(on: req.db)
            .filter(\.$id.$voting.$id == voting.requireID())
            .with(\.$id.$identity)
            .filter(\.$id.$identity.$id ~~ identityIds)
            .first() {
            getVotingResultsDTO.myVote = myVote.index
        }
        
        var totalVotes: [[Vote]] = []
        
        for i in 0...votingOptions.count {
            try await totalVotes.append(Vote.query(on: req.db)
                .filter(\.$id.$voting.$id == voting.requireID())
                .filter(\.$index == UInt8(i))
                .all())
        }
        var totalVoteAmounts: [Int] = totalVotes.map { votes in
            votes.count
        }
        let totalVotesCount = totalVoteAmounts.reduce(0) { partialResult, votes in
            partialResult + votes
        }
        var percentageCutoffs: [percentageCutoff] = totalVoteAmounts.enumerated().map { index, votes in
            let percentage = (Double(votes) / Double(totalVotesCount))
            let roundedDownPercentage = (percentage * 100.0).rounded(.down) / 100.0
            return .init(index: UInt8(index), percentage: roundedDownPercentage, cutoff: percentage - roundedDownPercentage)
        }
        
        percentageCutoffs.sort { percentageCutoff1, percentageCutoff2 in
            percentageCutoff1.cutoff > percentageCutoff2.cutoff
        }
        let totalPercentage = percentageCutoffs.reduce(0) { partialResult, percentageCutoff in
            partialResult + percentageCutoff.percentage
        }
        
        for i in 0..<(Int(100.0 - totalPercentage)*100) {
            percentageCutoffs[i].percentage += 0.01
        }
        percentageCutoffs.sort { percentageCutoff1, percentageCutoff2 in
            percentageCutoff1.index < percentageCutoff2.index
        }
        
        for option in votingOptions {
            let index = Int(try option.requireID().index)
            let percentageCutoff = percentageCutoffs[index]
            try getVotingResultsDTO.results.append(
                GetVotingResultDTO(index: option.requireID().index,
                                   total: UInt8(totalVotesCount),
                                   percentage: percentageCutoff.percentage,
                                   identities: voting.anonymous ? nil : totalVotes[index].map({ vote in
                                       try vote.requireID().identity.toGetIdentityDTO()
                                   })))
        }
        
        return getVotingResultsDTO
    }
    
    @Sendable func updateVoting(req: Request) async throws -> GetVotingDTO {
        guard let voting = try await Voting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let patchVotingDTO = try? req.content.decode(PatchVotingDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected PatchVotingDTO.")
        }
        try PatchVotingDTO.validate(content: req)
        guard !voting.isOpen && voting.startedAt == nil && voting.closedAt == nil else {
            throw Abort(.badRequest, reason: "Only votings which have not started yet can be updated.")
        }
        if let question = patchVotingDTO.question {
            voting.question = question
        }
        if let description = patchVotingDTO.description {
            voting.description = description
        }
        if let anonymous = patchVotingDTO.anonymous {
            voting.anonymous = anonymous
        }
        try await req.db.transaction { db in
            if let options = patchVotingDTO.options {
                try await voting.votingOptions.delete(on: db)
                try await voting.$votingOptions.create(options.map({ getVotingOptionDTO in
                    try .init(id: .init(voting: voting, index: getVotingOptionDTO.index), text: getVotingOptionDTO.text)
                }), on: db)
            }
            
            // Check if changes were made
            guard voting.hasChanges else {
                throw Abort(.conflict, reason: "No changes were made.")
            }
            
            try await voting.update(on: db)
            try await voting.$votingOptions.load(on: db)
        }
        return try voting.toGetVotingDTO()
    }
    
    @Sendable func deleteVoting(req: Request) async throws -> HTTPStatus {
        guard let voting = try await Voting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard !voting.isOpen && voting.startedAt == nil && voting.closedAt == nil else {
            throw Abort(.badRequest, reason: "Only votings which have not started yet can be deleted.")
        }
        
        try await req.db.transaction { db in
            try await voting.votingOptions.delete(on: db)
            try await voting.delete(on: db)
        }
        
        return .noContent
    }
    
    @Sendable func openVoting(req: Request) async throws -> GetVotingDTO {
        guard let voting = try await Voting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard !voting.isOpen && voting.startedAt == nil && voting.closedAt == nil else {
            throw Abort(.badRequest, reason: "Only votings which have not started yet can be opened.")
        }
        
        voting.startedAt = .now
        voting.isOpen = true
        
        try await voting.update(on: req.db)
        return try voting.toGetVotingDTO()
    }
    
    @Sendable func closeVoting(req: Request) async throws -> GetVotingDTO {
        guard let voting = try await Voting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard voting.isOpen && voting.startedAt != nil && voting.closedAt == nil else {
            throw Abort(.badRequest, reason: "Only votings which are currently open can be closed.")
        }
        
        voting.closedAt = .now
        voting.isOpen = false
        
        try await voting.update(on: req.db)
        return try voting.toGetVotingDTO()
    }
    
    @Sendable func voteOnVoting(req: Request) async throws -> HTTPStatus {
        guard let voting = try await Voting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await voting.$votingOptions.load(on: req.db)
        guard let index = UInt8(req.parameters.get("index")!), try index == 0 || voting.votingOptions.contains(where: { votingOption in
            try votingOption.requireID().index == index
        }) else {
            throw Abort(.notFound)
        }
        guard voting.isOpen && voting.startedAt != nil && voting.closedAt == nil else {
            throw Abort(.badRequest, reason: "You can only vote on votings which are currently open.")
        }
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        let identity = try await Identity.byUserId(userId, req.db)
        guard try await Vote.find(.init(voting: voting, identity: identity), on: req.db) == nil else {
            throw Abort(.badRequest, reason: "You have already voted on this voting.")
        }
        
        let vote = try Vote(id: .init(voting: voting, identity: identity), index: index)
        try await vote.create(on: req.db)
        return .noContent
    }
}

struct percentageCutoff {
    public var index: UInt8
    public var percentage: Double
    public var cutoff: Double
}
