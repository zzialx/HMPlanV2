//
//  WSDataGridComponentView.h
//  WinSFA
//
//  Created by HZH on 2017/7/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSDataGridRightTableModel.h"

@interface WSDataGridComponentView : UIView <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) WSDataGridRightTableModel *dataModel;

- (id)initWithFrame:(CGRect)aRect andDataModel:(WSDataGridRightTableModel *)dataModel;

- (void)setGridBecomeFirstResponder;

@end
