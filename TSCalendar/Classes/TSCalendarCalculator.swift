//
//  TSCalendarCalculator.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 2018. 4. 17..
//

import UIKit

class TSCalendarCalculator: NSObject {
    
    private var numberOfMonths: Int = 0
    private var months: [Int: Date] = [:]
    private var monthHeads: [Int: Date] = [:]
    
    var minimumDate: Date = Date()
    var maximumDate: Date = Date()
    
    var gregorian: Calendar!
    
    // MARK: - Date
    func date(indexPath: IndexPath, index: Int) -> Date {
        let head = monthHead(indexPath.section)
        let daysOffset = indexPath.item
        let date = gregorian.date(byAdding: .day, value: daysOffset*7 + index, to: head)!
        return date
    }
    
    func indexPathAndIndex(date: Date, monthPosition: TSCalendarMonthPosition = .current) -> (indexPath: IndexPath, index: Int)  {
        var section = gregorian.dateComponents([.month], from: gregorian.ts_firstDayOfMonth(month: minimumDate), to: gregorian.ts_firstDayOfMonth(month: date)).month!
        switch monthPosition {
        case .previous:
            section += 1
        case .next:
            section -= 1
        case .current:
            break
        }
        let head = monthHead(section)
        let daysOffset = gregorian.dateComponents([.day], from: head, to: date).day!
        let item = daysOffset / 7
        let index = daysOffset % 7
        return (indexPath: IndexPath(item: item, section: section), index: index)
    }
    
    // MARK: - Month
    func month(_ section: Int) -> Date {
        if let month = months[section] {
            return month
        }
        let month = gregorian.date(byAdding: .month, value: section, to: gregorian.ts_firstDayOfMonth(month: minimumDate))!
        let numberOfHeadPlaceholders = self.numberOfHeadPlaceholders(month: month)
        let monthHead = gregorian.date(byAdding: .day, value: -numberOfHeadPlaceholders, to: month)!
        months[section] = month
        monthHeads[section] = monthHead
        return monthHead
    }
    
    func monthHead(_ section: Int) -> Date {
        if let monthHead = monthHeads[section] {
            return monthHead
        }
        let month = gregorian.date(byAdding: .month, value: section, to: gregorian.ts_firstDayOfMonth(month: minimumDate))!
        let numberOfHeadPlaceholders = self.numberOfHeadPlaceholders(month: month)
        let monthHead = gregorian.date(byAdding: .day, value: -numberOfHeadPlaceholders, to: month)!
        months[section] = month
        monthHeads[section] = monthHead
        return monthHead
    }
    
    func numberOfHeadPlaceholders(month: Date) -> Int {
        let currentWeekday = gregorian.component(.weekday, from: month)
        let number = (currentWeekday - gregorian.firstWeekday + 7) % 7
        return number
    }
    
    // MARK: - Section
    func numberOfSections() -> Int {
        return numberOfMonths
    }
    
    func reloadSections() {
        numberOfMonths = gregorian.dateComponents([.month], from: gregorian.ts_firstDayOfMonth(month: minimumDate), to: maximumDate).month! + 1
    }
    
    func reloadData() {
        months.removeAll()
        monthHeads.removeAll()
        reloadSections()
    }
}
