//
//  WSNoticeNumFcService.m
//  WinSFA
//
//  Created by wangzhiwei on 2018/5/17.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSNoticeNumFcService.h"
#import "WSBaseAcvtdisDBService.h"
static WSNoticeNumFcService *noticeNumFcService;

@interface WSNoticeNumFcService ()
@property (nonatomic, strong) NSDictionary *storeMenuNotice;
@end

@implementation WSNoticeNumFcService

-(NSDictionary *)getAllStoreMenuNotice
{
    if (self.storeMenuNotice == nil) {
        
        NSDictionary *menuNoticeDict = [self noticeNumFunctionRelation];
        WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
        NSArray *PlistKeys = @[@"getMenuNoticeNum1",@"getMenuNoticeNum2",@"getMenuNoticeNum3"];
        NSMutableArray *sqlArray = [NSMutableArray array];
        for (NSString *PlistKey in PlistKeys) {
            [sqlArray addObject:[service getSQLWithPlistKey:PlistKey keyArray:nil valueArray:nil]];
        }
        NSString *tempFc = nil;
        NSMutableDictionary *TempMenuNoticeDict = [NSMutableDictionary dictionary];
        for (NSString *sql in sqlArray) {
            NSArray *storeMens = [self getWillShowCurrentStoreMensBySql:sql andClassName:@"WSFuncsMenuNoticeObject"];
            for (WSFuncsMenuNoticeObject * obj in storeMens) {
                tempFc = [menuNoticeDict objectForKey:obj.fc];
                if (tempFc == nil) {
                    tempFc = obj.fc;
                }
                
                NSString *value = [NSString stringWithFormat:@"%@_%@",obj.sid,tempFc];

                //YIHAIKERRY-3154 益海嘉里-深圳：【ios】传统渠道-门店拜访：模块右上角未显示“问卷数量”   2018-6-21
                if (TempMenuNoticeDict[value] ) {
                    int  num = [TempMenuNoticeDict[value] intValue];
                    num += [obj.totalNum intValue];
                    [TempMenuNoticeDict setValue:[NSString stringWithFormat:@"%d",num] forKey:value];
                }else {
                    [TempMenuNoticeDict setValue:obj.totalNum forKey:value];
                }

            }
            
        }
        
        self.storeMenuNotice = [NSDictionary dictionaryWithDictionary:TempMenuNoticeDict];
    }
    return self.storeMenuNotice;
}
- (NSDictionary *)noticeNumFunctionRelation
{
    
    NSMutableDictionary *noticeNumFcDict = [NSMutableDictionary dictionary];
    NSString * sql = @"select noticeNumFc, fc from base_funcs where noticeNumFc is not null";
    NSArray *storeMens = [self getWillShowCurrentStoreMensBySql:sql andClassName:@"WSFuncsMenuNoticeObject"];
    NSString *noticeNumFc = nil;
    NSString *fc = nil;
    for (WSFuncsMenuNoticeObject *obj in storeMens) {
        
        noticeNumFc = obj.noticeNumFc;
        fc = obj.fc;
        NSArray *noticeNumFcs = [noticeNumFc componentsSeparatedByString:@","];
        
        for (NSString * noticeNumfc in noticeNumFcs) {
            
            [noticeNumFcDict setValue:fc forKey:noticeNumfc];
        }
        
    }
    return noticeNumFcDict;
}
//获取要展示的门店菜单的数量
- (NSArray *)getWillShowCurrentStoreMensBySql:(NSString *)sql andClassName:(NSString *)className {
    
    WSSqliteUtil *object = [[WSSqliteUtil alloc]init];
    
    return  [object queryAndReturnInfosBySql:sql andClassName:className];
}


@end
