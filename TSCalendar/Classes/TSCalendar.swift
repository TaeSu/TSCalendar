//
//  TSCalendar.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 2018. 4. 17..
//

import UIKit

enum TSCalendarMonthPosition {
    case previous
    case current
    case next
}

public enum TSCalendarDayOfTheWeek {
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

open class TSCalendar: UIView {
    
    open weak var dataSource: TSCalendarDataSource?
    open weak var delegate: TSCalendarDelegate?
    
    open var gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
    public let appearance = TSCalendarAppearance()
    open var isSelectable: Bool = true
    
    private var cToday: Date?
    open var customToday: Date? {
        willSet(newVal) {
            if let newVal = newVal {
                cToday = gregorian.ts_dateByIgnoringTime(newVal)
            }
        }
    }
    
    private var selectedDate: Date?
    open var customSelectedDate: Date? {
        willSet(newVal) {
            if let newVal = newVal {
                selectedDate = gregorian.ts_dateByIgnoringTime(newVal)
            }
        }
    }
    
    private let CellIdentifier = "TSCalendarWeekCell"
    private var calculator = TSCalendarCalculator()
    private let formatter = DateFormatter()
    
    private var currentPage: Date! {
        didSet(oldVal) {
            delegate?.calendar?(self, pageDidChange: currentPage)
        }
        willSet(newVal) {
            delegate?.calendar?(self, pageWillChange: newVal)
        }
    }
    
    private var minimumDate: Date!
    private var maximumDate: Date!
    
    private weak var weekdayHeader: TSCalendarWeekdayHeader!
    private weak var collectionView: TSCalendarCollectionView!
    
    private let constraint = TSCalendarConstraints()
    private var todayType = TSCalendarDayViewTodayType.circle
    private var selectedType = TSCalendarDayViewSelectedType.circle
    
    private var isFirstLoad: Bool = true
    
    private var firstWeekday: Int = 1   //sunday
    private var locale: Locale = Locale.autoupdatingCurrent
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        formatter.dateFormat = "yyyy-MM-dd"
        minimumDate = formatter.date(from: "2018-01-01")
        maximumDate = formatter.date(from: "2018-12-31")
        gregorian.locale = locale
        calculator.gregorian = gregorian
        calculator.minimumDate = minimumDate
        calculator.maximumDate = maximumDate
        
        let weekdayHeader = TSCalendarWeekdayHeader(appearance: appearance, gregorian: gregorian)
        constraint.addSubview(weekdayHeader, toItem: self)
        self.weekdayHeader = weekdayHeader
        constraint.attributes(item: weekdayHeader, toItem: self, types: [.top, .leading, .trailing])
        constraint.height(parent: self, item: weekdayHeader, constant: 21)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        let collectionView = TSCalendarCollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        constraint.addSubview(collectionView, toItem: self)
        self.collectionView = collectionView
        constraint.attributes(item: collectionView, toItem: self, types: [.bottom, .leading, .trailing])
        constraint.bottomTop(parent: self, item: collectionView, toItem: weekdayHeader)
        
        calculator.reloadSections()
        collectionView.register(TSCalendarWeekCell.classForCoder(), forCellWithReuseIdentifier: CellIdentifier)
        
        currentPage = gregorian.ts_firstDayOfMonth(month: minimumDate)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if isFirstLoad {
            isFirstLoad = false
            weekdayHeader.reloadData()
            if let customSelectedDate = customSelectedDate {
                focus(date: customSelectedDate, animated: false)
            } else {
                today(animated: false)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TSCalendar: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return calculator.numberOfSections()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as! TSCalendarWeekCell
        cell.lblWeekOfYearWidthConstraint.constant = appearance.weekOfYear ? appearance.weekOfYearWidth : 0
        configure(cell: cell, indexPath: indexPath)
        dataSource?.calendar?(self, weekWillDisplay: cell.weekView)
        return cell
    }
    
    private func configure(cell: TSCalendarWeekCell, indexPath: IndexPath) {
        let section = indexPath.section
        let month = gregorian.date(byAdding: .month, value: section, to: minimumDate)!
        cell.weekView.gregorian = gregorian
        for (index, dayView) in cell.weekView.dayViews.enumerated() {
            
            let date = calculator.date(indexPath: indexPath, index: index)
            dayView.calendar = self
            dayView.delegate = self
            dayView.gregorian = gregorian
            dayView.appearance = appearance
            dayView.todayType = todayType
            dayView.selectedType = selectedType
            dayView.date = date
            
            dataSource?.calendar?(self, dayWillDisplay: dayView)
            
            switch gregorian.compare(date, to: month, toGranularity: .month) {
            case .orderedAscending:
                dayView.isPlaceholder = true
            case .orderedDescending:
                dayView.isPlaceholder = true
            case .orderedSame:
                dayView.isPlaceholder = false
                if let cToday = cToday, gregorian.isDate(date, inSameDayAs: cToday) {
                    dayView.isToday = true
                } else if gregorian.isDateInToday(date) {
                    dayView.isToday = true
                }
                if let selectedDate = selectedDate {
                    if gregorian.isDate(date, inSameDayAs: selectedDate) {
                        dayView.isSelected = true
                        delegate?.calendar?(self, focusDidChange: date)
                    }
                }
            }
            
            if dayView.isPlaceholder {
                dayView.alpha = 0.3
            } else {
                dayView.alpha = 1
            }
        }
    }
}

extension TSCalendar: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Double(collectionView.frame.width), height: Double(collectionView.frame.height)/Double(6.0))
    }
}

