//
//  NSDate+BeginningEnd.swift
//  WorkAndRest
//
//  Created by Carl.Yang on 1/13/16.
//  Copyright © 2016 YangCun. All rights reserved.
//

import UIKit

extension NSDate {
    func beginningOfDate() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        if #available(iOS 8.0, *) {
            return calendar.startOfDayForDate(self)
        } else {
            // Fallback on earlier versions
            let components = calendar.components([.Year, .Month, .Day], fromDate: self)
            return calendar.dateFromComponents(components)!
        }
    }
    
    func endOfDate() -> NSDate {
        let components = NSDateComponents()
        components.day = 1
        var date = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: self.beginningOfDate(), options: [])!
        date = date.dateByAddingTimeInterval(-1)
        return date
    }
    
    func tomorrow() -> NSDate {
        return self.addDays(1)
    }
    
    func yesterday() -> NSDate {
        return self.addDays(-1)
    }
    
    func addDays(i: Int) -> NSDate {
        let components = NSDateComponents()
        components.day = i
        return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: NSDate(), options: [])!
    }
    
    func toString(dateFormat: String = "M月d日") -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.stringFromDate(self)
    }
    
    func toSampleString() -> String {
        return self.toString("d")
    }
}
