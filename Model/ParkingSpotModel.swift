//
//  ParkingSpotModel.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 04/01/2025.
//


import Foundation

struct ParkingSpotModel {
    let parkingSpotID: Int
    let isAvailable: Bool
    let type: String
    let latitude: Double
    let longitude: Double
    let streetName: String
    let areaName: String
    let distance: Double?
}
