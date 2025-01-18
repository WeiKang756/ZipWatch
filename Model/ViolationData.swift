//
//  ViolationData.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 16/01/2025.
//
import Foundation

struct ViolationData: Codable {
    let id: UUID
    let violationCode: String
    let section: String
    let description: String
    let baseAmount: Double
    let amount7Days: Double
    let amount30Days: Double
    let amount60Days: Double
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case violationCode = "violation_code"
        case section
        case description
        case baseAmount = "base_amount"
        case amount7Days = "amount_7_days"
        case amount30Days = "amount_30_days"
        case amount60Days = "amount_60_days"
        case createdAt = "created_at"
    }
}
