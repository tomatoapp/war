//
//  AppDelegate.swift
//  WorkAndRest
//
//  Created by YangCun on 15/2/1.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIAlertViewDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
//        println(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String)
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
        
//        println("\(UIDevice.currentDevice().modelName)" + ":" + "\(WARDevice.getPhoneType().description())")
        NSThread.sleepForTimeInterval(1.0)
        return true
    }
    
    // MARK: - Application Status
    
    func applicationWillResignActive(application: UIApplication) {
//        println("applicationWillResignActive")
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
//        println("applicationDidEnterBackground")
        
        let state = UIApplication.sharedApplication().applicationState
        switch state {
        case UIApplicationState.Active:
//            println("Active")
            break
            
        case UIApplicationState.Background:
            if NSUserDefaults.standardUserDefaults().boolForKey("kDisplayStatusLocked") {
//                println("Sent to background by locking screen")
                if TaskRunner.sharedInstance.isRunning {
                    self.addNotificationWithSeconds(TaskRunner.sharedInstance.seconds)
                    TaskRunnerManager.sharedInstance.freezeTaskManager(TaskRunner.sharedInstance)
                }
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_ISWORKING)
                NSUserDefaults.standardUserDefaults().synchronize()
            } else {
//                println("Sent to background by home button/switching to other app")
                if TaskRunner.sharedInstance.isRunning {
                    TaskRunner.sharedInstance.stop()
                    self.showBreakNotification()
                }
            }
            break
            
        case UIApplicationState.Inactive:
            println("Inactive")
            break
        }
        var isWorking = false
        
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
//        println("applicationWillEnterForeground")
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "kDisplayStatusLocked")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
//        println("applicationDidBecomeActive")
        
        if NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_ISWORKING) {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
//            println("cancelAllLocalNotifications")
            
//            println("isWorking! become active")
            TaskRunnerManager.sharedInstance.activeFrozenTaskManager()
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: GlobalConstants.kBOOL_ISWORKING)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
//        println("applicationWillTerminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    
    // MARK: - Methods
    
    func firstRun() {
        if !NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.k_HASRAN_BEFORE) {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.k_HASRAN_BEFORE)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_SECOND_SOUND)
            //NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_KEEP_LIGHT)
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
        
        let fireDate = NSDate(timeIntervalSinceNow: secondsLeftTimeInterval)
        notification.fireDate = fireDate
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        println("addNotificationWithSeconds")
    }
    
    func showBreakNotification() {
        let notification = UILocalNotification()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.alertBody = "You breaked this timer"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
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
        sampleTask.taskId = 0
        sampleTask.title = NSLocalizedString("Task Sample", comment: "")
        sampleTask.minutes = GlobalConstants.DEFAULT_MINUTES
        sampleTask.completed = false
        sampleTask.expect_times = 3
        sampleTask.finished_times = 1
        return sampleTask
    }
}








