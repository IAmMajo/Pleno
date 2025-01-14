import Foundation

public struct GetUserWithoutFeedbackDTO: Codable {
    public var name: String
    public var itsMe: Bool
    
    public init(name: String, itsMe: Bool) {
        self.name = name
        self.itsMe = itsMe
    }
}
