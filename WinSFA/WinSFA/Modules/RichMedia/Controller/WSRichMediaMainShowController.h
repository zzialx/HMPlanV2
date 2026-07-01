//
//  WSRichMediaMainShowController.h
//  WinSFA
//
//  Created by huzepei on 16/8/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@interface WSRichMediaMainShowController : BaseViewController

@property (nonatomic, strong) WSFuncsBean         *m_currentFuncs;
@property (nonatomic, strong) WSStoreBean         *m_currentStore;
@property (nonatomic,copy) NSString *visitData;

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)aStore;

@end
