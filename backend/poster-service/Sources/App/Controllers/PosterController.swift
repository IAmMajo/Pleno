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
        let posters = authProtected.grouped("posters")
        posters.get(use: getPosters).openAPI(
            summary: "Alle verfügbaren Poster abfragen",
            description: "Gibt alle verfügbaren Poster zurück. Unterstützt optionale Pagination über Query-Parameter.",
            query:["page":.integer,"per":.integer],
            body: nil,
            response: .type(PagedResponseDTO<PosterResponseDTO>.self),
            responseContentType: .application(.json)
        )
        posters.post(use: createPoster).openAPI(
            summary: "Erstellt ein neues Poster",
            description: "Erstellt ein neues Poster mithilfe eines multipart/form-data Requests. Erwartet mindestens name und image.",
            query:[],
            body: .type(CreatePosterDTO.self),
            contentType: .multipart(.formData),
            response: .type(PosterResponseDTO.self),
            responseContentType: .application(.json)
        )
        posters.patch(":posterId", use: updatePoster).openAPI(
            summary: "Updatet ein Poster",
            description: "Updatet ein Poster anhand seiner ID mithilfe eines multipart/form-data Requests.",
            query:[],
            path: .type(Poster.IDValue.self),
            body: .type(UpdatePosterDTO.self),
            contentType: .multipart(.formData),
            response: .type(PosterResponseDTO.self),
            responseContentType: .application(.json)
        )

        let adminRoutesPoster = posters.grouped(adminMiddleware)
        adminRoutesPoster.delete(":id", use: deletePoster).openAPI(
            summary: "Löscht ein Poster",
            description: "Löscht ein Poster anhand seiner ID.",
            query:[],
            path: .type(Poster.IDValue.self)
        )
        adminRoutesPoster.delete("batch", use: deletePosters).openAPI(
            summary: "Löscht mehrere Poster",
            description: "Löscht mehrere Poster anhand der übergebenen IDs.",
            query:[],
            body: .type(DeleteDTO.self),
            contentType: .application(.json)
            
        )
        
        // PosterPosition-Routen
        let posterPositions = authProtected.grouped("poster-positions")
        posterPositions.get(use: getPostersPositions).openAPI(
            summary: "Poster Positionen abfragen",
            description: "Gibt alle verfügbaren Poster zurück. Unterstützt optionale Pagination über Query-Parameter. Des weiteren kann innerhalb der Query-Parameter optional unterschieden werden ob alle Poster Positionen, welche aufgehangen sind angezeigt werden oder Positionen, welche noch aufgehangen werden müssen",
            query:["page":.integer,"per":.integer,"displayed":.boolean],
            body: nil,
            response: .type(PagedResponseDTO<PosterPositionResponseDTO>.self),
            responseContentType: .application(.json)
        )
        posterPositions.get("to-be-taken-down", use: getPostersToBeTakenDown).openAPI(
            summary: "Gibt abzuhängende Poster zurück",
            description: "Gibt alle abzuhängende Poster zurück. Unterstützt optionale Pagination über Query-Parameter. Des weiteren kann der Admin die Einstellung 'poster_to_be_taken_down_interval' konfigurieren.",
            query:["page":.integer,"per":.integer],
            body: nil,
            response: .type(PagedResponseDTO<PosterPositionResponseDTO>.self),
            responseContentType: .application(.json)
        )
        posterPositions.post(use: createPosterPosition).openAPI(
            summary: "Erstellt eine neu Poster Position",
            description: "Erstellt eine neue Poster Position mithilfe eines multipart/form-data Requests.",
            query:[],
            body: .type(CreatePosterDTO.self),
            contentType: .multipart(.formData),
            response: .type(PosterPositionResponseDTO.self),
            responseContentType: .application(.json)
        )
        posterPositions.patch(":positionId", use: updatePosterPosition).openAPI(
            summary: "Updatet eine Poster Position",
            description: "Updatet eine Poster Position anhand seiner ID mithilfe eines multipart/form-data Requests.",
            query:[],
            path: .type(PosterPosition.IDValue.self),
            body: .type(UpdatePosterPositionDTO.self),
            contentType: .multipart(.formData),
            response: .type(PosterPositionResponseDTO.self),
            responseContentType: .application(.json)
        )

        let adminRoutesPosterPositions = posterPositions.grouped(adminMiddleware)
        adminRoutesPosterPositions.delete(":id", use: deletePosterPosition).openAPI(
            summary: "Löscht ein Poster",
            description: "Löscht ein Poster anhand seiner ID.",
            query:[],
            path: .type(PosterPosition.IDValue.self)
        )
        adminRoutesPosterPositions.delete("batch", use: deletePosterPositions).openAPI(
            summary: "Löscht mehrere Poster Positonen",
            description: "Löscht mehrere Poster Positionen anhand der übergebenen IDs.",
            query:[],
            body: .type(DeleteDTO.self),
            contentType: .application(.json)
        )
        
        // Bild-Routen
        authProtected.get("images", ":imageURL", use: getImageFile).openAPI(
            summary: "Gibt ein gespeichertes Bild zurück",
            description: "Diese Route gibt eine zuvor gespeicherte Bilddatei zurück.Der Pfadparameter imageURL gibt den relativen Speicherort bzw. Dateinamen an.",
            path: ["imageURL": .string],
            body: nil,
            responseContentType: .init("image/jpeg")
        )
    }

    // MARK: - Hilfsfunktionen

    /// Erstellt eine HTTP-Response mit JSON-Inhalt aus einem codierbaren DTO.
    @Sendable
    private func createResponse<T: Codable>(with dto: T, on req: Request) async throws -> Response {
        let responseData = try JSONEncoder().encode(dto)
        var headers = HTTPHeaders()
        headers.contentType = .json
        return Response(status: .ok, headers: headers, body: .init(data: responseData))
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

        let allowedMimeTypes = ["image/jpeg", "image/png", "image/gif"]
        guard allowedMimeTypes.contains(posterData.image.contentType?.description ?? "") else {
            throw PosterCreationError.invalidFormData(reason: "Ungültiger Bildtyp. Erlaubt sind JPEG, PNG und GIF.")
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
    
    /// Gibt alle verfügbaren Poster zurück oder Poster basierend auf Anzahl der gewählten Menge und Seite
    @Sendable
    func getPosters(req: Request) async throws -> Response {
        let page = try? req.query.get(Int.self, at: "page")
        let per = try? req.query.get(Int.self, at: "per")
        
        if let page = page, let per = per {
            let paginatedData = try await Poster.query(on: req.db)
                .paginate(PageRequest(page: page, per: per))
            
            let responseDTOs = paginatedData.items.map { poster in
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
            
            // Mapping der Vapor-PageMetadata auf den eigenen Typ
            let customMeta = CustomPageMetadata(
                        currentPage: currentPage,
                        perPage: perPage,
                        totalItems: totalItems,
                        totalPages: totalPages
                    )
            
            let response = PagedResponseDTO(
                items: responseDTOs,
                metadata: customMeta
            )
            
            return try await createResponse(with: response, on: req)
            
        } else {
            let posters = try await Poster.query(on: req.db).all()
            let responseDTOs = posters.map { poster in
                PosterResponseDTO(
                    id: poster.id!,
                    name: poster.name,
                    description: poster.description,
                    imageUrl: poster.image_url
                )
            }
            
            // Ohne Pagination kein Metadata
            let response = PagedResponseDTO<PosterResponseDTO>(
                items: responseDTOs,
                metadata: nil
            )
            
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
    
    /// Löscht ein einzelnes Poster und dessen zugehörige Bilddatei.
    @Sendable
    func deletePoster(req: Request) async throws -> HTTPStatus {
        guard let posterID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Poster-ID.")
        }

        guard let poster = try await Poster.find(posterID, on: req.db) else {
            throw Abort(.notFound, reason: "Poster mit der ID \(posterID) wurde nicht gefunden.")
        }

        let imageUrl = poster.image_url
        let filePath = req.application.directory.workingDirectory + imageUrl

        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch {
            req.logger.error("Fehler beim Löschen der Bilddatei: \(error.localizedDescription)")
            // Hier wird das Poster dennoch gelöscht, um Datenkonsistenz zu gewährleisten.
        }

        try await poster.delete(on: req.db)

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

        let postersToDelete = try await Poster.query(on: req.db)
            .filter(\.$id ~~ posterIDs)
            .all()

        if postersToDelete.count != posterIDs.count {
            let foundIDs = Set(postersToDelete.compactMap { $0.id })
            let notFoundIDs = posterIDs.filter { !foundIDs.contains($0) }
            throw Abort(.notFound, reason: "Poster mit den folgenden IDs wurden nicht gefunden: \(notFoundIDs.map { $0.uuidString }.joined(separator: ", "))")
        }

        try await req.db.transaction { database in
            for poster in postersToDelete {
                let imageUrl = poster.image_url
                let filePath = req.application.directory.workingDirectory + imageUrl
                let fileManager = FileManager.default

                do {
                    try fileManager.removeItem(atPath: filePath)
                } catch {
                    req.logger.error("Fehler beim Löschen der Bilddatei für Poster ID \(poster.id?.uuidString ?? "Unbekannt"): \(error.localizedDescription)")
                    throw Abort(.internalServerError, reason: "Fehler beim Löschen der Bilddatei für Poster ID \(poster.id?.uuidString ?? "Unbekannt")")
                }

                try await poster.delete(on: database)
            }
        }

        return .noContent
    }
    
    // MARK: - PosterPosition-Routen

    /// Gibt alle angezeigten oder nicht angezeigten PosterPositionen zurück.
    /// Parameter `displayed` in der Query bestimmt, ob nur angezeigte oder nicht angezeigte zurückgegeben werden.
    @Sendable
    func getPostersPositions(req: Request) async throws -> Response {
        let isDisplayed = (try? req.query.get(Bool.self, at: "displayed")) ?? true
        let page = try? req.query.get(Int.self, at: "page")
        let per = try? req.query.get(Int.self, at: "per")

        // Baue den Basis-Query auf, abhängig von `isDisplayed`
        let query = PosterPosition.query(on: req.db)

        if isDisplayed {
            query.filter(\.$is_Displayed == true)
        } else {
            let currentDate = Date()
            query.filter(\.$is_Displayed == false)
            query.filter(\.$expires_at > currentDate)
        }

        if let page = page, let per = per {
            // Paginierte Abfrage
            let paginatedData = try await query.paginate(PageRequest(page: page, per: per))

            let responseDTOs = paginatedData.items.map { position in
                PosterToBeTakenDownDTO(
                    positionId: position.id!,
                    posterId: position.$poster.id,
                    responsibleUserId: position.$responsibleUser.id,
                    latitude: position.latitude,
                    longitude: position.longitude,
                    isDisplayed: position.is_Displayed,
                    imageURL: position.image_url ?? "",
                    expiresAt: position.expires_at!
                )
            }

            let currentPage = paginatedData.metadata.page
            let perPage = paginatedData.metadata.per
            let totalItems = paginatedData.metadata.total
            let totalPages = Int((Double(totalItems) / Double(perPage)).rounded(.up))

            let customMeta = CustomPageMetadata(
                currentPage: currentPage,
                perPage: perPage,
                totalItems: totalItems,
                totalPages: totalPages
            )

            let response = PagedResponseDTO(
                items: responseDTOs,
                metadata: customMeta
            )

            return try await createResponse(with: response, on: req)

        } else {
            // Keine Pagination-Parameter, alle laden
            let positions = try await query.all()

            let responseDTOs = positions.map { position in
                PosterToBeTakenDownDTO(
                    positionId: position.id!,
                    posterId: position.$poster.id,
                    responsibleUserId: position.responsibleUser.id!,
                    latitude: position.latitude,
                    longitude: position.longitude,
                    isDisplayed: position.is_Displayed,
                    imageURL: position.image_url ?? "",
                    expiresAt: position.expires_at!
                )
            }

            // Kein Paging -> metadata = nil
            let response = PagedResponseDTO(
                items: responseDTOs,
                metadata: nil
            )

            return try await createResponse(with: response, on: req)
        }
    }


    /// Gibt alle PosterPositionen zurück, die demnächst abgehangen werden müssen.
    /// Die Zeitspanne wird über die Einstellung `poster_deletion_interval` bestimmt.
    @Sendable
    func getPostersToBeTakenDown(req: Request) async throws -> Response {
        async let toBeTakenDown: Int? = SettingsManager.shared.getSetting(forKey: "poster_to_be_taken_down_interval")
        guard let takenDownInterval = await toBeTakenDown else {
            req.logger.error("Einstellung 'poster_deletion_interval' nicht gefunden oder ungültig.")
            throw PosterCreationError.settingFetchFailed(reason: "Einstellung 'poster_deletion_interval' nicht gefunden oder ungültig.")
        }

        // Paging Parameter auslesen
        let page = try? req.query.get(Int.self, at: "page")
        let per = try? req.query.get(Int.self, at: "per")

        let now = Date()
        let thresholdDate = now.addingTimeInterval(TimeInterval(takenDownInterval))

        // Basis-Query vorbereiten
        let query = PosterPosition.query(on: req.db)
            .filter(\.$is_Displayed == true)
            .filter(\.$expires_at <= thresholdDate)

        if let page = page, let per = per {
            // Paginierte Abfrage
            let paginatedData = try await query.paginate(PageRequest(page: page, per: per))

            let responseDTOs = paginatedData.items.map { position in
                PosterToBeTakenDownDTO(
                    positionId: position.id!,
                    posterId: position.$poster.id,
                    responsibleUserId: position.$responsibleUser.id,
                    latitude: position.latitude,
                    longitude: position.longitude,
                    isDisplayed: position.is_Displayed,
                    imageURL: position.image_url ?? "",
                    expiresAt: position.expires_at!
                )
            }

            let currentPage = paginatedData.metadata.page
            let perPage = paginatedData.metadata.per
            let totalItems = paginatedData.metadata.total
            let totalPages = Int((Double(totalItems) / Double(perPage)).rounded(.up))

            let customMeta = CustomPageMetadata(
                currentPage: currentPage,
                perPage: perPage,
                totalItems: totalItems,
                totalPages: totalPages
            )

            let response = PagedResponseDTO(
                items: responseDTOs,
                metadata: customMeta
            )

            return try await createResponse(with: response, on: req)
        } else {
            // Keine Paging-Parameter: alle Einträge laden
            let positions = try await query.all()

            let responseDTOs = positions.map { position in
                PosterToBeTakenDownDTO(
                    positionId: position.id!,
                    posterId: position.$poster.id,
                    responsibleUserId: position.$responsibleUser.id ,
                    latitude: position.latitude,
                    longitude: position.longitude,
                    isDisplayed: position.is_Displayed,
                    imageURL: position.image_url ?? "",
                    expiresAt: position.expires_at!
                )
            }

            let response = PagedResponseDTO(
                items: responseDTOs,
                metadata: nil
            )

            return try await createResponse(with: response, on: req)
        }
    }



    /// Erstellt eine neue PosterPosition mit Bild und speichert sie in der Datenbank.
    @Sendable
    func createPosterPosition(req: Request) async throws -> Response {
        guard let contentType = req.headers.contentType,
              contentType.type == "multipart",
              contentType.subType == "form-data" else {
            throw Abort(.unsupportedMediaType, reason: "Erwartet multipart/form-data")
        }

        let dto = try req.content.decode(CreatePosterPositionDTO.self)


        // latitude und longitude in einem sinnvollen Bereich
        guard (-90...90).contains(dto.latitude) else {
            throw Abort(.badRequest, reason: "latitude muss zwischen -90 und 90 liegen.")
        }

        guard (-180...180).contains(dto.longitude) else {
            throw Abort(.badRequest, reason: "longitude muss zwischen -180 und 180 liegen.")
        }

        // Wenn image vorhanden ist, Bild speichern. Wenn nicht, bleibt imageUrl nil.
        let imageUrl: String
        if let imageData = dto.image {
            imageUrl = try await saveImage(imageData, in: "Storage/Images/PosterPositions", on: req)
        } else {
            imageUrl = ""
        }

        
        let posterPosition = PosterPosition(
            posterId: dto.posterId,
            responsibleUserID: dto.responsibleUserId!,
            latitude: dto.latitude,
            longitude: dto.longitude,
            imageUrl: imageUrl,
            expiresAt: dto.expiresAt
        )

        try await posterPosition.create(on: req.db)

        let responseDTO = PosterPositionResponseDTO(
            id: posterPosition.id!,
            posterId: posterPosition.$poster.id,
            responsibleUserId: posterPosition.$responsibleUser.id,
            latitude: posterPosition.latitude,
            longitude: posterPosition.longitude,
            isDisplayed: posterPosition.is_Displayed,
            imageUrl: posterPosition.image_url ?? "",
            expiresAt: posterPosition.expires_at!,
            postedAt: posterPosition.posted_at!
        )

        return try await createResponse(with: responseDTO, on: req)
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

        if let latitude = dto.latitude {
            position.latitude = latitude
        }
        if let longitude = dto.longitude {
            position.longitude = longitude
        }
        if let isDisplayed = dto.isDisplayed {
            position.is_Displayed = isDisplayed
        }
        if let expiresAt = dto.expiresAt {
            position.expires_at = expiresAt
        }
        if let responsibleUserId = dto.responsibleUserId {
            position.$responsibleUser.id = responsibleUserId
        }
        if let posterId = dto.posterId {
            position.$poster.id = posterId
        }
        if let image = dto.image {
            let imageUrl = try await saveImage(image, in: "Storage/Images/PosterPositions", on: req)
            position.image_url = imageUrl
        }

        try await position.update(on: req.db)

        let responseDTO = PosterPositionResponseDTO(
            id: position.id!,
            posterId: position.$poster.id,
            responsibleUserId: position.$responsibleUser.id,
            latitude: position.latitude,
            longitude: position.longitude,
            isDisplayed: position.is_Displayed,
            imageUrl: position.image_url,
            expiresAt: position.expires_at!,
            postedAt: position.posted_at!
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
            let filePath = req.application.directory.workingDirectory + url

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
                    let filePath = req.application.directory.workingDirectory + url

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
        let supportedExtensions = ["jpg", "jpeg", "png", "gif"]
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

        return "\(directory)/\(uniqueFileName)"
    }
    
    /// Gibt eine gespeicherte Bilddatei zurück.
    /// Diese Route streamt die Datei direkt aus dem geschützten Verzeichnis.
    @Sendable
    func getImageFile(req: Request) async throws -> Response {
        guard let imageURL = req.parameters.get("imageURL", as: String.self) else {
            throw Abort(.badRequest, reason: "Ungültige Bild-ID")
        }

        let imagePath = req.application.directory.workingDirectory + imageURL

        guard FileManager.default.fileExists(atPath: imagePath) else {
            throw Abort(.notFound, reason: "Bilddatei nicht gefunden")
        }

        return req.fileio.streamFile(at: imagePath)
    }

}
