import Fluent
import Vapor
import VaporToOpenAPI

func routes(_ app: Application) throws {
    try app.register(collection: AIController())
    try app.register(collection: WebhookController())

    app.get("openapi.json") { req in
      app.routes.openAPI(
        info: .init(
          title: "KIVoP AI Service API",
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
        openAPIPath: "/ai-service/openapi.json"
    )
}
