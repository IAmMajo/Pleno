package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID

import java.time.LocalDateTime

//
//  PosterResponseDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
data class PosterResponseDTO (
    var id : UUID?,
    var name : String,
    var description : String?,
    var imageBase64 : String, // Hinzugefügt
)
