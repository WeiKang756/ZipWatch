//
//  DateFormatterUtility.swift
//  ZipWatch
//
//  Created by Wei Kang Tan on 05/01/2025.
//


//
//  DateFormatterUtility.swift
//  Map(1.0)
//
//  Created by Wei Kang Tan on 12/12/2024.
//
import UIKit

class DateFormatterUtility {
    // Shared instance for reuse
    static let shared = DateFormatterUtility()
    
    // Base formatter for parsing API dates
    private let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    // Various formatting options
    enum Format {
        case time           // 2:30 PM
        case date          // Dec 4, 2024
        case dateTime      // Dec 4, 2024 at 2:30 PM
        case shortTime     // 14:30
        case fullDate      // December 4, 2024
        case custom(String) // Custom format
        
        var formatString: String {
            switch self {
            case .time:
                return "h:mm a"
            case .date:
                return "MMM d, yyyy"
            case .dateTime:
                return "MMM d, yyyy 'at' h:mm a"
            case .shortTime:
                return "HH:mm"
            case .fullDate:
                return "MMMM d, yyyy"
            case .custom(let format):
                return format
            }
        }
    }
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSSSSSZZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    func formatTime(_ timeString: String) -> String {
        // Convert to readable time format (e.g., "7:16 PM")
        if let date = timeFormatter.date(from: timeString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "h:mm a" // This will give format like "7:16 PM"
            return outputFormatter.string(from: date)
        }
        return timeString // Return original string if parsing fails
    }
    
    // Format API date string to desired format
    func formatDate(_ dateString: String, to format: Format) -> String {
        guard let date = apiDateFormatter.date(from: dateString) else {
            return "Invalid Date"
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = format.formatString
        return outputFormatter.string(from: date)
    }
    
    // Convert API date string to Date object
    func dateFromString(_ dateString: String) -> Date? {
        return apiDateFormatter.date(from: dateString)
    }
    
    // Format Date object to desired format
    func formatDate(_ date: Date, to format: Format) -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = format.formatString
        return outputFormatter.string(from: date)
    }
    
    func formatDuration(_ durationString: String) -> String {
        let components = durationString.split(separator: ":")
        if components.count == 3 {
            let hours = Int(components[0]) ?? 0
            let minutes = Int(components[1]) ?? 0
            return "\(hours)h \(minutes)m"
        }
        return durationString
    }
}
