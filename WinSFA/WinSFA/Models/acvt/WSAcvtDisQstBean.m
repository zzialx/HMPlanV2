//
//  AcvtDisBean.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSAcvtDisQstBean.h"
#import "WinSFA.h"

@implementation WSAcvtDisQstBean

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
            self.m_empId = [NSString stringWithValue:[i_dic objectForKey:@"empId"]];
            self.gen_id = [NSString stringWithValue:[i_dic objectForKey:@"gen_id"]];
            self.submitEmpId = [NSString stringWithValue:[i_dic objectForKey:@"submitempid"]];
            self.storeIdForQst = [NSString stringWithValue:[object objectForKey:@"newStoreId"]];
            _m_p = [[NSMutableArray alloc]init];
            NSString* i_p = [i_dic objectForKey:@"p"];
            NSArray* i_pArray = [i_p componentsSeparatedByString:@","];
            
            if (i_pArray && [i_pArray count] >= WSACVTDIS_P_Componet_count) {
                
                self.acvtId = [i_pArray firstObject];
            
                self.qstId = [i_pArray objectAtIndex:1];
                
                if ([i_pArray count] == WSACVTDIS_P_Componet_count) {
                    
                    self.qstValue = [i_pArray objectAtIndex:2];
                    
                } else if ([i_pArray count] > WSACVTDIS_P_Componet_count) {
                    
                    NSArray *subArray = [i_pArray subarrayWithRange:NSMakeRange(2, [i_pArray count] - 2)];
                    self.qstValue =[subArray componentsJoinedByString:@","];
                }
            }
            [_m_p addObjectsFromArray:i_pArray];
        }
    }
    return self;
}


@end
