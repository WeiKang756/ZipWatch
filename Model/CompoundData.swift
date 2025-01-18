import Foundation

struct CompoundData: Codable {
    let id: UUID
    let violationId: UUID
    let location: String
    let status: String
    let paymentDate: Date?
    let amountPaid: Double?
    let createdAt: Date
    let plateNumber: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case violationId = "violation_id"
        case location
        case status 
        case paymentDate = "payment_date"
        case amountPaid = "amount_paid"
        case createdAt = "created_at"
        case plateNumber = "plate_number"
    }
    
    // Custom decoding initialization for handling optional dates
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        id = try container.decode(UUID.self, forKey: .id)
        violationId = try container.decode(UUID.self, forKey: .violationId)
        location = try container.decode(String.self, forKey: .location)
        status = try container.decode(String.self, forKey: .status)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        plateNumber = try container.decode(String.self, forKey: .plateNumber)
        
        // Optional fields
        paymentDate = try container.decodeIfPresent(Date.self, forKey: .paymentDate)
        amountPaid = try container.decodeIfPresent(Double.self, forKey: .amountPaid)
    }
}

// Extension for mocking data (helpful for testing and UI development)
extension CompoundData {
    static var mockData: CompoundData {
        return CompoundData(
            id: UUID(),
            violationId: UUID(),
            location: "Jalan Api-Api, Kota Kinabalu",
            status: "pending",
            paymentDate: nil,
            amountPaid: nil,
            createdAt: Date(),
            plateNumber: "SAB1234A"
        )
    }
}