//
//  WSPfizerEtripModifyStoreInfoViewController.h
//  WinSFA
//
//  Created by yang on 14-5-9.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WCBaseViewController.h"
#import "BaseViewController.h"

@interface WSPfizerEtripModifyStoreInfoViewController : BaseViewController

- (id)initWithFuncs:(WSFuncsBean *)funcs store:(WSStoreBean*)store storeInfoDic:(NSDictionary *)storeInfoDic;

@end
