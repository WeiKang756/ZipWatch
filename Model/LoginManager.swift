//
//  LoginManager.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 03/01/2025.
//
import Supabase
import Foundation

protocol LoginManagerDelegate {
    func didSignIn(_ result: Bool, _ description: String, _ role: String?)
    func didSignOut()
}

extension LoginManagerDelegate {
    func didSignIn(_ result: Bool, _ description: String, _ role: String?){
        print("Did Sign In")
    }
    
    func didSignOut() {
        print("Did Sign Out")
    }
}

struct LoginManager {
    let supabase = SupabaseManager.shared.client
    var delegate: LoginManagerDelegate?
    
    
    func signIn(email: String, password: String) {
        Task {
            do {
                let authResponse = try await supabase.auth.signIn(
                    email: email,
                    password: password
                )
                
                // Fetch user's role from officials table
                let response: [Official] = try await supabase
                    .from("officials")
                    .select()
                    .eq("id", value: authResponse.user.id)
                    .execute()
                    .value
                
                if let official = response.first {
                    delegate?.didSignIn(true, "Login successful", official.type)
                } else {
                    try await supabase.auth.signOut()
                    delegate?.didSignIn(false, "User not found", nil)
                }
                
            } catch {
                delegate?.didSignIn(false, error.localizedDescription, nil)
            }
        }
    }
    
    private func checkIfOfficial(officialId: UUID) async throws -> Bool {
        let response: [Official] = try await supabase
            .from("officials")
            .select()
            .eq("id", value: officialId)
            .execute()
            .value
        
        return !response.isEmpty
    }
    
    func signOut() {
        Task{
            do{
                try await supabase.auth.signOut()
                print("Sign Out sucessful")
                delegate?.didSignOut()
            }catch {
                print(error.localizedDescription)
            }
        }
    }
}
