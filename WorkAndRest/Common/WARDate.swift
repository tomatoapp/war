//
//  WARDate.swift
//  WorkAndRest
//
//  Created by Carl.Yang on 8/21/15.
//  Copyright © 2015 YangCun. All rights reserved.
//

import UIKit

class WARDate: NSObject {
    class func dateByAddDaysFromToday(daysToAdd: Int) -> NSDate {
        return NSDate().dateByAddingTimeInterval(NSTimeInterval(60*60*24*daysToAdd))
    }
}
