//
//  PayDisPlayBeanArray.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-6-27.
//
//

#import "PayDisPlayBeanArray.h"

@implementation PayDisPlayBeanArray

@synthesize beanArray = _beanArray;


- (id)initWithObject:(id)object {
    if (!object) {
        return nil;
    }
    self = [super init];
    if (self) {
        if ([object isKindOfClass:[NSArray class]]) {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:[object count]];
            for (NSDictionary *beanDic in object) {
                PayDisPlayBean *bean = [[PayDisPlayBean alloc] initWithObject:beanDic];
                if (bean) {
                    [array addObject:bean];
                }
            }
            _beanArray = [[NSMutableArray alloc] initWithArray:array];
        }
    }
    return self;
}

- (id)initWithFilter:(NSString *)filter{

    if (!filter) {
        return nil;
    }
    self = [super init];
    if (self) {
        PayDisPlayBeanArray *payDisPlays = [WSAppData getObjectbyKey:@"pay"];
        
        NSMutableArray *Array = [[NSMutableArray alloc]init];
        
        for (PayDisPlayBean *payDisBean in payDisPlays.beanArray) {
            if ([payDisBean.sid isEqualToString:filter]) {
                [Array addObject:payDisBean];
            }
        }
        
        _beanArray= [[NSMutableArray alloc]initWithArray:Array];

    }
    
    return self;
}

@end
