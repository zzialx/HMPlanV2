//
//  WSStoreVisitViewController.h
//  WinSFA
//
//  Created by Alicia on 17/1/19.
//  Copyright © 2017年 WinChannel. All rights reserved.
//
#import "WSAllStoresViewController.h"

@interface WSStoreVisitScrollViewController : WSAllStoresViewController

@property (nonatomic,assign) BOOL infiniteLoop; // Default YES

@property (nonatomic, assign) BOOL isAutoScroll; // Default NO

- (id)initWithFuncs:(WSFuncsBean *)funcs;

@end
