//
//  GetVotingOptionDTOArray.swift
//  poll-service
//
//  Created by Lennart Guggenberger on 18.01.25.
//


import Vapor
import PollServiceDTOs

extension GetPollVotingOptionDTO: @retroactive Content, @unchecked @retroactive Sendable { }

extension ValidatorResults {
    /// Represents the result of a validator that checks whether a `[GetPollVotingOptionDTO]` is a valid array of poll voting options.
    public struct GetPollVotingOptionDTOArray {
        /// Indicates whether the input is a valid array of poll voting options.
        public let isValidGetPollVotingOptionDTOArray: Bool
    }
}

extension ValidatorResults.GetPollVotingOptionDTOArray: ValidatorResult {
    public var isFailure: Bool {
        !self.isValidGetPollVotingOptionDTOArray
    }
    
    public var successDescription: String? {
        "is a valid array of poll voting options"
    }
    
    public var failureDescription: String? {
        "is not a valid array of poll voting options"
    }
}

extension Validator where T == [GetPollVotingOptionDTO] {
    /// Validates whether a `[GetPollVotingOptionDTO]` is a valid array of poll voting options.
    public static var validGetPollVotingOptionDTOArray: Validator<T> {
        .init { input in
            guard input.count > 1
            else {
                return ValidatorResults.GetPollVotingOptionDTOArray(isValidGetPollVotingOptionDTOArray: false)
            }
            for option in input.enumerated() {
                guard option.element.index == UInt8(option.offset + 1) else {
                    return ValidatorResults.GetPollVotingOptionDTOArray(isValidGetPollVotingOptionDTOArray: false)
                }
            }
            return ValidatorResults.GetPollVotingOptionDTOArray(isValidGetPollVotingOptionDTOArray: true)
        }
    }
}
