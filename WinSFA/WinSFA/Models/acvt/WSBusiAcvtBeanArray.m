//
//  WCBusiAcvtBeanArray.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 6/26/13.
//
//

#import "WSBusiAcvtBeanArray.h"
#import "WSBusiAcvtBean.h"

@implementation WSBusiAcvtBeanArray

@synthesize busiAcvtBeanArray = _busiAcvtBeanArray;


- (id)initWithObject:(id)aObject
{
    self = [super init];
    if (self) {
        if (aObject != nil && [aObject isKindOfClass:[NSArray class]]) {
            NSArray *items = (NSArray *)aObject;
            for (id item in items) {
                if (item != nil && [item isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dicItem = (NSDictionary *)item;
                    WSBusiAcvtBean *bean = [[WSBusiAcvtBean alloc] initWithObject:dicItem];
                    [self.busiAcvtBeanArray addObject:bean];
                }
            }
        }
    }
    return self;
}


- (NSMutableArray *)busiAcvtBeanArray
{
    if (_busiAcvtBeanArray == nil) {
        _busiAcvtBeanArray = [[NSMutableArray alloc] init];
    }
    return _busiAcvtBeanArray;
}

- (NSArray *)getBusiAcvtArrayByAcvtId:(int)aAcvtId
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:8];
    for (WSBusiAcvtBean *bean in self.busiAcvtBeanArray) {
        if (bean.acvtId && ([bean.acvtId intValue] == aAcvtId)) {
            [array addObject:bean];
        }
    }
    return array;
}

@end
