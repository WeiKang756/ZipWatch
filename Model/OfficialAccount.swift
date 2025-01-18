//
//  OfficialAccount.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 05/01/2025.
//

import Foundation

struct OfficialAccount: Codable {
    let id: UUID
    let name: String
    let officialId: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case officialId = "official_id"
        case type
    }
}
