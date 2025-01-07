//
//  LoginManager.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 03/01/2025.
//
import Supabase
import Foundation

protocol LoginManagerDelegate {
    func didSignIn(_ result: Bool, _ description: String)
    func didSignOut()
}

extension LoginManagerDelegate {
    func didSignIn(_ result: Bool, _ description: String){
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
                
                let isOfficial = try await checkIfOfficial(officialId: authResponse.user.id)
                
                if isOfficial {
                    delegate?.didSignIn(true, "Login successful")
                } else {
                    try await supabase.auth.signOut()
                    delegate?.didSignIn(false, "Unauthorized access. Only officials can login.")
                }
                
            } catch {
                delegate?.didSignIn(false, error.localizedDescription)
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
