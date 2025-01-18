struct ViolationRequest: Codable {
    let violationCode: String
    let section: String
    let description: String
    let baseAmount: Double
    let amount7Days: Double
    let amount30Days: Double
    let amount60Days: Double
    
    // Add CodingKeys to match Supabase column names
    enum CodingKeys: String, CodingKey {
        case violationCode = "violation_code"
        case section
        case description
        case baseAmount = "base_amount"
        case amount7Days = "amount_7_days"
        case amount30Days = "amount_30_days"
        case amount60Days = "amount_60_days"
    }
    