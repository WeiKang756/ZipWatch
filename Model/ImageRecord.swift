//
//  ImageRecord.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 18/12/2024.
//

import Foundation

struct ImageRecord: Codable {
    let reportID: UUID
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case reportID = "report_id"
        case imageURL = "image_url"
    }
}
