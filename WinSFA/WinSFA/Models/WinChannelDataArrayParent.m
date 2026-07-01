//
//  WinChannelDataArrayParent.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WinChannelDataArrayParent.h"

@implementation WinChannelDataArrayParent

@synthesize pParent = _pParent;

-(void)initWithObject:(id)object Key:(NSString*)targetId;
{
    self.pParent = [[NSMutableDictionary alloc]init];
//    if([object isKindOfClass:[NSArray class]])
//    {
//        for (int i = 0; i < [object count]; i++) {
//            NSObject *element = [[NSObject alloc]init]; 
//            eleme\nt = [object objectAtIndex:i];
//            NSDictionary *dic = [object objectAtIndex:i];
//            NSString *key = [NSString stringWithValue:
//                             [dic objectForKey:targetId]];
//            [self.pParent setObject:element forKey:key];
//            
//            [element release];
//            
//        }
//    }
    
}


@end
