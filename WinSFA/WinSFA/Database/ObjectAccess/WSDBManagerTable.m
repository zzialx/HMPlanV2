//
//  WSDBManagerTable.m
//  WinSFA
//
//  Created by zhangke on 14/9/1.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSDBManagerTable.h"
#import "WSPlistHelper.h"
#import "WSPlistHelper.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"
#import "WCLogFormatter.h"
#import "DDLog.h"


#define kWCH_DBVERSIONTABLE @"wch_dbversion"
#define kWCH_DBVERSIONKEY @"DBVersion"
#define kWCH_UPDATESQLTABLE @"dbSchemeUpdate" // It is updatetable.plist
#define kWCH_SEPARATED @"_"
#define kWCH_DBVERSIONLENGTH 4
#define kWCH_DBVERSIONSEPARATED 2
#define kWCH_DBUPDATEVERSIONSPARATED 2
/**
 从数据库版本7开始 改变数据库的升级逻辑(和安卓保持一致)
 */
#define KWCH_CHANGE_DB_UPDATE_PTTERN_FROME_SEVEN  @"7"


#define k_wch_imagePath "wch_imagePath"
#define k_wch_inoutStore "wch_inoutStore"
#define k_wch_fpt  "wch_fpt"
#define k_wch_fac "wch_fac"
#define k_wch_fdt   "wch_fdt"
#define k_wch_addStore "wch_addStore"
#define k_wch_offLineUpload "wch_offLineUpload"
#define k_wch_product "wch_product"
#define k_wch_facQst "wch_facQst"
#define k_wch_dict "wch_dict"
#define k_wch_addStoreQst "wch_addStoreQst"
#define k_wch_dbversion "wch_dbversion"
#define k_wch_addProduct "wch_addProduct"
#define k_wch_addProductQst "wch_addProductQst"
#define k_visit_store_action "visit_store_action"
#define k_wch_base_store_data "wch_base_store_data"
#define k_ws_request_data_cache "ws_request_data_cache"
#define k_ws_add_newAcvt "ws_add_newAcvt"
#define k_wch_visitStorePlan "wch_visitStorePlan"
#define k_wch_visitPeoplePlan "wch_visitPeoplePlan"
#define k_wch_customTime "wch_customTime"
#define k_ws_download_file "ws_download_file"
#define k_ws_base_store_table "ws_base_store_table"
#define k_ws_base_store_visitplan "ws_base_store_visitplan"
#define k_ws_spe_rich_media "spe_richMedia"
#define k_ws_spe_rich_media_template "spe_richMedia_template"


// Create table by order
static const int kTablesCount = 26;
static const char* wcTables[kTablesCount] = {
    k_wch_imagePath,
    k_wch_inoutStore,
    k_wch_fpt,
    k_wch_fac,
    k_wch_fdt,
    k_wch_addStore,
    k_wch_offLineUpload,
    k_wch_product,
    k_wch_facQst,
    k_wch_dict,
    k_wch_addStoreQst,
    k_wch_dbversion,
    k_wch_addProduct,
    k_wch_addProductQst,
    k_visit_store_action,
    k_wch_base_store_data,
    k_ws_request_data_cache,
    k_ws_add_newAcvt,
    k_wch_visitStorePlan,
    k_wch_visitPeoplePlan,
    k_wch_customTime,
    k_ws_download_file,
    k_ws_base_store_table,
    k_ws_base_store_visitplan,
    k_ws_spe_rich_media,
    k_ws_spe_rich_media_template
};

static WSDBManagerTable *sharedInstance;


#define DBUpdateErrorDomain @"com.channel.dbupdate"
typedef enum {
    XDefultFailed = -1000,
}DBUpdateErrorFailed;


@interface WSDBManagerTable()

@property (nonatomic, assign)int globalError;
@property (nonatomic, strong)NSMutableArray *allUpdateSqls;

- (NSString *)fetchNewDBVersionFromPlist;
- (NSString *)fetchOldDBVersionFromDB;
- (void)sortNumberArray:(NSMutableArray *)aNumberArray order:(BOOL) aOrder; // YES: Ascending NO: Descending
- (BOOL)fetchAllUpdateSqlsByOldVersion:(NSString *)aOldVersion newVersion:(NSString *)aNewVersion;
- (BOOL)execAllSqls;

- (NSArray *)fetchAllCreateTableSqls;
- (BOOL)execAllSqls:(NSArray *)aSqls;

@end



@implementation WSDBManagerTable
@synthesize globalError = _globalError;
@synthesize allUpdateSqls = _allUpdateSqls;


