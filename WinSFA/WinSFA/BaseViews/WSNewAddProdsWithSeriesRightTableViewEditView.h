//
//  WSNewAddProdsWithSeriesRightTableViewEditView.h
//  WinSFA
//
//  Created by zhangmin on 2018/11/7.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSDataGridRightTableModel.h"

@interface WSNewAddProdsWithSeriesRightTableViewEditView : UIView<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) WSDataGridRightTableModel *dataModel;

- (id)initWithFrame:(CGRect)aRect andDataModel:(WSDataGridRightTableModel *)dataModel;

- (void)setGridBecomeFirstResponder;
@end
