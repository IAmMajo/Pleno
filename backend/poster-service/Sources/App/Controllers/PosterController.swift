import Fluent
import Vapor
import Foundation
import Models
@preconcurrency import JWTKit

// Fehlerdefinitionen für Poster-Erstellung und -Verwaltung
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


// Controller für Poster und PosterPositionen
struct PosterController: RouteCollection, Sendable {
    // JWT Signer und Auth Middleware
    let jwtSigner: JWTSigner
    let authMiddleware: Middleware

    init() throws {
        // Verwenden Sie einen sicheren Schlüssel in der Produktion
        guard let keyData = "Ganzgeheimespasswort".data(using: .utf8) else {
            throw Abort(.internalServerError, reason: "Fehler beim Erstellen des JWT-Signers")
        }
        self.jwtSigner = JWTSigner.hs256(key: keyData)
        self.authMiddleware = AuthMiddleware(jwtSigner: jwtSigner, payloadType: JWTPayloadDTO.self)
    }

    func boot(routes: RoutesBuilder) throws {
        // Alle Routen mit Authentifizierung
        let authProtected = routes.grouped(authMiddleware)
        
        // Gruppierung für Poster-Routen
        let posters = authProtected.grouped("posters")
        posters.get(use: getPosters)
        posters.post(use: createPoster)
        posters.patch(":posterId", use: updatePoster)
        
        // Gruppierung für PosterPosition-Routen
        let posterPositions = authProtected.grouped("poster-positions")
        posterPositions.get(use: getDisplayedPosters)
        posterPositions.get("to-be-taken-down", use: getPostersToBeTakenDown)
        posterPositions.post(use: createPosterPosition)
        posterPositions.patch(":positionId", use: updatePosterPosition)
        
        // Bild-Routen
        authProtected.get("images", ":imageURL", use: getImageFile)
        
    }

