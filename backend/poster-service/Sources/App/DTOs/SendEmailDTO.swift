public struct SendEmailDTO: Codable {
    public var receiver: String
    public var subject: String
    public var message: String?
    public var template: String?
    public var templateData: [String: String]?

    public init(
        receiver: String,
        subject: String,
        message: String? = nil,
        template: String? = nil,
        templateData: [String: String]? = nil
    ) {
        self.receiver = receiver
        self.subject = subject
        self.message = message
        self.template = template
        self.templateData = templateData
    }
}
