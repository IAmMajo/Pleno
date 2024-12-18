package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

//
//  HangPosterPositionDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 18.12.24.
//
data class HangPosterPositionDTO (
    var user : UUID,
    var poster_position : UUID,
)
