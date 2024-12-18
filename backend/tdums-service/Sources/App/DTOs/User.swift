import Vapor

struct User: Authenticatable {
    var name: String
}

struct UserAuthenticator: AsyncBasicAuthenticator {
    typealias User = App.User

    func authenticate(
        basic: BasicAuthorization,
        for request: Request
    ) async throws {
        if basic.username == Environment.get("TDUMS_USERNAME") && basic.password == Environment.get("TDUMS_PASSWORD") {
            request.logger.notice("Hat geklappt :)")
            request.auth.login(User(name: basic.username))
        }
   }
}
