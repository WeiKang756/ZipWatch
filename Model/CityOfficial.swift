//
//  CityOfficial.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 06/01/2025.
//


import Foundation

struct CityOfficial: Codable {
    let id: UUID
    let officialId: String
    let name: String
    let email: String
    let role: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case officialId = "official_id"
        case name
        case email
        case role
        case status
    }
}

struct EnforcementOfficial: Codable {
    let id: UUID
    let officialId: String
    let name: String
    let email: String
    let zone: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case officialId = "official_id"
        case name
        case email
        case zone
        case status
    }
}