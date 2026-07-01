//
//  WSAcvtDisBean.m
//  WinSFA
//
//  Created by heju on 15/8/21.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAcvtDisBean.h"

@implementation WSAcvtDisBean

- (id)initWithObject:(id)object {
    
    self = [super init];
    if (self) {
        if (!object) {
            NSLog(@"object is nil");
            return nil;
        }
        if ([object isKindOfClass:[NSDictionary class]]) {
            self.empId = [NSString stringWithValue:[object objectForKey:@"empId"]];
            self.gen_id = [NSString stringWithValue:[object objectForKey:@"gen_id"]];
            self.submitEmpId = [NSString stringWithValue:[object objectForKey:@"submitempid"]];
            self.storeId = [NSString stringWithValue:[object objectForKey:@"newStoreId"]];
            NSString *componentsString = [object objectForKey:@"p"];
            NSArray *components = [componentsString componentsSeparatedByString:@","];
           
            if ([components count] >= WSACVTDIS_P_Componet_count) {
                self.acvtId = [components firstObject];
            }  
            _acvtDisQsts = [[NSMutableArray alloc] init];
            return  self;
        }
        
    }
    return nil;
}

- (void)addQstDisBean:(WSAcvtDisQstBean *)qst  {
    [_acvtDisQsts addObject:qst];
}

@end
