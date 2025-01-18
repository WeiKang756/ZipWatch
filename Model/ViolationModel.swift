//
//  ViolationModel.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 18/01/2025.
//


struct ViolationModel: Codable {
    let violationCode: String
    
    enum CodingKeys: String, CodingKey {
        case violationCode = "violation_code"
    }
}