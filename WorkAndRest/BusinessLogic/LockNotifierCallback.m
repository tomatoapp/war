//
//  LockNotifierCallback.m
//  WorkAndRest
//
//  Created by YangCun on 15/2/5.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

#import "LockNotifierCallback.h"

@implementation LockNotifierCallback

static void lockcompleteChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *boject, CFDictionaryRef userInfo) {
    
    CFStringRef result = CFSTR("com.apple.springboard.lockcomplete");
    if ([(__bridge NSString*)name isEqualToString:(__bridge NSString*)result]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisplayStatusLocked"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
+ (void(*)(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *boject, CFDictionaryRef userInfo))notifierProc {
    return lockcompleteChanged;
}

@end
