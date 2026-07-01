//
//  WSBrandLevelArray.m
//  WinSFA
//
//  Created by xiaotang.wang on 9/6/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import "WSBrandLevelArray.h"
#import "WSPointInfo.h"

@implementation WSBrandLevelArray

@synthesize iBrandLevelArray = _iBrandLevelArray;

- (id)initWithObject:(id)aObj
{
    self = [super init];
    if (self != nil) {
        
        NSArray *array = [aObj objectForKey:GEOPOINTINFO];
        if (array != nil && [array count] > 0) {
            _iBrandLevelArray = [[NSMutableArray alloc] initWithCapacity:8];
            
            for (NSDictionary *dic in array) {
                WSPointInfo *info = [[WSPointInfo alloc] initWithObject:dic withPointInfoType:WSPointInfoBrandType];
                [_iBrandLevelArray addObject:info];
            }
        }
    }
    return self;
}

@end
