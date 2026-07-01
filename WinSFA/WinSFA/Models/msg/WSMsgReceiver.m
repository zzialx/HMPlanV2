//
//  MsgReceiver.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-21.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSMsgReceiver.h"

@implementation WSMsgReceiver

@synthesize m_empId = _m_empId;
@synthesize m_msgId = _m_msgId;
@synthesize m_empName = _m_empName;
@synthesize m_orgName = _m_orgName;

- (id)initWithObject:(id)object
{
    if(object == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        if([object isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* l_dic = (NSDictionary*)object;
            _m_empId = [NSString stringWithValue:[l_dic objectForKey:MSG_RCV_EMPID]];
            _m_msgId = [NSString stringWithValue:[l_dic objectForKey:MSG_RCV_ID]];
            _m_orgName = [NSString stringWithValue:[l_dic objectForKey:MSG_RCV_ORGNAME]];
            _m_empName = [NSString stringWithValue:[l_dic objectForKey:MSG_RVC_EMPNAME]];
        }
    }
    return self;
}


@end
