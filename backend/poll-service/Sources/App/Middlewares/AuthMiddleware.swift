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
@preconcurrency import VaporToOpenAPI
@preconcurrency import JWT

struct AuthMiddleware: AsyncMiddleware {
    let payloadType: JWTPayloadDTO.Type
    
    init(payloadType: JWTPayloadDTO.Type) {
        self.payloadType = payloadType
    }
    
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let  token = request.headers.bearerAuthorization?.token ?? request.cookies["token"]?.string else {
            request.logger.warning("Not Token found in Authorization header or cookies.")
            throw Abort(.unauthorized, reason: "Authorization token required")
        }
        
        do {
            let payload = try request.jwt.verify(token, as: JWTPayloadDTO.self)
            
            request.jwtPayload = payload
        } catch {
            request.logger.error("Token verification failed: \(error)")
            throw Abort(.unauthorized, reason: "Invalid or expired token")
        }
        
        return try await next.respond(to: request)
    }
}

extension Request {
    private struct JWTKey: StorageKey {
        typealias Value = JWTPayloadDTO
    }
    var jwtPayload: JWTPayloadDTO? {
        get { storage[JWTKey.self] }
        set { storage[JWTKey.self] = newValue }
    }
}

extension AuthMiddleware {
    static let schemeObject = AuthSchemeObject.bearer()
}
