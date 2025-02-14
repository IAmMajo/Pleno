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

import Foundation

public struct OpenAPIInfo {
    public static let title: String = "KIVoP Service API"
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
