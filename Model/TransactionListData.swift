//
//  TransactionListData.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 14/01/2025.
//

import Foundation


struct TransactionListData: Codable {
    let id: UUID
    let walletId: UUID 
    let typeId: Int
    let amount: Double
    let referenceId: String
    let transactionDate: String
    let transactionType: TransactionType
    
    enum CodingKeys: String, CodingKey {
        case id
        case walletId = "wallet_id"
        case typeId = "type_id"
        case amount
        case referenceId = "reference_id"
        case transactionDate = "transaction_date"
        case transactionType = "transaction_types"
    }
}

struct TransactionType: Codable {
    let name: String
}
