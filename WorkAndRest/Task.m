//
//  Task.m
//  WorkAndRest
//
//  Created by YangCun on 14-3-25.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import "Task.h"


@implementation Task

//@dynamic taskId;
//@dynamic title;
//@dynamic text;
//@dynamic completed;
//@dynamic costWorkTimes;
//@dynamic date;

@synthesize taskId;
@synthesize title;
@synthesize text;
@synthesize completed;
@synthesize costWorkTimes;
@synthesize date;

- (void)toggleCompleted
{
    self.completed = [NSNumber numberWithBool:![self.completed boolValue]];
}

@end
