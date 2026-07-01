//
//  WSTypListMsgViewController.h
//  WinSFA
//
//  Created by mac on 2018/11/9.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WCBaseViewController.h"

@interface WSTypListMsgViewController : WCBaseViewController

@property (nonatomic, strong) UITableView           *titlesTableView;

@property (nonatomic, strong) NSMutableArray        *dataArray;

- (id)initWithFuncs:(WSFuncsBean *)funcs;

@end
