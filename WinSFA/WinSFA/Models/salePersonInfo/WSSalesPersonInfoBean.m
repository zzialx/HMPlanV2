//
//  SalesPersonInfoBean.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-3-12.
//
//

#import "WSSalesPersonInfoBean.h"

@implementation WSSalesPersonInfoBean

@synthesize empId = _empId;
@synthesize col1 = _col1;
@synthesize col2 = _col2;
@synthesize col3 = _col3;
@synthesize col4 = _col4;
@synthesize col5 = _col5;
@synthesize typ = _typ;

- (id)initWithObject:(id)object {
    
    if (nil == object) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic = (NSDictionary *)object;
            self.empId = [NSString stringWithValue:[dic objectForKey:SALESPERSONINFO_EMPID]];
            self.col1 = [[dic objectForKey:SALESPERSONINFO_COL1] copy];
            self.col2 = [[dic objectForKey:SALESPERSONINFO_COL2] copy];
            self.col3 = [[dic objectForKey:SALESPERSONINFO_COL3] copy];
            self.col4 = [[dic objectForKey:SALESPERSONINFO_COL4] copy];
            self.col5 = [[dic objectForKey:SALESPERSONINFO_COL5] copy];
            self.typ = [[dic objectForKey:SALESPERSONINFO_TYP] copy];
        }
    }
    
    return self;
}


@end
