package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

//
//  PagedResponseDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 06.12.24.
//
public struct PagedResponseDTO<Item: Codable>: Codable {
   public  var items: List<Item>
    var metadata : CustomPageMetadata?,
}
data class CustomPageMetadata (
    public let currentPage: Int
    public let perPage: Int
    public let totalItems: Int
    public let totalPages: Int
)
