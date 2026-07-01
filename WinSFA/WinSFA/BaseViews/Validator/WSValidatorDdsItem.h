//
//  WSValidatorDdsItem.h
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-6.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#define FUNCTION_TYPE_COUNT             @"count"            // 总行数（包括填 0 的行数）
#define FUNCTION_TYPE_COUNT_NONZERO     @"count_nonzero"    // 不包括填零的行数
#define FUNCTION_TYPE_SUM               @"sum"              // 总和

#import <Foundation/Foundation.h>
#import "WSAcvtBean_qst.h"
#import "WSAcvtDataGridComponentView.h"

@interface WSValidatorDdsItem : NSObject

@property (nonatomic, copy) NSString *acvtCode;
@property (nonatomic, copy) NSString *acvtQstCode;
@property (nonatomic, copy) NSString *qstCol;
@property (nonatomic, copy) NSString *function;
@property (nonatomic, copy) NSString *checkType;

@property (nonatomic, strong) WSAcvtBean *acvtBean;
@property (nonatomic, assign) BOOL pageData;
@property (nonatomic, strong) UIView *view;

- (float)getValue;

@end
