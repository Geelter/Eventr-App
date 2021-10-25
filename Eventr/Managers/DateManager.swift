//
//  DateManager.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 12/10/2021.
//

import Foundation

struct DateManager {
    static let shared = DateManager()
    
    func stringFromDate(using date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss'Z'"
        
        return dateFormatter.string(from: date)
    }

    func dateFromString(using string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssz"
        
        return dateFormatter.date(from: string)
    }
    
    func getDateStringForCell(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en-US")
        // Use E MMMd HH:mm for display in event cells
        dateFormatter.setLocalizedDateFormatFromTemplate("E MMMd HH:mm")
        
        return dateFormatter.string(from: date)
    }
}
