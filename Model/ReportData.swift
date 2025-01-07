//
//  ReportData.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 05/01/2025.
//


//
//  reportData.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 18/12/2024.
//

import Foundation

struct ReportData: Codable {
    let id: UUID?
    let userID: UUID
    let parkingSpotID: Int
    let issueType: String
    let description: String
    let status: String
    let date: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case parkingSpotID = "parking_spot_id"
        case issueType = "issue_type"
        case description
        case status
        case date = "created_at"
    }
}
