//
//  WSCustomEnterStoreTimeObject.m
//  WinSFA
//  自定义进店时间对象
//  Created by dujinfeng481 on 14-7-29.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSCustomEnterStoreTimeObject.h"

@implementation WSCustomEnterStoreTimeObject

- (id) initWithDic:(NSDictionary*)dic
{
    if (!dic) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        id temp = [dic objectForKey:EMPID];
        if (temp && ![temp isKindOfClass:[NSNull class]]) {
            _empIdStr = [NSString stringWithValue:temp];
        }
        
        temp = [dic objectForKey:ALLOWED_PERIOD];
        if (temp && ![temp isKindOfClass:[NSNull class]]) {
            _timeLimitStr = [NSString stringWithValue:temp];
        }
    }
    
    return self;
}


@end
