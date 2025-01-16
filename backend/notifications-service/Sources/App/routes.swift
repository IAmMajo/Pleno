import Vapor
import VaporToOpenAPI
import Models

func routes(_ app: Application) throws {
    try app.register(collection: EmailController())
    try app.register(collection: WebhookController())
    app.get("openapi.json") { req in
        app.routes.openAPI(
            info: .init(
                title: OpenAPIInfo.title,
                summary: OpenAPIInfo.summary,
                description: OpenAPIInfo.description,
                termsOfService: OpenAPIInfo.termsOfService,
                contact: OpenAPIInfo.contact == nil ? nil :
                        .init(name: OpenAPIInfo.contact!.name,
                              url: OpenAPIInfo.contact!.url,
                              email: OpenAPIInfo.contact!.email),
                license: OpenAPIInfo.license == nil ? nil :
                        .init(
                            name: OpenAPIInfo.license!.name,
                            identifier: OpenAPIInfo.license!.identifier,
                            url: OpenAPIInfo.license!.url
                        ),
                version: "\(OpenAPIInfo.version.major).\(OpenAPIInfo.version.minor).\(OpenAPIInfo.version.patch)"
            )
        )
    }
    .excludeFromOpenAPI()
    
    app.stoplightDocumentation(
        "stoplight",
        openAPIPath: "/notifications-service/openapi.json"
    )
}
