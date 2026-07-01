//
//  WSMediaMainController.h
//  WinSFA
//
//  Created by huzepei on 16/7/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface WSRichMediaMainController : BaseViewController

@property (nonatomic, strong) WSFuncsBean         *m_currentFuncs;
@property (nonatomic, strong) WSStoreBean         *m_currentStore;

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)aStore;

@property (nonatomic,copy) NSString *visitData;

@property (nonatomic,copy) void (^uploadDemolist)();

@end
