//
//  WCNavigationController.h
//  QuadCore
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//



#import <UIKit/UIKit.h>

@class WSFuncsBean;


@interface WCNavigationController : UINavigationController

@property (nonatomic, assign) BOOL shouldRotate;

@property (nonatomic, strong) WSFuncsBean *funcsBean;

@end
