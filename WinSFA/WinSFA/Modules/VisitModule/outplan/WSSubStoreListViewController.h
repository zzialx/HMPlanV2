//
//  WSSubStoreListViewController.h
//  WinSFA
//
//  Created by yang on 14-5-21.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSAllStoresViewController.h"

@interface WSSubStoreListViewController : WSAllStoresViewController

@property (nonatomic, strong) WSStoreBean *parentStoreBean;

-(id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean*)store;

@end