// MARK: - UIScrollViewDelegate
extension TSCalendar: UIScrollViewDelegate {
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        afterScrollAnimationSelectedDate()
        collectionView.isScrollEnabled = true
        collectionView.isUserInteractionEnabled = true
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var targetOffset: CGFloat = 0, contentSize: CGFloat = 0
        
        targetOffset = targetContentOffset.pointee.y
        
        contentSize = scrollView.frame.height
        
        let minimumPage = gregorian.ts_firstDayOfMonth(month: minimumDate)
        let targetPage = gregorian.date(byAdding: .month, value: Int(targetOffset/contentSize), to: minimumPage)!
        
        let shouldTriggerPageChange = isDateInDifferentPage(date: targetPage)
        if shouldTriggerPageChange {
            //첫번째 행의 선택 값이 제거 안되는 이슈로 추가 (첫번째 행은 바로 재활용이 되지 않아서 값이 남아 있어 강제로 초기화가 필요하다.)
            deselect(date: selectedDate, monthPosition: .current)
            currentPage = targetPage
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        afterScrollInPersonSelectedDate()
    }
}

extension TSCalendar: TSCalendarDayViewDelegate {
    func calendarDayViewDidSelect(_ dayView: TSCalendarDayView) {
        if !isSelectable {
            return
        }
        
        if let selectedDate = selectedDate {
            if gregorian.isDate(selectedDate, equalTo: dayView.date, toGranularity: .day) {
                delegate?.calendar?(self, didSelect: selectedDate)
                return
            }
        }
        select(dayView: dayView)
    }
}

// MARK: - Helper {
extension TSCalendar {
    private func isDateInDifferentPage(date: Date) -> Bool {
        return !gregorian.isDate(date, equalTo: currentPage, toGranularity: .month)
    }
    
    private func select(dayView: TSCalendarDayView) {
        if let selectedDate = selectedDate {
            deselect(date: selectedDate, monthPosition: .current)
        }
        
        if isDateInDifferentPage(date: dayView.date) {
            select(date: dayView.date, animated: true)
        } else {
            select(date: dayView.date)
            dayView.isSelected = true
        }
    }
    
    private func deselect(date: Date?, monthPosition: TSCalendarMonthPosition) {
        guard let date = date else { return }
        let indexPathAndIndex = calculator.indexPathAndIndex(date: date, monthPosition: monthPosition)
        if let cell = collectionView.cellForItem(at: indexPathAndIndex.indexPath) as? TSCalendarWeekCell {
            let dayView = cell.weekView.dayViews[indexPathAndIndex.index]
            dayView.isSelected = false
        }
    }
    
    private func afterScrollInPersonSelectedDate() {
        if let selectedDate = selectedDate {
            if gregorian.isDate(selectedDate, equalTo: currentPage, toGranularity: .month) {
                return
            }
        }
        let today = gregorian.ts_dateByIgnoringTime(Date())
        if gregorian.isDate(today, equalTo: currentPage, toGranularity: .month) {
            selectedDate = today
        } else {
            selectedDate = currentPage
        }
        if let selectedDate = selectedDate {
            let indexPathAndIndex = calculator.indexPathAndIndex(date: selectedDate)
            if let cell = collectionView.cellForItem(at: indexPathAndIndex.indexPath) as? TSCalendarWeekCell {
                let dayView = cell.weekView.dayViews[indexPathAndIndex.index]
                dayView.isSelected = true
            }
            delegate?.calendar?(self, focusDidChange: selectedDate)
        }
    }
    
