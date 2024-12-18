package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

//
//  TakeDownPosterPositionResponseDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 18.12.24.
//
data class TakeDownPosterPositionResponseDTO (
    var poster_position : UUID,
    var removed_at : LocalDateTime,
    var removed_by : UUID,
)
