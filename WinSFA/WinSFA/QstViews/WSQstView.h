//
//  WSQstView.h
//  WinSFA
//
//  Created by zhangke on 15/2/2.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "WSAcvtViewController.h"

@interface WSQstView : UIView

@property (nonatomic,weak) WSAcvtViewController* acvtVC;

@property (nonatomic, strong) WSAcvtBean_qst* qst;

@property (nonatomic, assign) float height;

@end
