package net.ipv64.kivop.dtos.ConfigServiceDTOs

import java.util.UUID

import java.time.LocalDateTime

//
//  SettingBulkUpdateDTO.swift.swift
//  config-service
//
//  Created by Dennis Sept on 19.11.24.
//
data class SettingBulkUpdateDTO (
    var updates : List<SettingUpdateItemDTO>,
)
