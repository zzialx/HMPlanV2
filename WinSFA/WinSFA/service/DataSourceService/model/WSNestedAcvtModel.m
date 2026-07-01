//
//  WSNestedAcvtModel.m
//  WinSFA
//
//  Created by yang on 16/1/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSNestedAcvtModel.h"

@implementation WSNestedAcvtModel

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.isSubAcvt = YES;
    }
    
    return self;
}

- (BOOL)isFromNewAddList
{
    return YES;
}


@end