    // Hilfsfunktion zum Erstellen einer Response
    @Sendable
    private func createResponse<T: Codable>(with dto: T, on req: Request) async throws -> Response {
        let responseData = try JSONEncoder().encode(dto)
        var headers = HTTPHeaders()
        headers.contentType = .json
        return Response(status: .ok, headers: headers, body: .init(data: responseData))
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

        let posterData: CreatePosterDTO
        do {
            // Dekodieren der Formulardaten
            posterData = try req.content.decode(CreatePosterDTO.self)
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

        // Bild speichern außerhalb des Public-Ordners
        let imageUrl: String
        do {
            imageUrl = try await saveImage(posterData.image, in: "Storage/Images/Posters", on: req)
        } catch {
            req.logger.error("Bildspeicherung fehlgeschlagen: \(error.localizedDescription)")
            throw PosterCreationError.imageSaveFailed
        }

        // Poster erstellen
        let poster:Poster = Poster(
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

        // Erstelle das Response DTO
        let responseDTO:PosterResponseDTO = PosterResponseDTO(
            id: poster.id!,
            name: poster.name,
            description: poster.description,
            imageUrl: poster.image_url
        )

        // Erstelle und gebe die Antwort zurück
        return try await createResponse(with: responseDTO, on: req)
    }
    
    // 2. Alle Poster abrufen
    @Sendable
    func getPosters(req: Request) async throws -> Response {
        let posters:[Poster] = try await Poster.query(on: req.db).all()
        let responseDTOs:[PosterResponseDTO] = posters.map { poster in
            PosterResponseDTO(
                id: poster.id!,
                name: poster.name,
                description: poster.description,
                imageUrl: poster.image_url
            )
        }
        return try await createResponse(with: responseDTOs, on: req)
    }
    
    
    // 3. Alle aufgehängten oder nicht aufgehängten Poster zurückgeben
    @Sendable
    func getDisplayedPosters(req: Request) async throws -> Response {
        
        let isDisplayed:Bool = (try? req.query.get(Bool.self, at: "displayed")) ?? true
        let positions:[PosterPosition]
        
        if isDisplayed {
            positions = try await PosterPosition.query(on: req.db)
                .filter(\.$is_Displayed == isDisplayed)
                .all()
        }
        
        else {
            let currentDate:Date = Date()
                
            positions = try await PosterPosition.query(on: req.db)
                .filter(\.$is_Displayed == false)
                .filter(\.$expires_at > currentDate)
                .all()
        }
        
        let responseDTOs:[PosterToBeTakenDownDTO] = positions.map { position in
            PosterToBeTakenDownDTO(
                posterId: position.id!,
                responsibleUserId: position.responsibleUser.id!,
                latitude:position.latitude,
                longitude:position.longitude,
                isDisplayed: position.is_Displayed,
                imageURL: position.image_url,
                expiresAt:position.expires_at!
             )
            
        }
        
        return try await createResponse(with: responseDTOs, on: req)
    }
    
    
    // 4. Alle Poster, die abgehangen werden müssen
    @Sendable
    func getPostersToBeTakenDown(req: Request) async throws -> Response {
        // Asynchron das posterDeletionInterval abrufen
        async let posterDeletionInterval: Int? = SettingsManager.shared.getSetting(forKey: "poster_deletion_interval")

        // Warten auf das Ergebnis des Einstellungsabrufs
        guard let deletionInterval = await posterDeletionInterval else {
            req.logger.error("Einstellung 'poster_deletion_interval' nicht gefunden oder ungültig.")
            throw PosterCreationError.settingFetchFailed(reason: "Einstellung 'poster_deletion_interval' nicht gefunden oder ungültig.")
        }

        // Berechne das Schwellen-Datum
        let now = Date()
        let thresholdDate = now.addingTimeInterval(TimeInterval(deletionInterval))

        // Führe die Datenbankabfrage durch
        let positions = try await PosterPosition.query(on: req.db)
            .filter(\.$is_Displayed == true)
            .filter(\.$expires_at <= thresholdDate)
            .all()

        
        let responseDTOs: [PosterToBeTakenDownDTO] = positions.map { position in
            
            return PosterToBeTakenDownDTO(
                posterId: position.id!,
                responsibleUserId: position.responsibleUser.id!,
                latitude:position.latitude,
                longitude:position.longitude,
                isDisplayed: position.is_Displayed,
                imageURL: position.image_url,
                expiresAt:position.expires_at!
            )
        }
        

        // Erstelle und gebe die Antwort zurück
        return try await createResponse(with: responseDTOs, on: req)
    }
    
    // 5. Poster updaten
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
    
    // 6. Neue PosterPosition erstellen
    @Sendable
    func createPosterPosition(req: Request) async throws -> Response {
        // Überprüfen, ob die Anfrage multipart/form-data ist
        guard let contentType = req.headers.contentType,
                 contentType.type == "multipart",
                 contentType.subType == "form-data" else {
               throw Abort(.unsupportedMediaType, reason: "Erwartet multipart/form-data")
           }
        
        let dto = try req.content.decode(CreatePosterPositionDTO.self)
        // bedingung einbauen
        let imageUrl = try await saveImage(dto.image, in: "Storage/Images/PosterPositions", on: req)
        
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
            id: posterPosition.id!,
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
    
    // 7. PosterPosition updaten
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

        
        let dto:UpdatePosterPositionDTO = try req.content.decode(UpdatePosterPositionDTO.self)
        guard let position:PosterPosition = try await PosterPosition.find(positionId, on: req.db) else {
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
        if let expiresAt = dto.expiresAt{
            position.expires_at = expiresAt
        }
        if let resonsibleUserId = dto.responsibleUserId {
            position.$responsibleUser.id = resonsibleUserId
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
    
   

    // 8. Route zum Abrufen der Bilddatei
    @Sendable
    func getImageFile(req: Request) async throws -> Response {
        guard let imageURL = req.parameters.get("imageURL", as: String.self) else {
            throw Abort(.badRequest, reason: "Ungültige Bild-ID")
        }

        
        // Der Pfad zu Ihrem geschützten Ordner
        let imagePath = req.application.directory.workingDirectory + imageURL

        // Prüfen, ob die Datei existiert
        guard FileManager.default.fileExists(atPath: imagePath) else {
            throw Abort(.notFound, reason: "Bilddatei nicht gefunden")
        }

        return req.fileio.streamFile(at: imagePath)
    }

    // Hilfsfunktion zum Speichern von Bildern außerhalb des Public-Ordners
    private func saveImage(_ file: File, in directory: String, on req: Request) async throws -> String {
        let supportedExtensions = ["jpg", "jpeg", "png", "gif"]
        
        let fileExtension = (file.extension ?? "jpg").lowercased()
        // Validierung der Dateiendung
        let validExtension = supportedExtensions.contains(fileExtension) ? fileExtension : "jpg"
        
        let uniqueFileName = "\(UUID().uuidString).\(validExtension)"
        let saveDirectory = "\(req.application.directory.workingDirectory)/\(directory)"
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
        
        // Gib den Pfad relativ zum Arbeitsverzeichnis zurück
        return "\(directory)/\(uniqueFileName)"
    }
    


}
