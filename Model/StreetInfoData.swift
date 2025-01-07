//
//  StreetInfoData.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 22/10/2024.
//

struct StreetInfoData: Decodable {
    let numGreen: Int
    let numRed: Int
    let numYellow: Int
    let numDisable: Int
    let numAvailable: Int
    
    enum CodingKeys: String, CodingKey {
        case numGreen = "green"
        case numRed = "red"
        case numYellow = "yellow"
        case numDisable = "disable"
        case numAvailable = "total_available"
    }
}
