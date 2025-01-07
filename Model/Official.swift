//
//  Official.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 03/01/2025.
//
import Foundation

struct Official: Codable {
    let id: UUID
    let name: String
    let officialId: String
    let createdAt: Date
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case officialId = "official_id"
        case createdAt = "created_at"
        case type
    }
}
