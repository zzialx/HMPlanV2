//
//  EmpAcvtDis.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSEmpAcvtDis.h"

@implementation WSEmpAcvtDis
@synthesize m_p = _m_p;
@synthesize m_empId = _m_empId;
@synthesize m_qstId = _m_qstId;
@synthesize m_acvtId = _m_acvtId;
@synthesize m_disValue = _m_disValue;

-(id)initWithObject:(id)object
{
    if(object == nil)
        return nil;
    self = [super init];
    if(self)
    {
        NSDictionary* i_object = (NSDictionary*)object;
        self.m_p = [i_object objectForKey:EAD_P];
        NSArray* i_pArray = [self.m_p componentsSeparatedByString:@","];
        if([i_pArray count]==4)
        {
            self.m_empId = [[NSString stringWithValue:[i_pArray objectAtIndex:0]]copy];
            self.m_acvtId = [[NSString stringWithValue:[i_pArray objectAtIndex:1]]copy];
            self.m_qstId = [[NSString stringWithValue:[i_pArray objectAtIndex:2]]copy];
            self.m_disValue = [[NSString stringWithValue:[i_pArray objectAtIndex:3]]copy];
        }
    }
    return self;
}


@end
