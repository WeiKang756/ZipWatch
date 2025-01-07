//
//  OfficialManagerDelegate.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 06/01/2025.
//


import Foundation
import Supabase

protocol OfficialManagerDelegate: AnyObject {
    func didFetchCityOfficials(_ officials: [Official])
    func didFetchEnforcementOfficials(_ officials: [Official])
    func didFailWithError(_ error: Error)
}

class OfficialManager {
    let supabase = SupabaseManager.shared.client
    weak var delegate: OfficialManagerDelegate?
    
    func fetchCityOfficials() {
        Task {
            do {
                let response: [Official] = try await supabase
                    .from("officials")
                    .select()
                    .eq("type", value: "city_official")
                    .execute()
                    .value
                
                await MainActor.run {
                    delegate?.didFetchCityOfficials(response)
                }
            } catch {
                await MainActor.run {
                    delegate?.didFailWithError(error)
                }
            }
        }
    }
    
    func fetchEnforcementOfficials() {
        Task {
            do {
                let response: [Official] = try await supabase
                    .from("officials")
                    .select()
                    .eq("type", value: "enforcement_official")
                    .execute()
                    .value
                
                await MainActor.run {
                    delegate?.didFetchEnforcementOfficials(response)
                }
            } catch {
                await MainActor.run {
                    delegate?.didFailWithError(error)
                }
            }
        }
    }
    
}
