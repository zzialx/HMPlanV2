//
//  WSValidatorTextField.h
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-6.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#define RANGE_TYPE_GE   @"GE"   // GE大于等于
#define RANGE_TYPE_LE   @"LE"   // LE小于等于
#define RANGE_TYPE_GT   @"GT"   // GT大于
#define RANGE_TYPE_LT   @"LT"   // LT大于
#define RANGE_TYPE_NE   @"NE"   // NE不等于
#define RANGE_TYPE_EQ   @"EQ"   // EQ等于

#import <Foundation/Foundation.h>
#import "WSAcvtViewController.h"
#import "WSAcvtBean_qst.h"
#import "WSValidatorSource.h"

@interface WSValidatorTextField : WSHTextField

- (id)initWithFrame:(CGRect)aRect qst:(WSAcvtBean_qst *)aQst validatorSource:(WSValidatorSource *)aSource;
- (BOOL)validate;

@property (nonatomic, strong) WSValidatorSource *currentSource;
@property (nonatomic, strong) WSAcvtBean_qst *qst;

@end
