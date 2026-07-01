//
//  WSBaseInStoreProdTable.m
//  WinSFA
//
//  Created by heju on 16/8/1.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseInStoreProdTable.h"

@implementation WSBaseInStoreProdTable

static WSBaseInStoreProdTable *baseInStoreProdTable;

+(instancetype)shareInstance {
    if (baseInStoreProdTable == nil) {
        static dispatch_once_t once_Token;
        dispatch_once(&once_Token, ^{
            baseInStoreProdTable = [[self alloc] init];
        });
    }
    return baseInStoreProdTable;
}

- (BOOL)insertInStoreProdToDbWith:(NSArray *)inStroeProds serverNode:(NSString *)serverNode{
    
    
    NSDictionary *firstProdDic = [inStroeProds firstObject];
    
    NSArray *pArray = [firstProdDic[@"p"] componentsSeparatedByString:@","];
    
    NSArray *spec = [WSAppData getObjectbyKey:PRODSPEC];
    
    if ([pArray count] > [spec count]) {
        LogInfo(@"[pArray count] > [spec count]  is error");
        return NO;
    }
    
    NSMutableArray *sqls = [NSMutableArray array];
   
    for (NSInteger i = 0; i < [inStroeProds count]; i++) {
        NSString *insertSql = @"INSERT INTO base_in_store_prod (";
        NSDictionary *prodDic = inStroeProds[i];
        NSString *p = prodDic[@"p"];
        NSString *imgtypeStr = [NSString stringNotNilWithValue:prodDic[@"imgtype"]];

        NSArray *pComponents = [p componentsSeparatedByString:@","];
        
        NSMutableArray *subSpecs = [NSMutableArray array];
        NSMutableArray *subSpecsValues = [NSMutableArray array];
        for (NSInteger j = 0; j < [spec count]; j++) {
            NSString *curentSubSpec = spec[j];
            if (j < [pComponents count]) {
                NSString *subSpecValue = pComponents[j];
                if (curentSubSpec && subSpecValue) {
                    [subSpecs addObject:curentSubSpec];
                    [subSpecsValues addObject:subSpecValue];
                }
            }
        }
        
        for (NSInteger m =0; m < [subSpecs count]; m++) {
            NSString *cSpecSub = [subSpecs[m] lowercaseString];
            if ([cSpecSub isEqualToString:@"sid"] || [cSpecSub isEqualToString:@"drid"]) {
                cSpecSub = @"store_id";
                [subSpecs replaceObjectAtIndex:m withObject:cSpecSub];
            }else if ([cSpecSub isEqualToString:@"pid"]){
                cSpecSub = @"prod_id";
                [subSpecs replaceObjectAtIndex:m withObject:cSpecSub];
            }else if ([cSpecSub isEqualToString:@"func_code"]){
                cSpecSub = @"funccode";
                [subSpecs replaceObjectAtIndex:m withObject:cSpecSub];
            }
            if (m != [subSpecs count] -1) {
                insertSql = [insertSql stringByAppendingFormat:@"%@,",cSpecSub];
                
            }else {
                insertSql = [insertSql stringByAppendingFormat:@"%@",cSpecSub];

                if (imgtypeStr && imgtypeStr.length > 0) {
                    insertSql = [insertSql stringByAppendingFormat:@",imgtype"];
                }
                insertSql = [insertSql stringByAppendingFormat:@",server_node)"];
            }
        }
        
        
        NSString  *sql = [insertSql copy];
        sql = [sql stringByAppendingFormat:@"values ("];
        
        for (NSInteger n = 0; n < [subSpecsValues count]; n++) {
            NSString *cSpecValue = subSpecsValues[n];
            if (n != [subSpecsValues count] -1) {
                sql = [sql stringByAppendingFormat:@"'%@',",[NSString stringNotNilWithValue:cSpecValue]];
                
            }else {
                sql = [sql stringByAppendingFormat:@"'%@'",[NSString stringNotNilWithValue:cSpecValue]];
            }
        }
        
        if (imgtypeStr && imgtypeStr.length > 0) {
            sql = [sql stringByAppendingFormat:@",'%@'",imgtypeStr];
        }
        sql = [sql stringByAppendingFormat:@",'%@')",[NSString stringNotNilWithValue:serverNode]];
        
        [sqls addObject:sql];
    }
    BOOL succeed = [self executeUpdateWithSqls:sqls];
    
    return succeed;
}

@end