+ (WSDBManagerTable *)sharedTable
{
    if (sharedInstance==nil) {
        sharedInstance= [[WSDBManagerTable alloc]init];
    }
    return  sharedInstance;
}


#pragma mark - private functions
- (NSArray *)fetchAllCreateTableSqls
{
    NSMutableArray *sqls = [NSMutableArray array];
    
    NSDictionary *sqlDic = [WSPlistHelper allPropertiesWithPlistName:@"createTables"];
    
    for (int i = 0; i < kTablesCount; i++) {
        const char* tablename = wcTables[i];
        NSString *keyTableName = [NSString stringWithUTF8String:tablename];
        NSString *createTableSql = [sqlDic objectForKey:keyTableName];
        if (createTableSql && [createTableSql length] > 0) {
            [sqls addObject:createTableSql];
        }
    }
    
    return sqls;
}

- (BOOL)execAllSqls:(NSArray *)aSqls
{
    if (!aSqls || [aSqls count] <= 0) {
        LogWarn(@"No create table sqls");
        return NO;
    }
    
    return [self executeUpdateWithSqls:aSqls];
}


#pragma mark - public functions

- (BOOL)createAllDbTables
{
    //config配置没有数据库版本号不允许创建数据库
    NSString *newDbVersion = [self fetchNewDBVersionFromPlist];
    if (!newDbVersion || [newDbVersion length] <= 0) {
        LogWarn(@"Don't setting DBVersion in the %@.plist" ,kConfilgFileName);
        return NO;
    }
    
    // Fetch old database version from database
    NSString *oldDbVersion = [self fetchOldDBVersionFromDB];
    if (self.globalError != 0) {
        LogWarn(@"sql error code = %d", self.globalError);
        return NO;
    }
    //无版本号创建，否则升级
    if (!oldDbVersion) {
        NSArray *sqls = [self fetchAllCreateTableSqls];
        
        if(!oldDbVersion
           || [oldDbVersion length] < 1){
            NSMutableArray *sqlArray = [NSMutableArray arrayWithCapacity:[sqls count]+ 1];
            [sqlArray addObjectsFromArray:sqls];
            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO wch_dbversion (VERSION,MEMO1,MEMO2) VALUES ('%@','%@','%@');", KWCH_CHANGE_DB_UPDATE_PTTERN_FROME_SEVEN,@"",@""];
            [sqlArray addObject:insertSql];
            sqls = sqlArray;
        }
        if (![self execAllSqls:sqls]) {
            LogError(@"create database failure ");
            return NO;
        }
        oldDbVersion = KWCH_CHANGE_DB_UPDATE_PTTERN_FROME_SEVEN;
        [self updateAllSqlsWithOldVersion:oldDbVersion newVersion:newDbVersion];
        return YES;
        
    }else{
        return [self updateAllSqlsWithOldVersion:oldDbVersion newVersion:newDbVersion];
        
    }
}

- (BOOL)updateAllSqlsWithOldVersion:(NSString *)oldDbVersion newVersion:(NSString *)newDbVersion {
    //升级表结构，不能通过添加、删除字段来修改。因为你不知道这个表是新建的还是老表。
    //所以现在的做法是：改表名为临时表->创建新表->导入数据->删除临时表（升级时会按照顺序操作）
    // Compare old version and new version
    if (oldDbVersion && [oldDbVersion length] > 0) {
        int newVersion = [newDbVersion intValue];
        int oldVersion = [oldDbVersion intValue];
        
        if ( newVersion == oldVersion ) return YES;
        
        if (newVersion < oldVersion) {
            LogWarn(@"old db version %d is greater than new db version %d", oldVersion, newVersion);
            return NO;
        }
    }
    
    //Fetch all update sql
    BOOL flag = [self fetchAllUpdateSqlsByOldVersion:oldDbVersion newVersion:newDbVersion];
    if (!flag) return YES;
    
    // No sql update
    if ([self.allUpdateSqls count] <= 0) return YES;
    
    // add last sql
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO wch_dbversion (VERSION,MEMO1,MEMO2) VALUES ('%@','%@','%@');", newDbVersion,@"",@""];
    [self.allUpdateSqls addObject:insertSql];
    
    if (![self execAllSqls]) {
        LogError(@"Update database failure errcode = %d", [WSDBManagerTable sharedTable].updateErrorCode );
        [self.allUpdateSqls removeAllObjects];
        return NO;
    }
    [self.allUpdateSqls removeAllObjects];
    return  YES;
}


