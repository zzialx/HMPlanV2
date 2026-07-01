//
//  WSQstView.h
//  WinSFA
//
//  Created by zhangke on 15/2/2.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface WSQstView : UIView <WSValidateData>

@property (nonatomic, strong) WSAcvtBean_qst* qst;

@property (nonatomic, assign) float height;

@property (nonatomic, assign) BOOL isValueChange;

@end
