package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

//
//  DeletePosterDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 02.12.24.
//
data class DeleteDTO (
    public let ids: List<UUID>
)
