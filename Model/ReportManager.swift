//
//  ReportManager.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 04/01/2025.
//
import Supabase

protocol ReportManagerDelegate {
    func didFetchReports(_ reports: [ReportData])
}

struct ReportManager {
    let supabase = SupabaseManager.shared.client
    var delegate: ReportManagerDelegate?
     
    func fetchReport() {
        Task{
            do {
                // Fetch reports with related parking spot data
                let reports: [ReportData] = try await supabase
                    .from("reports")
                    .select("""
                        *,
                        ParkingSpot:parking_spot_id (
                            parkingSpotID,
                            latitude,
                            longitude,
                            type,
                            isAvailable,
                            Street (
                                streetName,
                                Area (
                                    areaName
                                )
                            )
                        )
                    """)
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                
                delegate?.didFetchReports(reports)
                
            } catch {
                print("Error fetching reports:", error.localizedDescription)
            }
        }
    }
}
