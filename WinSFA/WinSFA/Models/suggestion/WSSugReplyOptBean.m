//
//  SugReplyOptBean.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSugReplyOptBean.h"

@implementation WSSugReplyOptBean
@synthesize m_sugid = _m_sugid;
@synthesize m_pk = _m_pk;
@synthesize m_name = _m_name;

- (id)initWithObject:(id)object
{
    if([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* dic = (NSDictionary*)object;
        
        self = [super init];
        if(self != nil)
        {
            _m_sugid = [dic objectForKey:@"sugid"];
            _m_pk = [dic objectForKey:@"pk"];
            _m_name = [dic objectForKey:@"name"];
            return self;
        }
    }
    return nil;
}



@end
