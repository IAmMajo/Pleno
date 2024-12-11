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
    var id : UUID?,
    var posterId : UUID,
    var responsibleUserId : UUID,
    var latitude : Double,
    var longitude : Double,
    var isDisplayed : Boolean,
    var imageBase64 : String, // Hinzugefügt
    var expiresAt :Date
    var postedAt :Date
)
