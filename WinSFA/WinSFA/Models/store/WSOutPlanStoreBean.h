//
//  OutPlanStoreBean.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
// 修改为
#define OUTPLANSTORE @ "outplanstore"
#define OUTEMPPLAN   @ "outempplan"
#define INEMPPLAN    @ "inempplan"
#define HOS          @ "hos"
#import <Foundation/Foundation.h>
#import "WSAbstArrayStoreBean.h"

@interface WSOutPlanStoreBean : WSAbstArrayStoreBean
//延迟获取storeBean的prodArray数据
-(id)initWithObjectForWSAppData:(id)object;
@end
