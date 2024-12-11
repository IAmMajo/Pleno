package net.ipv64.kivop.dtos.ConfigServiceDTOs

import java.util.UUID

import java.time.LocalDateTime

//
//  SettingUpdateItemDTO.swift.swift
//  config-service
//
//  Created by Dennis Sept on 19.11.24.
//
data class SettingUpdateItemDTO (
    var id : UUID,
    var value : String,
)
