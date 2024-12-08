package net.ipv64.kivop.dtos

//
//  BulkUpdateResponseDTO.swift
//  config-service
//
//  Created by Dennis Sept on 19.11.24.
//
data class BulkUpdateResponseDTO (
    var updated : List<Uuid>,
    var failed : Map<Uuid, String>
)
