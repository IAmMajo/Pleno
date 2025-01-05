import Fluent
import Vapor
import Foundation
import Models
@preconcurrency import JWTKit
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

/// Controller für Poster und PosterPositionen.
/// Dieser Controller enthält Routen zum Erstellen, Aktualisieren, Löschen und Abrufen von Postern und deren Positionen.
struct PosterController: RouteCollection, Sendable {
    let jwtSigner: JWTSigner
    let authMiddleware: Middleware
    let adminMiddleware: Middleware
    
    /// Initialisiert den `PosterController` mit JWT-basiertem Auth und Admin-Middleware.
    /// Der JWT-Secret-Key wird aus einer Umgebungsvariablen gelesen, um Hardcoding zu vermeiden.
    init() throws {
        //guard let jwtSecret = Environment.get("JWT_SECRET"),
        //      let keyData = jwtSecret.data(using: .utf8) else {
        //    throw Abort(.internalServerError, reason: "JWT_SECRET Umgebungsvariable nicht gesetzt oder ungültig.")
        guard let keyData = "Ganzgeheimespasswort".data(using: .utf8) else {
            throw Abort(.internalServerError, reason: "Fehler beim Erstellen des JWT-Signers")
        }
        self.jwtSigner = JWTSigner.hs256(key: keyData)
        self.authMiddleware = AuthMiddleware(jwtSigner: jwtSigner, payloadType: JWTPayloadDTO.self)
        self.adminMiddleware = AdminMiddleware()
    }
    
