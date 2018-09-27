//
//  TSCalendarDayView.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 2018. 4. 17..
//

import UIKit

protocol TSCalendarDayViewDelegate: NSObjectProtocol {
    func calendarDayViewDidSelect(_ dayView: TSCalendarDayView)
}

public enum TSCalendarDayViewTodayType {
    case circle
    case rectangle
}

public enum TSCalendarDayViewSelectedType {
    case circle
    case rectangle
}

open class TSCalendarDayView: UIView {
    
    weak var calendar: TSCalendar!
    weak var delegate: TSCalendarDayViewDelegate?
    var gregorian: Calendar!
    weak var appearance: TSCalendarAppearance!
    
    var isPlaceholder: Bool = false
    open var dayOfTheWeek: TSCalendarDayOfTheWeek!
    open var isHoliday: Bool = false
    
    open var date: Date = Date() {
        didSet(oldVal) {
            lblDay.text = formatter.string(from: date)
            lblDay.sizeToFit()
            setupDayOfTheWeek()
            lblDay.font = appearance.font.days
        }
    }
    
    open var topRightText: String? = nil {
        didSet {
            lblTopRight.text = topRightText
            lblTopRight.sizeToFit()
            textColorTopRight = appearance.color.text.topRight
            lblTopRight.font = appearance.font.topRight
        }
    }
    
    open var textColor: UIColor? {
        willSet(newVal) {
            lblDay.textColor = newVal
        }
    }

    open var textColorTopRight: UIColor? {
        willSet(newVal) {
            lblTopRight.textColor = newVal
        }
    }
    
    var isToday: Bool = false {
        willSet(newVal) {
            if newVal {
                addToday()
            } else {
                removeToday()
            }
        }
    }
    
    var isSelected: Bool = false {
        willSet(newVal) {
            if newVal {
                performSelecting()
            } else {
                performDeselecting()
            }
        }
    }
    
    var todayType: TSCalendarDayViewTodayType = .circle
    var selectedType: TSCalendarDayViewSelectedType = .circle
    
    private weak var viewDay: UIView!
    private weak var lblDay: UILabel!
    private weak var lblTopRight: UILabel!
    private weak var viewIcon: UIView!
    private weak var viewToday: UIView?             // TSCalendarDayViewTodayType.rectangle
    private weak var todayLayer: CAShapeLayer?      // TSCalendarDayViewTodayType.circle
    private weak var selectedLayer: CAShapeLayer?
    private weak var selectedDay: UIView?
    
    private let formatter = DateFormatter()
    
    private let SUBVIEW_TAG = 1224
    private let constraint = TSCalendarConstraints()
    
