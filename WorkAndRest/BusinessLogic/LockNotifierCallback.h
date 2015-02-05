//
//  LockNotifierCallback.h
//  WorkAndRest
//
//  Created by YangCun on 15/2/5.
//  Copyright (c) 2015年 YangCun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LockNotifierCallback : NSObject

+ (void(*)(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *boject, CFDictionaryRef userInfo))notifierProc;

@end
