import Fluent
import Vapor
import Foundation
import Models
import VaporToOpenAPI

// MARK: - Fehlerdefinitionen für Poster-Erstellung und -Verwaltung

enum PosterCreationError: AbortError {
    case invalidContentType
    case invalidFormData(reason: String)
    case imageSaveFailed
    case databaseSaveFailed
    case unknownError
    case settingFetchFailed(reason: String)
    
    var status: HTTPResponseStatus {
        switch self {
        case .invalidContentType:
            return .unsupportedMediaType
        case .invalidFormData:
            return .badRequest
        case .imageSaveFailed,
                .databaseSaveFailed,
                .settingFetchFailed,
                .unknownError:
            return .internalServerError
        }
    }
    
    var reason: String {
        switch self {
        case .invalidContentType:
            return "Erwartet multipart/form-data"
        case .invalidFormData(let reason):
            return "Ungültige Formulardaten: \(reason)"
        case .imageSaveFailed:
            return "Fehler beim Speichern des Bildes"
        case .databaseSaveFailed:
            return "Fehler beim Speichern des Posters in der Datenbank"
        case .settingFetchFailed(let reason):
            return "Fehler beim Abrufen der 'poster_deletion_interval' Einstellung: \(reason)"
        case .unknownError:
            return "Unbekannter Fehler"
        }
    }
}

// MARK: - PosterController

/// Controller für Poster
/// Dieser Controller enthält Routen zum Erstellen, Aktualisieren, Löschen und Abrufen von Postern.
struct PosterController: RouteCollection, Sendable {
    let adminMiddleware: Middleware
    
    /// Initialisiert den `PosterController` mit Admin-Middleware.
    init() throws {
        self.adminMiddleware = AdminMiddleware()
    }
    
