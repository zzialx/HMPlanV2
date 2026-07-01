//
//  SugReplyBeanArray.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSugReplyBeanArray.h"
#import "WSSugReplyOptBean.h"
#import "WSSugReplyBean.h"

@implementation WSSugReplyBeanArray

@synthesize sugReplyArray = _sugReplyArray;
@synthesize optArray = _optArray;

-(id)initWithObject:(id)object
{
    if(object == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        NSDictionary* dic = (NSDictionary*)object;
        NSArray* sug_array = [dic objectForKey:@"suggestioninfo"];
        NSDictionary* sug_dic = nil;
        if([sug_array count]>0)
          sug_dic = [sug_array objectAtIndex:0];

        NSArray* l_optArray =[sug_dic objectForKey:@"opt"];
        _optArray = [[NSMutableArray alloc]init];
        for(int i = 0 ; i < [l_optArray count]; i++)
        {
            WSSugReplyOptBean* srob = [[WSSugReplyOptBean alloc]initWithObject:[l_optArray objectAtIndex:i]];
            [_optArray addObject:srob];
        }
        
        NSArray* l_sugReplyArray = [sug_dic objectForKey:@"c"];
        _sugReplyArray = [[NSMutableArray alloc]init];
        for(int i = 0 ; i < [l_sugReplyArray count]; i++)
        {
            WSSugReplyBean* srb = [[WSSugReplyBean alloc]initWithObject:[l_sugReplyArray objectAtIndex:i]];
            [_sugReplyArray addObject:srb];
        }
        return self;
    }
    return nil;
}


@end
