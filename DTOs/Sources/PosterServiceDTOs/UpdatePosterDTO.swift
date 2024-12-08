//
//  UpdatePosterDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//

public struct UpdatePosterDTO: Codable {
    public var name: String?
    public var description: String?
    public var imageBase64: String? // Optionaler Base64-String für das Bild

    public init(name: String?, description: String?, imageBase64: String?) {
        self.name = name
        self.description = description
        self.imageBase64 = imageBase64
    }
}
