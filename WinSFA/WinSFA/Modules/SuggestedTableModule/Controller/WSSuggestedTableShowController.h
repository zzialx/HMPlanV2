//
//  WSSuggestedTableShowController.h
//  WinSFA
//
//  Created by huzepei on 16/7/5.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCBaseViewController.h"

@interface WSSuggestedTableShowController : WCBaseViewController

@property (nonatomic, strong) WSFuncsBean         *m_currentFuncs;
@property (nonatomic, strong) WSStoreBean         *m_currentStore;

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)aStore;

@property (nonatomic,copy) NSString *prepareDate;

@end
