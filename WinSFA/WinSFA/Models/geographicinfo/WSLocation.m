//
//  WSLocation.m
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-16.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSLocation.h"

@implementation WSLocation

- (id)initWithObject:(id)object {
    if (nil == object) {
        return nil;
    }
    self = [super init];
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)object;
            _city = [NSString stringWithValue:[dic objectForKey:@"city"]];
            _cityCode = [NSString stringWithValue: [dic objectForKey:@"cityCode"]];
        }
    }
    return self;
}


@end