    /// Registriert alle Routen des Controllers.
    func boot(routes: RoutesBuilder) throws {
        // Authentifizierte Routen-Gruppe
        
        let openAPITagPoster = TagObject(name: "Poster")
        
        routes.get("summary", use: getPostersSummary).openAPI(
            tags: openAPITagPoster,
            summary: "Anzahl der verschiedenen PosterPositionen Staten abfragen",
            description: """
                        Diese Route für die Staten hangs,toHang,overdue und takenDown einen numerischen Wert zurück, welcher die Anzahl der gefunden Einträge abbildet. 
                        """,
            body: nil,
            response: .type(PosterSummaryResponseDTO.self),
            responseContentType: .application(.json),
            auth: .bearer()
        )
        
        // GET /posters
        routes.get(":id", use: getPoster).openAPI(
            tags: openAPITagPoster,
            summary: "Einzelnes Poster abfragen",
            description: """
                        Diese Route gibt ein einzelnes verfügbares Poster zurück. 
                        """,
            path: .type(Poster.IDValue.self),
            body: nil,
            response: .type(PosterResponseDTO.self),
            responseContentType: .application(.json),
            auth: .bearer()
        )
        
        // GET /posters
        routes.get(use: getPosters).openAPI(
            tags: openAPITagPoster,
            summary: "Alle verfügbaren Poster abfragen",
            description: """
                        Diese Route gibt eine Liste aller verfügbaren Poster zurück. Optional kann über die Query-Parameter
                        `page` und `per` eine Pagination vorgenommen werden, um große Datenmengen seitenweise abzurufen.
                        
                        **Beispiel:**
                        - `GET /poster-service?page=2&per=10` gibt die zweite Seite mit jeweils 10 Einträgen zurück.
                        """,
            query: ["page": .integer, "per": .integer],
            body: nil,
            response: .type(PosterResponseDTO.self),
            responseContentType: .application(.json),
            auth: .bearer()
        )
        
        // POST /posters
        routes.post(use: createPoster).openAPI(
            tags: openAPITagPoster,
            summary: "Erstellt ein neues Poster",
            description: """
                        Diese Route ermöglicht das Erstellen eines neuen Posters. Der Request muss als `multipart/form-data` gesendet werden
                        und sollte mindestens einen Namen (`name`) sowie ein Bild (`image`) enthalten. Optional kann auch
                        eine Beschreibung (`description`) übergeben werden.
                        
                        **Ablauf:**
                        - Sende im Body ein `CreatePosterDTO` mit den erforderlichen Daten.
                        - Das übertragene Bild wird auf dem Server gespeichert und kann über die /image Route aufgerufen werden
                        - Bei Erfolg wird ein `PosterResponseDTO` mit den Daten des neu erstellten Posters zurückgegeben.
                        """,
            query: [],
            body: .type(CreatePosterDTO.self),
            contentType: .multipart(.formData),
            response: .type(PosterResponseDTO.self),
            responseContentType: .application(.json),
            auth: .bearer()
        )
        
        // PATCH /posters/:id
        routes.patch(":id", use: updatePoster).openAPI(
            tags: openAPITagPoster,
            summary: "Updatet ein Poster",
            description: """
                        Aktualisiert ein vorhandenes Poster basierend auf seiner ID. Der Request muss als `multipart/form-data` gesendet werden
                        und kann Felder wie `name`, `description` oder ein neues `image` enthalten. Nur Felder, die angegeben werden, werden aktualisiert.
                        
                        **Ablauf:**
                        - Gib die ID des zu aktualisierenden Posters als Pfadparameter `:id` an.
                        - Senden Sie ein `UpdatePosterDTO` mit den zu ändernden Feldern. Nicht übergebene Felder bleiben unverändert.
                        - Wird ein neues Bild übertragen, wird das alte Bild gelöscht und durch das neue ersetzt.
                        - Die Route gibt ein `PosterResponseDTO` mit den aktualisierten Daten zurück.
                        """,
            query: [],
            path: .type(Poster.IDValue.self),
            body: .type(UpdatePosterDTO.self),
            contentType: .multipart(.formData),
            response: .type(PosterResponseDTO.self),
            responseContentType: .application(.json),
            auth: .bearer()
        )
        
        // Admin-geschützte Haupt-Poster-Routen (ohne :id)
        let adminRoutesPoster = routes.grouped(adminMiddleware)
        
        // DELETE /posters/:id (admin)
        adminRoutesPoster.delete(":id", use: deletePoster).openAPI(
            tags: openAPITagPoster,
            summary: "Löscht ein Poster",
            description: """
                        Löscht ein vorhandenes Poster anhand seiner ID. Das zugehörige Bild wird ebenfalls entfernt.
                        Des Weiteren werden auch die zugehörigen Poster Positionen gelöscht samt zugehöriger Bilder.
                        Die Request kann nur von einem Admin erstellt werden.
                        
                        **Ablauf:**
                        - Gib die ID des zu löschenden Posters als Pfadparameter `:id` an.
                        - Bei Erfolg wird ein HTTP-Status `204 No Content` zurückgegeben.
                        """,
            query: [],
            path: .type(Poster.IDValue.self),
            statusCode: .noContent,
            auth: .bearer()
        )
        
        // DELETE /posters/batch (admin)
        adminRoutesPoster.delete("batch", use: deletePosters).openAPI(
            tags: openAPITagPoster,
            summary: "Löscht mehrere Poster",
            description: """
                        Löscht mehrere Poster anhand einer Liste von IDs. Die zugehörigen Bilder werden ebenfalls entfernt.
                        Des Weiteren werden auch die zugehörigen Poster Positionen gelöscht samt zugehöriger Bilder.
                        Die Request kann nur von einem Admin erstellt werden.
                        
                        **Ablauf:**
                        - Senden Sie ein `DeleteDTO` mit einem Array von Poster-IDs.
                        - Falls eine oder mehrere IDs nicht gefunden werden, wird ein Fehler zurückgegeben.
                        - Bei Erfolg wird ein HTTP-Status `204 No Content` zurückgegeben.
                        """,
            query: [],
            body: .type(DeleteDTO.self),
            contentType: .application(.json),
            statusCode: .noContent,
            auth: .bearer()
        )
        
        // Bild-Routen-Gruppe
        let images = routes.grouped("images")
        let openAPITagImage = TagObject(name: "Image")
        
        // GET /images/:folder/:imageURL
        images.get(":folder", ":imageURL", use: getImageFile).openAPI(
            tags: openAPITagImage,
            summary: "Gibt ein gespeichertes Bild zurück",
            description: """
                    Diese Route gibt eine zuvor gespeicherte Bilddatei zurück. Der Pfadparameter imageURL gibt den relativen Speicherort bzw. Dateinamen an und der Pfadparameter folder, ob es sich um ein Poster oder Poster Position Bild handelt.
                    
                    **folder**
                    - **Posters**: Sucht ein Bild eines Poster mit der übergebenen imageURL
                    - **PosterPositions**: Sucht ein Bild einer Poster Position mit der übergebenen imageURL
                    """,
            path: ["folder": .string, "imageURL": .string],
            body: nil,
            responseContentType: .init("image/jpeg"),
            auth: .bearer()
        )
    }
    
    
    // MARK: - Hilfsfunktionen
    
