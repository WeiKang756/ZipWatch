//
//  ParkingInsertData.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 15/01/2025.
//

struct ParkingInsertData: Codable {
    let parkingSpotID: Int
    let streetID: Int
    let latitude: Double
    let longitude: Double
    let type: String
    var isAvailable: Bool = true
}
