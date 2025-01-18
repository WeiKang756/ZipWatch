struct ViolationModel: Codable {
    let violationCode: String
    
    enum CodingKeys: String, CodingKey {
        case violationCode = "violation_code"
    }
}