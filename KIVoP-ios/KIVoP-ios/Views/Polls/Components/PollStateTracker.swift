//
//  PollStateTracker.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 18.01.25.
//

import Foundation

struct PollStateTracker {
    private static let pollKey = "userPollVotes"

    // Save the user's vote for a specific voting
    static func saveVote(pollId: UUID, voteIndex: UInt8) {
        var polls = getPollVotes()
        polls[pollId.uuidString] = voteIndex
        UserDefaults.standard.setValue(polls, forKey: pollKey)
    }

    // Retrieve the user's vote for a specific voting
    static func getPollVote(for pollId: UUID) -> UInt8? {
        let polls = getPollVotes()
        return polls[pollId.uuidString]
    }

    // Check if the user has voted for a specific voting
    static func hasVotedForPoll(for pollId: UUID) -> Bool {
        return getPollVote(for: pollId) != nil
    }

    // Retrieve all votes (for internal use)
    private static func getPollVotes() -> [String: UInt8] {
        return UserDefaults.standard.dictionary(forKey: pollKey) as? [String: UInt8] ?? [:]
    }
}
