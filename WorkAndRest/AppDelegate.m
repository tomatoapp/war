//
//  WorkAndRestAppDelegate.m
//  WorkAndRest
//
//  Created by YangCun on 14-3-4.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import "AppDelegate.h"
#import "WorkWithItemViewController.h"
#import "Appirater.h"
#import "WorkAndRest-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"app dir: %@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    
    [DBOperate db_init];
    [self firstRun];
    
    [Appirater setAppId:@"868078759"];
    [Appirater setDaysUntilPrompt:3];
    [Appirater setUsesUntilPrompt:3];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
    
    return YES;
}

#pragma mark - Core Data

- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (NSString *)dataStorePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"DataStore.sqlite"];
}

- (void)fatalCoreDataError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Internal Error", nil)
                              message:NSLocalizedString(@"There was a fatal error in the app and it connot continue.\n\nPress OK to terminate the app. Sorry for the inconvenience.", nil)
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    abort();
}

#pragma mark - Application Status

- (void)applicationWillResignActive:(UIApplication *)application
{
    if ([self.currentModelViewController isKindOfClass:[WorkWithItemViewController class]]) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:((WorkWithItemViewController *)self.currentModelViewController).isWorking] forKey:@"isWorking"];
        if (((WorkWithItemViewController *)self.currentModelViewController).isWorking) {
            
            
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"NowDate"];
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:((WorkWithItemViewController *)self.currentModelViewController).secondsLeft] forKey:@"SecondsLeft"];
            
            // 添加通知
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.alertBody = NSLocalizedString(@"Time is up!", nil);
            int leftSeconds = ((WorkWithItemViewController *)self.currentModelViewController).secondsLeft;
            NSTimeInterval leftSecondsTimeInterval = leftSeconds;
            notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:leftSecondsTimeInterval];
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    if ([self.currentModelViewController isKindOfClass:[WorkWithItemViewController class]]) {
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isWorking"] boolValue]) {
            WorkWithItemViewController *controller = (WorkWithItemViewController *)self.currentModelViewController;
            
            NSDate *savedDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"NowDate"];
            int savedScondsLeft = [[[NSUserDefaults standardUserDefaults] valueForKey:@"SecondsLeft"] intValue];
            NSTimeInterval passedTimeInterval = [savedDate timeIntervalSinceNow];
            
            if ((savedScondsLeft + (int)passedTimeInterval) > 0) {
                controller.secondsLeft = savedScondsLeft + (int)passedTimeInterval;
            } else { // 时间已经耗尽
                [controller completedOneWorkTime];
                [controller reset];
            }}
    }
}

#pragma mark - First Run

- (void)firstRun
{
    BOOL hasRunBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstRun"];
    
    if (!hasRunBefore) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstRun"];
        
        // Add the "Task Sample" item to the list.
        Task *sampleTask = [Task new];
        sampleTask.title = NSLocalizedString(@"Task Sample", nil);
        sampleTask.costWorkTimes = [NSNumber numberWithInteger:0];
        sampleTask.completed = [NSNumber numberWithBool:NO];
        sampleTask.date = [NSDate date];
        [DBOperate insertTask:sampleTask];
        
        // Set the default Second Sound to YES.
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"SecondSound"];
        
        // Set the default Keep Screen Light to YES.
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"KeepLight"];
        
        // Set the Default Seconds.
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:25] forKey:@"Seconds"];
    }
}


@end
