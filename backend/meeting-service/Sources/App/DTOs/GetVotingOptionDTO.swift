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
                guard option.element.index == UInt8(option.offset) else {
                    return ValidatorResults.GetVotingOptionDTOArray(isValidGetVotingOptionDTOArray: false)
                }
            }
            return ValidatorResults.GetVotingOptionDTOArray(isValidGetVotingOptionDTOArray: true)
        }
    }
}
