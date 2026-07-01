//
//  WSBaseInstoreProdDBService.m
//  WinSFA
//
//  Created by heju on 16/8/1.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseInstoreProdDBService.h"

#import "WSBaseInStoreProdTable.h"

@implementation WSBaseInstoreProdDBService



-(BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData
{
    return [self replaceToTableWithDicts:dicts FromNode:nodeName hasNewData:hasNewData storeID:nil];
}

- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID
{
    if ([storeID length] > 0) {
        if ([dicts count] > 0) {
            //根据storeId或者drId清除数据
            NSString *idStr = nil;
            
            NSDictionary *firstProdDic = [dicts firstObject];
            NSArray *pArray = [firstProdDic[@"p"] componentsSeparatedByString:@","];
            NSArray *spec = [WSAppData getObjectbyKey:PRODSPEC];
            
            for (NSInteger m = 0; m < [spec count]; m++) {
                NSString *cSpecSub = [spec[m] lowercaseString];
                if ([cSpecSub isEqualToString:@"sid"] || [cSpecSub isEqualToString:@"drid"]) {
                    if ([pArray count] > m) {
                        idStr = pArray[m];
                    }
                    break;
                }
            }
            
            if ([idStr length] > 0) {
                
                [[WSBaseInStoreProdTable shareInstance] deleteWithNames:@[@"store_id",@"server_node"] ArgumentsValue:@[idStr,nodeName]];
            }
            
        }
    }else {
        
        //兼容：base_in_store_prod表新增了server_node列，老数据的server_node为空，为了清空老数据，清除server_node为空的数据。
        NSString *sql = @"delete from base_in_store_prod where server_node is null";
        [[WSBaseInStoreProdTable shareInstance] executeUpdateWithSqls:@[sql]];
        
        [[WSBaseInStoreProdTable shareInstance] deleteWithNames:@[@"server_node"] ArgumentsValue:@[nodeName]];
    }
    
    if ([dicts count] > 0) {
        return [[WSBaseInStoreProdTable shareInstance] insertInStoreProdToDbWith:dicts serverNode:nodeName];
    }
    
    return YES;
}





@end
