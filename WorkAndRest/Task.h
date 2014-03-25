//
//  Task.h
//  WorkAndRest
//
//  Created by YangCun on 14-3-25.
//  Copyright (c) 2014年 YangCun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSNumber * costWorkTimes;

@end
