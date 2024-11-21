//
//  settings.swift
//  config-service
//
//  Created by Dennis Sept on 02.11.24.
//
public struct SettingResponseDTO: Codable{
    public var id : Uuid?
    public var key : String
    public var datatype : String
    public var value : String
    public var description : String?
}
