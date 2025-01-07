//
//  ParkingData.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 04/10/2024.
//


import Foundation

struct ParkingSpotData: Decodable {
    let parkingSpotID: Int
    let latitude: Double
    let longitude: Double
    let type: String
    let isAvailable: Bool
    let street: Street
    
    enum CodingKeys: String, CodingKey {
        case parkingSpotID
        case type
        case latitude
        case longitude
        case isAvailable
        case street = "Street"
    }
}

struct Street: Decodable {
    let streetName: String
    let area: Area  // Changed from 'Area' to 'area'
    
    enum CodingKeys: String, CodingKey {
        case streetName
        case area = "Area"  // Added coding key to match JSON structure
    }
}

struct Area: Decodable {
    let areaName: String
}