    private var isFirstLoad: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        formatter.dateFormat = "d"
        prepareDay()
        prepareTopRight()
        prepareIcon()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if isFirstLoad {
            isFirstLoad = false
            if isSelected {
                performSelecting()
            } else {
                performDeselecting()
            }
        }
    }
    
    private func prepareDay() {
        let view = UIView()
        let lblDay = UILabel()
        constraint.addSubview(lblDay, toItem: view)
        self.lblDay = lblDay
        constraint.attributes(item: lblDay, toItem: view, types: [.centerX, .centerY])
        
        constraint.addSubview(view, toItem: self)
        self.viewDay = view
        constraint.top(parent: self, item: view, constant: 2)
        constraint.centerX(parent: self, item: view)
        constraint.width(parent: self, item: view, constant: 20)
        constraint.height(parent: self, item: view, constant: 20)
    }
    
    private func prepareTopRight() {
        let lblTopRight = UILabel()
        constraint.addSubview(lblTopRight, toItem: self)
        self.lblTopRight = lblTopRight
        constraint.top(parent: self, item: lblTopRight, constant: 0)
//        constraint.trailingLeading(parent: self, item: lblTopRight, toItem: viewDay, constant: 7)
        constraint.trailing(parent: self, item: lblTopRight, constant: -1)
    }
    
    private func prepareIcon() {
        let view = UIView()
        
        constraint.addSubview(view, toItem: self)
        self.viewIcon = view
        constraint.attributes(item: view, toItem: self, types: [.leading, .trailing])
        constraint.bottomTop(parent: self, item: view, toItem: viewDay, constant: 4)
        constraint.height(parent: self, item: view, constant: 9)
    }
    
    // MARK: - Helper
    private func setupDayOfTheWeek() {
        if let dayOfTheWeek = gregorian.dateComponents([.weekday], from: date).weekday {
            switch dayOfTheWeek {
            case 1:
                self.dayOfTheWeek = .sunday
                self.textColor = appearance.color.text.sunday
            case 2:
                self.dayOfTheWeek = .monday
                self.textColor = appearance.color.text.weekday
            case 3:
                self.dayOfTheWeek = .tuesday
                self.textColor = appearance.color.text.weekday
            case 4:
                self.dayOfTheWeek = .wednesday
                self.textColor = appearance.color.text.weekday
            case 5:
                self.dayOfTheWeek = .thursday
                self.textColor = appearance.color.text.weekday
            case 6:
                self.dayOfTheWeek = .friday
                self.textColor = appearance.color.text.weekday
            case 7:
                self.dayOfTheWeek = .saturday
                self.textColor = appearance.color.text.saturday
            default:
                break
            }
        }
    }
    
    private func addToday() {
        self.todayLayer?.removeFromSuperlayer()
        self.todayLayer = nil
        self.viewToday?.removeFromSuperview()
        self.viewToday = nil
        
        if todayType == .circle {
            let bgColor: UIColor
            let textColor: UIColor
            if isHoliday {
                bgColor = appearance.color.bg.today.circle.sunday
                textColor = appearance.color.text.today.circle.sunday
            } else {
                switch dayOfTheWeek {
                case .sunday?:
                    bgColor = appearance.color.bg.today.circle.sunday
                    textColor = appearance.color.text.today.circle.sunday
                case .saturday?:
                    bgColor = appearance.color.bg.today.circle.saturday
                    textColor = appearance.color.text.today.circle.saturday
                default:
                    bgColor = appearance.color.bg.today.circle.weekday
                    textColor = appearance.color.text.today.circle.weekday
                }
            }
            
            let todayLayer: CAShapeLayer = CAShapeLayer()
            let radius = appearance.size.circleRadius
            todayLayer.frame = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
            let path: CGPath = UIBezierPath(ovalIn: todayLayer.bounds).cgPath
            if todayLayer.path != path {
                todayLayer.path = path
            }
            let cellFillColor: CGColor = bgColor.cgColor
            if todayLayer.fillColor != cellFillColor {
                todayLayer.fillColor = cellFillColor
            }
            viewDay.layer.insertSublayer(todayLayer, at: 0)
            self.todayLayer = todayLayer
            
            lblDay.textColor = textColor
        } else {
            let bgColor: UIColor
            let textColor: UIColor
            if isHoliday {
                bgColor = appearance.color.bg.today.rectangle.sunday
                textColor = appearance.color.text.today.rectangle.sunday
            } else {
                switch dayOfTheWeek {
                case .sunday?:
                    bgColor = appearance.color.bg.today.rectangle.sunday
                    textColor = appearance.color.text.today.rectangle.sunday
                case .saturday?:
                    bgColor = appearance.color.bg.today.rectangle.saturday
                    textColor = appearance.color.text.today.rectangle.saturday
                default:
                    bgColor = appearance.color.bg.today.rectangle.weekday
                    textColor = appearance.color.text.today.rectangle.weekday
                }
            }
            
            let viewToday = UIView()
            viewToday.backgroundColor = bgColor

            insertSubview(viewToday, at: 0)
            viewToday.translatesAutoresizingMaskIntoConstraints = false
            constraint.attributes(parent: superview, item: viewToday, toItem: self, types: [.top, .bottom, .leading, .trailing])

            self.viewToday = viewToday
            
            lblDay.textColor = textColor
        }
    }

    private func removeToday() {
        todayLayer?.removeFromSuperlayer()
        todayLayer = nil
        viewToday?.removeFromSuperview()
        viewToday = nil
        
        lblDay.textColor = textColor
    }

    private func performSelecting() {
        if selectedType == .circle {
            performSelectingForCircle()
        } else {
            performSelectingForRectangle()
        }
    }
    
    private func performDeselecting() {
        selectedLayer?.removeFromSuperlayer()
        selectedLayer = nil
        self.selectedDay?.removeFromSuperview()
        self.selectedDay = nil
    }
    
    private func performSelectingForCircle() {
        performDeselecting()
        
        let selectedLayer: CAShapeLayer = CAShapeLayer()

        let radius = appearance.size.circleRadius
        selectedLayer.frame = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
        let path: CGPath = UIBezierPath(ovalIn: selectedLayer.bounds).cgPath
        if selectedLayer.path != path {
            selectedLayer.path = path
        }
        let cellFillColor: CGColor = UIColor.clear.cgColor
        if selectedLayer.fillColor != cellFillColor {
            selectedLayer.fillColor = cellFillColor
        }
        let cellBorderColor: CGColor =  appearance.color.text.selectedDate.cgColor
        if selectedLayer.strokeColor != cellBorderColor {
            selectedLayer.strokeColor = cellBorderColor
        }
        layer.addSublayer(selectedLayer)
        self.selectedLayer = selectedLayer
    }
    
    private func performSelectingForRectangle() {
        performDeselecting()
        
        let selectedDay = UILabel()
        if let superview = superview {
            constraint.addSubview(selectedDay, toItem: superview)
            self.selectedDay = selectedDay
            constraint.attributes(parent: superview, item: selectedDay, toItem: self, types: [.top, .bottom, .leading, .trailing])
        } else {
            constraint.addSubview(selectedDay, toItem: self)
            self.selectedDay = selectedDay
            constraint.attributes(item: selectedDay, toItem: self, types: [.top, .bottom, .leading, .trailing])
        }
        
        selectedDay.layer.borderColor = appearance.color.text.selectedDate.cgColor
        selectedDay.layer.borderWidth = 1
    }
    
    // MARK: - override
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        if let selectedLayer = selectedLayer {
            if selectedType == .circle {
                let radius = appearance.size.circleRadius
                selectedLayer.frame = CGRect(x: viewDay.center.x-radius, y: viewDay.center.y-radius, width: radius*2, height: radius*2)
            }
        }
    }
    
    // MARK: - Touch
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        delegate?.calendarDayViewDidSelect(self)
    }
    
    // MARK: - Public
    open func dayView() -> UIView {
        return viewDay
    }
    
    open func iconView() -> UIView {
        return viewIcon
    }
    
    open func endDateBeforeNextDate() -> Date? {
        if let tmpDate = gregorian.date(byAdding: .day, value: 1, to: date) {
            return gregorian.date(byAdding: .second, value: -1, to: tmpDate)
        }
        return nil
    }
    
    open func maxYForDay() -> CGFloat {
        return viewDay.frame.maxY
    }
    
    open func addIcons(_ views: [UIView]) {
        if views.count >= 3 {
            constraint.addSubview(views[0], toItem: viewIcon)
            constraint.addSubview(views[1], toItem: viewIcon)
            constraint.addSubview(views[2], toItem: viewIcon)
            
            constraint.centerX(parent: viewIcon, item: views[1])
            constraint.centerY(parent: viewIcon, item: views[1])
            
            constraint.leadingTrailing(parent: viewIcon, item: views[0], toItem: views[1], constant: -3)
            constraint.centerY(parent: viewIcon, item: views[0])
            
            constraint.trailingLeading(parent: viewIcon, item: views[2], toItem: views[1], constant: 3)
            constraint.centerY(parent: viewIcon, item: views[2])
        } else if views.count == 2 {
            let view = UIView()
            
            constraint.addSubview(view, toItem: viewIcon)
            constraint.addSubview(views[0], toItem: viewIcon)
            constraint.addSubview(views[1], toItem: viewIcon)
            
            constraint.centerX(parent: viewIcon, item: view)
            constraint.centerY(parent: viewIcon, item: view)
            constraint.width(parent: viewIcon, item: view, constant: 0)
            
            constraint.leadingTrailing(parent: viewIcon, item: views[0], toItem: view, constant: -1.5)
            constraint.centerY(parent: viewIcon, item: views[0])
            
            constraint.trailingLeading(parent: viewIcon, item: views[1], toItem: view, constant: 1.5)
            constraint.centerY(parent: viewIcon, item: views[1])
        } else {
            constraint.addSubview(views[0], toItem: viewIcon)
            constraint.centerX(parent: viewIcon, item: views[0])
            constraint.centerY(parent: viewIcon, item: views[0])
        }
    }
    
    open func addLastIconText(_ text: String) {
        // 항상 마지막이 아이콘에 텍스트를 기제한다.
        if let subview = viewIcon.subviews.last {
            let lblPill = UILabel()
            lblPill.font = UIFont.systemFont(ofSize: 7)
            lblPill.text = text
            lblPill.isUserInteractionEnabled = false
            constraint.addSubview(lblPill, toItem: viewIcon)
            constraint.attributes(item: lblPill, toItem: viewIcon, types: [.top, .bottom])
            constraint.trailingLeading(parent: viewIcon, item: lblPill, toItem: subview, constant: 2)
        }
    }
    
    open func resetIcons() {
        for subview in viewIcon.subviews {
            subview.removeFromSuperview()
        }
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
        resetIcons()
    }
}
