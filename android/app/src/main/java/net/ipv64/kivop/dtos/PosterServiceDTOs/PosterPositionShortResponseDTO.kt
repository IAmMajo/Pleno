package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

//
//  PosterPositionShortResponseDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 18.12.24.
//
data class PosterPositionShortResponseDTO (
    var id : UUID,
    var posterId : UUID?,
    var expires_at :Date
    var status : String,
)
