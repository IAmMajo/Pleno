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
