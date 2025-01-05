import Fluent
import Vapor
import VaporToOpenAPI

func routes(_ app: Application) throws {
  
    try app.register(collection: ConfigController())

    app.get("openapi.json") { req in
      app.routes.openAPI(
        info: .init(
          title: "KIVoP Config Service API",
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
        openAPIPath: "/config-service/openapi.json"
    )
}
