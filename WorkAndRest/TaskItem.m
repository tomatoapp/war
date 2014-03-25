//
//  TaskItem.m
//  WorkAndRest
//
//  Created by YangCun on 14-3-24.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import "TaskItem.h"

@implementation TaskItem

@synthesize text;
@synthesize completed;
@synthesize costWorkTimes;

- (id)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

- (void)toggleCompleted
{
    self.completed = !self.completed;
}

@end
