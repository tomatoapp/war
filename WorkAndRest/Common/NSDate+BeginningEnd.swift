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
}
