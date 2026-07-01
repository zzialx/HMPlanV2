//
//  WCSpbaInfoBeanArray.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 6/27/13.
//
//

#import "WSSpbaInfoBeanArray.h"
#import "WSSpbaInfoBean.h"

@implementation WSSpbaInfoBeanArray

@synthesize spbaInfoBeanArray = _spbaInfoBeanArray;

#pragma mark - init & dealloc
- (id)initWithObject:(id)aObject
{
    self = [super init];
    if (self) {
        if (aObject != nil && [aObject isKindOfClass:[NSArray class]]) {
            NSArray *array = (NSArray *)aObject;
            for (id item in array) {
                if (item != nil && [item isKindOfClass:[NSDictionary class]]) {
                    WSSpbaInfoBean *bean = [[WSSpbaInfoBean alloc] initWithObject:item];
                    [self.spbaInfoBeanArray addObject:bean];
                }
            }
        }
    }
    return self;
}



- (NSMutableArray *)spbaInfoBeanArray
{
    if (_spbaInfoBeanArray == nil) {
        _spbaInfoBeanArray = [[NSMutableArray alloc] initWithCapacity:8];
    }
    return _spbaInfoBeanArray;
}

- (NSArray *)getspbaInfoBeansByType:(NSString *)aType
{
    NSMutableArray *arrayBeans = [[NSMutableArray alloc] initWithCapacity:8];
    for (WSSpbaInfoBean *bean in self.spbaInfoBeanArray) {
        if (bean.typ != nil && [bean.typ isKindOfClass:[NSString class]] && [bean.typ isEqualToString:aType]) {
            [arrayBeans addObject:bean];
        }
    }
    return arrayBeans;
}

- (NSArray *)getspbaInfoBeansByType:(NSString *)aType andWithAcvtId:(int)aAcvtId
{
    NSMutableArray *arrayBeans = [[NSMutableArray alloc] initWithCapacity:8];
    for (WSSpbaInfoBean *bean in self.spbaInfoBeanArray) {
        if (bean.typ != nil && [bean.typ isKindOfClass:[NSString class]] && [bean.typ isEqualToString:aType] && ([bean.acvtId intValue] == aAcvtId)) {
            [arrayBeans addObject:bean];
        }
    }
    return arrayBeans;
}

@end
