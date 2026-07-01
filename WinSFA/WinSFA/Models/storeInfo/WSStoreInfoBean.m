//
//  StoreInfoBean.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSStoreInfoBean.h"

@implementation WSStoreInfoBean
@synthesize empId = _empId;
@synthesize storeId = _storeId;
@synthesize col1 = _col1;
@synthesize col2 = _col2;
@synthesize col3 = _col3;
@synthesize col4 = _col4;
@synthesize col5 = _col5;
@synthesize typ = _typ;
@synthesize typid = _typid;


- (id)initWithObject:(id)object
{
    
    if (nil == object) {
        return nil;
    }
    self = [super init];
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic = (NSDictionary *)object;
            self.empId = [NSString stringWithValue:[dic objectForKey:STOREINFO_EMPID]];
            self.storeId = [NSString stringWithValue:[dic objectForKey:STOREINFO_STOREID]];
            self.col1 = [dic objectForKey:STOREINFO_COL1];
            self.col2 = [dic objectForKey:STOREINFO_COL2];
            self.col3 = [dic objectForKey:STOREINFO_COL3];
            self.col4 = [dic objectForKey:STOREINFO_COL4];
            self.col5 = [dic objectForKey:STOREINFO_COL5];
            self.typ = [NSString stringWithValue:[dic objectForKey:STOREINFO_TYP]];
            self.typid = [dic objectForKey:STOREINFO_TYPID];
            
        }
    }
    
    return self;
}



@end
