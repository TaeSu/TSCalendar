//
//  TSCalendarConstraints.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 2018. 4. 17..
//

import UIKit

open class TSCalendarConstraints: NSObject {
    
    public enum TSCalendarConstraintType {
        case top
        case bottom
        case leading
        case trailing
        case centerX
        case centerY
    }
    
    open func addSubview(_ item: UIView, toItem: UIView) {
        toItem.addSubview(item)
        item.translatesAutoresizingMaskIntoConstraints = false
    }
    
    open func attributes(parent: UIView? = nil, item: UIView, toItem: UIView, types: [TSCalendarConstraintType]) {
        for type in types {
            switch type {
            case .top:
                top(parent: (parent ?? toItem), item: item, toItem: toItem)
            case .bottom:
                bottom(parent: (parent ?? toItem), item: item, toItem: toItem)
            case .leading:
                leading(parent: (parent ?? toItem), item: item, toItem: toItem)
            case .trailing:
                trailing(parent: (parent ?? toItem), item: item, toItem: toItem)
            case .centerX:
                centerX(parent: (parent ?? toItem), item: item, toItem: toItem)
            case .centerY:
                centerY(parent: (parent ?? toItem), item: item, toItem: toItem)
            }
        }
    }
    
    @discardableResult
    open func top(parent: UIView, item: UIView, toItem: UIView? = nil, multiplier: CGFloat = 1.0, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: toItem ?? parent,
                                            attribute: .top,
                                            multiplier: multiplier,
                                            constant: constant)
        parent.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    open func bottom(parent: UIView, item: UIView, toItem: UIView? = nil, multiplier: CGFloat = 1.0, constant: CGFloat = 0) -> NSLayoutConstraint {
        let bottom = NSLayoutConstraint(item: item,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: toItem ?? parent,
                                        attribute: .bottom,
                                        multiplier: multiplier,
                                        constant: constant)
        parent.addConstraint(bottom)
        return bottom
    }
    
    @discardableResult
    open func bottomTop(parent: UIView, item: UIView, toItem: UIView? = nil, multiplier: CGFloat = 1.0, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: toItem ?? parent,
                                            attribute: .bottom,
                                            multiplier: multiplier,
                                            constant: constant)
        parent.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    open func centerX(parent: UIView,item: UIView, toItem: UIView? = nil, multiplier: CGFloat = 1.0, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .centerX,
                                            relatedBy: .equal,
                                            toItem: toItem ?? parent,
                                            attribute: .centerX,
                                            multiplier: multiplier,
                                            constant: constant)
        parent.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    open func centerY(parent: UIView, item: UIView, toItem: UIView? = nil, multiplier: CGFloat = 1.0, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .centerY,
                                            relatedBy: .equal,
                                            toItem: toItem ?? parent,
                                            attribute: .centerY,
                                            multiplier: multiplier,
                                            constant: constant)
        parent.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    open func leading(parent: UIView, item: UIView, toItem: UIView? = nil, multiplier: CGFloat = 1.0, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: toItem ?? parent,
                                            attribute: .leading,
                                            multiplier: multiplier,
                                            constant: constant)
        parent.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    open func leadingTrailing(parent: UIView, item: UIView, toItem: UIView, multiplier: CGFloat = 1.0, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .trailing,
                                            relatedBy: .equal,
                                            toItem: toItem,
                                            attribute: .leading,
                                            multiplier: multiplier,
                                            constant: constant)
        parent.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    open func trailing(parent: UIView, item: UIView, toItem: UIView? = nil, multiplier: CGFloat = 1.0, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .trailing,
                                            relatedBy: .equal,
                                            toItem: toItem ?? parent,
                                            attribute: .trailing,
                                            multiplier: multiplier,
                                            constant: constant)
        parent.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    open func trailingLeading(parent: UIView, item: UIView, toItem: UIView, multiplier: CGFloat = 1.0, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: toItem,
                                            attribute: .trailing,
                                            multiplier: multiplier,
                                            constant: constant)
        parent.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    open func width(parent: UIView,item: UIView, multiplier: CGFloat = 1.0, constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: multiplier,
                                            constant: constant)
        parent.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    open func equalWidth(parent: UIView,item: UIView, toItem: UIView) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: toItem,
                                            attribute: .width,
                                            multiplier: 1,
                                            constant: 0)
        parent.addConstraint(constraint)
        return constraint
    }
    
    @discardableResult
    open func height(parent: UIView,item: UIView, multiplier: CGFloat = 1.0, constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: multiplier,
                                            constant: constant)
        parent.addConstraint(constraint)
        return constraint
    }
}