    /// Erstellt eine HTTP-Response mit JSON-Inhalt aus einem codierbaren DTO.
    @Sendable
    private func createResponse<T: Codable>(
            with dto: T,
            on req: Request,
            status: HTTPStatus = .ok, // Standardstatus auf 200 OK gesetzt
            additionalHeaders: HTTPHeaders? = nil
        ) async throws -> Response {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let responseData = try encoder.encode(dto)
            var headers = HTTPHeaders()
            headers.contentType = .json
            
            if let extraHeaders = additionalHeaders {
                for (name, value) in extraHeaders {
                    headers.add(name: name, value: value)
                }
            }
            
            return Response(status: status, headers: headers, body: .init(data: responseData))
        }
    
    /// Speichert ein hochgeladenes Bild in einem angegebenen Verzeichnis außerhalb des Public-Ordners.
    /// Wirft einen Fehler, wenn das Bild ungültige Daten enthält oder nicht gespeichert werden kann.
    private func saveImage(_ file: File, in directory: String, on req: Request) async throws -> String {
        let supportedExtensions = ["jpg", "jpeg", "png"]
        let fileExtension = (file.extension ?? "jpg").lowercased()
        let validExtension = supportedExtensions.contains(fileExtension) ? fileExtension : "jpg"
        
        let uniqueFileName = "\(UUID().uuidString).\(validExtension)"
        let saveDirectory = req.application.directory.workingDirectory + directory
        let savePath = saveDirectory + "/" + uniqueFileName
        
        let directoryURL = URL(fileURLWithPath: saveDirectory, isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        
        guard let imageData = file.data.getData(at: 0, length: file.data.readableBytes) else {
            throw Abort(.badRequest, reason: "Ungültige Bilddaten.")
        }
        
        let fileURL = URL(fileURLWithPath: savePath)
        do {
            try imageData.write(to: fileURL)
        } catch {
            req.logger.error("Fehler beim Speichern der Bilddatei: \(error.localizedDescription)")
            throw PosterCreationError.imageSaveFailed
        }
        
        return uniqueFileName
    }
    
    // Hilfsfunktion um nach page & per zu paginieren
    @Sendable
    private func paginate<T>(_ items: [T], page: Int, per: Int) -> (pagedItems: [T], totalItems: Int) {
        let start = (page - 1) * per
        let end = start + per
        guard start < items.count else {
            return ([], items.count)
        }
        let sliced = Array(items[start..<min(end, items.count)])
        return (sliced, items.count)
    }
    
    // MARK: - Poster-Routen
    
    /// Erstellt ein neues Poster aus multipart/form-data.
    /// Erwartet mindestens `name` und `image` im Request Body.
    @Sendable
    func createPoster(req: Request) async throws -> Response {
        // Überprüfen des Content-Types
        guard let contentType = req.headers.contentType,
              contentType.type == "multipart",
              contentType.subType == "form-data" else {
            throw PosterCreationError.invalidContentType
        }
        
        let posterData: CreatePosterDTO
        do {
            posterData = try req.content.decode(CreatePosterDTO.self)
        } catch {
            throw PosterCreationError.invalidFormData(reason: "Fehler beim Dekodieren der Formulardaten.")
        }
        
        guard !posterData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PosterCreationError.invalidFormData(reason: "Name darf nicht leer sein.")
        }
        
        let allowedMimeTypes = ["image/jpeg", "image/png"]
        guard allowedMimeTypes.contains(posterData.image.contentType?.description ?? "") else {
            throw PosterCreationError.invalidFormData(reason: "Ungültiger Bildtyp. Erlaubt sind JPEG, PNG")
        }
        
        // Bild speichern
        let imageUrl: String
        do {
            imageUrl = try await saveImage(posterData.image, in: "Storage/Images/Posters", on: req)
        } catch {
            req.logger.error("Bildspeicherung fehlgeschlagen: \(error.localizedDescription)")
            throw PosterCreationError.imageSaveFailed
        }
        
        // Poster in DB speichern
        let poster = Poster(
            name: posterData.name,
            description: posterData.description,
            imageUrl: imageUrl
        )
        
        do {
            try await poster.create(on: req.db)
        } catch {
            req.logger.error("Datenbankspeicherung fehlgeschlagen: \(error.localizedDescription)")
            throw PosterCreationError.databaseSaveFailed
        }
        
        let responseDTO = PosterResponseDTO(
            id: poster.id!,
            name: poster.name,
            description: poster.description,
            imageUrl: poster.image_url
        )
        
        return try await createResponse(with: responseDTO, on: req, status: .created)
    }
    
