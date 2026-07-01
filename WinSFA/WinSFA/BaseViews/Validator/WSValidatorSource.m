//
//  WSValidatorSource.m
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-6.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSValidatorSource.h"
#import "WSAcvtViewController.h"
#import "WSValidatorDdsItem.h"

@implementation WSValidatorSource


- (void)initDDS {
    NSString *dds = self.currentQst.dds;
    NSArray *array = [dds componentsSeparatedByString:@","];
    _ddsArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for (NSString *aStr in array) {
        if ([self respondsToSelector:@selector(ddsItem:acvtQst:)]) {
//            id item = [self performSelector:@selector(ddsItem:function:) withObject:aStr withObject:self.currentQst.func];
            id item = [self performSelector:@selector(ddsItem:acvtQst:) withObject:aStr withObject:self.currentQst];
            [_ddsArray addObject:item];
        }
    }
}

/*!
 *  支持 2 条校验逻辑
 */
- (void)initDDS2 {
    NSString *dds2 = self.currentQst.dds2;
    NSArray *array2 = [dds2 componentsSeparatedByString:@","];
    _dds2Array = [[NSMutableArray alloc] initWithCapacity:[array2 count]];
    for (NSString *aStr in array2) {
        if ([self respondsToSelector:@selector(ddsItem2:acvtQst:)]) {
            //            id item = [self performSelector:@selector(ddsItem:function:) withObject:aStr withObject:self.currentQst.func];
            id item2 = [self performSelector:@selector(ddsItem2:acvtQst:) withObject:aStr withObject:self.currentQst];
            [_dds2Array addObject:item2];
        }
    }
}

- (float)value {
    if (_ddsArray == nil) {
        [self initDDS];
    }
    float result = 0;
    for (WSValidatorDdsItem *aItem in _ddsArray) {
//        NSNumber *number = [self performSelector:@selector(getValueFromDddsString:) withObject:aDds];
        result += [aItem getValue];
    }
    return result;
}

- (float)value2 {
    if (_dds2Array == nil) {
        [self initDDS2];
    }
    float result = 0;
    for (WSValidatorDdsItem *aItem in _dds2Array) {
        result += [aItem getValue];
    }
    return result;
}

@end
