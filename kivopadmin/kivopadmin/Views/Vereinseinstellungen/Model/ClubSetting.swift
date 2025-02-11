//
//  ClubSetting.swift
//  kivopadmin
//
//  Created by Amine Ahamri on 11.02.25.
//


import Foundation

struct ClubSetting: Identifiable, Codable {
    var id: String
    var key: String
    var description: String?
    var value: String
    var datatype: String
}
