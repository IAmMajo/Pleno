//
//  UpdatePosterPositionDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
import Foundation
import Vapor

public struct UpdatePosterPositionDTO: Codable {
    
    public var posterId: UUID?
    public var latitude: Double?
    public var longitude: Double?
    public var expiresAt:Date?
    public var responsible_users: [UUID]?
    public var image: File?
    

    public init(
                posterId: UUID? = nil,
                latitude: Double? = nil,
                longitude: Double? = nil,
                imageUrl: String? = nil,
                expiresAt: Date? = nil,
                responsibleUsers:[UUID]? = nil,
                image: File? = nil
                )
    {
        self.latitude = round((latitude ?? 0) * 1_000_000) / 1_000_000
        self.longitude = round(longitude ?? 0 * 1_000_000) / 1_000_000
        self.posterId = posterId
        self.expiresAt = expiresAt
        self.responsible_users = responsibleUsers
        self.image = image
    }
    
    // Custom Decoding: So interpretieren wir 'expires_at' korrekt aus multipart/form-data
       public init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)

           // posterId
           self.posterId = try container.decodeIfPresent(UUID.self, forKey: .posterId)

           // latitude
           if let lat = try container.decodeIfPresent(Double.self, forKey: .latitude) {
               self.latitude = round(lat * 1_000_000) / 1_000_000
           }

           // longitude
           if let lng = try container.decodeIfPresent(Double.self, forKey: .longitude) {
               self.longitude = round(lng * 1_000_000) / 1_000_000
           }

           // responsible_users
           self.responsible_users = try container.decodeIfPresent([UUID].self, forKey: .responsible_users)

           // image (File)
           self.image = try container.decodeIfPresent(File.self, forKey: .image)

           // expires_at: Erst als Double (Unixzeit), dann als String (z. B. ISO8601)
           if let unixTimestamp = try? container.decode(Double.self, forKey: .expiresAt) {
               // Falls jemand z. B. "1700000000.0" schickt
               self.expiresAt = Date(timeIntervalSince1970: unixTimestamp)
           } else if let dateString = try? container.decode(String.self, forKey: .expiresAt) {
               // Falls jemand z. B. "2025-01-04T12:00:00Z" schickt
               if let parsedDate = ISO8601DateFormatter().date(from: dateString) {
                   self.expiresAt = parsedDate
               } else {
                   // Hier könntest du versuchen, einen anderen DateFormatter zu nehmen
                   // oder z. B. "yyyy-MM-dd" parsen, falls du es brauchst.
                   self.expiresAt = nil
               }
           } else {
               // Kein Feld 'expires_at' oder konnte nicht gelesen werden
               self.expiresAt = nil
           }
       }

       // Die CodingKeys, damit wir auf die Felder zugreifen können
       enum CodingKeys: String, CodingKey {
           case posterId
           case latitude
           case longitude
           case expiresAt
           case responsible_users
           case image
       }
}



