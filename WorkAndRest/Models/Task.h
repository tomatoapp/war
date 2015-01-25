//
//  Task.h
//  WorkAndRest
//
//  Created by YangCun on 14-3-25.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


// @interface Task : NSManagedObject
@interface Task : NSObject

@property (nonatomic, assign) NSInteger taskId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSNumber * completed;
@property (nonatomic, strong) NSNumber * costWorkTimes;
@property (nonatomic, strong) NSDate *date;

- (void)toggleCompleted;

@end
