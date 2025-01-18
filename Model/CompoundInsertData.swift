//
//  CompoundInsertData.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 18/01/2025.
//

import Foundation


struct CompoundInsertData: Codable {
    let violationId: UUID
    let plateNumber: String
    let location: String
    
    enum CodingKeys: String, CodingKey {
        case violationId = "violation_id"
        case plateNumber = "plate_number"
        case location
    }
}
