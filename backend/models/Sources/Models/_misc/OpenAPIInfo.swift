import Foundation

public struct OpenAPIInfo {
    public static let title: String = "KIVoP Meeting Service API"
    public static let summary: String? = nil
    public static let description: String? = """
# Alle Services
- [Config-Service](/config-service/swagger/#/)
- [Auth-Service](/auth-service/swagger/#/)
- [Meeting-Service](/meeting-service/swagger/#/)
- [Notifications-Service](/notifications-service/swagger/#/)
- [Poster-Service](/poster-service/swagger/#/)
- [Ride-Service](/ride-service/swagger/#/)
- [Ai-Service](/ai-service/swagger/#/)
- [Poll-Service](/poll-service/swagger/#/)
""" // Description: END
    public static let termsOfService: URL? = nil
    public static let contact: Contact? = nil
    public static let license: License? = .init(name: "MIT-0", url: URL(string: "https://github.com/aws/mit-0"))
    public static let version: Version = .init(0, 1, 0)
    
    public struct Contact : Sendable {
        public let name: String?
        public let url: URL?
        public let email: String?
        
        public init(name: String? = nil, url: URL? = nil, email: String? = nil) {
            self.name = name
            self.url = url
            self.email = email
        }
    }
    
    public struct License : Sendable {
        public let name: String
        public let identifier: String?
        public let url: URL?
        
        public init(name: String, identifier: String? = nil, url: URL? = nil) {
            self.name = name
            self.identifier = identifier
            self.url = url
        }
    }
    
    public struct Version : Sendable {
        public let major: UInt
        public let minor: UInt
        public let patch: UInt
        
        public init(_ major: UInt, _ minor: UInt, _ patch: UInt) {
            self.major = major
            self.minor = minor
            self.patch = patch
        }
    }
}
