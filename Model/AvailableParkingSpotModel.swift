//
//  ParkingSpotModel 2.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 11/11/2024.
//


struct AvailableParkingSpotModel {
    let parkingSpotID: Int
    let type: String
    let latitude: Double
    let longitude: Double
    let distance: Double
    let areaName: String
    let streetName: String
    
    struct ParkingSpotModel {
        let parkingSpotID: Int
        let isAvailable: Bool
        let type: String
        let latitude: Double
        let longitude: Double
        let streetID: Int
        let distance: Double?
        let areaName: String?
        let streetName: String?
    }
}
