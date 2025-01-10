import Fluent
import Vapor
import Foundation
import Models
import VaporToOpenAPI


// MARK: - PosterController

/// Controller für Poster und PosterPositionen.
/// Dieser Controller enthält Routen zum Erstellen, Aktualisieren, Löschen und Abrufen von Postern und deren Positionen.
struct PosterPositionController: RouteCollection, Sendable {
    
    let adminMiddleware: Middleware
    
    /// Initialisiert den `PosterPositionController` mit Admin-Middleware.
    
    init() throws {
        self.adminMiddleware = AdminMiddleware()
    }
    
    /// Registriert alle Routen des Controllers.
    func boot(routes: RoutesBuilder) throws {
        let openAPITagPosterPosition = TagObject(name: "Poster Position")
        
        routes.group(":id") { poster in
            // Spezifischere Route zuerst: /posters/:id/positions
            poster.group("positions") { positions in
                // GET /posters/:id/positions/:positionid
                positions.get(":positionid", use: getPostersPosition).openAPI(
                    tags: openAPITagPosterPosition,
                    summary: "Gibt eine einzelne Poster Position zurück",
                    description: """
                            Diese Route gibt eine Poster-Position zurück mit dem zugehörigen Status.
                            """,
                    path: .type(PosterPosition.IDValue.self),
                    body: nil,
                    response: .type(PosterPositionResponseDTO.self),
                    responseContentType: .application(.json),
                    auth: .bearer()
                )
                
                // GET /posters/:id/positions
                positions.get(use: getPostersPositions).openAPI(
                    tags: openAPITagPosterPosition,
                    summary: "Poster Positionen abfragen",
                    description: """
                            Diese Route gibt eine Liste von Poster-Positionen zurück. Dabei können verschiedene Filter- und Paginierungsoptionen über Query-Parameter genutzt werden:
                            
                            - **Pagination**:  
                              Über die Parameter `page` und `per` kann die Ausgabe paginiert werden, um nur einen Teil der Daten zurückzugeben.
                            
                            - **Status-Filter**:  
                              Über den Query-Parameter `status` kann die Ausgabe auf bestimmte Kategorien von Poster-Positionen eingeschränkt werden. Mögliche Werte sind:
                              - **hangs**: Gibt alle Poster-Positionen zurück, bei denen ein Poster bereits aufgehängt wurde, aber noch nicht abgenommen ist.
                              - **tohang**: Gibt alle Positionen zurück, an denen noch kein Poster hängt und deren Verfallsdatum (expires_at) in der Zukunft liegt.
                              - **overdue**: Zeigt alle Positionen, bei denen ein Poster hängt, deren Verfallsdatum jedoch bereits überschritten ist.
                              - **takendown**: Zeigt alle vergangenen Positionen.
                            
                              Wird kein `status`-Parameter übergeben, werden alle Kategorien (ausser takenDown) zusammen zurückgegeben.
                            
                            Das Ergebnis wird standardmäßig als JSON zurückgeliefert. Bei aktivierter Paginierung wird ein `PagedResponseDTO` mit Metadaten zu Seitenanzahl, aktueller Seite und Gesamtmenge an Items zurückgegeben. Ohne Paginierung erhält man ein einfaches Array von PosterPositionResponseDTO-Objekten.
                            """,
                    query: ["page": .integer, "per": .integer, "status": .string],
                    body: nil,
                    response: .type(PosterPositionResponseDTO.self),
                    responseContentType: .application(.json),
                    auth: .bearer()
                )
                
                // PUT /posters/:id/positions/hang
                positions.put("hang", use: hangPosterPosition).openAPI(
                    tags: openAPITagPosterPosition,
                    summary: "Hängt eine Poster-Position auf",
                    description: """
                                Markiert eine bestimmte Poster-Position als aufgehängt. Die Aktion wird als `multipart/form-data` gesendet, muss ein Bild enthalten und setzt `posted_at` sowie `posted_by`.
                                
                                **Ablauf:**
                                - Sende ein `HangPosterPositionDTO` mit `image` und `poster_position`.
                                - Das Bild mitschicken, um die aktuelle Ansicht zu dokumentieren.
                                - Gibt ein `HangPosterPositionResponseDTO` mit `posted_at`, `posted_by` und der Positions-ID zurück.
                                """,
                    query: [],
                    body: .type(HangPosterPositionDTO.self),
                    contentType: .multipart(.formData),
                    response: .type(HangPosterPositionResponseDTO.self),
                    responseContentType: .application(.json),
                    auth: .bearer()
                )
                
                // PUT /posters/:id/positions/take-down
                positions.put("take-down", use: takeDownPosterPosition).openAPI(
                    tags: openAPITagPosterPosition,
                    summary: "Hängt eine Poster-Position ab",
                    description: """
                                Markiert eine bestimmte Poster-Position als abgehängt. Die Aktion wird als `multipart/form-data` gesendet, muss ein neues Bild enthalten und setzt `removed_at` sowie `removed_by`.
                                
                                **Ablauf:**
                                - Senden Sie ein `TakeDownPosterPositionDTO` mit `user` und `poster_position`.
                                - Optional ein Bild mitschicken, um den Zustand nach dem Abhängen zu dokumentieren.
                                - Gibt ein `TakeDownPosterPositionResponseDTO` mit `removed_at`, `removed_by` und der Positions-ID zurück.
                                """,
                    query: [],
                    body: .type(TakeDownPosterPositionDTO.self),
                    contentType: .application(.json),
                    response: .type(TakeDownPosterPositionResponseDTO.self),
                    responseContentType: .application(.json),
                    auth: .bearer()
                )
                
                // Admin-geschützte Routen innerhalb von /posters/:id/positions
                let adminRoutesPosterPositions = positions.grouped(adminMiddleware)
                
                // POST /posters/:id/positions (admin)
                adminRoutesPosterPositions.post(use: createPosterPosition).openAPI(
                    tags: openAPITagPosterPosition,
                    summary: "Erstellt eine neue Poster-Position",
                    description: """
                                Erstellt eine neue Poster-Position mit Poster-Bezug, Koordinaten, Verantwortlichen und Ablaufdatum.
                                Die Request kann nur von einem Admin erstellt werden.
                                
                                **Ablauf:**
                                - Sende ein `CreatePosterPositionDTO` mit den erforderlichen Daten.
                                - Bei Erfolg gibt die Route ein `PosterPositionResponseDTO` mit allen Details zurück.
                                """,
                    query: [],
                    body: .type(CreatePosterPositionDTO.self),
                    contentType: .application(.json),
                    response: .type(PosterPositionResponseDTO.self),
                    responseContentType: .application(.json),
                    auth: .bearer()
                )
                
                // PATCH /posters/:id/positions/:positionid (admin)
                adminRoutesPosterPositions.patch(":positionid", use: updatePosterPosition).openAPI(
                    tags: openAPITagPosterPosition,
                    summary: "Aktualisiert eine bestehende Poster-Position",
                    description: """
                                Aktualisiert eine vorhandene Poster-Position anhand ihrer ID. Der Request muss als `multipart/form-data` gesendet werden.
                                Nur die Felder, die im `UpdatePosterPositionDTO` gesetzt sind, werden aktualisiert. Neue Verantwortliche können hinzugefügt,
                                bestehende entfernt und ein neues Bild hochgeladen werden (das alte wird dann gelöscht).
                                Die Request kann nur von einem Admin erstellt werden.
                                
                                **Ablauf:**
                                - Pfadparameter `:positionId` für die ID der zu aktualisierenden Position angeben.
                                - `UpdatePosterPositionDTO` im Body senden, nur die Felder setzen, die geändert werden sollen.
                                - Bei Erfolg erhalten Sie ein aktualisiertes `PosterPositionResponseDTO`.
                                """,
                    query: [],
                    path: .type(PosterPosition.IDValue.self),
                    body: .type(UpdatePosterPositionDTO.self),
                    contentType: .multipart(.formData),
                    response: .type(PosterPositionResponseDTO.self),
                    responseContentType: .application(.json),
                    auth: .bearer()
                )
                
                // DELETE /posters/:id/positions/:positionid (admin)
                adminRoutesPosterPositions.delete(":positionid", use: deletePosterPosition).openAPI(
                    tags: openAPITagPosterPosition,
                    summary: "Löscht ein Poster",
                    description: """
                                Löscht eine vorhandene Poster-Position anhand ihrer ID. Das zugehörige Bild wird ebenfalls entfernt.
                                Die Request kann nur von einem Admin erstellt werden.
                                
                                **Ablauf:**
                                - Geben Sie die ID der zu löschenden Poster-Position als Pfadparameter `:id` an.
                                - Bei Erfolg wird ein HTTP-Status `204 No Content` zurückgegeben.
                                """,
                    query: [],
                    path: .type(PosterPosition.IDValue.self),
                    statusCode: .noContent,
                    auth: .bearer()
                )
                
                // DELETE /posters/:id/positions/batch (admin)
                adminRoutesPosterPositions.delete("batch", use: deletePosterPositions).openAPI(
                    tags: openAPITagPosterPosition,
                    summary: "Löscht mehrere Poster Positonen",
                    description: """
                                Löscht mehrere Poster-Positionen anhand einer übergebenen Liste von IDs. Die zugehörigen Bilder werden ebenfalls entfernt.
                                Die Request kann nur von einem Admin erstellt werden.                
                                **Ablauf:**
                                - Senden Sie ein `DeleteDTO` mit einem Array von PosterPositions-IDs.
                                - Falls eine oder mehrere IDs nicht gefunden werden, wird ein Fehler zurückgegeben.
                                - Bei Erfolg wird ein HTTP-Status `204 No Content` zurückgegeben.
                                """,
                    query: [],
                    body: .type(DeleteDTO.self),
                    contentType: .application(.json),
                    statusCode: .noContent,
                    auth: .bearer()
                )
            }
            
        }
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
    
    
    // MARK: - PosterPosition-Routen
    /// Erstellt eine neue PosterPosition mit Bild und speichert sie in der Datenbank.
    @Sendable
    func createPosterPosition(req: Request) async throws -> Response {
        
        let dto = try req.content.decode(CreatePosterPositionDTO.self)
        
        guard let posterId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Poster-ID.")
        }
        
        // Plausibilitätsprüfungen für Koordinaten
        guard (-90...90).contains(dto.latitude) else {
            throw Abort(.badRequest, reason: "Latitude muss zwischen -90 und 90 liegen.")
        }
        guard (-180...180).contains(dto.longitude) else {
            throw Abort(.badRequest, reason: "Longitude muss zwischen -180 und 180 liegen.")
        }
        
        // Neue PosterPosition erstellen
        let posterPosition = PosterPosition(
            posterId: posterId,
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
            .filter(\.$id ~~ userIDs)    // Alle User, deren ID in userIDs enthalten ist
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
            .with(\.$user) { user in
                user.with(\.$identity) // Eager load Identity-Beziehung des Users
            }
            .all()
        
        let responsibleUsers = responsibilities.compactMap { responsibility -> ResponsibleUsersDTO? in
            let user = responsibility.user // Zugriff auf den geladenen User
            let identityName = user.identity.name // Zugriff auf den geladenen Identity-Namen
            return ResponsibleUsersDTO(
                id: user.id!,
                name: identityName
            )
        }

        // PosterPositionResponseDTO erstellen
        let responseDTO = PosterPositionResponseDTO(
            id: posterPosition.id!,
            posterId: posterPosition.$poster.id,
            latitude: posterPosition.latitude,
            longitude: posterPosition.longitude,
            postedBy: posterPosition.posted_by?.name,
            postedAt: posterPosition.posted_at,
            expiresAt: posterPosition.expires_at!,
            removedBy: posterPosition.removed_by?.name,
            removedAt: posterPosition.removed_at,
            imageUrl: posterPosition.image_url,
            responsibleUsers: responsibleUsers,
            status: "Created"
        )
        
        return try await createResponse(with: responseDTO, on: req, status: .created)
    }
    
    @Sendable
    func getPostersPosition(req: Request) async throws -> Response {
        // Schritt 1: Position ID aus den Parametern abrufen
        guard let positionId = req.parameters.get("positionid", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Position-ID.")
        }
        
        // Schritt 2: PosterPosition mit allen notwendigen Beziehungen abrufen
        let position = try await PosterPosition.query(on: req.db)
            .with(\.$responsibilities) { responsibilities in
                responsibilities.with(\.$user) { user in
                    user.with(\.$identity) // Eager load Identity-Beziehung des Users
                }
            }
            .with(\.$posted_by) // Eager load posted_by Beziehung
            .with(\.$removed_by) // Eager load removed_by Beziehung
            .filter(\.$id == positionId)
            .first()
        if (position == nil){
            throw Abort(.notFound, reason: "PosterPosition nicht gefunden")
        }
        
        // Schritt 3: Status basierend auf den Beziehungen bestimmen
        var status = ""
        let currentDate = Date()
        
        if (position!.posted_by != nil && position!.removed_by == nil) {
            status = "hangs"
        } else if (position!.posted_by == nil) {
            status = "toHang"
        } else if (position!.removed_by != nil) {
            status = "takenDown"
        }
        
        if (position!.posted_by != nil &&
            position!.removed_by == nil &&
            position!.expires_at! <= currentDate) {
            status = "overdue"
        }
        
        // Schritt 4: Mapping zur DTO
        let response = position?.posterPositionMapToDTO(status)
        
        // Schritt 5: Antwort erstellen und zurückgeben
        return try await createResponse(with: response, on: req)
    }
    
    
    /// Gibt alle angezeigten oder nicht angezeigten PosterPositionen zurück.
    /// Parameter `displayed` in der Query bestimmt, ob nur angezeigte oder nicht angezeigte zurückgegeben werden.
    @Sendable
    func getPostersPositions(req: Request) async throws -> Response {
        // 1. Extrahiere die posterid aus den Routenparametern
        guard let posterId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Poster-ID.")
        }
        
        // 2. Extrahiere die Query-Parameter für Pagination und Status
        let statusQuery = try? req.query.get(String.self, at: "status")
        let page = try? req.query.get(Int.self, at: "page")
        let per = try? req.query.get(Int.self, at: "per")
        
        let currentDate = Date()
        
        // 3. Hilfsfunktion zur Handhabung von Paginierung und Headern
        func handlePagination(
            query: QueryBuilder<PosterPosition>,
            status: String,
            page: Int?,
            per: Int?
        ) async throws -> Response {
            if let page = page, let per = per {
                let paginatedData = try await query.paginate(PageRequest(page: page, per: per))
                
                let response = paginatedData.items.map{$0.posterPositionMapToDTO(status)}
                let currentPage = paginatedData.metadata.page
                let perPage = paginatedData.metadata.per
                let totalItems = paginatedData.metadata.total
                let totalPages = Int((Double(totalItems) / Double(perPage)).rounded(.up))
                
                var headers = HTTPHeaders()
                headers.contentType = .json
                headers.add(name: "Pagination-Current-Page", value: "\(currentPage)")
                headers.add(name: "Pagination-Per-Page", value: "\(perPage)")
                headers.add(name: "Pagination-Total-Items", value: "\(totalItems)")
                headers.add(name: "Pagination-Total-Pages", value: "\(totalPages)")
                
                return try await createResponse(with: response, on: req, additionalHeaders: headers)
            } else {
                // Ohne Paginierung
                let positions = try await query.all()
                let response = positions.map{$0.posterPositionMapToDTO(status)}
                return try await createResponse(with: response, on: req)
            }
        }
        
        // 4. Switch über statusQuery mit posterId-Filter
        switch statusQuery?.lowercased() {
        case "hangs":
            // Hangs: posted_by != nil && removed_by == nil && poster_id == posterId, sort by expires_at ascending
            let query = PosterPosition.query(on: req.db)
                .filter(\.$poster.$id == posterId)
                .with(\.$responsibilities) { responsibilities in
                    responsibilities.with(\.$user) { user in
                        user.with(\.$identity) // Eager load Identity-Beziehung des Users
                    }
                }
                .with(\.$posted_by)
                .with(\.$removed_by)
                .filter(\.$posted_by.$id != nil)
                .filter(\.$removed_by.$id == nil)
                .sort(\.$expires_at, .ascending)
            
            
            return try await handlePagination(query: query, status: "hangs", page: page, per: per)
            
        case "tohang":
            // ToHang: posted_by == nil && expires_at > currentDate && poster_id == posterId, sort by expires_at ascending
            let query = PosterPosition.query(on: req.db)
                .filter(\.$poster.$id == posterId)
                .with(\.$responsibilities) { responsibilities in
                    responsibilities.with(\.$user) { user in
                        user.with(\.$identity) // Eager load Identity-Beziehung des Users
                    }
                }
                .with(\.$posted_by)
                .with(\.$removed_by)
                .filter(\.$posted_by.$id == nil)
                .filter(\.$expires_at > currentDate)
                .sort(\.$expires_at, .ascending)
            
            return try await handlePagination(query: query, status: "toHang", page: page, per: per)
            
        case "overdue":
            // Overdue: posted_by != nil && removed_by == nil && expires_at <= currentDate && poster_id == posterId, sort by expires_at ascending
            let query = PosterPosition.query(on: req.db)
                .filter(\.$poster.$id == posterId)
                .with(\.$responsibilities) { responsibilities in
                    responsibilities.with(\.$user) { user in
                        user.with(\.$identity) // Eager load Identity-Beziehung des Users
                    }
                }
                .with(\.$posted_by)
                .with(\.$removed_by)
                .filter(\.$posted_by.$id != nil)
                .filter(\.$removed_by.$id == nil)
                .filter(\.$expires_at <= currentDate)
                .sort(\.$expires_at, .ascending)
            
            return try await handlePagination(query: query, status: "overdue", page: page, per: per)
            
        case "takendown":
            // TakenDown: removed_by != nil && poster_id == posterId, sort by expires_at ascending
            let query = PosterPosition.query(on: req.db)
                .filter(\.$poster.$id == posterId)
                .with(\.$responsibilities) { responsibilities in
                    responsibilities.with(\.$user) { user in
                        user.with(\.$identity) // Eager load Identity-Beziehung des Users
                    }
                }
                .with(\.$posted_by)
                .with(\.$removed_by)
                .filter(\.$removed_by.$id != nil)
                .sort(\.$expires_at, .ascending)
            
            return try await handlePagination(query: query, status: "takenDown", page: page, per: per)
            
        default:
            // Standardfall: Kombiniere hangs, toHang, overdue für die gegebene posterId
            let hangsQuery = PosterPosition.query(on: req.db)
                .filter(\.$poster.$id == posterId)
                .with(\.$responsibilities) { responsibilities in
                    responsibilities.with(\.$user) { user in
                        user.with(\.$identity) // Eager load Identity-Beziehung des Users
                    }
                }
                .with(\.$posted_by)
                .with(\.$removed_by)
                .filter(\.$posted_by.$id != nil)
                .filter(\.$removed_by.$id == nil)
                .sort(\.$expires_at, .ascending)
            
            let toHangQuery = PosterPosition.query(on: req.db)
                .filter(\.$poster.$id == posterId)
                .with(\.$responsibilities) { responsibilities in
                    responsibilities.with(\.$user) { user in
                        user.with(\.$identity) // Eager load Identity-Beziehung des Users
                    }
                }
                .with(\.$posted_by)
                .with(\.$removed_by)
                .filter(\.$posted_by.$id == nil)
                .filter(\.$expires_at > currentDate)
                .sort(\.$expires_at, .ascending)
            
            let overdueQuery = PosterPosition.query(on: req.db)
                .filter(\.$poster.$id == posterId)
                .with(\.$responsibilities) { responsibilities in
                    responsibilities.with(\.$user) { user in
                        user.with(\.$identity) // Eager load Identity-Beziehung des Users
                    }
                }
                .with(\.$posted_by)
                .with(\.$removed_by)
                .filter(\.$posted_by.$id != nil)
                .filter(\.$removed_by.$id == nil)
                .filter(\.$expires_at <= currentDate)
                .sort(\.$expires_at, .ascending)
            
            // Führe alle drei Abfragen gleichzeitig aus
            let (hangsPositions, toHangPositions, overduePositions) = try await (
                hangsQuery.all(),
                toHangQuery.all(),
                overdueQuery.all()
            )
            let hangsDTOs = hangsPositions.map{$0.posterPositionMapToDTO("hangs")}
            let toHangDTOs = toHangPositions.map{$0.posterPositionMapToDTO("toHang")}
            let overdueDTOs = overduePositions.map{$0.posterPositionMapToDTO("overdue")}
            
            
            let combined = hangsDTOs + toHangDTOs + overdueDTOs
            
            // Wenn page und per gesetzt sind, manuelle Pagination im Speicher
            if let page = page, let per = per {
                let totalItems = combined.count
                let totalPages = Int((Double(totalItems) / Double(per)).rounded(.up))
                let start = (page - 1) * per
                let end = min(start + per, totalItems)
                guard start < end else {
                    throw Abort(.badRequest, reason: "Ungültige Paginierungsparameter.")
                }
                let pagedItems = Array(combined[start..<end])
                
                var headers = HTTPHeaders()
                headers.contentType = .json
                headers.add(name: "Pagination-Current-Page", value: "\(page)")
                headers.add(name: "Pagination-Per-Page", value: "\(per)")
                headers.add(name: "Pagination-Total-Items", value: "\(totalItems)")
                headers.add(name: "Pagination-Total-Pages", value: "\(totalPages)")
                
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
        guard let positionId = req.parameters.get("positionid", as: UUID.self) else {
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
        
        let responsibleUsers = updatedResponsibilities.map {
            ResponsibleUsersDTO(id: $0.$user.id, name: $0.$user.name)
        }
        
        let responseDTO = PosterPositionResponseDTO(
            id: position.id!,
            posterId: position.$poster.id,
            latitude: position.latitude,
            longitude: position.longitude,
            postedBy: position.$posted_by.name,
            postedAt: position.posted_at,
            expiresAt: position.expires_at!,
            removedBy: position.$removed_by.name,
            removedAt: position.removed_at,
            imageUrl: position.image_url,
            responsibleUsers: responsibleUsers,
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
        let position = try await PosterPosition.query(on: req.db)
            .filter(\.$id == dto.posterPosition)
            .with(\.$responsibilities)
            .first()
        
        if (position == nil){
            throw Abort(.notFound, reason: "PosterPosition nicht gefunden")
        }
        // Check: Ist der User in responsibilities?
        guard position!.responsibilities.contains(where: { $0.$user.id == userId }) else {
            throw Abort(.forbidden, reason: "Sie sind nicht verantwortlich für diese PosterPosition.")
        }
        
        
        // Check: Bereits aufgehängt?
        if position!.$posted_by.id != nil || position!.posted_at != nil {
            req.logger.warning("PosterPosition (ID \(String(describing: position!.id))) is already posted.")
            throw Abort(.badRequest, reason: "Diese PosterPosition ist bereits aufgehängt worden.")
        }
        
        // Identity laden
        let identity = try await Identity.byUserId(userId, req.db)
        
        let imageData = dto.image
        
        let imageUrl = try await saveImage(imageData, in: "Storage/Images/PosterPositions", on: req)
        
        
        // Position updaten
        position!.image_url = imageUrl
        position!.posted_at = Date()
        position!.$posted_by.id = identity.id
        
        
        try await position!.update(on: req.db)
        
        // Response erstellen
        let responseDTO = HangPosterPositionResponseDTO(
            posterPosition: position!.id!,
            postedAt: position!.posted_at!,
            postedBy: position!.$posted_by.id!,
            imageUrl: position!.image_url!
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
        
        let position = try await PosterPosition.query(on: req.db)
            .filter(\.$id == dto.posterPosition)
            .with(\.$responsibilities)
            .first()
        
        if (position == nil){
            throw Abort(.notFound, reason: "PosterPosition nicht gefunden")
        }
        
        guard position!.responsibilities.contains(where: { $0.$user.id == userId }) else {
            throw Abort(.forbidden, reason: "Sie sind nicht verantwortlich für diese PosterPosition.")
        }
        
        if position!.$removed_by.id != nil || position!.removed_at != nil {
            throw Abort(.badRequest, reason: "Diese PosterPosition ist bereits abgehängt worden.")
        }
        
        let identity = try await Identity.byUserId(userId, req.db)
        
        let imageData = dto.image
        if let oldImageUrl = position!.image_url {
            let oldFilePath = req.application.directory.workingDirectory + "Storage/Images/PosterPositions/"  + oldImageUrl
            do {
                try FileManager.default.removeItem(atPath: oldFilePath)
            } catch {
                req.logger.warning("Altes Bild konnte nicht gelöscht werden: \(error)")
            }
        }
        let imageUrl = try await saveImage(imageData, in: "Storage/Images/PosterPositions", on: req)
        
        position!.image_url = imageUrl
        position!.removed_at = Date()
        position!.$removed_by.id = identity.id
        
        try await position!.update(on: req.db)
        
        let responseDTO = TakeDownPosterPositionResponseDTO(
            posterPosition: position!.id!,
            removedAt: position!.removed_at!,
            removedBy: position!.$removed_by.id!,
            imageUrl: position!.image_url!
        )
        
        return try await createResponse(with: responseDTO, on: req)
    }
    
    
    /// Löscht eine einzelne PosterPosition und deren zugehörige Bilddatei.
    @Sendable
    func deletePosterPosition(req: Request) async throws -> HTTPStatus {
        guard let positionID = req.parameters.get("positionid", as: UUID.self) else {
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
    
    
}





