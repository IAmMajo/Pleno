// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//
//  DTOextensions.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 16.01.25.
//

import Foundation
import MeetingServiceDTOs
import PosterServiceDTOs
import PollServiceDTOs


// MARK: - Extensions for Data Transfer Objects (DTOs)
// These extensions add additional capabilities to DTOs used in the app

// MARK: - GetMeetingDTO Extensions
extension GetMeetingDTO: @retroactive Identifiable {} // Enables identification using `id`
extension GetMeetingDTO: @retroactive Equatable {} // Allows equality comparison
extension GetMeetingDTO: @retroactive Hashable { // Enables hashing for use in Sets or Dictionaries
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id) // Uses `id` as the unique hash value
    }
    public static func == (lhs: GetMeetingDTO, rhs: GetMeetingDTO) -> Bool {
        return lhs.id == rhs.id // Compares objects based on `id`
    }
}
extension GetMeetingDTO: @retroactive @unchecked Sendable {}  // Allows safe use in concurrency without strict checks

// MARK: - GetVotingDTO Extensions
extension GetVotingDTO: @retroactive Identifiable {}
extension GetVotingDTO: @retroactive Equatable {}
extension GetVotingDTO: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public static func == (lhs: GetVotingDTO, rhs: GetVotingDTO) -> Bool {
        return lhs.id == rhs.id
    }
}

extension GetVotingDTO: @unchecked @retroactive Sendable {}


// MARK: - GetVotingOptionDTO Extensions
extension GetVotingOptionDTO: @retroactive Identifiable {
   public var id: UInt8 {
      self.index
   }
}
extension GetVotingOptionDTO: @retroactive Equatable {}
extension GetVotingOptionDTO: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }

    public static func == (lhs: GetVotingOptionDTO, rhs: GetVotingOptionDTO) -> Bool {
        return lhs.index == rhs.index
    }
}

// MARK: - Voting Results Extensions
extension GetVotingResultsDTO: @retroactive @unchecked Sendable {}

extension GetVotingResultDTO: @retroactive Identifiable {
   public var id: UInt8 {
      self.index
   }
}
extension GetVotingResultDTO: @retroactive Equatable {}
extension GetVotingResultDTO: @retroactive Hashable {
   public func hash(into hasher: inout Hasher) {
      hasher.combine(index) // Use `index` as the hashable property
   }
   
   public static func == (lhs: GetVotingResultDTO, rhs: GetVotingResultDTO) -> Bool {
      return lhs.index == rhs.index // Compare instances based on `index`
   }
}

// MARK: - CreateVotingDTO Extensions
extension CreateVotingDTO: @retroactive @unchecked Sendable {}


// MARK: - Poster DTO Extensions
extension PosterResponseDTO: @retroactive Identifiable {}
extension PosterResponseDTO: @retroactive @unchecked Sendable {}
extension PosterPositionResponseDTO: @retroactive @unchecked Sendable {}
extension UpdatePosterPositionDTO: @retroactive @unchecked Sendable {}
extension HangPosterPositionDTO: @retroactive @unchecked Sendable {}
extension HangPosterPositionResponseDTO: @retroactive @unchecked Sendable {}
extension TakeDownPosterPositionDTO: @retroactive @unchecked Sendable {}
extension TakeDownPosterPositionResponseDTO: @retroactive @unchecked Sendable {}
extension ReportDamagedPosterPositionDTO: @retroactive @unchecked Sendable {}
extension PosterSummaryResponseDTO: @retroactive @unchecked Sendable {}

// MARK: - Poll DTO Extensions
extension GetPollDTO: @retroactive Identifiable {}
extension GetPollDTO: @retroactive Equatable {}
extension GetPollDTO: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public static func == (lhs: GetPollDTO, rhs: GetPollDTO) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - GetPollVotingOptionDTO Extensions
extension GetPollVotingOptionDTO: @retroactive Identifiable {
   public var id: UInt8 {
      self.index
   }
}
extension GetPollVotingOptionDTO: @retroactive Equatable {}
extension GetPollVotingOptionDTO: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }

    public static func == (lhs: GetPollVotingOptionDTO, rhs: GetPollVotingOptionDTO) -> Bool {
        return lhs.index == rhs.index
    }
}

// MARK: - GetPollResultDTO Extensions
extension GetPollResultDTO: @retroactive Identifiable {
   public var id: UInt8 {
      self.index
   }
}
extension GetPollResultDTO: @retroactive Equatable {}
extension GetPollResultDTO: @retroactive Hashable {
   public func hash(into hasher: inout Hasher) {
      hasher.combine(index) // Use `index` as the hashable property
   }
   
   public static func == (lhs: GetPollResultDTO, rhs: GetPollResultDTO) -> Bool {
      return lhs.index == rhs.index // Compare instances based on `index`
   }
}

