//
//  ParkingSpotArray.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 20/10/2024.
//

struct ParkingSpotArray: Decodable{
    let numGreen: Int?
    let numYellow: Int?
    let numRed: Int?
    let numDisable: Int?
    let totalParking: Int?
    let availableParking: Int?
    
    enum CodingKeys: String, CodingKey {
        case numGreen = "green"
        case numYellow = "yellow"
        case numRed = "red"
        case numDisable = "disable"
        case totalParking = "totalParking"
        case availableParking = "availableParking"
    }
}
