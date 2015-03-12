//
//  ApplicationStateManager.swift
//  WorkAndRest
//
//  Created by YangCun on 15/3/5.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

private let _singletonInstance = ApplicationStateManager()

enum VersionType {
    case Free, Pro
}

class ApplicationStateManager: NSObject {

    let Probation: NSTimeInterval = 7
    class var sharedInstance: ApplicationStateManager {
        return _singletonInstance
    }

    func setup() {
        NSUserDefaults.standardUserDefaults().setValue(NSDate(), forKey: GlobalConstants.k_FirstLauchDate)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: GlobalConstants.kBOOL_isPaid)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func isExpired() -> Bool {
        let firstLaunchDate: NSDate = NSUserDefaults.standardUserDefaults().valueForKey(GlobalConstants.k_FirstLauchDate) as NSDate
        let timeInterval: NSTimeInterval = 60 * 60 * 24 * Probation * -1
        return NSDate(timeIntervalSinceNow: timeInterval).compare(firstLaunchDate) == NSComparisonResult.OrderedDescending
    }
    
    func paid() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_isPaid)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func versionType() -> VersionType {
        let isPaid = NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_isPaid)
        return isPaid ? .Pro : .Free
    }
}
