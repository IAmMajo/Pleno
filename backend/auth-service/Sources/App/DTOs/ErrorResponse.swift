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

/// Structure of Vapor's `ErrorMiddleware` default response.
internal struct ErrorResponse: Codable {
    /// Always `true` to indicate this is a non-typical JSON response.
    var error: Bool

    /// The reason for the error.
    var reason: String
}

extension ClientResponse {
    /// Bubbles up the received error if this request's response is of type `ErrorResponse`.
    /// Otherwise returns `self`.
    func throwOnVaporError() throws -> Self {
        if let errorResponse = try? self.content.decode(ErrorResponse.self) {
            throw Abort(self.status, reason: errorResponse.reason)
        }
        return self
    }
}