    /// Registriert alle Routen des Controllers.
    func boot(routes: RoutesBuilder) throws {
        // Authentifizierte Routen
        let authProtected = routes.grouped(authMiddleware)
        
        // Poster-Routen
        authProtected.get(":posterId",use: getPoster).openAPI(
            summary: "Poster abfragen",
            description: """
                Diese Route gibt ein Poster anhand der ID zurück. 
                **Beispiel:**
                - `GET /poster-service/121434-132131` gibt das Poster mit der dazugehörigen UUID zurück.
                """,
            path: .type(Poster.IDValue.self),
            body: nil,
            response: .type(PosterResponseDTO.self),
            responseContentType: .application(.json)
        )
        
        authProtected.get(use: getPosters).openAPI(
            summary: "Alle verfügbaren Poster abfragen",
            description: """
                Diese Route gibt eine Liste aller verfügbaren Poster zurück. Optional kann über die Query-Parameter
                `page` und `per` eine Pagination vorgenommen werden, um große Datenmengen seitenweise abzurufen.
                
                **Beispiel:**
                - `GET /poster-service?page=2&per=10` gibt die zweite Seite mit jeweils 10 Einträgen zurück.
                """,
            query:["page":.integer,"per":.integer],
            body: nil,
            response: .type(PosterResponseDTO.self),
            responseContentType: .application(.json)
        )
        authProtected.post(use: createPoster).openAPI(
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
            query:[],
            body: .type(CreatePosterDTO.self),
            contentType: .multipart(.formData),
            response: .type(PosterResponseDTO.self),
            responseContentType: .application(.json)
        )
        authProtected.patch(":posterId", use: updatePoster).openAPI(
            summary: "Updatet ein Poster",
            description: """
                Aktualisiert ein vorhandenes Poster basierend auf seiner ID. Der Request muss als `multipart/form-data` gesendet werden
                und kann Felder wie `name`, `description` oder ein neues `image` enthalten. Nur Felder, die angegeben werden, werden aktualisiert.
                
                **Ablauf:**
                - Gib die ID des zu aktualisierenden Posters als Pfadparameter `:posterId` an.
                - Senden Sie ein `UpdatePosterDTO` mit den zu ändernden Feldern. Nicht übergebene Felder bleiben unverändert.
                - Wird ein neues Bild übertragen, wird das alte Bild gelöscht und durch das neue ersetzt.
                - Die Route gibt ein `PosterResponseDTO` mit den aktualisierten Daten zurück.
                """,
            query:[],
            path: .type(Poster.IDValue.self),
            body: .type(UpdatePosterDTO.self),
            contentType: .multipart(.formData),
            response: .type(PosterResponseDTO.self),
            responseContentType: .application(.json)
        )
        
        let adminRoutesPoster = authProtected.grouped(adminMiddleware)
        adminRoutesPoster.delete(":id", use: deletePoster).openAPI(
            summary: "Löscht ein Poster",
            description: """
                Löscht ein vorhandenes Poster anhand seiner ID. Das zugehörige Bild wird ebenfalls entfernt.
                Des Weiteren werden auch die zugehörigen Poster Positionen gelöscht samt zugehöriger Bilder.
                **Ablauf:**
                - Gib die ID des zu löschenden Posters als Pfadparameter `:id` an.
                - Bei Erfolg wird ein HTTP-Status `204 No Content` zurückgegeben.
                """,
            query:[],
            path: .type(Poster.IDValue.self)
        )
        adminRoutesPoster.delete("batch", use: deletePosters).openAPI(
            summary: "Löscht mehrere Poster",
            description: """
                Löscht mehrere Poster anhand einer Liste von IDs. Die zugehörigen Bilder werden ebenfalls entfernt.
                Des Weiteren werden auch die zugehörigen Poster Positionen gelöscht samt zugehöriger Bilder.
                **Ablauf:**
                - Senden Sie ein `DeleteDTO` mit einem Array von Poster-IDs.
                - Falls eine oder mehrere IDs nicht gefunden werden, wird ein Fehler zurückgegeben.
                - Bei Erfolg wird ein HTTP-Status `204 No Content` zurückgegeben.
                """,            query:[],
            body: .type(DeleteDTO.self),
            contentType: .application(.json)
            
        )
        
        // PosterPosition-Routen
        let posterPositions = authProtected.grouped("positions")
        
        posterPositions.get(":positionId",use: getPostersPosition)
        
        posterPositions.get(use: getPostersPositions).openAPI(
            summary: "Poster Positionen abfragen",
            description: """
            Diese Route gibt eine Liste von Poster-Positionen zurück. Dabei können verschiedene Filter- und Paginierungsoptionen über Query-Parameter genutzt werden:
            
            - **Pagination**:  
              Über die Parameter `page` und `per` kann die Ausgabe paginiert werden, um nur einen Teil der Daten zurückzugeben.
            
            - **Status-Filter**:  
              Über den Query-Parameter `status` kann die Ausgabe auf bestimmte Kategorien von Poster-Positionen eingeschränkt werden. Mögliche Werte sind:
              - **hangs**: Gibt alle Poster-Positionen zurück, bei denen ein Poster bereits aufgehängt wurde, aber noch nicht abgenommen ist.
              - **toHang**: Gibt alle Positionen zurück, an denen noch kein Poster hängt und deren Verfallsdatum (expires_at) in der Zukunft liegt.
              - **overdue**: Zeigt alle Positionen, bei denen ein Poster hängt, deren Verfallsdatum jedoch bereits überschritten ist.
              - **takenDown**: Zeigt alle vergangenen Positionen.
            
              Wird kein `status`-Parameter übergeben, werden alle Kategorien (ausser takenDown) zusammen zurückgegeben.
            
            Das Ergebnis wird standardmäßig als JSON zurückgeliefert. Bei aktivierter Paginierung wird ein `PagedResponseDTO` mit Metadaten zu Seitenanzahl, aktueller Seite und Gesamtmenge an Items zurückgegeben. Ohne Paginierung erhält man ein einfaches Array von PosterPositionResponseDTO-Objekten.
            """,
            query:["page":.integer,"per":.integer,"status":.string],
            body: nil,
            response: .type(PosterPositionResponseDTO.self),
            responseContentType: .application(.json)
        )
        
        posterPositions.post(use: createPosterPosition).openAPI(
            summary: "Erstellt eine neue Poster-Position",
            description: """
                Erstellt eine neue Poster-Position mit optionalem Poster-Bezug, Koordinaten, Verantwortlichen und Ablaufdatum.
                Der Request muss als `multipart/form-data` gesendet werden und kann ein Bild enthalten.
                
                **Ablauf:**
                - Sende ein `CreatePosterPositionDTO` mit den erforderlichen Daten.
                - Bei Erfolg gibt die Route ein `PosterPositionResponseDTO` mit allen Details zurück.
                """,
            query:[],
            body: .type(CreatePosterPositionDTO.self),
            contentType: .application(.json),
            response: .type(PosterPositionResponseDTO.self),
            responseContentType: .application(.json)
        )
        
        posterPositions.put("hang", use: hangPosterPosition).openAPI(
            summary: "Hängt eine Poster-Position auf",
            description: """
                Markiert eine bestimmte Poster-Position als aufgehängt. Die Aktion wird als `multipart/form-data` gesendet, muss ein Bild enthalten und setzt `posted_at` sowie `posted_by`.
                
                **Ablauf:**
                - Sende ein `HangPosterPositionDTO` mit `image` und `poster_position`.
                - Das Bild mitschicken, um die aktuelle Ansicht zu dokumentieren.
                - Gibt ein `HangPosterPositionResponseDTO` mit `posted_at`, `posted_by` und der Positions-ID zurück.
                """,
            query:[],
            body: .type(HangPosterPositionDTO.self),
            contentType: .multipart(.formData),
            response: .type(HangPosterPositionResponseDTO.self),
            responseContentType: .application(.json)
        )
        
        posterPositions.put("take-down", use: takeDownPosterPosition).openAPI(
            summary: "Hängt eine Poster-Position ab",
            description: """
                Markiert eine bestimmte Poster-Position als abgehängt. Die Aktion wird als `multipart/form-data` gesendet, muss ein neues Bild enthalten und setzt `removed_at` sowie `removed_by`.
                
                **Ablauf:**
                - Senden Sie ein `TakeDownPosterPositionDTO` mit `user` und `poster_position`.
                - Optional ein Bild mitschicken, um den Zustand nach dem Abhängen zu dokumentieren.
                - Gibt ein `TakeDownPosterPositionResponseDTO` mit `removed_at`, `removed_by` und der Positions-ID zurück.
                """,
            query:[],
            body: .type(TakeDownPosterPositionDTO.self),
            contentType: .application(.json),
            response: .type(TakeDownPosterPositionResponseDTO.self),
            responseContentType: .application(.json)
        )
        
        
        let adminRoutesPosterPositions = posterPositions.grouped(adminMiddleware)
        adminRoutesPosterPositions.patch(":positionId", use: updatePosterPosition).openAPI(
            summary: "Aktualisiert eine bestehende Poster-Position",
            description: """
                Aktualisiert eine vorhandene Poster-Position anhand ihrer ID. Der Request muss als `multipart/form-data` gesendet werden.
                Nur die Felder, die im `UpdatePosterPositionDTO` gesetzt sind, werden aktualisiert. Neue Verantwortliche können hinzugefügt,
                bestehende entfernt und ein neues Bild hochgeladen werden (das alte wird dann gelöscht).
                
                **Ablauf:**
                - Pfadparameter `:positionId` für die ID der zu aktualisierenden Position angeben.
                - `UpdatePosterPositionDTO` im Body senden, nur die Felder setzen, die geändert werden sollen.
                - Bei Erfolg erhalten Sie ein aktualisiertes `PosterPositionResponseDTO`.
                """,
            query:[],
            path: .type(PosterPosition.IDValue.self),
            body: .type(UpdatePosterPositionDTO.self),
            contentType: .multipart(.formData),
            response: .type(PosterPositionResponseDTO.self),
            responseContentType: .application(.json)
        )
        
        adminRoutesPosterPositions.delete(":id", use: deletePosterPosition).openAPI(
            summary: "Löscht ein Poster",
            description: """
                Löscht eine vorhandene Poster-Position anhand ihrer ID. Das zugehörige Bild wird ebenfalls entfernt.
                
                **Ablauf:**
                - Geben Sie die ID der zu löschenden Poster-Position als Pfadparameter `:id` an.
                - Bei Erfolg wird ein HTTP-Status `204 No Content` zurückgegeben.
                """,            query:[],
            path: .type(PosterPosition.IDValue.self)
        )
        adminRoutesPosterPositions.delete("batch", use: deletePosterPositions).openAPI(
            summary: "Löscht mehrere Poster Positonen",
            description: """
                Löscht mehrere Poster-Positionen anhand einer übergebenen Liste von IDs. Die zugehörigen Bilder werden ebenfalls entfernt.
                
                **Ablauf:**
                - Senden Sie ein `DeleteDTO` mit einem Array von PosterPositions-IDs.
                - Falls eine oder mehrere IDs nicht gefunden werden, wird ein Fehler zurückgegeben.
                - Bei Erfolg wird ein HTTP-Status `204 No Content` zurückgegeben.
                """,
            query:[],
            body: .type(DeleteDTO.self),
            contentType: .application(.json)
        )
        let images = authProtected.grouped("images")
        // Bild-Routen
        images.get(":folder" ,":imageURL", use: getImageFile).openAPI(
            summary: "Gibt ein gespeichertes Bild zurück",
            description: """
            Diese Route gibt eine zuvor gespeicherte Bilddatei zurück.Der Pfadparameter imageURL gibt den relativen Speicherort bzw. Dateinamen an und der Pfadparameter folder, ob es sich um ein Poster oder Poster Position Bild handelt.
            
            **folder**
            - **Posters**: Sucht ein Bild eines Poster mit der übergebenen imageURL
            - **PosterPositions**: Sucht ein Bild einer POster Position mit der übergebenen imageURL
            """,
            path: ["folder": .string,"imageURL": .string],
            body: nil,
            responseContentType: .init("image/jpeg")
        )
    }
    
