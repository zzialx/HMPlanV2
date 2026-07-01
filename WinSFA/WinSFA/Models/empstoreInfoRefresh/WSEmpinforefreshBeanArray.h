//
//  empinforefreshBeanArray.h
//  WinChannelFrameWork
//
//  Created by wdy on 12-4-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSEmpinforefreshBean.h"
#define EMPINFOREFRESHS @ "empinforefresh"

@interface WSEmpinforefreshBeanArray : NSObject

@property (nonatomic, strong) NSMutableArray *empinforefreshArray;

- (id)initWithObject:(id)object;

- (NSArray *)getEmpinforefreshsWithFilter:(NSString *)filter;

@end
