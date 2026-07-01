//
//  SuggestionListArray.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSuggestionListArray.h"
#import "WSSuggestListBean.h"


@implementation WSSuggestionListArray

@synthesize m_suggestListArray = _m_suggestListArray;

-(id)initWithObject:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]]){
        
        self = [super init];
        if(self != nil)
        {
            NSDictionary* dic = (NSDictionary*)object;
            NSArray* l_sugArray = [dic objectForKey:@"mysuggestionlist"];
            
            self.m_suggestListArray = [[NSMutableArray alloc]init];
            for(int i = 0 ; i < [l_sugArray count]; i++)
            {
                WSSuggestListBean* sb = [[WSSuggestListBean alloc]initWithObject:[l_sugArray objectAtIndex:i]];
                [self.m_suggestListArray addObject:sb];
            }
            return self;
        }
        return nil;
        
    }
    return nil;
}


@end
