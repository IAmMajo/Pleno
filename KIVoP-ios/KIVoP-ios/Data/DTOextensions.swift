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

// Extension der DTOs
extension GetMeetingDTO: @retroactive Identifiable {}
extension GetMeetingDTO: @retroactive Equatable {}
extension GetMeetingDTO: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public static func == (lhs: GetMeetingDTO, rhs: GetMeetingDTO) -> Bool {
        return lhs.id == rhs.id
    }
}
extension GetMeetingDTO: @retroactive @unchecked Sendable {}

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

extension CreateVotingDTO: @retroactive @unchecked Sendable {}

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
