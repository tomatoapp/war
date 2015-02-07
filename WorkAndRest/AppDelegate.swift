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
    
    var rootViewController: UITabBarController? {
        get {
            let navigationController = self.window?.rootViewController as UINavigationController
            if navigationController.topViewController.isKindOfClass(UITabBarController) {
                let rootViewController = navigationController.topViewController as UITabBarController
                return rootViewController
            }
            return nil
        }
    }
    
    var taskListViewController: TaskListViewController? {
        get {
            if self.rootViewController != nil {
                let taskListViewController = self.rootViewController!.viewControllers!.first as TaskListViewController
                return taskListViewController
            }
            return nil
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        println(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String)
        DBOperate.db_init()
        self.firstRun()
        self.initRater()
        
        if application.respondsToSelector("isRegisteredForRemoteNotifications") {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Sound | .Alert | .Badge, categories: nil))
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotificationTypes(.Sound | .Alert | .Badge)
        }
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
            nil,
            LockNotifierCallback.notifierProc(),
            "com.apple.springboard.lockcomplete",
            nil,
            CFNotificationSuspensionBehavior.DeliverImmediately)
        
        println("\(UIDevice.currentDevice().modelName)" + ":" + "\(WARDevice.getPhoneType().description())")
        return true
    }
    
    // MARK: - Application Status
    
    func applicationWillResignActive(application: UIApplication) {
        println("applicationWillResignActive")
 
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        println("applicationDidEnterBackground")
        
        let state = UIApplication.sharedApplication().applicationState
        switch state {
        case UIApplicationState.Active:
            println("Active")
            break
            
        case UIApplicationState.Background:
            if NSUserDefaults.standardUserDefaults().boolForKey("kDisplayStatusLocked") {
                println("Sent to background by locking screen")
            } else {
                println("Sent to background by home button/switching to other app")
            }
            break
            
        case UIApplicationState.Inactive:
            println("Inactive")
            break
        }
        var isWorking = false
        
        if self.taskListViewController != nil && self.taskListViewController!.runningTaskRunner != nil {
            isWorking = true
            println("isWorking! resign active")
            self.addNotificationWithSeconds(self.taskListViewController!.runningTaskRunner!.seconds)
            self.taskListViewController!.freezeTaskManager(self.taskListViewController!.runningTaskRunner)
        }
        NSUserDefaults.standardUserDefaults().setBool(isWorking, forKey: GlobalConstants.kBOOL_ISWORKING)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        println("applicationWillEnterForeground")
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "kDisplayStatusLocked")
        NSUserDefaults.standardUserDefaults().synchronize()

        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        println("applicationDidBecomeActive")
        
        if NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_ISWORKING) {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            println("cancelAllLocalNotifications")
            
            println("isWorking! become active")
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: GlobalConstants.kBOOL_ISWORKING)
            NSUserDefaults.standardUserDefaults().synchronize()
            self.taskListViewController!.activeFrozenTaskManager()
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        println("applicationWillTerminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    
    // MARK: - Methods
    
    func firstRun() {
        if !NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.k_HASRAN_BEFORE) {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.k_HASRAN_BEFORE)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_SECOND_SOUND)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_KEEP_LIGHT)
            NSUserDefaults.standardUserDefaults().setInteger(GlobalConstants.DEFAULT_MINUTES, forKey: GlobalConstants.k_SECONDS)
            NSUserDefaults.standardUserDefaults().synchronize()
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








