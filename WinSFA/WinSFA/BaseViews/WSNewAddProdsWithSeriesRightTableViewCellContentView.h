//
//  WSNewAddProdsWithSeriesRightTableViewCellContentView.h
//  WinSFA
//
//  Created by HZH on 2017/12/6.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSAcvtScrollView, WSAcvtBean,WSAcvtModel,WSTableItem, WSNewAddProdsWithSeriesModel;

@protocol WSNewAddProdsWithSeriesRightTableViewCellContentViewDelegate <NSObject>

- (void)cellContentViewIsFoldedValueChanged:(BOOL)isFolded;
- (void)cellDataModelValueIsChanged;
- (void)totalSumPriceIsChanged;
- (void)cellHeightIsChanged;
@end

@interface WSNewAddProdsWithSeriesRightTableViewCellContentView : UIView

@property (nonatomic, assign) BOOL isChecked;
@property (nonatomic, assign) BOOL isFolded;
@property (nonatomic, assign) BOOL isBuildDisplayContent;  // MN-2441 是否创建了显示内容，没有显示的时候不需要创建显示内容，否则执行脚本效率太低
@property (nonatomic, strong) WSProdBean *prodBean;
@property (nonatomic, strong) WSStoreBean *currentStore;
@property (nonatomic, strong) NSMutableDictionary *prodKeyValueCacheDataDic;
@property (nonatomic, strong) WSAcvtScrollView *contentScrollView;
@property (nonatomic, strong) WSTableItem *currentTableItem;
@property (nonatomic, copy) NSString *luaScriptString;
@property (nonatomic, strong) WSNewAddProdsWithSeriesModel *rightTableModel;

@property (nonatomic, weak) id <WSNewAddProdsWithSeriesRightTableViewCellContentViewDelegate>  cellContentViewDelegate;

//
- (instancetype)initWithFrame:(CGRect)frame andAllNeedParams:(NSArray *)paramsArray;

@end
