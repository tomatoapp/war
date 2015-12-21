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
        print(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
        
        DBOperate.db_init()
        
        self.firstRun()
        
        self.initRater()
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
            nil,
            LockNotifierCallback.notifierProc(),
            "com.apple.springboard.lockcomplete",
            nil,
            CFNotificationSuspensionBehavior.DeliverImmediately)
        
        
        if !NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_firstLaunch) {
            NSThread.sleepForTimeInterval(0.5)
            self.hideIconWithAnimation()
        }
        
        Parse.setApplicationId(applicationId, clientKey: clientKey)
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        return true
    }
    
    func hideIconWithAnimation() {
        let imageView = UIImageView(image: UIImage(named: "launch page icon"))
        var height: CGFloat = 148
        if WARDevice.getPhoneType() == PhoneType.iPhone4 {
            height = 146
        }
        
        imageView.frame = CGRectMake((self.window!.frame.width-151)/2, height, 151, 142)
        
        self.window?.rootViewController?.view.addSubview(imageView)
        self.window?.rootViewController?.view.bringSubviewToFront(imageView)
        
        imageView.alpha = 1.0
        UIView.animateWithDuration(0.6,
            delay: 0.25,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
                imageView.alpha = 0.0
                imageView.transform = CGAffineTransformMakeScale(1.7, 1.7)
                imageView.center = CGPointMake(imageView.center.x, imageView.center.y + 40)
                
            }) { (finished) -> Void in
                imageView.removeFromSuperview()
        }
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
                self.freezeTask()
            } else {
                if NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_IS_DETERMINATION) { // 开启手机学习模式
                    self.freezeTask()
                } else {
                    self.stopTask()
                }
            }
            break
            
        case UIApplicationState.Inactive:
            print("Inactive")
            break
        }
        IconBadgeNumberManager.sharedInstance.setBadgeNumber()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        //        println("applicationWillEnterForeground")
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "kDisplayStatusLocked")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {

        // Cancel local notification: IdleWatcher & WoringTask
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        IdleWatcher.scheduleLocalNotification()
        if NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.kBOOL_ISWORKING) {
            TaskRunnerManager.sharedInstance.activeFrozenTaskManager()
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: GlobalConstants.kBOOL_ISWORKING)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
                print("applicationWillTerminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    
    // MARK: - Methods
    
    func firstRun() {
        if !NSUserDefaults.standardUserDefaults().boolForKey(GlobalConstants.k_HASRAN_BEFORE) {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_firstLaunch)
            
            self.setup()
            ApplicationStateManager.sharedInstance.setup()
        } else {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: GlobalConstants.kBOOL_firstLaunch)
        }
    }
    
    func setup() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.k_HASRAN_BEFORE)
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_SECOND_SOUND)
        NSUserDefaults.standardUserDefaults().setInteger(GlobalConstants.DEFAULT_MINUTES, forKey: GlobalConstants.k_SECONDS)
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_BADGEAPPICON)
//        NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_IS_DETERMINATION)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func addNotificationWithSeconds(seconds: Int) {
        let notification = UILocalNotification()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.alertBody = NSLocalizedString("Time is up!", comment:"")
        let secondsLeftTimeInterval = NSTimeInterval(seconds)
        
        let fireDate = NSDate(timeIntervalSinceNow: secondsLeftTimeInterval)
        notification.fireDate = fireDate
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        print("addNotificationWithSeconds")
    }
    
    func showBreakNotification() {
        let notification = UILocalNotification()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.alertBody = "You stoped the timer!"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
    func initRater() {
        Appirater.setAppId(GlobalConstants.k_APPID)
        Appirater.setDaysUntilPrompt(1)
        Appirater.setUsesUntilPrompt(3)
        Appirater.setSignificantEventsUntilPrompt(-1)
        Appirater.setTimeBeforeReminding(2)
        Appirater.setDebug(false)
        Appirater.appLaunched(true)
    }
    
    func freezeTask() {
        if TaskRunner.sharedInstance.isRunning {
            self.addNotificationWithSeconds(TaskRunner.sharedInstance.seconds)
            TaskRunnerManager.sharedInstance.freezeTaskManager(TaskRunner.sharedInstance)
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: GlobalConstants.kBOOL_ISWORKING)
            print("kBOOL_ISWORKING = true")
            NSUserDefaults.standardUserDefaults().synchronize()
        } else {
            print("kBOOL_ISWORKING = false")
        }
    }
    
    func stopTask() {
        if TaskRunner.sharedInstance.isRunning {
            TaskRunner.sharedInstance.stop()
            self.showBreakNotification()
        }
    }
}