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

import Vapor
import MeetingServiceDTOs

extension GetVotingOptionDTO: @retroactive Content, @unchecked @retroactive Sendable { }

extension ValidatorResults {
    /// Represents the result of a validator that checks if a string is a valid zip code.
    public struct GetVotingOptionDTOArray {
        /// Indicates whether the input is a valid zip code.
        public let isValidGetVotingOptionDTOArray: Bool
    }
}

extension ValidatorResults.GetVotingOptionDTOArray: ValidatorResult {
    public var isFailure: Bool {
        !self.isValidGetVotingOptionDTOArray
    }
    
    public var successDescription: String? {
        "is a valid array of voting options"
    }
    
    public var failureDescription: String? {
        "is not a valid array of voting options"
    }
}

extension Validator where T == [GetVotingOptionDTO] {
    /// Validates whether a `[GetVotingOptionDTO]` is a valid array of voting options.
    public static var validGetVotingOptionDTOArray: Validator<T> {
        .init { input in
            guard input.count > 1
            else {
                return ValidatorResults.GetVotingOptionDTOArray(isValidGetVotingOptionDTOArray: false)
            }
            for option in input.enumerated() {
                guard option.element.index == UInt8(option.offset + 1) else {
                    return ValidatorResults.GetVotingOptionDTOArray(isValidGetVotingOptionDTOArray: false)
                }
            }
            return ValidatorResults.GetVotingOptionDTOArray(isValidGetVotingOptionDTOArray: true)
        }
    }
}
