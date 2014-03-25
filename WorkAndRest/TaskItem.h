//
//  TaskItem.h
//  WorkAndRest
//
//  Created by YangCun on 14-3-24.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskItem : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, assign) NSInteger costWorkTimes;

- (void)toggleCompleted;

@end