    @Sendable
    func getPoster(req: Request) async throws -> Response {
        guard let posterId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Position-ID.")
        }
        guard let poster = try await Poster.find(posterId, on: req.db) else {
            throw Abort(.notFound, reason: "PosterPosition nicht gefunden.")
        }
        let response =
        PosterResponseDTO(
            id: poster.id!,
            name: poster.name,
            description: poster.description,
            imageUrl: poster.image_url
        )
        
        return try await createResponse(with: response, on: req)
    }
    /// Gibt alle verfügbaren Poster zurück oder Poster basierend auf Anzahl der gewählten Menge und Seite
    @Sendable
    func getPosters(req: Request) async throws -> Response {
        let page = try? req.query.get(Int.self, at: "page")
        let per = try? req.query.get(Int.self, at: "per")
        
        if let page = page, let per = per {
            let paginatedData = try await Poster.query(on: req.db)
                .paginate(PageRequest(page: page, per: per))
            
            let response = paginatedData.items.map { poster in
                PosterResponseDTO(
                    id: poster.id!,
                    name: poster.name,
                    description: poster.description,
                    imageUrl: poster.image_url
                )
            }
            let currentPage = paginatedData.metadata.page
            let perPage = paginatedData.metadata.per
            let totalItems = paginatedData.metadata.total
            let totalPages = Int((Double(totalItems) / Double(perPage)).rounded(.up))
            
            var headers = HTTPHeaders()
            headers.contentType = .json
            headers.add(name: "Pagnation-Current-Page", value: "\(currentPage)")
            headers.add(name: "Pagnation-Per-Page", value: "\(perPage)")
            headers.add(name: "Pagnation-Total-Items", value: "\(totalItems)")
            headers.add(name: "Pagnation-Total-Pages", value: "\(totalPages)")
            
            return try await createResponse(with: response, on: req, additionalHeaders: headers)
            
        } else {
            let posters = try await Poster.query(on: req.db).all()
            let response = posters.map { poster in
                PosterResponseDTO(
                    id: poster.id!,
                    name: poster.name,
                    description: poster.description,
                    imageUrl: poster.image_url
                )
            }
            
            return try await createResponse(with: response, on: req)
        }
    }
    
    @Sendable
        func getPostersSummary(req: Request) async throws -> Response {
            let currentDate = Date()
            
            // 1. "hangs": posted_by != nil && removed_by == nil
            let hangsCount = try await PosterPosition.query(on: req.db)
                .filter(\.$posted_by.$id != nil)
                .filter(\.$removed_by.$id == nil)
                .count()
            
            // 2. "toHang": posted_by == nil && expires_at > currentDate
            let toHangCount = try await PosterPosition.query(on: req.db)
                .filter(\.$posted_by.$id == nil)
                .filter(\.$expires_at > currentDate)
                .count()
            
            // 3. "overdue": posted_by != nil && removed_by == nil && expires_at <= currentDate
            let overdueCount = try await PosterPosition.query(on: req.db)
                .filter(\.$posted_by.$id != nil)
                .filter(\.$removed_by.$id == nil)
                .filter(\.$expires_at <= currentDate)
                .count()
            
            // 4. "takenDown": removed_by != nil
            let takenDownCount = try await PosterPosition.query(on: req.db)
                .filter(\.$removed_by.$id != nil)
                .count()
            
            // Zusammenbauen des DTO
            let summary = PosterSummaryResponseDTO(
                hangs: hangsCount,
                toHang: toHangCount,
                overdue: overdueCount,
                takenDown: takenDownCount
            )
            
            return try await createResponse(with: summary, on: req)
        }
    
    
    /// Aktualisiert ein bestehendes Poster (Name, Beschreibung und/oder Bild).
    @Sendable
    func updatePoster(req: Request) async throws -> Response {
        guard let posterId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Poster-ID.")
        }
        
        guard let contentType = req.headers.contentType,
              contentType.type == "multipart",
              contentType.subType == "form-data" else {
            throw Abort(.unsupportedMediaType, reason: "Erwartet multipart/form-data")
        }
        
        let dto = try req.content.decode(UpdatePosterDTO.self)
        guard let poster = try await Poster.find(posterId, on: req.db) else {
            throw Abort(.notFound, reason: "Poster nicht gefunden.")
        }
        
        if let name = dto.name {
            poster.name = name
        }
        if let description = dto.description {
            poster.description = description
        }
        if let image = dto.image {
            // Altes Bild löschen, wenn vorhanden
            let oldFilePath = req.application.directory.workingDirectory + "Storage/Images/Posters/" + poster.image_url
            do {
                try FileManager.default.removeItem(atPath: oldFilePath)
            } catch {
                req.logger.warning("Altes Bild konnte nicht gelöscht werden: \(error)")
                // Nicht unbedingt aborten, da das Poster dennoch aktualisiert werden kann.
            }
            
            // Neues Bild speichern
            let imageUrl = try await saveImage(image, in: "Storage/Images/Posters", on: req)
            poster.image_url = imageUrl
        }
        
        try await poster.update(on: req.db)
        
        let responseDTO = PosterResponseDTO(
            id: poster.id!,
            name: poster.name,
            description: poster.description,
            imageUrl: poster.image_url
        )
        
        return try await createResponse(with: responseDTO, on: req)
    }
    
    /// Löscht ein einzelnes Poster **und** alle zugehörigen PosterPositionen + deren Bilder.
    @Sendable
    func deletePoster(req: Request) async throws -> HTTPStatus {
        guard let posterID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Poster-ID.")
        }
        
        guard let poster = try await Poster.find(posterID, on: req.db) else {
            throw Abort(.notFound, reason: "Poster mit der ID \(posterID) wurde nicht gefunden.")
        }
        
        try await req.db.transaction { database in
            // 1) Alle PosterPositionen zu diesem Poster laden
            let positions = try await PosterPosition.query(on: database)
                .filter(\.$poster.$id == posterID) // PosterPosition where poster_id == posterID
                .all()
            
            // 2) Für jede Position das zugehörige Bild löschen + Position löschen
            for position in positions {
                if let imageUrl = position.image_url {
                    let filePath = req.application.directory.workingDirectory
                    + "Storage/Images/PosterPositions/"
                    + imageUrl
                    do {
                        try FileManager.default.removeItem(atPath: filePath)
                    } catch {
                        req.logger.error("Fehler beim Löschen der Bilddatei für PosterPosition-ID \(position.id?.uuidString ?? "unbekannt"): \(error)")
                    }
                }
                
                try await position.delete(on: database)
            }
            
            // 3) Poster-Bild löschen
            let filePathPoster = req.application.directory.workingDirectory
            + "Storage/Images/Posters/"
            + poster.image_url
            do {
                try FileManager.default.removeItem(atPath: filePathPoster)
            } catch {
                req.logger.error("Fehler beim Löschen der Poster-Bilddatei \(poster.id?.uuidString ?? "unbekannt"): \(error)")
                // Analog: ggf. throw oder nur loggen
            }
            
            // 4) Poster selbst löschen
            try await poster.delete(on: database)
        }
        
        return .noContent
    }
    
    
    /// Löscht mehrere Poster und deren zugehörige Bilddateien in einem Batch.
    @Sendable
    func deletePosters(req: Request) async throws -> HTTPStatus {
        let deleteDTO = try req.content.decode(DeleteDTO.self)
        let posterIDs = deleteDTO.ids
        
        guard !posterIDs.isEmpty else {
            throw Abort(.badRequest, reason: "Es müssen mindestens eine Poster-ID übergeben werden.")
        }
        
        // Alle Poster laden, die gelöscht werden sollen
        let postersToDelete = try await Poster.query(on: req.db)
            .filter(\.$id ~~ posterIDs)
            .all()
        
        // Prüfen, ob alle IDs existieren
        if postersToDelete.count != posterIDs.count {
            let foundIDs = Set(postersToDelete.compactMap { $0.id })
            let notFoundIDs = posterIDs.filter { !foundIDs.contains($0) }
            throw Abort(.notFound, reason: "Poster mit den folgenden IDs wurden nicht gefunden: \(notFoundIDs.map { $0.uuidString }.joined(separator: ", "))")
        }
        
        try await req.db.transaction { database in
            let fileManager = FileManager.default
            
            // Für jedes Poster...
            for poster in postersToDelete {
                // 1) Alle PosterPositionen finden, die auf dieses Poster referenzieren
                let positions = try await PosterPosition.query(on: database)
                    .filter(\.$poster.$id == poster.id!)
                    .all()
                
                // 2) Für jede Position das Bild löschen (falls vorhanden) + Position löschen
                for position in positions {
                    if let imageUrl = position.image_url {
                        let filePath = req.application.directory.workingDirectory
                        + "Storage/Images/PosterPositions/"
                        + imageUrl
                        do {
                            try fileManager.removeItem(atPath: filePath)
                        } catch {
                            req.logger.error("Fehler beim Löschen der Bilddatei für PosterPosition-ID \(position.id?.uuidString ?? "unbekannt"): \(error)")
                        }
                    }
                    
                    try await position.delete(on: database)
                }
                
                // 3) Poster-Bild löschen
                let posterFilePath = req.application.directory.workingDirectory
                + "Storage/Images/Posters/"
                + poster.image_url
                do {
                    try fileManager.removeItem(atPath: posterFilePath)
                } catch {
                    req.logger.error("Fehler beim Löschen der Bilddatei für Poster ID \(poster.id?.uuidString ?? "Unbekannt"): \(error.localizedDescription)")
                    throw Abort(.internalServerError, reason: "Fehler beim Löschen der Bilddatei für Poster ID \(poster.id?.uuidString ?? "Unbekannt")")
                }
                
                // 4) Poster löschen
                try await poster.delete(on: database)
            }
        }
        
        return .noContent
    }
    
    
    
    // MARK: - Bild-Handling
    
    /// Gibt eine gespeicherte Bilddatei zurück.
    /// Diese Route streamt die Datei direkt aus dem geschützten Verzeichnis.
    @Sendable
    func getImageFile(req: Request) async throws -> Response {
        guard let imageURL = req.parameters.get("imageURL", as: String.self) else {
            throw Abort(.badRequest, reason: "Ungültige Bild-url")
        }
        guard let folder = req.parameters.get("folder", as: String.self) else {
            throw Abort(.badRequest, reason: "Ungültiger Ordner")
        }
        
        let imagePath = req.application.directory.workingDirectory
        + "Storage/Images/"
        + folder + "/"
        + imageURL
        
        
        guard FileManager.default.fileExists(atPath: imagePath) else {
            throw Abort(.notFound, reason: "Bilddatei nicht gefunden")
        }
        
        return req.fileio.streamFile(at: imagePath)
    }
}




