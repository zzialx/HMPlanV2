//
//  WSFMDatebase.m
//  WinSFA
//
//  Created by dujinfeng481 on 14-11-10.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSFMDatebase.h"
#import "FMDatabaseQueue.h"

@interface WSFMDatebase ()
@property (nonatomic, strong) FMDatabaseQueue *queue;
@end

@implementation WSFMDatebase

#pragma mark - Create Single
static WSFMDatebase *wsfmdbInstance = nil;
+ (WSFMDatebase*) getInstance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        if (wsfmdbInstance == nil) {
            wsfmdbInstance = [[WSFMDatebase alloc] init];
        }
    });
    
    return wsfmdbInstance;
}

- (void) closeDB
{
    NSString *filePath = [wsfmdbInstance databaseFilePathWithDBName:KDataBaseName];
    self.queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self) {
        if (nil == wsfmdbInstance) {
            wsfmdbInstance = [super allocWithZone:zone];
            NSString *filePath = [wsfmdbInstance databaseFilePathWithDBName:KDataBaseName];
            
            NSLog(@"filePath-----%@",filePath);
            
            wsfmdbInstance.queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
        }
        
        return wsfmdbInstance;
    }
    
    return nil;
}

-(id)copy
{
    return self;
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;    //如果未MRC，个人感觉应该使用 [self retain]
}

#if __has_feature(objc_arc)
#else
- (id) retain
{
    return self;
}

- (unsigned) retainCount
{
    return NSUIntegerMax;
}

- (oneway void) release
{
    // Do nothing
}

- (id) autorelease
{
    return self;
}
#endif

#pragma mark Create Single End

#pragma mark - private method
-(NSString *)databaseFilePathWithDBName:(NSString *)dbName{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString*filePath= [documentsDirectory stringByAppendingPathComponent:dbName];
    NSLog(@"SFAFilePath--%@",filePath);
    return filePath;
}

#pragma mark - public method
- (BOOL)insertWithSql:(NSString *)insertSql withArgumentsInArrays:(NSArray *)values
{
    __block BOOL isSuccess = NO;
    
//    if ([values count] > 0) {
//        values = [values valueForKeyPath:@"@distinctUnionOfObjects.self"];
//    }
    
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (NSArray* items  in values) {
            isSuccess = [db executeUpdate:insertSql withArgumentsInArray:items];
            if (!isSuccess) {
                LogError(@"sql error [%@], code [%d], rollback! values:%@", db.lastErrorMessage, db.lastErrorCode, items);
                *rollback = YES;
                return;
            }
        }
    }];
    
    return isSuccess;
}

- (BOOL)executeUpdateWithSql:(NSString *)sqlStr withArgumentsInArray:(NSArray *)values
{
    LogInfo(@"sqlStr:%@\n values:%@",sqlStr,values);
    __block BOOL isSuccess = NO;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        isSuccess = [db executeUpdate:sqlStr withArgumentsInArray:values];
        if (!isSuccess) {
            LogError(@"sql error [%@], code [%d], rollback!", db.lastErrorMessage, db.lastErrorCode);
            *rollback = YES;
            return;
        }
    }];
    
    return isSuccess;
}

- (BOOL)executeUpdateWithSqls:(NSArray *)aSqlsArray
{
    __block BOOL isSuccess = NO;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSError *errorMessage=nil;
        
        for (NSString *sql in aSqlsArray){
            isSuccess = [db executeUpdate:sql withErrorAndBindings:&errorMessage];
           
            if(!isSuccess){
                
                LogError(@"sql error [%@], code [%ld], sql:%@, rollback!", errorMessage.localizedDescription, (long)errorMessage.code, sql);
                *rollback = YES;
                return;
            
            }
        }
    }];
    
    return isSuccess;
}

- (BOOL)executeUpdateWithSql:(NSString *)sqlStr
{
    if (!sqlStr) {
        return NO;
    }
    
    NSArray *aSqls = [NSArray arrayWithObjects:sqlStr, nil];
    return [self executeUpdateWithSqls:aSqls];
}

- (FMResultSet*) executeQueryWithSql:(NSString*)sqlStr withArgumentsInArray:(NSArray *)arguments
{
    __block FMResultSet *rs = nil;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        rs = [db executeQuery:sqlStr withArgumentsInArray:arguments];
        if (!rs) {
            LogError(@"sql error [%@], code [%d], sql:%@,%@ rollback!", db.lastErrorMessage, db.lastErrorCode, sqlStr, arguments);
            *rollback = YES;
            return;
        }
    }];
    
    return rs;
}


- (BOOL)executeUpdateWithSqls:(NSArray *)sqlArray withArgumentsInValueArrays:(NSArray *)valuesArray {
    {
        if (!sqlArray || [sqlArray count] == 0) {
            return NO;
        }
        
        __block BOOL isSuccess = NO;

        [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            for (NSInteger i = 0; i < [sqlArray count]; i++) {
                NSString *sql = [sqlArray objectAtIndex:i];
                
                NSArray *values = [valuesArray objectAtIndex:i];
                
                isSuccess = [db executeUpdate:sql withArgumentsInArray:values];
                if (!isSuccess) {
                    NSLog(@"sql error [%@], code [%d], rollback!", db.lastErrorMessage, db.lastErrorCode);
                    *rollback = YES;
                    return;
                }
            } 
        }];
        
        return isSuccess;
    }

}

- (FMResultSet*) executeQueryWithSql:(NSString*)sqlStr
{
    __block FMResultSet *rs = nil;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        rs = [db executeQuery:sqlStr];
        if (!rs) {
            LogError(@"sql error [%@], code [%d], sql:%@ rollback!", db.lastErrorMessage, db.lastErrorCode, sqlStr);
            *rollback = YES;
            return;
        }
    }];
    
    return rs;
}

- (BOOL)isTableExists:(NSString*)tableName {
    tableName = [tableName lowercaseString];
    
    NSString *sql = [NSString stringWithFormat:@"select [sql] from sqlite_master where [type] = 'table' and lower(name) = '%@'", tableName];
    
    FMResultSet *rs = [self executeQueryWithSql:sql];
    
    //if at least one next exists, table exists
    BOOL returnBool = [rs next];
    
    //close and free object
    [rs close];
    
    return returnBool;
}


@end
