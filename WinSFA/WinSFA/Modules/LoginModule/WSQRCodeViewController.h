//
//  WSQRCodeViewController.h
//  WinSFA
//
//  Created by heju on 14-7-29.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

//#if BUILD_QQAPIDEMO
//#import "TencentOpenAPI/QQApiInterface.h"
//#else
//#define QQApiInterfaceDelegate NSObject
//#endif

#import "BaseViewController.h"
@interface WSQRCodeViewController : BaseViewController


@property (nonatomic, strong) NSString *updateUrl;
@property (nonatomic, assign) BOOL isFromQst;
@property (nonatomic, assign) BOOL isNotSendMessage;
@property (nonatomic, assign) CGFloat qrCodeWidth;

@end
