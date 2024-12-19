package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

//
//  PosterPositionResponseDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
data class PosterPositionResponseDTO (
    var id : UUID,
    var posterId : UUID?,
    var latitude : Double,
    var longitude : Double,
    var posted_by :UUID?
    var postedAt :Date?
    var expires_at :Date
    var removed_by : UUID?,
    var removed_at : LocalDateTime?,
    var imageUrl : String?,
    var responsible_users : List<UUID>,
    var status : String,
)
