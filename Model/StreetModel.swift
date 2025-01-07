//
//  StreetModel.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 04/01/2025.
//


import Foundation

struct StreetModel {
    let streetID: Int
    let streetName: String
    let areaID: Int
    let numGreen: Int
    let numRed: Int
    let numYellow: Int
    let numDisable: Int
    let numAvailable: Int
    let parkingSpots: [ParkingSpotModel]
}
