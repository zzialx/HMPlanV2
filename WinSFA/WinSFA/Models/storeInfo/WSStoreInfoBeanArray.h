//
//  StoreInfoBeanArray.h
//  WinChannelFrameWork
//
//  Created by wdy on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSStoreInfoBean.h"
#define STOREINFOS @ "storeInfo"
#define EMPSRINFO @ "empsrinfo"

@interface WSStoreInfoBeanArray : NSObject

@property (nonatomic, strong) NSMutableArray *storeinfoArray;

- (id)initWithObject:(id)object;

- (NSArray *)getStoreinfosWithFilter:(NSString *)filter;

@end
