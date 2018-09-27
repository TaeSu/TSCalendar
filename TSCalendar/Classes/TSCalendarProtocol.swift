//
//  TSCalendarProtocol.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 2018. 4. 17..
//

import UIKit

@objc public protocol TSCalendarDataSource: NSObjectProtocol {
    @objc optional func calendar(_ calendar: TSCalendar, weekWillDisplay weekView: TSCalendarWeekView)
    @objc optional func calendar(_ calendar: TSCalendar, dayWillDisplay dayView: TSCalendarDayView)
}

@objc public protocol TSCalendarDelegate: NSObjectProtocol {
    @objc optional func calendar(_ calendar: TSCalendar, pageWillChange date: Date)
    @objc optional func calendar(_ calendar: TSCalendar, pageDidChange date: Date)
    
    @objc optional func calendar(_ calendar: TSCalendar, focusDidChange date: Date)
    @objc optional func calendar(_ calendar: TSCalendar, didSelect date: Date)
}
