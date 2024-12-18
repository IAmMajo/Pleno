package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

//
//  UpdatePosterDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
data class UpdatePosterDTO (
    var name : String?,
    var description : String?,
    var image : ByteArray?,
)
