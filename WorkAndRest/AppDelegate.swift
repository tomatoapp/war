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
    
    var rootViewController: UITabBarController {
        get {
            let navigationController = self.window?.rootViewController as UINavigationController
            let rootViewController = navigationController.topViewController as UITabBarController
            return rootViewController
        }
    }
    
    var taskListViewController: TaskListViewController {
        get {
            let taskListViewController = self.rootViewController.viewControllers!.first as TaskListViewController
            return taskListViewController
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
        var isWorking = false
        if self.taskListViewController.runningTaskRunner != nil {
            isWorking = true
            println("isWorking! resign active")
            self.addNotificationWithSeconds(self.taskListViewController.runningTaskRunner!.seconds)
            self.taskListViewController.freezeTaskManager(self.taskListViewController.runningTaskRunner)

        }
        NSUserDefaults.standardUserDefaults().setBool(isWorking, forKey: GlobalConstants.kBOOL_ISWORKING)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        if NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_ISWORKING) {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            println("isWorking! become active")
            println("cancelAllLocalNotifications")
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: GlobalConstants.kBOOL_ISWORKING)
            self.taskListViewController.activeFrozenTaskManager()
        }
    }
    
    // MARK: - Methods
    
    func firstRun() {
        if !NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.k_HASRAN_BEFORE) {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.k_HASRAN_BEFORE)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_SECOND_SOUND)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_KEEP_LIGHT)
            DBOperate.insertTask(self.createSampleTask())
        }
    }

    func addNotificationWithSeconds(seconds: Int) {
        let notification = UILocalNotification()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.alertBody = NSLocalizedString("Time is up!", comment:"")
        let secondsLeftTimeInterval = NSTimeInterval(seconds)
        
        println("\(secondsLeftTimeInterval)")
        let fireDate = NSDate(timeIntervalSinceNow: secondsLeftTimeInterval)
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone.defaultTimeZone()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeStr = formatter.stringFromDate(fireDate)
        println(timeStr)
        notification.fireDate = fireDate
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        println("addNotificationWithSeconds")
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
    
    func createSampleTask() -> Task {
        println("createSampleTask")
        let sampleTask = Task()
        sampleTask.title = NSLocalizedString("Task Sample", comment: "")
        sampleTask.minutes = GlobalConstants.DEFAULT_MINUTES
        return sampleTask
    }
}
