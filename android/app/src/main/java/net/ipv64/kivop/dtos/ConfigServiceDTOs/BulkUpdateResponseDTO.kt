package net.ipv64.kivop.dtos.ConfigServiceDTOs

import java.util.UUID

import java.time.LocalDateTime

//
//  BulkUpdateResponseDTO.swift
//  config-service
//
//  Created by Dennis Sept on 19.11.24.
//
data class BulkUpdateResponseDTO (
    var updated : List<UUID>,
    var failed : Map<UUID, String>
)
