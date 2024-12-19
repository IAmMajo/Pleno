package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

//
//  HangPosterPositionResponseDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 18.12.24.
//
data class HangPosterPositionResponseDTO (
    var poster_position : UUID,
    var posted_at : LocalDateTime,
    var posted_by : UUID,
    var image_url :String
)