    // MARK: - Hilfsfunktionen
    
    /// Erstellt eine HTTP-Response mit JSON-Inhalt aus einem codierbaren DTO.
    @Sendable
    private func createResponse<T: Codable>(
        with dto: T,
        on req: Request,
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
        
        return Response(status: .ok, headers: headers, body: .init(data: responseData))
    }
    
    
    // Hilfsfunktion zum Mappen von PosterPosition in PosterPositionResponseDTO
    @Sendable
    private func posterPositionMapToDTO(_ positions: [PosterPosition], status: String) -> [PosterPositionResponseDTO] {
        return positions.map { position in
            let responsibleUsers = position.responsibilities.compactMap { $0.$user.id }
            return PosterPositionResponseDTO(
                id: position.id!,
                posterId: position.$poster.id,
                latitude: position.latitude,
                longitude: position.longitude,
                postedBy: position.$posted_by.id,
                postedAt: position.posted_at,
                expiresAt: position.expires_at!,
                removedBy: position.$removed_by.id,
                removedAt: position.removed_at,
                imageUrl: position.image_url,
                responsibleUsers: responsibleUsers,
                status: status
            )
        }
    }
    
    
    private func posterPositionMapToDTOSingle(_ position: PosterPosition, status: String) -> PosterPositionResponseDTO {
        let responsibleUsers = position.responsibilities.compactMap { $0.$user.id }
        return PosterPositionResponseDTO(
            id: position.id!,
            posterId: position.$poster.id,
            latitude: position.latitude,
            longitude: position.longitude,
            postedBy: position.$posted_by.id,
            postedAt: position.posted_at,
            expiresAt: position.expires_at!,
            removedBy: position.$removed_by.id,
            removedAt: position.removed_at,
            imageUrl: position.image_url,
            responsibleUsers: responsibleUsers,
            status: status
        )
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
        
        return try await createResponse(with: responseDTO, on: req)
    }
    
