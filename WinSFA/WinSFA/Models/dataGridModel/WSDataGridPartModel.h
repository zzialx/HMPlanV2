//
//  WSDataGridPartModel.h
//  WinSFA
//
//  Created by HZH on 2017/7/17.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSDataGridPartModel : NSObject

@property (nonatomic, copy) NSString *widgetType;
@property (nonatomic, strong) WSAcvtBean_qst *acvtQst;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) NSInteger point_x;
@property (nonatomic, assign) NSInteger point_y;

@property (nonatomic, assign) NSInteger point_m;
@property (nonatomic, assign) NSInteger point_n;

@property (nonatomic, copy) NSString *valueStr;
@property (nonatomic, assign) BOOL hideTopLine;
@property (nonatomic, assign) BOOL hideLeftLine;

@end
