//
//  WSAcvtListFlag.m
//  WinSFA
//
//  Created by zhangke on 14/6/27.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSAcvtListFlag.h"

@implementation WSAcvtListFlag
@synthesize acvtId = _acvtId;
@synthesize memo = _memo;
@synthesize storeId = _storeId;
@synthesize empId = _empId;


- (id)initWithObject:(id)object
{
    if (nil == object) {
        return nil;
    }
    self = [super init];
    if (self)
    {
        if ([object isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dic = (NSDictionary *)object;
            _acvtId = [NSString stringWithValue:[dic objectForKey:ACVT_ID]];
            _storeId = [NSString stringWithValue:[dic objectForKey:STOREINFO_STOREID]];
            _memo = [NSString stringWithValue:[dic objectForKey:ACVT_MEMO]];
            _empId = [NSString stringWithValue:[dic objectForKey:ACVT_EMPID]];
         }
    }
    
    return self;
    
}

@end
