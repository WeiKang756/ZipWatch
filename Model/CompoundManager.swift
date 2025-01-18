//
//  AddCompoundManager.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 18/01/2025.
//
import Foundation

struct Response: Codable {
    let compoundID: UUID
}

protocol CompoundManagerDelegate {
    func didCreateCompound()
    func didFailCreateCompound(_ error: Error)
}

struct CompoundManager {
    let supabase = SupabaseManager.shared.client
    var delegate: CompoundManagerDelegate?
    
    func createCompound(compoundData: CompoundInsertData) {
        Task{
            do{
                let response: String = try await supabase
                    .rpc("create_compound",
                         params: [
                        "p_violation_id": compoundData.violationId.uuidString,
                        "p_plate_number": compoundData.plateNumber,
                        "p_location": compoundData.location
                    ])
                    .execute()
                    .value
                print(response)
                delegate?.didCreateCompound()
                
            }catch {
                print(error.localizedDescription)
                delegate?.didFailCreateCompound(error)
            }
        }
    }
}
