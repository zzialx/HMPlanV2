//
//  WSEditCellBaseView.h
//  WinSFA
//
//  Created by zhangmin on 2018/11/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSWidget.h"
#import "WSDataGridPartModel.h"
@interface WSEditCellBaseView : UIView<WSWidgetDelegate>
@property (nonatomic, strong) WSWidget  *widget;

-(id)initWithFrame:(CGRect)frame andDataGridModel:(WSDataGridPartModel *)model;

- (void)setTextFieldBecomeFirstResonder;
@end
