//
//  DBOperate.m
//  FMDB_demo
//
//  Created by YangCun on 15/1/5.
//  Copyright (c) 2015年 backslash112. All rights reserved.
//

#import "DBOperate.h"

#define DB_PATH @"db_demo.sqlite3"

static FMDatabase* _dbOperate;
@implementation DBOperate

+ (void)db_init {
    @synchronized(_dbOperate) {
        if (!_dbOperate) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DB_PATH];
            _dbOperate = [FMDatabase databaseWithPath:writableDBPath];
            [self createTaskTable];
            [self createWorkTable];
        }
    }
}

#pragma mark --
#pragma mark Task
+ (void)createTaskTable {
    NSString *sql = @"CREATE TABLE t_tasks(task_id DECIMAL(18,0) DEFAULT '0', title VARCHAR(1024))";
    // open the db.
    if (![_dbOperate open]) {
        NSLog(@"Unable to open the db.");
        return;
    }
    BOOL success = [_dbOperate executeUpdate:sql];
    if (success) {
        NSLog(@"Create the task table succeed!");
    }
    [_dbOperate close];
}

+ (void)insertTask:(Task *)task {
    // open the db.
    if (![_dbOperate open]) {
        return;
    }
    BOOL success = [_dbOperate executeUpdate:@"INSERT INTO t_tasks VALUES (?, ?)",
                    [NSNumber numberWithLongLong:task.taskId],
                    task.title];
    if (success) {
        NSLog(@"insert into the task table succeed!");
        [_dbOperate close];
    } else {
        NSLog(@"error to insert into the task table.");
    }
}

+ (NSArray*)selectTaskWithTaskId:(NSInteger)taskId {
    NSString *sql = @"SELECT * from t_tasks";
    if (![_dbOperate open]) {
        return nil;
    }
    
    NSMutableArray *result = [NSMutableArray new];
    FMResultSet *rs = [_dbOperate executeQuery:sql];
    while (rs.next) {
        Task *tempTask = [Task new];
        tempTask.taskId = [[rs stringForColumn:@"task_id"] integerValue];
        tempTask.title = [rs stringForColumn:@"title"];
        [result addObject:tempTask];
    }
    [_dbOperate close];
    return result;
}

+ (void)updateTask:(Task *)task {
    
}

+ (void)deleteTask:(Task *)task {
    
}

#pragma mark --
#pragma mark Work
+ (void)createWorkTable {
    NSString *sql = @"CREATE TABLE t_works(work_id DECIMAL(18,0) DEFAULT '0', title VARCHAR(1024))";
    // open the db.
    if (![_dbOperate open]) {
        NSLog(@"Unable to open the db.");
        return;
    }
    BOOL success = [_dbOperate executeUpdate:sql];
    if (success) {
        NSLog(@"Create the work table succeed!");
    }
    [_dbOperate close];
}
+ (void)insertWork:(Work*)work {
    // open the db.
    if (![_dbOperate open]) {
        return;
    }
    BOOL success = [_dbOperate executeUpdate:@"INSERT INTO t_works VALUES (?, ?)",
                    [NSNumber numberWithLongLong:work.workId],
                    work.title];
    if (success) {
        NSLog(@"insert into the work table succeed!");
        [_dbOperate close];
    } else {
        NSLog(@"error to insert into the work table.");
    }
}
+ (NSArray*)selectWorkWithWorkId:(NSInteger)taskId {
    NSString *sql = @"SELECT * from t_works";
    if (![_dbOperate open]) {
        return nil;
    }
    
    NSMutableArray *result = [NSMutableArray new];
    FMResultSet *rs = [_dbOperate executeQuery:sql];
    while (rs.next) {
        Task *tempTask = [Task new];
        tempTask.taskId = [[rs stringForColumn:@"work_id"] integerValue];
        tempTask.title = [rs stringForColumn:@"title"];
        [result addObject:tempTask];
    }
    [_dbOperate close];
    return result;
}

+ (void)updateWork:(Work*)task {
    
}
+ (void)deleteWork:(Work*)task {
    
}

@end
