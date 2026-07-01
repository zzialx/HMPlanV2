//
//  InPlanStoreBean.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#define INPLANSTORE @ "inplanstore"
#import <Foundation/Foundation.h>
#import "WSAbstArrayStoreBean.h"

@class WSStoreBean;

@interface WSInPlanStoreBean : WSAbstArrayStoreBean
//延迟获取storeBean的prodArray数据
-(id)initWithObjectForWSAppData:(id)object;
-(id)initWithObjectForWSAppData:(id)object andParseKey:(NSString *)parseKey;

- (WSStoreBean *)getStoreBeanByID:(NSString *)storeID;

@end
