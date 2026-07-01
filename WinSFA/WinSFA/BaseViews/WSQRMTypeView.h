//
//  WSQRMTypeView.h
//  WinSFA
//
//  Created by HZH on 17/4/7.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSQRTypeView.h"

@interface WSQRMTypeView : WSQRTypeView

@property (nonatomic, copy)NSString *displayString;

- (instancetype)initWithParam:(WSFuncsBean_Param *)aParam;

@end
