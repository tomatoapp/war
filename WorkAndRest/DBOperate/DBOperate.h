//
//  DBOperate.h
//  FMDB_demo
//
//  Created by YangCun on 15/1/5.
//  Copyright (c) 2015年 backslash112. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "Task.h"
#import "WorkAndRest-Swift.h"
#import "WorkAndRest-Bridging-Header.h"

@interface DBOperate : NSObject

+ (void)db_init;

+ (void)createTaskTable;
+ (void)insertTask:(Task*)task;
+ (NSArray*)selectTaskWithTaskId:(NSInteger)taskId;
+ (void)updateTask:(Task*)task;
+ (void)deleteTask:(Task*)task;

+ (void)createWorkTable;
+ (void)insertWork:(Work*)task;
+ (NSArray*)selectWorkWithWorkId:(NSInteger)taskId;
+ (void)updateWork:(Work*)task;
+ (void)deleteWork:(Work*)task;

@end
