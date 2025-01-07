//
//  AvailableParkingData.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 11/11/2024.
//

struct AvailableParkingData: Decodable{
    let id: Int
    let type: String
    let latitude: Double
    let longitude: Double
    let street: Street
    
    enum CodingKeys: String, CodingKey {
        case id = "parkingSpotID"
        case type = "type"
        case latitude = "latitude"
        case longitude = "longitude"
        case street = "Street"
    }
}
