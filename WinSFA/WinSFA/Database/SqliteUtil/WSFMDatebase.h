//
//  WSFMDatebase.h
//  WinSFA
//
//  Created by dujinfeng481 on 14-11-10.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KDataBaseName @ "wch_DataBase.db"

@class FMResultSet;

@interface WSFMDatebase : NSObject

+ (WSFMDatebase*) getInstance;
- (void) closeDB;

- (BOOL)insertWithSql:(NSString *)insertSql withArgumentsInArrays:(NSArray *)values;
- (BOOL)executeUpdateWithSql:(NSString *)sqlStr withArgumentsInArray:(NSArray *)values;

/*批量执行sql的域绑定方法 解决 sql语句中字段值带有单引号问题*/
- (BOOL)executeUpdateWithSqls:(NSArray *)sqlArray withArgumentsInValueArrays:(NSArray *)valuesArray;

- (BOOL)executeUpdateWithSqls:(NSArray *)aSqlsArray;
- (BOOL)executeUpdateWithSql:(NSString *)sqlStr;
- (FMResultSet*) executeQueryWithSql:(NSString*)sqlStr withArgumentsInArray:(NSArray *)arguments;
- (FMResultSet*) executeQueryWithSql:(NSString*)sqlStr;


- (BOOL)isTableExists:(NSString*)tableName;

@end
