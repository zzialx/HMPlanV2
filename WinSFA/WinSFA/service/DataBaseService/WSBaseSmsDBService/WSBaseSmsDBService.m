//
//  WSBaseSmsDBService.m
//  WinSFA
//
//  Created by mac on 16/12/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseSmsDBService.h"
#import "WSBaseSmsDataTable.h"
#import "WSSMSManagerModel.h"
@implementation WSBaseSmsDBService

-(NSMutableArray *)getAllSMSManagerFromDB{
    
    WSBaseSmsDataTable * smstable = [[WSBaseSmsDataTable alloc]init];
    NSMutableArray * mutableArray = [smstable queryAndReturnInfosBySql:@"select * from base_sms_data" andClassName:@"WSBaseSmsDataObject"];
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    NSMutableArray * dataSource = [NSMutableArray arrayWithCapacity:0];
    for (WSBaseSmsDataObject * obj in mutableArray) {
        NSMutableArray * array =  [dic objectForKey:obj.receiver_num];
        if (!array) {
            array = [[NSMutableArray alloc]init];
        }
        [array addObject:obj];
        [dic setObject:array forKey:obj.receiver_num];
        
    }
    NSArray * keyArray = [dic allKeys];
    
    for (NSString * key in keyArray) {
        NSMutableArray * tempArray = [dic objectForKey:key];
        NSSortDescriptor *carNameDesc = [NSSortDescriptor sortDescriptorWithKey:@"receiver_num" ascending:NO];
        NSArray *descriptorArray = [NSArray arrayWithObjects:carNameDesc, nil];
        tempArray =  [[tempArray sortedArrayUsingDescriptors:descriptorArray] mutableCopy];
        WSSMSManagerModel  *model = [[WSSMSManagerModel alloc]init];
        model.lastObject = [tempArray lastObject];
        model.array = tempArray;
        [dataSource addObject:model];
    }
    return dataSource;
}
@end
