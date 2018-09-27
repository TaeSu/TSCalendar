//
//  TSCalendarWeekdayHeader.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 2018. 4. 23..
//

import UIKit

class TSCalendarWeekdayHeader: UIView {
    
    weak var lblWeekOfYear: UILabel!
    var lblWeekdays: [UILabel] = []
    var gregorian: Calendar!
    
    private let constraint = TSCalendarConstraints()
    private weak var appearance: TSCalendarAppearance!
    private var lblWeekOfYearWidthConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        assertionFailure("do not init frame")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assertionFailure("do not init corder")
    }
    
    convenience public init(appearance: TSCalendarAppearance, gregorian: Calendar) {
        self.init()
        self.appearance = appearance
        self.gregorian = gregorian
        initialize()
    }
    
    private func initialize() {
        prepareWeekOfYear()
        prepareWeekday()
        invalidateWeekdaySymbols()
    }
    
    private func prepareWeekOfYear() {
        let lblWeekOfYear = UILabel()
        lblWeekOfYear.text = "W"
        lblWeekOfYear.textColor = appearance.color.text.weekdayHeader
        constraint.addSubview(lblWeekOfYear, toItem: self)
        self.lblWeekOfYear = lblWeekOfYear
        
        constraint.attributes(item: lblWeekOfYear, toItem: self, types: [.top, .bottom, .leading])
        let constant: CGFloat = appearance.weekOfYear ? appearance.weekOfYearWidth : 0
        lblWeekOfYearWidthConstraint = constraint.width(parent: self, item: lblWeekOfYear, constant: constant)
    }
    
    private func prepareWeekday() {
        let view = UIView()
        constraint.addSubview(view, toItem: self)
        constraint.attributes(item: view, toItem: self, types: [.top, .bottom, .trailing])
        constraint.trailingLeading(parent: self, item: view, toItem: lblWeekOfYear)
        
        for index in 0...6 {
            autoreleasepool {
                let lblWeekday = UILabel()
                lblWeekday.textAlignment = .center
                lblWeekday.font = appearance.font.weekdayHeader
                lblWeekday.textColor = appearance.color.text.weekdayHeader
                constraint.addSubview(lblWeekday, toItem: view)
                constraint.attributes(item: lblWeekday, toItem: view, types: [.top, .bottom])
                if let previousWeekday = lblWeekdays.last {
                    constraint.equalWidth(parent: view, item: lblWeekday, toItem: previousWeekday)
                    constraint.trailingLeading(parent: view, item: lblWeekday, toItem: previousWeekday)
                    if index == 6 { //마지막
                        constraint.trailing(parent: view, item: lblWeekday)
                    }
                } else { //처음
                    constraint.leading(parent: view, item: lblWeekday)
                }
                lblWeekdays.append(lblWeekday)
            }
        }
    }
    
    // MARK: - Help
    private func invalidateWeekdaySymbols() {
        var weekdaySymbols = gregorian.shortWeekdaySymbols
        for _ in 1..<gregorian.firstWeekday {
            if let firstSymbol = weekdaySymbols.first {
                weekdaySymbols.removeFirst()
                weekdaySymbols.append(firstSymbol)
            }
        }
        for (index, lblWeekday) in lblWeekdays.enumerated() {
            lblWeekday.font = appearance.font.weekdayHeader
            lblWeekday.textColor = appearance.color.text.weekdayHeader
            lblWeekday.text = weekdaySymbols[index].uppercased()
        }
    }
    
    // MARK: - Public
    func weekOfYear() {
        if appearance.weekOfYear {
            lblWeekOfYearWidthConstraint.constant = appearance.weekOfYearWidth
        } else {
            lblWeekOfYearWidthConstraint.constant = 0
        }
    }
    
    func reloadData() {
        invalidateWeekdaySymbols()
    }
}
