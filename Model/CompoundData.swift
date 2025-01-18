//
//  CompoundData.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 18/01/2025.
//


import Foundation

struct CompoundData: Codable {
    let id: UUID
    let violation: ViolationData
    let location: String
    let status: String
    let paymentDate: Date?
    let amountPaid: Double?
    let createdAt: Date
    let plateNumber: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case violation = "violations"
        case location
        case status 
        case paymentDate = "payment_date"
        case amountPaid = "amount_paid"
        case createdAt = "created_at"
        case plateNumber = "plate_number"
    }
    
}
