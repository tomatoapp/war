//
//  WorkAndRestAppDelegate.m
//  WorkAndRest
//
//  Created by YangCun on 14-3-4.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import "AppDelegate.h"
#import "TaskListViewController.h"
#import "WorkWithItemViewController.h"
#import "Appirater.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation AppDelegate

@synthesize managedObjectModel, managedObjectContext, persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    TaskListViewController *taskListViewController = (TaskListViewController *)[[navigationController viewControllers] objectAtIndex:0];
    taskListViewController.managedObjectContext = self.managedObjectContext;
    
    // UNDONE:
    [Appirater setAppId:@""];
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

- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel == nil) {
        NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"DataModel" ofType:@"momd"];
        NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
        managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator == nil) {
        NSURL *storeURL = [NSURL fileURLWithPath:[self dataStorePath]];
        
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSError *error;
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            FATAL_CORE_DATA_ERROR(error);
        }
    }
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext == nil) {
        NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
        if (coordinator != nil) {
            managedObjectContext = [[NSManagedObjectContext alloc] init];
            [managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return managedObjectContext;
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
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"NowDate"];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:((WorkWithItemViewController *)self.currentModelViewController).secondsLeft] forKey:@"SecondsLeft"];
        
        // 添加通知
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = NSLocalizedString(@"Time is up!", nil);
        int leftSeconds = ((WorkWithItemViewController *)self.currentModelViewController).secondsLeft;
        NSTimeInterval leftSecondsTimeInterval = leftSeconds;
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:leftSecondsTimeInterval];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    if ([self.currentModelViewController isKindOfClass:[WorkWithItemViewController class]]) {
        
        WorkWithItemViewController *controller = (WorkWithItemViewController *)self.currentModelViewController;
        
        NSDate *savedDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"NowDate"];
        int savedScondsLeft = [[[NSUserDefaults standardUserDefaults] valueForKey:@"SecondsLeft"] intValue];
        NSTimeInterval passedTimeInterval = [savedDate timeIntervalSinceNow];
        
        if ((savedScondsLeft + (int)passedTimeInterval) > 0) {
            controller.secondsLeft = savedScondsLeft + (int)passedTimeInterval;
        } else { // 时间已经耗尽
            [controller completedOneWorkTime];
            [controller reset];
        }
    }
}

@end
