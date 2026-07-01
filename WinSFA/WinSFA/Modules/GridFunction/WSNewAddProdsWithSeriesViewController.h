//
//  WSNewAddProdsWithSeriesViewController.h
//  WinSFA
//
//  Created by HZH on 2017/9/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "BaseViewController.h"
#import "WSDataGridPartModel.h"
#import "WSWidget.h"
#import "WSBaseDataGridComponentDataSource.h"
#import "WSAcvtBean.h"

#define RECEIVEMORE             @"receiveMoreProducts"

@interface WSNewAddProdsWithSeriesViewController : BaseViewController

@property (nonatomic, copy) NSString *addProdsJumpStyle;

@property (nonatomic ,strong) WSAcvtBean *currentAcvtBean;


- (instancetype)initWithDataGridComponentDataSource:(WSBaseDataGridComponentDataSource *)dataSource title:(NSString *)titleName;

- (void)postReceiveMoreNotificationAndSendSelectedProducts;

- (void)gridWidgetValueChangeWithWidget:(WSWidget *)widget andDataGridModel:(WSDataGridPartModel *)model;

@end
