//
//  IconBadgeNumberManager.swift
//  WorkAndRest
//
//  Created by YangCun on 15/3/4.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

private let _singletonInstance = IconBadgeNumberManager()

class IconBadgeNumberManager: NSObject {
    
    class var sharedInstance: IconBadgeNumberManager {
        return _singletonInstance
    }
    
    func setBadgeNumber() {
        let number = TaskManager.sharedInstance.loadUnCompletedTaskList().count
        UIApplication.sharedApplication().applicationIconBadgeNumber = number
    }
}
