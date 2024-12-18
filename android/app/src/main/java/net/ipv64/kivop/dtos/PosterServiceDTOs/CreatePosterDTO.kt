package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

//
//  CreatePosterDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
data class CreatePosterDTO (
    var name : String,
    var description : String?,
    var image : ByteArray, 
)
