//
//  StoreAcvtDisBean.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-4-9.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSStoreAcvtDisBean.h"
#import "I_W_OptionDataItem.h"

@implementation WSStoreAcvtDisBean
@synthesize m_p = _m_p;
@synthesize m_empId = _m_empId;

- (id)initWithObject:(id)object
{
    if([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* i_dic = (NSDictionary*)object;
        self = [super init];
        if(self)
        {
            _m_p = [[NSMutableArray alloc]init];
            NSString* i_p = [i_dic objectForKey:@"p"];
            NSArray* i_pArray = [i_p componentsSeparatedByString:@","];
            [_m_p addObjectsFromArray:i_pArray];
            
            self.m_empId = [i_dic objectForKey:@"empId"];
            self.gen_id = [i_dic objectForKey:@"gen_id"];
            self.acvt_newStoreId = [i_dic objectForKey:@"newStoreId"];
        }
    }
    return self;
}


- (NSString *)getDataItemID
{
    return self.gen_id;
}

- (NSString *)getDataItemName
{
    if ([_m_p count] > ACVTDIS_VALUE) {
        return [_m_p objectAtIndex:ACVTDIS_VALUE];
    }
    
    return nil;
}


@end