- (NSMutableArray *)allUpdateSqls
{
    if (!_allUpdateSqls) {
        _allUpdateSqls = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _allUpdateSqls;
}

- (void)dealloc
{
    self.globalError = 0;
}

#pragma mark - private function
- (NSString *)fetchNewDBVersionFromPlist
{
    NSString *value = [WSPlistHelper valueForKey:kWCH_DBVERSIONKEY withPlistName:kConfilgFileName];
    return value;
}


- (NSString *)fetchOldDBVersionFromDB
{
    BOOL isExists = [[WSFMDatebase getInstance] isTableExists:@"wch_dbversion"];
    if (!isExists) {
        return nil;
    }
    NSString *dbversion = nil;
    NSString *sql = [NSString stringWithFormat:@"select a.VERSION as version from wch_dbversion a, (select MAX(ID) as ID from wch_dbversion) b where a.ID = b.ID;"];
    
    FMResultSet *rs = [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    while ([rs next]) {
        dbversion=[rs stringForColumn:@"version"];
    }
    
    return dbversion;
}

- (BOOL)fetchAllUpdateSqlsByOldVersion:(NSString *)aOldVersion newVersion:(NSString *)aNewVersion
{
    NSDictionary *dic = [WSPlistHelper allPropertiesWithPlistName:kWCH_UPDATESQLTABLE];
    
    if (!dic) return NO;
    NSArray *allKeys = [dic allKeys];
    if (!allKeys || [allKeys count] == 0) return NO;
    /**
     *  根据configFile.plist的DBVersion版本号决定本次升级执行dbSchemeUpdate.plist的update_(DBVersion)键
     */
    NSMutableArray *numVersionArray = [[NSMutableArray alloc] initWithCapacity:10];
    [allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *updateVersion = (NSString *)obj;
        NSArray *compont = [updateVersion componentsSeparatedByString:kWCH_SEPARATED];
        if (compont && [compont count] >= kWCH_DBUPDATEVERSIONSPARATED ) {
            NSString *version = [compont lastObject];
            NSNumber *versionNumber = [NSNumber numberWithInteger:[version intValue]];
            int newVersion = [aNewVersion intValue];
            
            if (!aOldVersion) {
                if ([versionNumber intValue] <= newVersion) {
                    [numVersionArray addObject:versionNumber];
                }
            }else{
                int oldVersion = [aOldVersion intValue];
                int vn = [versionNumber intValue];
                if (vn > oldVersion && vn <= newVersion) {
                    [numVersionArray addObject:versionNumber];
                }
            }
            
        }
    }];
    
    [self sortNumberArray:numVersionArray order:YES];
    
    //__block NSMutableArray *sqlArray = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
    [numVersionArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *numberVersion = (NSNumber*)obj;
        NSString *key = [NSString stringWithFormat:@"update_%d", [numberVersion intValue]];
        NSDictionary *updateDic = [dic objectForKey:key];
        NSArray *sqlKeys = [updateDic allKeys];
        NSMutableArray *numKeys = [[NSMutableArray alloc] initWithCapacity:10];
        for (NSString *sqlKey in sqlKeys) {
            NSArray *compont = [sqlKey componentsSeparatedByString:kWCH_SEPARATED];
            if (compont && [compont count] == kWCH_DBUPDATEVERSIONSPARATED ) {
                NSString *sqlnumber = [compont lastObject];
                NSNumber *sqlnum = [NSNumber numberWithInteger:[sqlnumber intValue]];
                if (sqlnum) {
                    [numKeys addObject:sqlnum];
                }
            }
        }
        [self sortNumberArray:numKeys order:YES];
        
        [numKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSNumber *number = (NSNumber *)obj;
            NSString *eachSqlKey = [NSString stringWithFormat:@"sql_%d", [number intValue]];
            NSString *sql = [updateDic objectForKey:eachSqlKey];
            if (sql && [sql length] > 0) {
                [self.allUpdateSqls addObject:sql];
            }
        }];
    }];
    
    return YES;
}

- (void)sortNumberArray:(NSMutableArray *)aNumberArray order:(BOOL) aOrder
{
    // Sort key array by ascending
    NSComparator compare = ^(id obj1, id obj2)
    {
        if ([obj1 intValue] > [obj2 intValue]) {
            return aOrder ? NSOrderedDescending : NSOrderedAscending;
        }
        
        if ([obj1 intValue] < [obj2 intValue]) {
            return aOrder ? NSOrderedAscending : NSOrderedDescending;
        }
        return NSOrderedSame;
    };
    
    if (aNumberArray && [aNumberArray count] > 1)
    {
        [aNumberArray sortUsingComparator:compare];
    }
    
}


- (BOOL)execAllSqls
{
    return [self executeUpdateWithSqls:self.allUpdateSqls];
}

- (int)updateErrorCode
{
    return self.globalError;
}


@end
