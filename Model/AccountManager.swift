import Foundation
import Supabase

protocol AccountManagerDelegate {
    func didCreateAccount(_ officialData: OfficialAccount)
    func didFailCreateAccount(_ error: String)
}

// Match the Edge Function response structure
struct AccountResponse: Decodable {
    let message: String
    let data: OfficialAccount?
    let error: String?
}

struct AccountManager {
    let supabase = SupabaseManager.shared.client
    var delegate: AccountManagerDelegate?
    
    func createAccount(accountDetail: AccountDetail) {
        let requestBody = [
            "email": accountDetail.email,
            "name": accountDetail.name,
            "password": accountDetail.password,
            "role": accountDetail.role,
            "officialId": accountDetail.officialId
        ]
        
        Task {
            do {
                // Use decodeResponse directly
                let responseData: AccountResponse = try await supabase.functions.invoke(
                    "create-account",
                    options: FunctionInvokeOptions(body: requestBody)
                )
                
                if let error = responseData.error {
                    delegate?.didFailCreateAccount(error)
                } else if let officialData = responseData.data {
                    print("Account created successfully: \(responseData.message)")
                    delegate?.didCreateAccount(officialData)
                } else {
                    delegate?.didFailCreateAccount("Unknown error occurred")
                }
                
            } catch {
                print("Error creating account: \(error)")
                delegate?.didFailCreateAccount(error.localizedDescription)
            }
        }
    }
    
    func fetchOfficialWithEmail(id: UUID) async throws {
        // Get user data from Auth
        try await supabase.auth.admin.deleteUser(id: "\(id)")
    }
}

// Helper extension for debugging
extension AccountManager {
    func printResponseData(_ data: Data) {
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw Response: \(jsonString)")
        }
    }
}
