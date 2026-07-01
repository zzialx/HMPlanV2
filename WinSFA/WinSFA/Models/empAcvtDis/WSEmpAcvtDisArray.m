//
//  EmpAcvtDisArray.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSEmpAcvtDisArray.h"
#import "WSEmpAcvtDis.h"


@implementation WSEmpAcvtDisArray

@synthesize m_empAcvtDisArray = _m_empAcvtDisArray;

- (void)initArrayWithArray:(NSArray*)array
{
    if(array == nil || [array count] <1)
        return;
    _m_empAcvtDisArray = [[NSMutableArray alloc]init];
    for(NSDictionary* f_dic in array)
    {
        WSEmpAcvtDis* f_empAcvtDis = [[WSEmpAcvtDis alloc]initWithObject:f_dic];
        [self.m_empAcvtDisArray addObject:f_empAcvtDis];
    }
        
}


-(id)initWithObject:(id)object
{
    if(object == nil)
        return nil;
    self = [super init];
    if(self)
    {
        if([object isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* i_dic = (NSDictionary*)object;
            NSArray* l_array = [i_dic objectForKey:EMPACVTDIS];
            [self initArrayWithArray:l_array];
        }
    }
    return self;
}


@end
