//
//  empinforefreshBean.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-4-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSEmpinforefreshBean.h"

@implementation WSEmpinforefreshBean
@synthesize empId = _empId;
@synthesize col1 = _col1;
@synthesize col2 = _col2;
@synthesize col3 = _col3;
@synthesize col4 = _col4;
@synthesize col5 = _col5;
@synthesize col6 = _col6;
@synthesize col7 = _col7;
@synthesize col8 = _col8;
@synthesize typ = _typ;
@synthesize typid = _typid;
@synthesize iEmpinfo = _iEmpinfo;

- (id)initWithObject:(id)object{

    if (nil == object) {
        return nil;
    }
    self = [super init];
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic = (NSDictionary *)object;
            _iEmpinfo = dic;
            _empId = [[NSString stringWithValue:[dic objectForKey:EMPINFOREFRESH_EMPID]] copy];
            _col1 = [[NSString stringWithValue:[dic objectForKey:EMPINFOREFRESH_COL1]] copy];
            _col2 = [[NSString stringWithValue:[dic objectForKey:EMPINFOREFRESH_COL2]] copy];
            _col3 = [[NSString stringWithValue:[dic objectForKey:EMPINFOREFRESH_COL3]] copy];
            _col4 = [[NSString stringWithValue:[dic objectForKey:EMPINFOREFRESH_COL4]] copy];
            _col5 = [[NSString stringWithValue:[dic objectForKey:EMPINFOREFRESH_COL5]] copy];
            _col6 = [[NSString stringWithValue:[dic objectForKey:EMPINFOREFRESH_COL6]] copy];
            _col7 = [[NSString stringWithValue:[dic objectForKey:EMPINFOREFRESH_COL7]] copy];
            _col8 = [[NSString stringWithValue:[dic objectForKey:EMPINFOREFRESH_COL8]] copy];
            _typ = [[NSString stringWithValue:[dic objectForKey:EMPINFOREFRESH_TYP]] copy];
            _typid = [[NSString stringWithValue:[dic objectForKey:EMPINFOREFRESH_TYPID]] copy];
             
        }
    }
    
    return self;
}


@end
