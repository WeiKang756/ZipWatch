//
//  ParkingManager.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 07/01/2025.
//
import Foundation
import CoreLocation
import Supabase

// MARK: - Protocols
protocol ParkingManagerDelegate: AnyObject {
    func didFetchAreaData(_ areasModel: [AreaModel])
    func didFetchStreetAndParkingSpotData(_ streetsModel: [StreetModel])
    func didFetchParkingSpotData(_ parkingSpotModel: [ParkingSpotModel])
}

// MARK: - Default Protocol Implementation
extension ParkingManagerDelegate {
    func didFetchAreaData(_ areasModel: [AreaModel]) {
        print("Did fetch area data")
    }
    
    func didFetchStreetAndParkingSpotData(_ streetsModel: [StreetModel]) {
        print("Did fetch street data")
    }
    
    func didFetchParkingSpotData(_ parkingSpotModel: [ParkingSpotModel]) {
        print("Did fetch parking spot data")
    }
}

// MARK: - Error Types
enum ParkingManagerError: Error {
    case userLocationNotAvailable
    case parkingDataFetchFailed(areaID: Int)
    case streetDataFetchFailed(streetID: Int)
    case invalidData
}

// MARK: - MapManager Implementation
struct ParkingManager {
    // MARK: - Properties
    private let supabase = SupabaseManager.shared.client
    weak var delegate: ParkingManagerDelegate?
    
