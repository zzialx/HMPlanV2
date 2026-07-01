//
//  WSDataGridCollectionViewCell.h
//  WinSFA
//
//  Created by HZH on 2017/7/17.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSWidget.h"
#import "WSDataGridPartModel.h"

@interface WSDataGridCollectionViewCell : UICollectionViewCell 

@property (nonatomic, strong) WSDataGridPartModel *model;

- (WSWidget *)getWidget;

- (void)setTextFieldBecomeFirstResonder;


@end
