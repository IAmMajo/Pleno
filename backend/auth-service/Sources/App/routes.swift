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
import VaporToOpenAPI
import Models

func routes(_ app: Application) throws {
    try app.register(collection: AuthController())
    try app.register(collection: UserController())
    try app.register(collection: WebhookController())
    try app.register(collection: UniversalLinkController())
    try app.grouped("internal").register(collection: InternalController())
    
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
        openAPIPath: "/auth-service/openapi.json"
    )
}
