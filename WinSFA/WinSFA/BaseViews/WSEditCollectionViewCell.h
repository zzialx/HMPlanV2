//
//  WSEditCollectionViewCell.h
//  WinSFA
//
//  Created by zhangmin on 2018/11/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSWidget.h"
#import "WSDataGridPartModel.h"

@interface WSEditCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) WSDataGridPartModel *model;

- (WSWidget *)getWidget;

- (void)setTextFieldBecomeFirstResonder;
@end
