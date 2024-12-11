package net.ipv64.kivop.dtos

//
//  UpdatePosterPositionDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
data class UpdatePosterPositionDTO (
    var latitude : Double?,
    var longitude : Double?,
    var isDisplayed : Boolean?,
    var imageBase64 : String?, // Optionaler Base64-String für das Bild
    var expiresAt :Date
)