    // MARK: - Public Methods
    func fetchAreaData() {
        Task {
            do {
                
                let areasData: [AreaData] = try await supabase
                    .from("Area")
                    .select()
                    .execute()
                    .value
                
                var areasModel: [AreaModel] = []
                
                for areaData in areasData {
                    let areaLocation = CLLocation(latitude: areaData.latitude, longitude: areaData.longitude)
                    
                    let parkingSpotArray = await fetchParkingSpotArray(areaID: areaData.areaID)
                    
                    let areaModel = AreaModel(
                        areaID: areaData.areaID,
                        areaName: areaData.areaName,
                        latitude: areaData.latitude,
                        longtitude: areaData.longitude,
                        totalParking: parkingSpotArray?.totalParking,
                        availableParking: parkingSpotArray?.availableParking,
                        numGreen: parkingSpotArray?.numGreen,
                        numYellow: parkingSpotArray?.numYellow,
                        numRed: parkingSpotArray?.numRed,
                        numDisable: parkingSpotArray?.numDisable,
                        distance: nil
                    )
                    
                    areasModel.append(areaModel)
                }
                
                areasModel.sort { $0.distance ?? Double.infinity < $1.distance ?? Double.infinity }
                delegate?.didFetchAreaData(areasModel)
                
            } catch {
                print("Error fetching area data: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchStreetAndParkingSpotData(areaID: Int) {
        Task {
            do {
                let streetsData: [StreetData] = try await supabase
                    .from("Street")
                    .select()
                    .eq("areaID", value: areaID)
                    .execute()
                    .value
                
                var streetsModel: [StreetModel] = []
                
                for streetData in streetsData {
                    let streetID = streetData.streetID
                    
                    let parkingSpotsData: [ParkingSpotData] = try await supabase
                        .from("ParkingSpot")
                        .select("""
                            *, 
                            Street!inner(
                                streetName,
                                Area!inner(
                                    areaName
                                )
                            )
                        """)
                        .eq("streetID", value: streetID)
                        .execute()
                        .value
                    
                    var parkingSpotModels: [ParkingSpotModel] = []
                    
                    for parkingSpotData in parkingSpotsData {
                        let parkingLocation = CLLocation(latitude: parkingSpotData.latitude, longitude: parkingSpotData.longitude)
                        
                        let parkingSpotModel = ParkingSpotModel(
                            parkingSpotID: parkingSpotData.parkingSpotID,
                            isAvailable: parkingSpotData.isAvailable,
                            type: parkingSpotData.type,
                            latitude: parkingSpotData.latitude,
                            longitude: parkingSpotData.longitude,
                            streetName: parkingSpotData.street.streetName,
                            areaName: parkingSpotData.street.area.areaName,
                            distance: nil
                        )
                        
                        parkingSpotModels.append(parkingSpotModel)
                    }
                    
                   let streetInfoData = await fetchStreetInfo(streetID: streetID)
                    
                    let streetModel = StreetModel(
                        streetID: streetData.streetID,
                        streetName: streetData.streetName,
                        areaID: streetData.areaID,
                        numGreen: streetInfoData?.numGreen ?? 0,
                        numRed: streetInfoData?.numRed ?? 0,
                        numYellow: streetInfoData?.numYellow ?? 0,
                        numDisable: streetInfoData?.numDisable ?? 0,
                        numAvailable: streetInfoData?.numAvailable ?? 0,
                        parkingSpots: parkingSpotModels
                    )
                    
                    streetsModel.append(streetModel)
                }
                
                if !streetsModel.isEmpty {
                    delegate?.didFetchStreetAndParkingSpotData(streetsModel)
                } else {
                    delegate?.didFetchStreetAndParkingSpotData(streetsModel)
                    print("No street data available")
                }
                
            } catch {
                print("Error fetching street data: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchParkingSpotData() {
        Task {
            do {
                
                let parkingSpotsData: [ParkingSpotData] = try await supabase
                    .from("ParkingSpot")
                    .select("""
                        *, 
                        Street!inner(
                            streetName,
                            Area!inner(
                                areaName
                            )
                        )
                    """)
                    .eq("isAvailable", value: true)
                    .execute()
                    .value
                
                var parkingSpotModels: [ParkingSpotModel] = []
                
                for parkingSpotData in parkingSpotsData {
                    let parkingLocation = CLLocation(latitude: parkingSpotData.latitude, longitude: parkingSpotData.longitude)
                    
                    let parkingSpotModel = ParkingSpotModel(
                        parkingSpotID: parkingSpotData.parkingSpotID,
                        isAvailable: parkingSpotData.isAvailable,
                        type: parkingSpotData.type,
                        latitude: parkingSpotData.latitude,
                        longitude: parkingSpotData.longitude,
                        streetName: parkingSpotData.street.streetName,
                        areaName: parkingSpotData.street.area.areaName,
                        distance: nil
                    )
                    
                    parkingSpotModels.append(parkingSpotModel)
                }
                
                parkingSpotModels.sort { $0.distance! < $1.distance! }
                delegate?.didFetchParkingSpotData(parkingSpotModels)
                
            } catch {
                print("Error fetching parking spot data: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private Methods
    private func fetchParkingSpotArray(areaID: Int) async -> ParkingSpotArray? {
        do {
            let parkingSpotArray: ParkingSpotArray = try await supabase
                .rpc("get_area_parking_info", params: ["area_id": areaID])
                .execute()
                .value
            return parkingSpotArray
        } catch {
            print("Error fetching parking spot array: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func fetchStreetInfo(streetID: Int) async -> StreetInfoData? {
        do {
            let streetInfoData: StreetInfoData = try await supabase
                .rpc("get_available_parking_count_by_type_street", params: ["street_id": streetID])
                .execute()
                .value
            return streetInfoData
        } catch {
            print("Error fetching street info: \(error.localizedDescription)")
            return nil
        }
    }
    
    func calculateDistance(_ depart: CLLocation, _ destination: CLLocation) -> Double {
        return depart.distance(from: destination)
    }
    
    func distanceToDistanceString(distance: Double) -> String {
        var distance = distance
        let distanceString: String
        
        if distance > 1000 {
            distance = distance / 1000
            distanceString = String(format: "%.1f KM", distance)
        } else {
            distanceString = String(format: "%.0f M", distance)
        }
        
        return distanceString
    }
}
