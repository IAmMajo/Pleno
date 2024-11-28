import Fluent
import Vapor
import Foundation
import Models

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
        case .imageSaveFailed:
            return .internalServerError
        case .databaseSaveFailed:
            return .internalServerError
        case .settingFetchFailed:
            return .internalServerError
        case .unknownError:
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
                    return "Fehler beim Abrufen der poster_deletion_interval Einstellung: \(reason)"
        case .unknownError:
            return "Unbekannter Fehler"
        }
    }
}

struct PosterController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let posters = routes.grouped("posters")
        posters.post(use: createPoster)
        posters.get("displayed", use: getDisplayedPosters)
        posters.get("to-be-taken-down", use: getPostersToBeTakenDown)
        posters.patch(":posterId", use: updatePoster)
        
        let posterPositions = routes.grouped("poster-positions")
        posterPositions.post(use: createPosterPosition)
        posterPositions.patch(":positionId", use: updatePosterPosition)
    }
    
    // Hilfsfunktion zum Erstellen einer Response
    @Sendable
    private func createResponse<T: Codable>(with dto: T, on req: Request) async throws -> Response {
        let responseData = try JSONEncoder().encode(dto)
        var headers = HTTPHeaders()
        headers.contentType = .json
        return Response(status: .ok, headers: headers, body: .init(data: responseData))
    }
    struct PosterData: Content {
        var name: String
        var description: String
        var image: File
    }

    // 1. Neues Poster erstellen
    @Sendable
        func createPoster(req: Request) async throws -> Response {
            // Überprüfen, ob die Anfrage multipart/form-data ist
            guard let contentType = req.headers.contentType,
                  contentType.type == "multipart",
                  contentType.subType == "form-data" else {
                throw PosterCreationError.invalidContentType
            }

            // Starte das asynchrone Abrufen der Einstellung parallel
            async let posterDeletionInterval:Int? = SettingsManager.shared.getSetting(forKey: "poster_deletion_interval")

            let posterData: PosterData
            do {
                // Dekodieren der Formulardaten
                posterData = try req.content.decode(PosterData.self)
            } catch {
                throw PosterCreationError.invalidFormData(reason: "Fehler beim Dekodieren der Formulardaten.")
            }

            // Zusätzliche Validierung der Formulardaten
            guard !posterData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw PosterCreationError.invalidFormData(reason: "Name darf nicht leer sein.")
            }

            // Validierung des Bildtyps und der Größe
            let allowedMimeTypes = ["image/jpeg", "image/png", "image/gif"]
            guard allowedMimeTypes.contains(posterData.image.contentType?.description ?? "") else {
                throw PosterCreationError.invalidFormData(reason: "Ungültiger Bildtyp. Erlaubt sind JPEG, PNG und GIF.")
            }

            // Bild speichern
            let imageUrl: String
            do {
                imageUrl = try await saveImage(posterData.image, in: "Posters", on: req)
            } catch {
                req.logger.error("Bildspeicherung fehlgeschlagen: \(error.localizedDescription)")
                throw PosterCreationError.imageSaveFailed
            }

            // Poster erstellen
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

            
            // Erstelle das Response DTO mit dem deletionInterval
            let responseDTO = PosterResponseDTO(
                id: poster.id,
                name: poster.name,
                description: poster.description,
                imageUrl: poster.image_url
            )

            // Erstelle und gebe die Antwort zurück
            return try await createResponse(with: responseDTO, on: req)
        }
    
    // 2. Alle aufgehängten Poster zurückgeben
    @Sendable
    func getDisplayedPosters(req: Request) async throws -> Response {
        let positions = try await PosterPosition.query(on: req.db)
            .filter(\.$is_Displayed == true)
            .with(\.$poster)
            .all()
        
        var responseDTOs: [PosterResponseDTO] = []
        
        for position in positions {
            let poster = position.poster
            
            let responseDTO = PosterResponseDTO(
                id: poster.id,
                name: poster.name,
                description: poster.description,
                imageUrl: poster.image_url
            )
            
            responseDTOs.append(responseDTO)
        }
        
        return try await createResponse(with: responseDTOs, on: req)
    }
    
    // 3. Alle Poster, die abgehangen werden müssen
    @Sendable
    func getPostersToBeTakenDown(req: Request) async throws -> Response {
            // 1. Asynchron das posterDeletionInterval abrufen
            async let posterDeletionIntervalFetch = SettingsManager.shared.getSetting(forKey: "poster_deletion_interval") as Int?

            // 2. Warten auf das Ergebnis des Einstellungsabrufs
            guard let deletionInterval =  await posterDeletionIntervalFetch else {
                req.logger.error("Einstellung 'poster_deletion_interval' nicht gefunden oder ungültig.")
                throw PosterCreationError.settingFetchFailed(reason: "Einstellung 'poster_deletion_interval' nicht gefunden oder ungültig.")
            }

            // 3. Berechne das Schwellen-Datum
            let now = Date()
            let thresholdDate = now.addingTimeInterval(TimeInterval(deletionInterval))

            // 4. Führe die Datenbankabfrage durch
            let positions = try await PosterPosition.query(on: req.db)
                .filter(\.$is_Displayed == true)
                .filter(\.$expires_at <= thresholdDate)
                .with(\.$poster)
                .all()

            // 5. Transformiere die PosterPositionen in DTOs
            let responseDTOs: [PosterToBeTakenDownDTO] = positions.map { position in
                let poster = position.poster
                return PosterToBeTakenDownDTO(
                    id: poster.id,
                    name: poster.name,
                    description: poster.description,
                    imageUrl: poster.image_url,
                    posterDeletionInterval: deletionInterval
                )
            }

            // 6. Erstelle und gebe die Antwort zurück
            return try await createResponse(with: responseDTOs, on: req)
        }
    
    // 4.Poster updaten
    @Sendable
    func updatePoster(req: Request) async throws -> Response {
        guard let posterId = req.parameters.get("posterId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Poster-ID.")
        }
        
        // Überprüfen, ob die Anfrage multipart/form-data ist
        guard let contentType = req.headers.contentType,
                     contentType.type == "multipart",
                     contentType.subType == "form-data" else {
                   throw Abort(.unsupportedMediaType, reason: "Erwartet multipart/form-data")
               }
        
        // Dekodieren der Formulardaten
        struct UpdatePosterData: Content {
            var name: String?
            var description: String?
            var image: File?
        }
        
        let dto = try req.content.decode(UpdatePosterData.self)
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
            let imageUrl = try await saveImage(image, in: "Posters",on: req)
            poster.image_url = imageUrl
        }
        
        try await poster.update(on: req.db)
        
        let responseDTO = PosterResponseDTO(
            id: poster.id,
            name: poster.name,
            description: poster.description,
            imageUrl: poster.image_url
        )
        
        return try await createResponse(with: responseDTO, on: req)
    }
    
    // 5. Neue PosterPosition erstellen
    @Sendable
    func createPosterPosition(req: Request) async throws -> Response {
        // Überprüfen, ob die Anfrage multipart/form-data ist
        guard let contentType = req.headers.contentType,
                     contentType.type == "multipart",
                     contentType.subType == "form-data" else {
                   throw Abort(.unsupportedMediaType, reason: "Erwartet multipart/form-data")
               }
        
        // Dekodieren der Formulardaten
        struct PosterPositionData: Content {
            var posterId: UUID
            var responsibleUserId: UUID
            var latitude: Double
            var longitude: Double
            var image: File
            var expiresAt: Date
        }
        
        let dto = try req.content.decode(PosterPositionData.self)
        
        // Bild speichern
        let imageUrl = try await saveImage(dto.image, in: "PosterPositions",on: req)
        
        let posterPosition = PosterPosition(
            posterId: dto.posterId,
            responsibleUserID: dto.responsibleUserId,
            latitude: dto.latitude,
            longitude: dto.longitude,
            imageUrl: imageUrl,
            expiresAt: dto.expiresAt
        )
        
        try await posterPosition.create(on: req.db)
        
        let responseDTO = PosterPositionResponseDTO(
            id: posterPosition.id,
            posterId: dto.posterId,
            responsibleUserId: dto.responsibleUserId,
            latitude: dto.latitude,
            longitude: dto.longitude,
            isDisplayed: posterPosition.is_Displayed,
            imageUrl: posterPosition.image_url,
            expiresAt: posterPosition.expires_at!,
            postedAt: posterPosition.posted_at!
        )
        
        return try await createResponse(with: responseDTO, on: req)
    }
    
    // 6. PosterPosition updaten
    @Sendable
    func updatePosterPosition(req: Request) async throws -> Response {
        guard let positionId = req.parameters.get("positionId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Position-ID.")
        }
        
        // Überprüfen, ob die Anfrage multipart/form-data ist
        guard let contentType = req.headers.contentType,
                     contentType.type == "multipart",
                     contentType.subType == "form-data" else {
                   throw Abort(.unsupportedMediaType, reason: "Erwartet multipart/form-data")
               }
        
        // Dekodieren der Formulardaten
        struct UpdatePosterPositionData: Content {
            var latitude: Double?
            var longitude: Double?
            var isDisplayed: Bool?
            var image: File?
        }
        
        let dto = try req.content.decode(UpdatePosterPositionData.self)
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
        if let image = dto.image {
            let imageUrl = try await saveImage(image, in: "PosterPositions",on: req)
            position.image_url = imageUrl
        }
        
        // Aktualisiere das expires_at Datum
        position.expires_at = Date()
        
        try await position.update(on: req.db)
        
        let responseDTO = PosterPositionResponseDTO(
            id: position.id,
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
    
    // Hilfsfunktion zum Speichern von Bildern ohne Skalierung
    private func saveImage(_ file: File, in directory: String, on req: Request) async throws -> String {
        let supportedExtensions = ["jpg", "jpeg", "png", "gif"]
        
        let fileExtension = (file.extension ?? "jpg").lowercased()
        // Validierung der Dateiendung
        let validExtension = supportedExtensions.contains(fileExtension) ? fileExtension : "jpg"
        
        let uniqueFileName = "\(UUID().uuidString).\(validExtension)"
        let saveDirectory = "\(req.application.directory.publicDirectory)\(directory)"
        let savePath = "\(saveDirectory)/\(uniqueFileName)"
        
        // Stelle sicher, dass das Verzeichnis existiert
        let directoryURL = URL(fileURLWithPath: saveDirectory, isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        
        // Lese die Bilddaten
        guard let imageData = file.data.getData(at: 0, length: file.data.readableBytes) else {
            throw Abort(.badRequest, reason: "Ungültige Bilddaten.")
        }
        
        // Speichere die Bilddaten direkt ohne Skalierung
        let fileURL = URL(fileURLWithPath: savePath)
        try imageData.write(to: fileURL)
        
        // Gib den Pfad relativ zum öffentlichen Verzeichnis zurück
        return "/\(directory)/\(uniqueFileName)"
    }


}
