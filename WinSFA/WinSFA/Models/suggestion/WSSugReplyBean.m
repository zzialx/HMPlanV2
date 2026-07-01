//
//  SugReplyBean.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSugReplyBean.h"

@implementation WSSugReplyBean
@synthesize m_REPLY = _m_REPLY;
@synthesize m_empName = _m_empName;
@synthesize m_uploadDate = _m_uploadDate;
@synthesize m_sugid = _m_sugid;

- (id)initWithObject:(id)object
{
    if([object isKindOfClass:[NSDictionary class]])
    {
        self = [super init];
        if(self != nil)
        {
            NSDictionary* dic = (NSDictionary*)object;
            _m_sugid = [dic objectForKey:@"sugid"];
            _m_empName = [dic objectForKey:@"empName"];
            _m_REPLY = [dic objectForKey:@"REPLY"];
            _m_uploadDate = [dic objectForKey:@"uploadDate"];
            return self;
        }

    }
    return nil;
}

@end
