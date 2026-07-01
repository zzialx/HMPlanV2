//
//  WCGeographicInfo.m
//  WinSFA
//
//  Created by xiaotang.wang on 7/19/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import "WSGeographicInfo.h"
#import "WSBaseGeographicInfo.h"

@implementation WSGeographicInfo

@synthesize iProvineceInfoArray = _iProvineceInfoArray;

- (id)initWithObject:(id)aObject
{
    if (aObject == nil || ![aObject isKindOfClass:[NSDictionary class]]) return nil;
    
    self = [super init];
    if (self) {
        NSDictionary *dic = (NSDictionary *)aObject;
        _iProvineceInfoArray = [[NSMutableArray alloc] init];
        NSArray *array = [dic objectForKey:GEOINFO];
        for (NSDictionary *dic in array) {
            WSBaseGeographicInfo *info = [[WSBaseGeographicInfo alloc] initWithObject:dic];
            [_iProvineceInfoArray addObject:info];
        }
    }
    return self;
}


@end
