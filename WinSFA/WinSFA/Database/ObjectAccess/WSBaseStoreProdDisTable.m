//
//  WSBaseStoreProdDisTable.m
//  WinSFA
//
//  Created by heju on 16/3/1.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseStoreProdDisTable.h"

@implementation WSBaseStoreProdDisTable


static WSBaseStoreProdDisTable *baseStoreProdDisTable = nil;

+ (WSBaseStoreProdDisTable *)sharedTable{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        baseStoreProdDisTable = [[WSBaseStoreProdDisTable alloc] init];
    });
    return baseStoreProdDisTable;
}


- (BOOL)deleteProddisDatasWithStoreId:(NSString *)storeId {
    
    NSArray *names = @[@"store_id"];
    NSArray *values = @[[NSString stringNotNilWithValue:storeId]];
    return [self deleteWithNames:names ArgumentsValue:values];
    
}


- (BOOL)deleteProddisDatasWithStoreId:(NSString *)storeId andProdIds:(NSArray *)prodIds
{
    
    NSMutableArray *whereNames = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *whereValues = [NSMutableArray arrayWithCapacity:1];
    //store_id
    [whereNames addObject:@"store_id"];
    [whereValues addObject:[NSString stringNotNilWithValue:storeId]];
    
    NSArray *uploadInfoArr=[self queryWithNames:whereNames ArgumentsValue:whereValues];
    
    
    if ([uploadInfoArr count]>0) {
        for(NSString *prodId in prodIds) {
            [whereNames removeAllObjects];
            [whereValues removeAllObjects];
            //prod_id
            [whereNames addObject:@"prod_id"];
            [whereValues addObject:[NSString stringNotNilWithValue:prodId]];
            [[WSBaseStoreProdDisTable sharedTable] deleteWithNames:whereNames ArgumentsValue:whereValues];
        }
        return YES;
    }
    return NO;
}

- (BOOL)insertProddisDatasWith:(NSArray *)proddiss {
    
    /*插入之前先出所有此门店的回显数据*/
    
    if (proddiss == nil) {
        LogInfo(@"proddis is nil");
        return NO;
    }
    
    NSArray* spec = [WSAppData getObjectbyKey:PRODSPECDIS];
    if (!spec || [spec count] < 1) {
        spec = [WSAppData getObjectbyKey:PRODSPEC];
    }
    
    NSMutableArray *sqls = [NSMutableArray array];
    NSString *insertSql = @"INSERT INTO base_store_prod_dis (";
    for (NSInteger i = 0; i < [proddiss count]; i++) {
        NSDictionary *proddisDic = proddiss[i];
        NSString *p = proddisDic[@"p"];
        NSArray *pComponents = [p componentsSeparatedByString:@","];
        NSString *sql = [insertSql copy];
        for (NSInteger m = 0; m < [pComponents count]; i++) {
            NSString *specSub = spec[m];
            specSub = [specSub lowercaseString];
            if ([specSub isEqualToString:@"sid"] || [specSub isEqualToString:@"drid"]) {
                specSub = @"store_id";
            }else if ([specSub isEqualToString:@"pid"]){
                specSub = @"prod_id";
            }else if ([specSub isEqualToString:@"func_code"]){
                specSub = @"funccode";
            }
            if (m != [pComponents count] -1) {
                sql = [sql stringByAppendingFormat:@"%@,",specSub];
            }else {
                sql = [sql stringByAppendingFormat:@"%@)",specSub];
            }
        }
        sql = [sql stringByAppendingFormat:@" values ("];
        for (NSInteger j = 0; j < [pComponents count]; j++) {
            if (j != [pComponents count] -1) {
                sql = [sql stringByAppendingFormat:@"'%@',",[NSString stringNotNilWithValue:pComponents[j]]];
            } else {
                sql = [sql stringByAppendingFormat:@"'%@')",[NSString stringNotNilWithValue:pComponents[j]]];
            }
        }
        
        [sqls addObject:sql];
    }
    return [self executeUpdateWithSqls:sqls];
}


@end
