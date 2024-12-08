package net.ipv64.kivop.dtos

//
//  settings.swift
//  config-service
//
//  Created by Dennis Sept on 02.11.24.
//
public struct SettingResponseDTO: Codable{
    var id : Uuid?,
    var key : String,
    var datatype : String,
    var value : String,
    var description : String?,
)
