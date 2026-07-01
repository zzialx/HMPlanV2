//
//  SugBean.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSugBean.h"

@implementation WSSugBean

@synthesize m_pk = _m_pk;
@synthesize m_empId = _m_empId;
@synthesize m_name = _m_name;

- (id)initWithObject:(id)object{
    if (nil == object) {
        return nil;
    }
    self = [super init];
    
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)object;
            
            _m_pk = [dic objectForKey:SUG_PK];
            _m_empId = [dic objectForKey:SUG_EMPID];
            _m_name = [dic objectForKey:SUG_NAME];
        }
    }
    
    return self;
}

@end
