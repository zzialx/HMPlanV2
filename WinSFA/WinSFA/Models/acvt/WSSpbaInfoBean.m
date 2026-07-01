//
//  WCSpbaInfoBean.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 6/27/13.
//
//

#import "WSSpbaInfoBean.h"

@implementation WSSpbaInfoBean

@synthesize empId = _empId;
@synthesize acvtId = _acvtId;
@synthesize spbaInfoId = _spbaInfoId;
@synthesize name = _name;
@synthesize typ = _typ;
@synthesize speechLevleId = _speechLevleId;
@synthesize brandTrendId = _brandTrendId;


- (id)initWithObject:(id)aObject
{
    self = [super init];
    if (self) {
        if (aObject != nil && [aObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)aObject;
            _empId = [dic objectForKey:ACVT_EMPID];
            _acvtId = [dic objectForKey:ACVT_ID];
            _spbaInfoId = [dic objectForKey:@"id"];
            _name = [[NSString stringWithValue:[dic objectForKey:@"name"]] copy];
            _typ = [[NSString stringWithValue:[dic objectForKey:@"typ"]] copy];
            _speechLevleId = [dic objectForKey:@"speechLevelId"];
            _brandTrendId = [dic objectForKey:@"brandTrendId"];
        }
    }
    return self;
}


@end


