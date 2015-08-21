//
//  IdleWatcher.swift
//  WorkAndRest
//
//  Created by Carl.Yang on 8/21/15.
//  Copyright © 2015 YangCun. All rights reserved.
//

import UIKit

/**
A Idle Watcher is for that if the user didn't work with this app, the wather will push a local notification to the user to tell the user that need do something.
*/
class IdleWatcher: NSObject {
    
    /**
    Add a notification by the last time the user use the app.
    Need to call this method in the applicationDidEnterBackground: method in the AppDelegate class.
    */
    class func scheduleLocalNotification() {
        let quotation = WARQuotation()
        for i in 1...3 {
            WARLocalNotification.scheduleLocalNotificationWithAlertBody(quotation.getQuotation(),
                andFireDate: WARDate.dateByAddDaysFromToday(GlobalConstants.NOTIFICATION_FREQUENCY_IDLEWATCHER * i))
        }
    }
    
    /**
    If the user reopen the app, great! cancel the notification which added in the last time.
    Need to call this method in the applicationWillTerminate: method in the AppDelegate class.
    */
    class func cancelNotification() {
        // By UILocalNotification.userInfo
    }
    
}

