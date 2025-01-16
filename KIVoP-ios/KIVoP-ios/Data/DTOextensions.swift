//
//  DTOextensions.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 16.01.25.
//

import Foundation
import MeetingServiceDTOs

// Extension der DTOs
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
