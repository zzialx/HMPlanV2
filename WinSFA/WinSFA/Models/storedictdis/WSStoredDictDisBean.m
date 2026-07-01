//
//  WSStoredDictDisBean.m
//  WinSFA
//
//  Created by xiajl on 14-11-20.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSStoredDictDisBean.h"

@implementation WSStoredDictDisBean

- (id)initWithObject:(id)object
{
    if([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* i_dic = (NSDictionary*)object;
        self = [super init];
        if(self)
        {
            NSString* i_p = [i_dic objectForKey:@"p"];
            NSArray* i_pArray = [i_p componentsSeparatedByString:@","];
            _m_p = i_pArray;
            
            _m_empId = [i_dic objectForKey:@"empId"];
            _gen_id = [i_dic objectForKey:@"gen_id"];
        }
    }
    return self;
}

@end
