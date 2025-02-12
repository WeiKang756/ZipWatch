//
//  CompoundModel.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 18/01/2025.
//

import Foundation

struct CompoundModel: Codable {
    let id: UUID
    let plateNumber: String
    let status: String
    let location: String 
    let createdAt: Date
    let violation: ViolationModel
    
    enum CodingKeys: String, CodingKey {
        case id
        case plateNumber = "plate_number"
        case status
        case location
        case createdAt = "created_at"
        case violation = "violations"
    }
}
