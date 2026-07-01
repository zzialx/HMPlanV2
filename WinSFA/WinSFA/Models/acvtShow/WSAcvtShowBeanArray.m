//
//  WCAcvtShowBeanArray.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 6/14/13.
//
//

#import "WSAcvtShowBeanArray.h"
#import "WSAcvtShowBean.h"

@implementation WSAcvtShowBeanArray

@synthesize iAcvtShowBeans = _iAcvtShowBeans;


- (id)initWithObject:(id) aObject
{
    self = [super init];
    if (self) {
        if (aObject != nil && [aObject isKindOfClass:[NSDictionary class]]) {
            NSArray *beans = [aObject objectForKey:@"acvtshow"];
            if (beans != nil) {
                _iAcvtShowBeans = [[NSMutableArray alloc] init];
                [beans enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    WSAcvtShowBean *bean = [[WSAcvtShowBean alloc] initWithObject:obj];
                    if (bean != nil) {
                        [_iAcvtShowBeans addObject:bean];
                    }
                    bean = nil;
                }];
            }
        }
        
    }
    return self;
}



- (NSArray *)getAcvtshowbeansWithAcvtid:(int) aAcvtId
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:8];
    for (WSAcvtShowBean *bean in self.iAcvtShowBeans) {
        if (bean && [bean.iId intValue] == aAcvtId) {
            [array addObject:bean];
        }
    }
    return (([array count] > 0) ? array : nil);
}

@end
