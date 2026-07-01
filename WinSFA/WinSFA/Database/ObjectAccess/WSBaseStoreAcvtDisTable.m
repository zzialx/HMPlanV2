//
//  WSBaseStoreAcvtDisTable.m
//  WinSFA
//
//  Created by heju on 16/2/23.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

static const NSInteger P_COUNT = 4;

#import "WSBaseStoreAcvtDisTable.h"

@implementation WSBaseStoreAcvtDisTable


static WSBaseStoreAcvtDisTable *baseStoreAcvtDisTable = nil;

+ (WSBaseStoreAcvtDisTable *)sharedTable{
  
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        baseStoreAcvtDisTable = [[WSBaseStoreAcvtDisTable alloc] init];
    });
    return baseStoreAcvtDisTable;
}


- (void)insertAcvtDisDatasWith:(NSArray *)acvtdiss{
    if (acvtdiss == nil) {
        LogInfo(@"acvtdiss is nil");
        return;
    }
    
    NSDictionary *dic = [acvtdiss firstObject];
    NSString *storeID = [NSString stringWithValue:dic[@"sid"]];
    NSString *acvtid = [NSString stringWithValue:dic[@"acvtid"]];
    NSString *qstid = [NSString stringWithValue:dic[@"acvtQstid"]];

    if ([storeID length] > 0 && acvtid.length == 0) {
        [self deleteWithNames:@[@"sid"] ArgumentsValue:@[storeID]];
    }
    //橙色已采集需要删除，再插入
    if ([storeID length] > 0 && acvtid.length > 0) {
        NSString * orangeAnswer = [NSString stringWithFormat:@"%@",dic[@"opt_value"]];
        if ([orangeAnswer isEqualToString:@"完美已采集"]) {
            [self deleteWithNames:@[@"sid",@"acvtid",@"acvtQstId"] ArgumentsValue:@[storeID,acvtid,qstid]];
        }
    }
    
    for (NSInteger i = 0; i < [acvtdiss count]; i++) {
        NSDictionary *acvtdisDic =acvtdiss[i];
        NSString *sid =acvtdisDic[@"sid"];
        NSString *p = acvtdisDic[@"p"];
        NSString *acvtId = [[NSString stringWithFormat:@"%@",acvtdisDic[@"acvtid"]] length] > 0 ? [NSString stringWithFormat:@"%@",acvtdisDic[@"acvtid"]]:@"";
        NSString *acvtQstId = [[NSString stringWithFormat:@"%@",acvtdisDic[@"acvtQstid"]] length] > 0 ? [NSString stringWithFormat:@"%@",acvtdisDic[@"acvtQstid"]]:@"";
        NSString *qst_answer = [[NSString stringWithFormat:@"%@",acvtdisDic[@"acvt_qst_answer"]] length] > 0 ? [NSString stringWithFormat:@"%@",acvtdisDic[@"acvt_qst_answer"]]:@"";
        NSArray *pComponents = [p componentsSeparatedByString:@","];
        if ([pComponents count] == P_COUNT) {
            acvtId = pComponents[1];
            acvtQstId = pComponents[2];
            qst_answer = pComponents[3]; 
        }
        NSString *gen_id = [NSString stringNotNilWithValue:acvtdisDic[@"gen_id"]];
        NSString *assetid = @"";
        NSString *opt_value = [[NSString stringWithFormat:@"%@",acvtdisDic[@"opt_value"]] length] > 0 ? [NSString stringWithFormat:@"%@",acvtdisDic[@"opt_value"]]:@"";
        NSString *is_search = @"";
        NSString *newstoreid = [NSString stringNotNilWithValue:acvtdisDic[@"newStoreId"]];
        NSString *server_node = [[NSString stringWithFormat:@"%@",acvtdisDic[@"server_node"]] length] > 0 ? [NSString stringWithFormat:@"%@",acvtdisDic[@"server_node"]]:@"storeacvtdis";
        NSString *empId = [NSString stringNotNilWithValue:acvtdisDic[@"empId"]];
        NSString *getTime = @"";
        NSArray *values = @[sid,acvtId,acvtQstId,qst_answer,gen_id,assetid,opt_value,is_search,newstoreid,server_node,empId,getTime];
        
        BOOL insertSucceed =[self insertWithArgumentsValue:values];
        if (!insertSucceed) {
            LogInfo(@"storeacvtdis 数据插入失败");
        }
    }
}

@end
