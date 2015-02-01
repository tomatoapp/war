//
//  AppDelegate.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/1.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var currentModelViewController: UIViewController {
        get {
            let navigationController = self.window?.rootViewController as UINavigationController
            let activeViewController = navigationController.visibleViewController
            return activeViewController
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        println(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String)
        DBOperate.db_init()
        self.firstRun()
        self.initRater()
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Sound | .Alert | .Badge, categories: nil))
        return true
    }
    
    // MARK: - Application Status
    
    func applicationWillResignActive(application: UIApplication) {
        if self.currentModelViewController.isKindOfClass(WorkWithItemViewController) {
            let isWorking = (self.currentModelViewController as WorkWithItemViewController).isWorking
            let secondsLeft = (self.currentModelViewController as WorkWithItemViewController).secondsLeft
            
           NSUserDefaults.standardUserDefaults().setBool(isWorking, forKey: GlobalConstants.kBOOL_ISWORKING)
            if isWorking {
                NSUserDefaults.standardUserDefaults().setValue(NSDate(), forKey: GlobalConstants.k_NOWDATE)
                NSUserDefaults.standardUserDefaults().setInteger(secondsLeft, forKey: GlobalConstants.k_SECONDS_LEFT)
                self.addNotification()
            }
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        if self.currentModelViewController.isKindOfClass(WorkWithItemViewController) {
            if NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_ISWORKING) {
                let controller = self.currentModelViewController as WorkWithItemViewController
                let dateWhenResignActive: NSDate = NSUserDefaults.standardUserDefaults().valueForKey(GlobalConstants.k_NOWDATE) as NSDate
                let secondsLeftWhenResignActive = NSUserDefaults.standardUserDefaults().integerForKey(GlobalConstants.k_SECONDS_LEFT)
                let passedTimeInterval = dateWhenResignActive.timeIntervalSinceNow
                
                if secondsLeftWhenResignActive + Int(passedTimeInterval) > 0 {
                    controller.secondsLeft = secondsLeftWhenResignActive + Int(passedTimeInterval)
                } else {
                    controller.completedOneWorkTime()
                    controller.reset()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    func firstRun() {
        if !NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.k_HASRAN) {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.k_HASRAN)
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_SECOND_SOUND)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_KEEP_LIGHT)
            NSUserDefaults.standardUserDefaults().setInteger(25, forKey: GlobalConstants.k_SECONDS)
            
            self.createSampleTask()
        }
    }
    

    func addNotification() {
        let notification = UILocalNotification()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.alertBody = NSLocalizedString("Time is up!", comment:"")
        let secondsLeftTimeInterval = NSTimeInterval((self.currentModelViewController as WorkWithItemViewController).secondsLeft)
        
        println("\(secondsLeftTimeInterval)")
        let fireDate = NSDate(timeIntervalSinceNow: secondsLeftTimeInterval)
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone.defaultTimeZone()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeStr = formatter.stringFromDate(fireDate)
        println(timeStr)
        notification.fireDate = fireDate
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func initRater() {
        Appirater.setAppId(GlobalConstants.k_APPID)
        Appirater.setDaysUntilPrompt(3)
        Appirater.setUsesUntilPrompt(3)
        Appirater.setSignificantEventsUntilPrompt(-1)
        Appirater.setTimeBeforeReminding(2)
        Appirater.setDebug(false)
        Appirater.appLaunched(true)
    }
    
    func createSampleTask() {
        let sampleTask = Task()
        sampleTask.title = NSLocalizedString("Task Sample", comment: "")
        DBOperate .insertTask(sampleTask)
    }
}
