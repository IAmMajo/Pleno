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

import PosterServiceDTOs
import Vapor
import Fluent
import Models

extension PosterResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {
    static func fetchAllPostersAndBuildResponse(_ req: Request) async throws -> Response {
    let page = try? req.query.get(Int.self, at: "page")
    let per = try? req.query.get(Int.self, at: "per")
    
    
    if let page = page, let per = per {
        
        let paginatedData: Page<Poster>
        do {
            paginatedData = try await Poster.query(on: req.db)
                .paginate(PageRequest(page: page, per: per))
        } catch {
            throw Abort(.internalServerError, reason: "Error fetching paginated posters: \(error.localizedDescription)")
        }
        
        let responseDTOs: [PosterResponseDTO]
        do {
            responseDTOs = try paginatedData.items.map { poster in
                PosterResponseDTO(
                    id: try poster.requireID(),
                    name: poster.name,
                    description: poster.description
                )
            }
        } catch {
            throw Abort(.internalServerError, reason: "Error mapping posters to response DTO: \(error.localizedDescription)")
        }
        
        let currentPage = paginatedData.metadata.page
        let perPage = paginatedData.metadata.per
        let totalItems = paginatedData.metadata.total
        let totalPages = Int((Double(totalItems) / Double(perPage)).rounded(.up))
        
        var headers = HTTPHeaders()
        headers.add(name: "Pagination-Current-Page", value: "\(currentPage)")
        headers.add(name: "Pagination-Per-Page", value: "\(perPage)")
        headers.add(name: "Pagination-Total-Items", value: "\(totalItems)")
        headers.add(name: "Pagination-Total-Pages", value: "\(totalPages)")
        
        let encodedBody: Response.Body
        do {
            encodedBody = try Response.Body(data: JSONEncoder().encode(responseDTOs))
        } catch {
            throw Abort(.internalServerError, reason: "Error encoding response DTO: \(error.localizedDescription)")
        }
        
        return Response(status: .ok, headers: headers, body: encodedBody)
        
    } else {
        
        let posters: [Poster]
        do {
            posters = try await Poster.query(on: req.db).all()
        } catch {
            throw Abort(.internalServerError, reason: "Error fetching posters: \(error.localizedDescription)")
        }
        
        let responseDTOs: [PosterResponseDTO]
        do {
            responseDTOs = try posters.map { poster in
                PosterResponseDTO(
                    id: try poster.requireID(),
                    name: poster.name,
                    description: poster.description
                )
            }
        } catch {
            throw Abort(.internalServerError, reason: "Error mapping posters to response DTO: \(error.localizedDescription)")
        }
        
        let encodedBody: Response.Body
        do {
            encodedBody = try Response.Body(data: JSONEncoder().encode(responseDTOs))
        } catch {
            throw Abort(.internalServerError, reason: "Error encoding response DTO: \(error.localizedDescription)")
        }
        
        return Response(status: .ok,
                        headers: ["Content-Type": "application/json"],
                        body: encodedBody)
    }
}}
