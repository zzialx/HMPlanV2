//
//  WSNewAddProdsWithSeriesRightTableViewCell.h
//  WinSFA
//
//  Created by HZH on 2017/9/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSNewAddProdsWithSeriesModel.h"

@class WSNewAddProdsWithSeriesRightTableViewCell;

@protocol WSNewAddProdsWithSeriesRightTableViewCellDelegate <NSObject>

- (void)needUpdateCell:(WSNewAddProdsWithSeriesRightTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)needRefreshTotalPrice;
- (void)needUpdateCellHeight;
@end

typedef NS_ENUM(NSInteger, HNewAddProdsWithSeriesDisplayStyle) {
    HNewAddProdsWithSeriesDisplayStyleDefault,
    HNewAddProdsWithSeriesDisplayStyleGridView,      //
    HNewAddProdsWithSeriesDisplayStyleAcvtView       //
};

@interface WSNewAddProdsWithSeriesRightTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *checkboxImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *inventoryLabel; //库存lab

@property (nonatomic, strong) UIButton *salesButton; //促销详情按钮


@property (nonatomic, assign) BOOL isChecked;
@property (nonatomic, assign) BOOL isFolded;

@property (nonatomic, strong) WSProdBean *prodBean;
@property (nonatomic, strong) WSStoreBean *currentStore;

@property (nonatomic, strong) NSArray *needAddEditParamsArray;
@property (nonatomic, strong) NSArray *allNeedParamsArray;

@property (nonatomic, strong) NSMutableDictionary *prodKeyValueCacheDataDic;

@property (nonatomic, assign) NSInteger secondTypeIndex;

@property (nonatomic, copy) NSString *prodTypeImageUrls;
@property (nonatomic, assign) HNewAddProdsWithSeriesDisplayStyle displayStyle;

@property (nonatomic, assign) CGFloat cellRealHeight;

@property (nonatomic, strong) WSTableItem *currentTableItem;

@property (nonatomic, copy) NSString *luaScriptString;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) id <WSNewAddProdsWithSeriesRightTableViewCellDelegate>  cellDelegate;

@property (nonatomic, strong) WSNewAddProdsWithSeriesModel *rightTableModel;

- (void)setGridBecomeFirstResponder;



@end
