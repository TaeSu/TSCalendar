//
//  TSCalendarExtension.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 2018. 4. 17..
//

import UIKit

extension Calendar {
    func ts_firstDayOfMonth(month: Date) -> Date {
        var components = dateComponents([.year, .month, .day], from: month)
        components.day = 1
        return date(from: components)!
    }
    
    func ts_lastDayOfMonth(month: Date) -> Date {
        var components = dateComponents([.year, .month, .day], from: month)
        components.month! += 1
        components.day = 0
        return date(from: components)!
    }
    
    func ts_dateByIgnoringTime(_ date: Date) -> Date {
        let components = dateComponents([.year, .month, .day], from: date)
        return self.date(from: components)!
    }
}
