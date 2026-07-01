//
//  WSBaseStoreDictDisTable.m
//  WinSFA
//
//  Created by heju on 16/3/7.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseStoreDictDisTable.h"

@implementation WSBaseStoreDictDisTable


static WSBaseStoreDictDisTable *baseStoreDictDisTable = nil;

+ (WSBaseStoreDictDisTable *)sharedTable {
    if (baseStoreDictDisTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseStoreDictDisTable = [[WSBaseStoreDictDisTable alloc] init];
        });
    }
    return baseStoreDictDisTable;
}


- (void)insertDictdisDatasWith:(NSArray *)dictdiss{
    if (dictdiss == nil) {
        LogInfo(@"dictdis is nil");
        return;
    }
    
    NSString *emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    [dictdiss enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = (NSDictionary *)obj;
        NSString *sid = dict[@"sid"];
        NSString *pStr = dict[@"p"];
        NSArray *pArray = [pStr componentsSeparatedByString:@","];
        NSString *dictIdAndFc = @"";
        NSString *dictId = @"";
        NSString *fc = @"";
        NSString *col1 = @"";
        NSString *col2 = @"";
        NSString *col3 = @"";
        NSString *col4 = @"";
        NSString *col5 = @"";
        NSString *col6 = @"";
        NSString *col7 = @"";
        NSString *col8 = @"";
        NSString *col9 = @"";
        NSString *col10 = @"";
        NSString *col11 = @"";
        NSString *col12 = @"";
        NSString *col13 = @"";
        NSString *col14 = @"";
        NSString *col15 = @"";
        NSString *col16 = @"";
        NSString *col17 = @"";
        NSString *col18 = @"";
        NSString *col19 = @"";
        NSString *col20 = @"";
        NSString *col21 = @"";
        NSString *col22 = @"";
        NSString *col23 = @"";
        NSString *col24 = @"";
        NSString *col25 = @"";
        NSString *col26 = @"";
        NSString *col27 = @"";
        NSString *col28 = @"";
        NSString *col29 = @"";
        NSString *col30 = @"";
        NSString *col31 = @"";
        NSString *col32 = @"";
        NSString *col33 = @"";
        NSString *col34 = @"";
        NSString *col35 = @"";
        NSString *col36 = @"";
        NSString *col37 = @"";
        NSString *col38 = @"";
        NSString *col39 = @"";
        NSString *col40 = @"";
        
        if ([pArray count]> 2) {
            dictIdAndFc = [pArray objectAtIndex:1];
            NSArray *idFcArray =[dictIdAndFc componentsSeparatedByString:@"@"];
            dictId = [idFcArray firstObject];
            fc = [idFcArray lastObject];
        }
        /*下发的 col1 - col9    表里边字段到col10*/
        if ([pArray count] >=40) {
            col1 = pArray[2];
            col2 = pArray[3];
            col3 = pArray[4];
            col4 = pArray[5];
            col5 = pArray[6];
            col6 = pArray[7];
            col7 = pArray[8];
            col8 = pArray[9];
            col9 = pArray[10];
            col10 = pArray[11];
            col11 = pArray[12];
            col12 = pArray[13];
            col13 = pArray[14];
            col14 = pArray[15];
            col15 = pArray[16];
            col16 = pArray[17];
            col17 = pArray[18];
            col18 = pArray[19];
            col19 = pArray[20];
            col20 = pArray[21];
            col21 = pArray[22];
            col22 = pArray[23];
            col23 = pArray[24];
            col24 = pArray[25];
            col25 = pArray[26];
            col26 = pArray[27];
            col27 = pArray[28];
            col28 = pArray[29];
            col29 = pArray[30];
            col30 = pArray[31];
            col31 = pArray[32];
            col32 = pArray[33];
            col33 = pArray[34];
            col34 = pArray[35];
            col35 = pArray[36];
            col36 = pArray[37];
            col37 = pArray[38];
            col38 = pArray[39];
            col39 = pArray[40];
            col40 = pArray[41];
        }
        NSString *assetId = @"";
        
        NSArray *names = @[@"emp_id",@"sid",@"dict_id",@"func_code"];
        NSArray *values = @[emp_id,sid,dictId,fc];
        /*查找是否有就旧数据*/
        NSInteger querys = [self queryCountWithNames:names  ArgumentsValue:values];
        if (querys > 0) {
            /*有则删除*/
            [self deleteWithNames:names ArgumentsValue:values];
        }
        NSArray *insertValues = @[emp_id,sid,fc,dictId,col1,col2,col3,col4,col5,col6,col7,col8,col9,col10,assetId,col11,col12,col13,col14,col15];
        [self insertWithArgumentsValue:insertValues];
        
    }];
    
}
@end
