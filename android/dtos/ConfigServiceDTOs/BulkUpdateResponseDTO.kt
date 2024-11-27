//
//  BulkUpdateResponseDTO.swift
//  config-service
//
//  Created by Dennis Sept on 19.11.24.
//
public data class BulkUpdateResponseDTO {
    public var updated : List<Uuid>
    public var failed : Map<Uuid, String>
}
