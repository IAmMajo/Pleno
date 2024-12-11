package net.ipv64.kivop.dtos

//
//  CreatePosterDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
data class CreatePosterDTO (
    var name : String,
    var description : String?,
    var imageBase64 : String, // Bild als Base64-String
)
