//
//  UIViewController+Additional.h
//  WinChannelFrameWork
//
//  Created by Niu Zhaowang on 10/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFuncsBean.h"
#import "WSStoreBean.h"
#import "WSMappingObject.h"

@interface UIViewController (Additional)

@property (nonatomic, strong) WSStoreBean *currentStore;
@property (nonatomic, strong) WSVisitStoreActionObject *currentVisitAction;
@property (nonatomic, assign) BOOL showActionTip;
@property (nonatomic, strong) NSString *prepareVisitDate;

@end
