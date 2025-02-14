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
import JWT
import VaporToOpenAPI

struct UniversalLinkController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let openAPITag = TagObject(name: "Universal Links")
        
        routes.group(".well-known") { route in
            /// **GET** `/.well-known/assetlinks.json`
            route.get("assetlinks.json") { req in
                let response = req.fileio.streamFile(at: "Resources/UniversalLinks/android.json")
                guard response.status != .internalServerError else {
                    throw Abort(.notImplemented)
                }
                return response
            }
            .openAPI(tags: openAPITag,
                     summary: "Android assetlinks.json",
                     response: .type([WellKnown.AssetLink].self),
                     responseContentType: .application(.json),
                     statusCode: .ok)
            
            /// **GET** `/.well-known/apple-app-site-association.json`
            route.get("apple-app-site-association") { req in
                let response = req.fileio.streamFile(at: "Resources/UniversalLinks/apple.json")
                guard response.status != .internalServerError else {
                    throw Abort(.notImplemented)
                }
                return response
            }
            .openAPI(tags: openAPITag,
                     summary: "Apple apple-app-site-association.json",
                     response: .type(WellKnown.AppleAppSiteAssociation.self),
                     responseContentType: .application(.json),
                     statusCode: .ok)
        }
    }
}

internal struct WellKnown {
    
    struct AssetLink: Content {
        let relation: [String]
        let target: AssetLinkTarget
        
        struct AssetLinkTarget: Content {
            let namespace: String
            let package_name: String
            let sha256_cert_fingerprints: [String]
        }
    }
    
    struct AppleAppSiteAssociation: Content {
        let applinks: Applinks
        let webcredentials: AppsArray
        let webclips: AppsArray
        let activitycontinuation: AppsArray
        
        struct AppsArray: Content {
            let apps: [String]
        }
        
        struct Applinks: Content {
            let defaults: Details.Components
            let details: [Details]
            let substitutionVariables: [String: [String]]
            
            struct Details: Content {
                let appID: String
                let appIDs: [String]
                let components: [Components]
                let defaults: Components
                
                struct Components: Content {
                    let slash: String
                    let questionMark: [String: String]
                    let hashtag: String
                    let exclude: Bool
                    let comment: String
                    let caseSensitive: Bool
                    let percentEncoded: Bool
                    
                    private enum CodingKeys: String, CodingKey {
                        case slash = "/"
                        case questionMark = "?"
                        case hashtag = "#"
                        case exclude
                        case comment
                        case caseSensitive
                        case percentEncoded
                    }
                }
            }
        }
    }
}
