//
//  TSCalendarAppearance.swift
//  TSCalendar
//
//  Created by TAE SU LEE on 2018. 4. 23..
//

import UIKit

open class TSCalendarAppearance: NSObject {
    
    public let color = Color()
    public let font = Font()
    public let size = Size()
    open var weekOfYear: Bool = false
    open var weekOfYearWidth: CGFloat = 30
    
    open class Color: NSObject {
        
        public let text = Text()
        public let bg = Background()
        
        open class Text: NSObject {
            open var weekdayHeader: UIColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
            open var sunday: UIColor = UIColor(red: 252/255, green: 79/255, blue: 78/255, alpha: 1)
            open var saturday: UIColor = UIColor(red: 74/255, green: 138/255, blue: 243/255, alpha: 1)
            open var weekday: UIColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
            open var selectedDate: UIColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
            open var topRight: UIColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
            
            public let today = Today()
            open class Today: NSObject {
                public let circle = Circle()
                public let rectangle = Rectangle()
                
                open class Circle: NSObject {
                    open var sunday: UIColor = UIColor.white
                    open var saturday: UIColor = UIColor.white
                    open var weekday: UIColor = UIColor.white
                }
                
                open class Rectangle: NSObject {
                    open var sunday: UIColor = UIColor(red: 252/255, green: 79/255, blue: 78/255, alpha: 1)
                    open var saturday: UIColor = UIColor(red: 74/255, green: 138/255, blue: 243/255, alpha: 1)
                    open var weekday: UIColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
                }
            }
        }
        
        open class Background: NSObject {
            public let today = Today()
            
            open class Today: NSObject {
                public let circle = Circle()
                public let rectangle = Rectangle()
                
                open class Circle: NSObject {
                    open var sunday: UIColor = UIColor(red: 253/255, green: 107/255, blue: 106/255, alpha: 1)
                    open var saturday: UIColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
                    open var weekday: UIColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
                }
                
                open class Rectangle: NSObject {
                    open var sunday: UIColor = UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1)
                    open var saturday: UIColor = UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1)
                    open var weekday: UIColor = UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1)
                }
            }
        }
    }
    
    open class Font: NSObject {
        open var weekdayHeader: UIFont = UIFont.boldSystemFont(ofSize: 12)
        open var days: UIFont = UIFont.boldSystemFont(ofSize: 12)
        open var topRight: UIFont = UIFont.systemFont(ofSize: 8)
    }
    
    open class Size: NSObject {
        open var circleRadius: CGFloat = 10
    }
}
