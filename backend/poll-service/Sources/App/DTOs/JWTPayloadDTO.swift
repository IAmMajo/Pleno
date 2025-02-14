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

import Fluent
import Vapor
import Models
@preconcurrency import JWT

public struct JWTPayloadDTO: JWTPayload, Authenticatable, Sendable {
    public var userID: UUID?
    public var exp: ExpirationClaim
    public var isAdmin: Bool?
    
    public init(userID: UUID!, exp: Date, isAdmin: Bool? = false) {
        self.userID = userID
        self.exp = ExpirationClaim(value: exp)
        self.isAdmin = isAdmin
    }
    
    public func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
