//
//  SpecialAcvtViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperWorkSpaceViewController.h"
#import "WSFuncsBean.h"

@class WSAcvtViewController;

@interface WSSpecialAcvtViewController : SuperWorkSpaceViewController {}

@property(nonatomic,strong)WSAcvtViewController* m_AcvtViewController;

@property(nonatomic, copy) NSString *uploadStyle; // YIHAIKERRY-2436 升级临时方案

- (id)initWithFuncs:(WSFuncsBean *)funcs;
-(void)setSubempid:(NSString*)empid;


- (BOOL)isValueChange;

@end
