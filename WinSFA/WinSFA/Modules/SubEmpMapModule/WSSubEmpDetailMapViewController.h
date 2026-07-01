//
//  WSSubEmpDetailMapViewController.h
//  WinSFA
//
//  Created by yang on 16/3/3.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WCBaseViewController.h"

@interface WSSubEmpDetailMapViewController : WCBaseViewController
@property (nonatomic , assign) BOOL isShowRefreshButton;

- (instancetype)initWithSubEmpID:(NSString *)subEmpID empArray:(NSArray *)empArray;

@end
