//
//  WARLocalNotification.swift
//  WorkAndRest
//
//  Created by Carl.Yang on 8/21/15.
//  Copyright © 2015 YangCun. All rights reserved.
//

import UIKit

class WARLocalNotification: NSObject {
    class func scheduleLocalNotificationWithAlertBody(message: String, andFireDate fireDate: NSDate, andIdentifier id: AnyObject = -1) {
        let notification = UILocalNotification()
        notification.userInfo = ["notification_identifier": id]
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.alertBody = message
        notification.fireDate = fireDate
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        print("addNotificationWithSeconds")
    }
}
