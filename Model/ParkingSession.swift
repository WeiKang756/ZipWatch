import Foundation

struct ParkingSession: Decodable {
    let id: String
    let date: String
    let startTime: String
    let status: String
    let plateNumber: String
    let totalCost: Double
    let duration: String
    let endTime: String
    let parkingSpot: ParkingSpotData
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case startTime = "start_time"
        case status
        case parkingSpot = "ParkingSpot"
        case plateNumber = "plate_number"
        case totalCost = "total_cost"
        case duration
        case endTime = "end_time"
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // Updated format to include timezone
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)  // Handle UTC time
        return formatter
    }()
    
    func calculateTimeLeft() -> String {
        // Convert string to date
        guard let endTime = dateFormatter.date(from: endTime) else {
            print("Failed to parse date: \(endTime)") // Add debugging
            return "Invalid Time"
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Check if session has ended
        guard endTime > now else {
            return "Expired"
        }
        
        // Get time difference
        let components = calendar.dateComponents([.hour, .minute], from: now, to: endTime)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        
        // Format time remaining string
        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}


