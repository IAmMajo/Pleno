import Fluent
import Vapor
import JWT
import VaporToOpenAPI

func routes(_ app: Application) throws {
    
    let authProtected = app.grouped(AuthMiddleware())
    
    try authProtected.register(collection: SpecialRideController())
    
    try app.register(collection: WebhookController())
    
    app.get("openapi.json") { req in
      app.routes.openAPI(
        info: .init(
          title: "KIVoP Ride Service API",
          license: .init(
            name: "MIT-0",
            url: URL(string: "https://github.com/aws/mit-0")
          ),
          version: "0.1.0"
        )
      )
    }
    .excludeFromOpenAPI()

    app.stoplightDocumentation(
        "stoplight",
        openAPIPath: "/ride-service/openapi.json"
    )
}
