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
