//
//  WSStorePlanManager.m
//  WinSFA
//
//  Created by mac on 2019/1/17.
//  Copyright © 2019年 WinChannel. All rights reserved.
//

#import "WSStorePlanManager.h"

@implementation WSStorePlanManager

static WSStorePlanManager *instance;

+ (WSStorePlanManager*)sharedInstance
{
    if (!instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[WSStorePlanManager alloc] init];
        });
    }
    
    return instance;
}

- (void)deleteData
{
    [WSStorePlanManager sharedInstance].storePlanArr = nil;
    [WSStorePlanManager sharedInstance].storePlanTime = nil;
    [WSStorePlanManager sharedInstance].fcTime =nil;
    [WSStorePlanManager sharedInstance].storePlanOldArr =nil;
    [WSStorePlanManager sharedInstance].isChange = NO;
    [WSStorePlanManager sharedInstance].isChangeDic =nil;


}
@end


