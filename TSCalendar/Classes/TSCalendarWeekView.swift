//
//  TSCalendarWeekView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 2018. 4. 17..
//

import UIKit

open class TSCalendarWeekView: UIView {

    open var dayViews: [TSCalendarDayView] = []
    open var gregorian: Calendar!
    
    private let SUBVIEW_TAG = 1224
    private let constraint = TSCalendarConstraints()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        prepareDayViews()
    }
    
    private func prepareDayViews() {
        for index in 0...6 {
            autoreleasepool {
                let dayView = TSCalendarDayView()
                constraint.addSubview(dayView, toItem: self)
                constraint.attributes(item: dayView, toItem: self, types: [.top, .bottom])
                if let previousDayView = dayViews.last {
                    constraint.equalWidth(parent: self, item: dayView, toItem: previousDayView)
                    constraint.trailingLeading(parent: self, item: dayView, toItem: previousDayView)
                    if index == 6 { //마지막
                        constraint.trailing(parent: self, item: dayView)
                    }
                } else { //처음
                    constraint.leading(parent: self, item: dayView)
                }
                dayViews.append(dayView)
            }
        }
    }
    
    // MARK: - Helper
    private func index(date: Date) -> Int? {
        let index = dayViews.index { (dayView) -> Bool in
            if Calendar.current.isDate(dayView.date, inSameDayAs: date) {
                return true
            }
            return false
        }
        return index
    }
    
    // MARK: - Public
    open func startDate() -> Date? {
        return dayViews.first?.date
    }
    
    open func endDate() -> Date? {
        return dayViews.last?.date
    }
    
    open func endDateBeforeNextDate() -> Date? {
        if let date = dayViews.last?.date {
            if let tmpDate = gregorian.date(byAdding: .day, value: 1, to: date) {
                return gregorian.date(byAdding: .second, value: -1, to: tmpDate)
            }
        }
        return nil
    }
    
    open func dayView(date: Date) -> TSCalendarDayView? {
        if let index = index(date: date) {
            return dayViews[index]
        }
        return nil
    }
    
    open func minX(date: Date) -> CGFloat {
        if let index = index(date: date) {
            return minX(index: index)
        }
        return 0
    }
    
    open func minX(index: Int) -> CGFloat {
        if index < dayViews.count {
            return dayViews[index].frame.minX
        }
        return 0
    }
    
    open func manX(date: Date) -> CGFloat {
        if let index = index(date: date) {
            return manX(index: index)
        }
        return 0
    }
    
    open func manX(index: Int) -> CGFloat {
        if index < dayViews.count {
            return dayViews[index].frame.maxX
        }
        return 0
    }
    
    open func maxYForDay() -> CGFloat {
        if let dayView = dayViews.first {
            return dayView.maxYForDay()
        }
        return 0
    }
    
    open func add(_ view: UIView) {
        view.tag = SUBVIEW_TAG
        view.isUserInteractionEnabled = false
        addSubview(view)
    }
    
    open func insert(_ view: UIView, at: Int) {
        view.tag = SUBVIEW_TAG
        view.isUserInteractionEnabled = false
        insertSubview(view, at: at)
    }
    
    open func insert(_ view: UIView, aboveSubview: UIView) {
        view.tag = SUBVIEW_TAG
        view.isUserInteractionEnabled = false
        insertSubview(view, aboveSubview: aboveSubview)
    }
    
    open func insert(_ view: UIView, belowSubview: UIView) {
        view.tag = SUBVIEW_TAG
        view.isUserInteractionEnabled = false
        insertSubview(view, belowSubview: belowSubview)
    }
    
    open func reset() {
        for subview in subviews {
            if subview.tag == SUBVIEW_TAG {
                subview.removeFromSuperview()
            }
        }
    }
}
