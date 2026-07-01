//
//  WSVisitRecordListController.h
//  WinSFA
//
//  Created by Nemo on 14-3-25.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface WSVisitRecordListController : BaseViewController<UITableViewDataSource,UITableViewDelegate>


- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store;

@end
