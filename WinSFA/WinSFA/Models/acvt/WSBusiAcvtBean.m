//
//  WCbusiAcvtBean.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 6/26/13.
//
//

#import "WSBusiAcvtBean.h"

@implementation WSBusiAcvtBean
@synthesize empId = _empId;
@synthesize acvtId = _acvtId;
@synthesize name = _name;
@synthesize isMyAcvt = _isMyAcvt;


#pragma mark - init & dealloc
- (id)initWithObject:(id)aObject
{
    self = [super init];
    if (self) {
        NSDictionary *dicAcvtItem = (NSDictionary *)aObject;
        if (dicAcvtItem != nil && [dicAcvtItem isKindOfClass:[NSDictionary class]]) {
            _empId = [dicAcvtItem objectForKey:ACVT_EMPID];
            _acvtId = [dicAcvtItem objectForKey:ACVT_ID];
            if ([dicAcvtItem objectForKey:@"name"] != nil) {
                _name =  [[NSString stringWithValue:[dicAcvtItem objectForKey:@"name"]] copy];
            }
            
            if ([dicAcvtItem objectForKey:@"isMyAcvt"] != nil) {
                _isMyAcvt = [[NSString stringWithValue:[dicAcvtItem objectForKey:@"isMyAcvt"]] copy];
            }
        }
    }
    return self;
}



@end