    private func afterScrollAnimationSelectedDate() {
        if let selectedDate = selectedDate {
            let indexPathAndIndex = calculator.indexPathAndIndex(date: selectedDate)
            if let cell = collectionView.cellForItem(at: indexPathAndIndex.indexPath) as? TSCalendarWeekCell {
                let dayView = cell.weekView.dayViews[indexPathAndIndex.index]
                dayView.isSelected = true
            }
        }
    }
    
    private func move(value: Int) {
        if let date = gregorian.date(byAdding: .month, value: value, to: currentPage) {
            deselect(date: selectedDate, monthPosition: .current)
            let today = gregorian.ts_dateByIgnoringTime(Date())
            let tmpDate: Date
            if gregorian.isDate(today, equalTo: date, toGranularity: .month) {
                tmpDate = today
            } else {
                tmpDate = date
            }
            focus(date: tmpDate, animated: true)
        }
    }
}

// MARK: - Public
extension TSCalendar {
    open func previous() {
        move(value: -1)
    }
    
    open func next() {
        move(value: 1)
    }
    
    open func today(animated: Bool = true) {
        if let cToday = cToday {
            focus(date: cToday, animated: animated)
        } else {
            let today = gregorian.ts_dateByIgnoringTime(Date())
            focus(date: today, animated: animated)
        }
    }
    
    open func firstWeekday(_ firstWeekday: TSCalendarDayOfTheWeek) {
        switch firstWeekday {
        case .sunday:
            gregorian.firstWeekday = 1
        case .monday:
            gregorian.firstWeekday = 2
        case .tuesday:
            gregorian.firstWeekday = 3
        case .wednesday:
            gregorian.firstWeekday = 4
        case .thursday:
            gregorian.firstWeekday = 5
        case .friday:
            gregorian.firstWeekday = 6
        case .saturday:
            gregorian.firstWeekday = 7
        }
        self.firstWeekday = gregorian.firstWeekday
        gregorian.locale = locale
        calculator.gregorian = gregorian
        weekdayHeader.gregorian = gregorian
    }
    
    open func todayType(_ todayType: TSCalendarDayViewTodayType) {
        self.todayType = todayType
    }
    
    open func selectedType(_ selectedType: TSCalendarDayViewSelectedType) {
        self.selectedType = selectedType
    }
    
    open func locale(_ locale: Locale) {
        self.locale = locale
        gregorian.locale = locale
        gregorian.firstWeekday = firstWeekday
        calculator.gregorian = gregorian
        weekdayHeader.gregorian = gregorian
    }
    
    open func minimumDate(_ minimumDate: Date) {
        self.minimumDate = minimumDate
        calculator.minimumDate = minimumDate
    }
    
    open func maximumDate(_ maximumDate: Date) {
        self.maximumDate = maximumDate
        calculator.maximumDate = maximumDate
    }
    
    open func reloadData() {
        calculator.reloadData()
        weekdayHeader.reloadData()
        collectionView.reloadData()
    }
    
    open func resize() {
        layoutIfNeeded()
        collectionView.reloadData()
        scroll(date: currentPage)
    }
    
    open func focus(date: Date, animated: Bool = false) {
        if date < minimumDate || date > maximumDate {
            return
        }
        
        if isDateInDifferentPage(date: date) {
            selectedDate = date
            currentPage = gregorian.ts_firstDayOfMonth(month: date)
            scroll(date: currentPage, animated: animated)
        } else {
            let indexPathAndIndex = calculator.indexPathAndIndex(date: date)
            if let cell = collectionView.cellForItem(at: indexPathAndIndex.indexPath) as? TSCalendarWeekCell {
                let dayView = cell.weekView.dayViews[indexPathAndIndex.index]
                if let selectedDate = selectedDate {
                    deselect(date: selectedDate, monthPosition: .current)
                }
                selectedDate = date
                dayView.isSelected = true
                delegate?.calendar?(self, focusDidChange: date)
            }
        }
    }
    
    open func select(date: Date, animated: Bool = false) {
        if date < minimumDate || date > maximumDate {
            return
        }
        
        selectedDate = date
        if isDateInDifferentPage(date: date) {
            currentPage = gregorian.ts_firstDayOfMonth(month: date)
            scroll(date: currentPage, animated: animated)
        }
        delegate?.calendar?(self, didSelect: date)
    }
    
    func scroll(date: Date, animated: Bool = false) {
        if animated == true {
            collectionView.isScrollEnabled = false
            collectionView.isUserInteractionEnabled = false
        }
        let indexPathAndIndex = calculator.indexPathAndIndex(date: date)
        let indexPath = IndexPath(item: 0, section: indexPathAndIndex.indexPath.section)
        collectionView.scrollToItem(at: indexPath, at: .top, animated: animated)
    }
}
