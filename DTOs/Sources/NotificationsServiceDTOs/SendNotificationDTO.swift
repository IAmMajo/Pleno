import Foundation

public struct SendNotificationDTO: Codable {
    public var userID: UUID
    public var subject: String
    public var message: String
    public var payload: String?

    public init(
        userID: UUID,
        subject: String,
        message: String,
        payload: String? = nil
    ) {
        self.userID = userID
        self.subject = subject
        self.message = message
        self.payload = payload
    }
}