    @Sendable
    func getPoster(req: Request) async throws -> Response {
        guard let posterId = req.parameters.get("posterId", as: UUID.self) else {
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
    
    
    /// Aktualisiert ein bestehendes Poster (Name, Beschreibung und/oder Bild).
    @Sendable
    func updatePoster(req: Request) async throws -> Response {
        guard let posterId = req.parameters.get("posterId", as: UUID.self) else {
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
    
    
    // MARK: - PosterPosition-Routen
    /// Erstellt eine neue PosterPosition mit Bild und speichert sie in der Datenbank.
    @Sendable
    func createPosterPosition(req: Request) async throws -> Response {
        
        let dto = try req.content.decode(CreatePosterPositionDTO.self)
        
        // Plausibilitätsprüfungen für Koordinaten
        guard (-90...90).contains(dto.latitude) else {
            throw Abort(.badRequest, reason: "latitude muss zwischen -90 und 90 liegen.")
        }
        guard (-180...180).contains(dto.longitude) else {
            throw Abort(.badRequest, reason: "longitude muss zwischen -180 und 180 liegen.")
        }
        
        // Neue PosterPosition erstellen
        let posterPosition = PosterPosition(
            posterId: dto.posterId,
            latitude: dto.latitude,
            longitude: dto.longitude,
            expiresAt: dto.expiresAt
        )
        try await posterPosition.create(on: req.db)
        
        // 1) Vorher prüfen, welche User-IDs es wirklich gibt
        // ------------------------------------------------
        // a) User-IDs aus dem DTO sammeln
        let userIDs = dto.responsibleUsers
        
        // b) Über die User-Tabelle alle existierenden User laden
        let existingUsers = try await User.query(on: req.db)
            .filter(\.$id ~~ userIDs)    // alle User, deren ID in userIDs enthalten ist
            .all()
        
        // c) Die IDs aller gefundenen User extrahieren
        let existingUserIDs = Set(existingUsers.compactMap(\.id))
        
        // d) Nur die IDs behalten, die wirklich existieren
        let validUserIDs = userIDs.filter { existingUserIDs.contains($0) }
        
        // 2) Für jede gültige User-ID Responsibilities erstellen
        // ------------------------------------------------------
        for userId in validUserIDs {
            let responsibility = PosterPositionResponsibilities(
                userID: userId,
                posterPositionID: posterPosition.id!
            )
            try await responsibility.save(on: req.db)
        }
        
        // Verantwortliche Nutzer erneut laden, um sie in die Response aufzunehmen
        let responsibilities = try await PosterPositionResponsibilities.query(on: req.db)
            .filter(\.$poster_position.$id == posterPosition.id!)
            .all()
        let responsibleUserIds = responsibilities.compactMap { $0.$user.id }
        
        // PosterPositionResponseDTO erstellen
        let responseDTO = PosterPositionResponseDTO(
            id: posterPosition.id!,
            posterId: posterPosition.$poster.id,
            latitude: posterPosition.latitude,
            longitude: posterPosition.longitude,
            postedBy: posterPosition.$posted_by.id,
            postedAt: posterPosition.posted_at,
            expiresAt: posterPosition.expires_at!,
            removedBy: posterPosition.$removed_by.id,
            removedAt: posterPosition.removed_at,
            imageUrl: posterPosition.image_url,
            responsibleUsers: responsibleUserIds,
            status: "Created"
        )
        
        return try await createResponse(with: responseDTO, on: req)
    }
    
    @Sendable
    func getPostersPosition(req: Request) async throws -> Response {
        guard let positionId = req.parameters.get("positionId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Position-ID.")
        }
        guard let position = try await PosterPosition.query(on: req.db)
            .with(\.$responsibilities)
            .filter(\.$id == positionId)
            .first()
        else {
            throw Abort(.notFound, reason: "PosterPosition nicht gefunden.")
        }
        let response = posterPositionMapToDTOSingle(position,status: "Details")
        
        return try await createResponse(with: response, on: req)
    }
    
    /// Gibt alle angezeigten oder nicht angezeigten PosterPositionen zurück.
    /// Parameter `displayed` in der Query bestimmt, ob nur angezeigte oder nicht angezeigte zurückgegeben werden.
    @Sendable
    func getPostersPositions(req: Request) async throws -> Response {
        let statusQuery = try? req.query.get(String.self, at: "status")
        let page = try? req.query.get(Int.self, at: "page")
        let per = try? req.query.get(Int.self, at: "per")
        
        
        let currentDate = Date()
        
        // Abhängig von statusQuery unterschiedlichen Code ausführen
        switch statusQuery {
        case "hangs":
            // hangs: posted_by != nil und removed_by == nil und nach expires_at sortieren
            let query = PosterPosition.query(on: req.db)
                .with(\.$responsibilities)
                .filter(\.$posted_by.$id != nil)
                .filter(\.$removed_by.$id == nil)
                .sort(\.$expires_at, .ascending)
            
            if let page = page, let per = per {
                // Paginieren über die Datenbank
                let paginatedData = try await query.paginate(PageRequest(page: page, per: per))
                let response = posterPositionMapToDTO(paginatedData.items, status: "hangs")
                
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
                // Ohne Paginierung
                let positions = try await query.all()
                let response = posterPositionMapToDTO(positions, status: "hangs")
                return try await createResponse(with: response, on: req)
            }
            
        case "toHang":
            // toHang: posted_by == nil && expires_at > currentDate
            let query = PosterPosition.query(on: req.db)
                .with(\.$responsibilities)
                .filter(\.$posted_by.$id == nil)
                .sort(\.$expires_at, .ascending)
            
            if let page = page, let per = per {
                let paginatedData = try await query.paginate(PageRequest(page: page, per: per))
                let response = posterPositionMapToDTO(paginatedData.items, status: "toHang")
                
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
                // Ohne Paginierung
                let positions = try await query.all()
                let response = posterPositionMapToDTO(positions, status: "toHang")
                return try await createResponse(with: response, on: req)
            }
            
        case "overdue":
            // overdue: posted_by != nil, removed_by == nil, expires_at <= currentDate
            let query = PosterPosition.query(on: req.db)
                .with(\.$responsibilities)
                .filter(\.$posted_by.$id != nil)
                .filter(\.$removed_by.$id == nil)
                .filter(\.$expires_at <= currentDate)
                .sort(\.$expires_at, .ascending)
            
            if let page = page, let per = per {
                let paginatedData = try await query.paginate(PageRequest(page: page, per: per))
                let response = posterPositionMapToDTO(paginatedData.items, status: "overdue")
                
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
                // Ohne Paginierung
                let positions = try await query.all()
                let response = posterPositionMapToDTO(positions, status: "overdue")
                return try await createResponse(with: response, on: req)
            }
            
        case "takenDown":
            let query = PosterPosition.query(on: req.db)
                .with(\.$responsibilities)
                .filter(\.$removed_by.$id != nil)
                .sort(\.$expires_at, .ascending)
            
            if let page = page, let per = per {
                let paginatedData = try await query.paginate(PageRequest(page: page, per: per))
                let response = posterPositionMapToDTO(paginatedData.items, status: "takenDown")
                
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
                // Ohne Paginierung
                let positions = try await query.all()
                let response = posterPositionMapToDTO(positions, status: "takenDown")
                return try await createResponse(with: response, on: req)
            }
        default:
            let hangsQuery = PosterPosition.query(on: req.db)
                .with(\.$responsibilities)
                .filter(\.$posted_by.$id != nil)
                .filter(\.$removed_by.$id == nil)
                .sort(\.$expires_at, .ascending)
            let toHangQuery = PosterPosition.query(on: req.db)
                .with(\.$responsibilities)
                .filter(\.$posted_by.$id == nil)
                .filter(\.$expires_at > currentDate)
                .sort(\.$expires_at, .ascending)
            let overdueQuery = PosterPosition.query(on: req.db)
                .with(\.$responsibilities)
                .filter(\.$posted_by.$id != nil)
                .filter(\.$removed_by.$id == nil)
                .filter(\.$expires_at <= currentDate)
                .sort(\.$expires_at, .ascending)
            
            let (hangsPositions, toHangPositions, overduePositions) = try await (
                hangsQuery.all(),
                toHangQuery.all(),
                overdueQuery.all()
            )
            
            let hangsDTOs = posterPositionMapToDTO(hangsPositions, status: "hangs")
            let toHangDTOs = posterPositionMapToDTO(toHangPositions, status: "toHang")
            let overdueDTOs = posterPositionMapToDTO(overduePositions, status: "overdue")
            
            let combined = hangsDTOs + toHangDTOs + overdueDTOs
            
            // Wenn page und per gesetzt sind, manuelle Pagination im Speicher
            if let page = page, let per = per {
                let (pagedItems, totalItems) = paginate(combined, page: page, per: per)
                let totalPages = Int((Double(totalItems) / Double(per)).rounded(.up))
                
                
                var headers = HTTPHeaders()
                headers.contentType = .json
                headers.add(name: "Pagnation-Current-Page", value: "\(page)")
                headers.add(name: "Pagnation-Per-Page", value: "\(per)")
                headers.add(name: "Pagnation-Total-Items", value: "\(totalItems)")
                headers.add(name: "Pagnation-Total-Pages", value: "\(totalPages)")
                
                return try await createResponse(with: pagedItems, on: req, additionalHeaders: headers)
            } else {
                // Ohne Paginierung
                return try await createResponse(with: combined, on: req)
            }
        }
    }
    
    
    /// Aktualisiert eine vorhandene PosterPosition (Location, Anzeigezustand, Ablaufdatum, Verantwortlicher, Poster-ID, Bild).
    @Sendable
    func updatePosterPosition(req: Request) async throws -> Response {
        guard let positionId = req.parameters.get("positionId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Position-ID.")
        }
        
        guard let contentType = req.headers.contentType,
              contentType.type == "multipart",
              contentType.subType == "form-data" else {
            throw Abort(.unsupportedMediaType, reason: "Erwartet multipart/form-data")
        }
        
        let dto = try req.content.decode(UpdatePosterPositionDTO.self)
        
        guard let position = try await PosterPosition.find(positionId, on: req.db) else {
            throw Abort(.notFound, reason: "PosterPosition nicht gefunden.")
        }
        
        // Nur updaten, was im DTO vorhanden ist (nicht-nil)
        if let newLatitude = dto.latitude {
            position.latitude = round(newLatitude * 1_000_000) / 1_000_000
        }
        
        if let newLongitude = dto.longitude {
            position.longitude = round(newLongitude * 1_000_000) / 1_000_000
        }
        
        if let newExpiresAt = dto.expiresAt {
            position.expires_at = newExpiresAt
        }
        
        if let newPosterId = dto.posterId {
            position.$poster.id = newPosterId
        }
        
        // Verantwortlichkeiten updaten, nur wenn übergeben
        if let newResponsibleUsers = dto.responsible_users {
            // Aktuelle Verantwortlichkeiten laden
            let currentResponsibilities = try await PosterPositionResponsibilities.query(on: req.db)
                .filter(\.$poster_position.$id == positionId)
                .all()
            
            let currentUserIds = Set(currentResponsibilities.compactMap { $0.$user.id })
            let newUserIds = Set(newResponsibleUsers)
            
            // Hinzufügen, was neu ist
            let toAdd = newUserIds.subtracting(currentUserIds)
            for userId in toAdd {
                let responsibility = PosterPositionResponsibilities(userID: userId, posterPositionID: positionId)
                try await responsibility.save(on: req.db)
            }
            
            // Entfernen, was nicht mehr gebraucht wird
            let toRemove = currentUserIds.subtracting(newUserIds)
            if !toRemove.isEmpty {
                try await PosterPositionResponsibilities.query(on: req.db)
                    .filter(\.$poster_position.$id == positionId)
                    .filter(\.$user.$id ~~ toRemove) // Enthält eine der userIds
                    .delete()
            }
        }
        
        // Bild updaten, falls übergeben
        if let newImage = dto.image {
            // Altes Bild löschen, wenn vorhanden
            if let oldImageUrl = position.image_url {
                let oldFilePath = req.application.directory.workingDirectory + "Storage/Images/PosterPositions/" + oldImageUrl
                do {
                    try FileManager.default.removeItem(atPath: oldFilePath)
                } catch {
                    req.logger.warning("Altes Bild konnte nicht gelöscht werden: \(error)")
                }
            }
            
            // Neues Bild speichern
            let imageUrl = try await saveImage(newImage, in: "Storage/Images/PosterPositions", on: req)
            position.image_url = imageUrl
        }
        
        
        // Position in der DB updaten
        try await position.update(on: req.db)
        
        // Neu geladene Verantwortlichkeiten für Response
        let updatedResponsibilities = try await PosterPositionResponsibilities.query(on: req.db)
            .filter(\.$poster_position.$id == positionId)
            .all()
        let responsibleUserIds = updatedResponsibilities.compactMap { $0.$user.id }
        
        
        let responseDTO = PosterPositionResponseDTO(
            id: position.id!,
            posterId: position.$poster.id,
            latitude: position.latitude,
            longitude: position.longitude,
            postedBy: position.$posted_by.id,
            postedAt: position.posted_at,
            expiresAt: position.expires_at!,
            removedBy: position.$removed_by.id,
            removedAt: position.removed_at,
            imageUrl: position.image_url,
            responsibleUsers: responsibleUserIds,
            status: "Updated"
        )
        
        return try await createResponse(with: responseDTO, on: req)
    }
    
    @Sendable
    func hangPosterPosition(req: Request) async throws -> Response {
        
        // Content-Type checken
        guard let contentType = req.headers.contentType,
              contentType.type == "multipart",
              contentType.subType == "form-data" else {
            req.logger.error("Unsupported media type. Got \(String(describing: req.headers.contentType))")
            throw Abort(.unsupportedMediaType, reason: "Erwartet multipart/form-data")
        }
        
        // User aus JWT laden
        guard let userId = req.jwtPayload?.userID else {
            req.logger.error("No userID found in JWT. Aborting.")
            throw Abort(.unauthorized)
        }
        
        // DTO decoden
        let dto = try req.content.decode(HangPosterPositionDTO.self)
        
        // PosterPosition laden
        guard let position = try await PosterPosition.find(dto.posterPosition, on: req.db) else {
            req.logger.warning("PosterPosition with ID \(dto.posterPosition) not found in DB.")
            throw Abort(.notFound, reason: "PosterPosition nicht gefunden.")
        }
        
        // Responsibilities laden
        let responsibilities = try await position.$responsibilities.query(on: req.db).all()
        
        
        // Check: Ist der User in responsibilities?
        guard responsibilities.contains(where: { $0.$user.id == userId }) else {
            req.logger.warning("User \(userId) is not in responsibilities for position \(String(describing: position.id)).")
            throw Abort(.forbidden, reason: "Sie sind nicht verantwortlich für diese PosterPosition.")
        }
        
        
        // Check: Bereits aufgehängt?
        if position.$posted_by.id != nil || position.posted_at != nil {
            req.logger.warning("PosterPosition (ID \(String(describing: position.id))) is already posted.")
            throw Abort(.badRequest, reason: "Diese PosterPosition ist bereits aufgehängt worden.")
        }
        
        // Identity laden
        let identity = try await Identity.byUserId(userId, req.db)
        
        
        
        let imageData = dto.image
        
        let imageUrl = try await saveImage(imageData, in: "Storage/Images/PosterPositions", on: req)
        
        
        // Position updaten
        position.image_url = imageUrl
        position.posted_at = Date()
        position.$posted_by.id = identity.id
        
        
        try await position.update(on: req.db)
        
        // Response erstellen
        let responseDTO = HangPosterPositionResponseDTO(
            posterPosition: position.id!,
            postedAt: position.posted_at!,
            postedBy: position.$posted_by.id!,
            imageUrl: position.image_url!
        )
        
        return try await createResponse(with: responseDTO, on: req)
    }
    
    @Sendable
    func takeDownPosterPosition(req: Request) async throws -> Response {
        
        guard let contentType = req.headers.contentType,
              contentType.type == "multipart",
              contentType.subType == "form-data" else {
            throw Abort(.unsupportedMediaType, reason: "Erwartet multipart/form-data")
        }
        
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        
        let dto = try req.content.decode(TakeDownPosterPositionDTO.self)
        
        guard let position = try await PosterPosition.find(dto.posterPosition, on: req.db) else {
            throw Abort(.notFound, reason: "PosterPosition nicht gefunden.")
        }
        
        let responsibilities = try await position.$responsibilities.query(on: req.db).all()
        
        guard responsibilities.contains(where: { $0.$user.id == userId }) else {
            throw Abort(.forbidden, reason: "Sie sind nicht verantwortlich für diese PosterPosition.")
        }
        
        if position.$removed_by.id != nil || position.removed_at != nil {
            throw Abort(.badRequest, reason: "Diese PosterPosition ist bereits abgehängt worden.")
        }
        
        let identity = try await Identity.byUserId(userId, req.db)
        
        let imageData = dto.image
        if let oldImageUrl = position.image_url {
            let oldFilePath = req.application.directory.workingDirectory + "Storage/Images/PosterPositions/"  + oldImageUrl
            do {
                try FileManager.default.removeItem(atPath: oldFilePath)
            } catch {
                req.logger.warning("Altes Bild konnte nicht gelöscht werden: \(error)")
            }
        }
        let imageUrl = try await saveImage(imageData, in: "Storage/Images/PosterPositions", on: req)
        
        position.image_url = imageUrl
        position.removed_at = Date()
        position.$removed_by.id = identity.id
        
        try await position.update(on: req.db)
        
        let responseDTO = TakeDownPosterPositionResponseDTO(
            posterPosition: position.id!,
            removedAt: position.removed_at!,
            removedBy: position.$removed_by.id!,
            imageUrl: position.image_url!
        )
        
        return try await createResponse(with: responseDTO, on: req)
    }
    
    
    /// Löscht eine einzelne PosterPosition und deren zugehörige Bilddatei.
    @Sendable
    func deletePosterPosition(req: Request) async throws -> HTTPStatus {
        guard let positionID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige PosterPosition-ID.")
        }
        
        guard let position = try await PosterPosition.find(positionID, on: req.db) else {
            throw Abort(.notFound, reason: "PosterPosition mit der ID \(positionID) wurde nicht gefunden.")
        }
        
        let imageUrl = position.image_url
        
        if let url = imageUrl {
            let filePath = req.application.directory.workingDirectory + "Storage/Images/PosterPositions/" + url
            
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: filePath)
            } catch {
                req.logger.error("Fehler beim Löschen der Bilddatei: \(error.localizedDescription)")
                throw Abort(.internalServerError, reason: "Fehler beim Löschen der Bilddatei für PosterPosition-ID \(positionID)")
            }
        }
        
        
        try await position.delete(on: req.db)
        return .noContent
    }
    
    /// Löscht mehrere PosterPositionen und deren zugehörige Bilddateien in einem Batch.
    @Sendable
    func deletePosterPositions(req: Request) async throws -> HTTPStatus {
        let deleteDTO = try req.content.decode(DeleteDTO.self)
        let positionIDs = deleteDTO.ids
        
        guard !positionIDs.isEmpty else {
            throw Abort(.badRequest, reason: "Es müssen mindestens eine PosterPosition-ID übergeben werden.")
        }
        
        let positionsToDelete = try await PosterPosition.query(on: req.db)
            .filter(\.$id ~~ positionIDs)
            .all()
        
        if positionsToDelete.count != positionIDs.count {
            let foundIDs = Set(positionsToDelete.compactMap { $0.id })
            let notFoundIDs = positionIDs.filter { !foundIDs.contains($0) }
            throw Abort(.notFound, reason: "PosterPositionen mit den folgenden IDs wurden nicht gefunden: \(notFoundIDs.map { $0.uuidString }.joined(separator: ", "))")
        }
        
        try await req.db.transaction { database in
            let fileManager = FileManager.default
            for position in positionsToDelete {
                let imageUrl = position.image_url
                if let url = imageUrl{
                    let filePath = req.application.directory.workingDirectory + "Storage/Images/PosterPositions/" + url
                    
                    do {
                        try fileManager.removeItem(atPath: filePath)
                    } catch {
                        req.logger.error("Fehler beim Löschen der Bilddatei für PosterPosition-ID \(position.id?.uuidString ?? "Unbekannt"): \(error.localizedDescription)")
                        throw Abort(.internalServerError, reason: "Fehler beim Löschen der Bilddatei für PosterPosition-ID \(position.id?.uuidString ?? "Unbekannt")")
                    }
                }
                
                try await position.delete(on: database)
            }
        }
        
        return .noContent
    }
    
    // MARK: - Bild-Handling
    
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
        
        print(imagePath)
        
        guard FileManager.default.fileExists(atPath: imagePath) else {
            throw Abort(.notFound, reason: "Bilddatei nicht gefunden")
        }
        
        return req.fileio.streamFile(at: imagePath)
    }
    
    
    
}
