//
//  VotingStateTracker.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 28.11.24.
//

import Foundation

struct VotingStateTracker {
    private static let votingKey = "userVotes"

    // Save the user's vote for a specific voting
    static func saveVote(votingId: UUID, voteIndex: UInt8) {
        var votes = getVotes()
        votes[votingId.uuidString] = voteIndex
        UserDefaults.standard.setValue(votes, forKey: votingKey)
    }

    // Retrieve the user's vote for a specific voting
    static func getVote(for votingId: UUID) -> UInt8? {
        let votes = getVotes()
        return votes[votingId.uuidString]
    }

    // Check if the user has voted for a specific voting
    static func hasVoted(for votingId: UUID) -> Bool {
        return getVote(for: votingId) != nil
    }

    // Retrieve all votes (for internal use)
    private static func getVotes() -> [String: UInt8] {
        return UserDefaults.standard.dictionary(forKey: votingKey) as? [String: UInt8] ?? [:]
    }
}
