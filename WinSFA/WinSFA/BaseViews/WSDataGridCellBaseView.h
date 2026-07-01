//
//  WSDataGridCellBaseView.h
//  WinSFA
//
//  Created by HZH on 2017/7/22.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSWidget.h"
#import "WSDataGridPartModel.h"

@interface WSDataGridCellBaseView : UIView <WSWidgetDelegate>
@property (nonatomic, strong) WSWidget  *widget;

-(id)initWithFrame:(CGRect)frame andDataGridModel:(WSDataGridPartModel *)model;

- (void)setTextFieldBecomeFirstResonder;

@end
