//
//  Poll.swift
//  kivopadmin
//
//  Created by Amine Ahamri on 10.01.25.
//


import Foundation

struct Poll: Identifiable {
    let id: UUID
    let question: String
    let description: String
    let options: [String]
    let votes: [String: [Int]] // Nutzer-ID und gewählte Optionen
    let deadline: Date
    var isActive: Bool
    let allowsMultipleSelections: Bool // Neu hinzugefügt
}
