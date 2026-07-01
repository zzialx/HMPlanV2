//
//  WSProdGrideWithExpandableBrandsViewController.h
//  WinSFA
//
//  Created by HZH on 2017/7/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "WSDataGridPartModel.h"
#import "WSWidget.h"

@interface WSProdGrideWithExpandableBrandsViewController : BaseViewController

- (void)gridWidgetValueChangeWithWidget:(WSWidget *)widget andDataGridModel:(WSDataGridPartModel *)model;

- (void)upload;

@end
