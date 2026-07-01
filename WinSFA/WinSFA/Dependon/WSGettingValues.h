//
//  WSGettingValues.h
//  WinSFA
//
//  Created by xiaotang.wang on 9/2/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WSGettingValues <NSObject>

@optional

- (NSDictionary *)getDicValue;

- (NSString *)getTextValue;

- (BOOL)isValueLegal;


@end
