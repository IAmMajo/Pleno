//
//  Poll.swift
//  kivopadmin
//
//  Created by Amine Ahamri on 10.01.25.
//


import Foundation

struct Poll: Identifiable {
    let id: UUID
    var question: String
    var description: String
    var options: [String]
    var votes: [String: Int]
    var deadline: Date
    var isActive: Bool
}
