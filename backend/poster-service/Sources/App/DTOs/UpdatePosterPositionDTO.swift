//
//  UpdatePosterPositionDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
import Foundation
import Vapor
public struct UpdatePosterPositionDTO: Codable {
    public var latitude: Double?
    public var longitude: Double?
    public var isDisplayed: Bool?
    public var image: File? // Optionaler Base64-String für das Bild
    public var expiresAt:Date?


    public init(latitude: Double?, longitude: Double?, isDisplayed: Bool?, image: File?,expiresAt:Date?) {
        self.latitude = latitude
        self.longitude = longitude
        self.isDisplayed = isDisplayed
        self.image = image
        self.expiresAt = expiresAt

    }
}
