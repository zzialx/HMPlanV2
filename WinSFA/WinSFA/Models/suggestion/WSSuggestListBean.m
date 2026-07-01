//
//  SuggestListBean.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSuggestListBean.h"

@implementation WSSuggestListBean
@synthesize m_id = _m_id;
@synthesize m_memo = _m_memo;
@synthesize m_topic = _m_topic;
@synthesize m_biz_date = _m_biz_date;
@synthesize m_emp_name = _m_emp_name;
@synthesize m_replyCount = _m_replyCount;

- (id)initWithObject:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]])
    {
        self = [super init];
        if(self != nil)
        {
            NSDictionary* dic = (NSDictionary*)object;
            _m_id = [dic objectForKey:SUG_LIST_ID];
            _m_memo = [dic objectForKey:SUG_LIST_MEMO];
            _m_topic = [dic objectForKey:SUG_LIST_TOPIC];
            _m_biz_date = [dic objectForKey:SUG_LIST_BIZ_DATE];
            _m_emp_name = [dic objectForKey:SUG_LIST_EMP_NAME];
            _m_replyCount = [NSString stringWithValue:[dic objectForKey:SUG_LIST_REPLYCOUNT]];
            return self;
        }
    }
    return nil;
}


@end
