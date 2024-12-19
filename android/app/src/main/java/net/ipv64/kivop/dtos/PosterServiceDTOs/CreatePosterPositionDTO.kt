package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

//
//  CreatePosterPositionDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
data class CreatePosterPositionDTO (
    var posterId : UUID?,
    var latitude : Double,
    var longitude : Double,
    var responsible_users : List<UUID>,
    var expires_at :Date
)
