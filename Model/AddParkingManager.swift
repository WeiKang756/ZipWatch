//
//  AddParkingManager.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 15/01/2025.
//
import Foundation
import CoreLocation

protocol AddParkingManagerDelegate {
    func didAddArea()
    func didFailAddArea()
    func didAddStreet()
    func didFailAddStreet()
    func didAddParkingSpot()
    func didFailAddParkingSpot()
    func didFetchParkingSpotData(_ parkingSpotModels: [ParkingSpotModel])
    func didFailFetchParkingSpotData()
}

extension AddParkingManagerDelegate {
    func didAddArea() {
        print("Did Add Area")
    }
    func didFailAddArea(){
        print("Did fail Add Area")
    }
    func didAddStreet(){
        print("Did Add Street")
    }
    func didFailAddStreet(){
        print("Did fail Add Street")
    }
    func didAddParkingSpot(){
        print("Did Add Street")
    }

    func didFailAddParkingSpot(){
        print("Did fail Add Street")
    }
    
    func didFetchParkingSpotData(_ parkingSpotModels: [ParkingSpotModel]){
        print("Did fetch Street")
    }
    
    func didFailFetchParkingSpotData(){
        print("Did fetch Street")
    }
    
}
struct AddParkingManager {
    let supabase = SupabaseManager.shared.client
    var delegate: AddParkingManagerDelegate?
    
    func addArea(area: AreaInsertData) {
        Task{
            do{
                try await supabase
                    .from("Area")
                    .insert(area)
                    .execute()
                delegate?.didAddArea()
            }catch{
                print(error.localizedDescription)
                delegate?.didFailAddArea()
            }
        }
    }
    
    func addStreet(street: StreetInsertData) {
        Task{
            do{
                try await supabase
                    .from("Street")
                    .insert(street)
                    .execute()
                delegate?.didAddStreet()
            }catch{
                print(error.localizedDescription)
                delegate?.didFailAddStreet()
            }
        }
    }
    
    func addParkingSpot(parkingSpot: ParkingInsertData) {
        Task{
            do{
                try await supabase
                    .from("ParkingSpot")
                    .insert(parkingSpot)
                    .execute()
                
                delegate?.didAddParkingSpot()
            }catch {
                delegate?.didFailAddParkingSpot()
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchParkingSpot(streetID: Int){
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
                
                delegate?.didFetchParkingSpotData(parkingSpotModels)
                
            } catch {
                print("Error fetching parking spot data: \(error.localizedDescription)")
                delegate?.didFailFetchParkingSpotData()
            }
        }
    }
}
