//
//  AreaData.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 03/10/2024.
//

import Foundation

struct AreaData: Decodable {
    let areaID: Int
    let areaName: String
    let latitude: Double
    let longitude: Double
    let availableParking: Int?
    let totalParking: Int?
}
