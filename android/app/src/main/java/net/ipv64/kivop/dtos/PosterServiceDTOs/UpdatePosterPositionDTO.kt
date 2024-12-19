package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

//
//  UpdatePosterPositionDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
data class UpdatePosterPositionDTO (
    var posterId : UUID?,
    var latitude : Double?,
    var longitude : Double?,
    var expires_at :Date?
    var responsible_users : List<UUID>?,
    var image : ByteArray?,
)
