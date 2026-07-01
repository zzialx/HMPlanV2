//
//  WSPersonnelListTreeView.h
//  WinSFA
//
//  Created by winchannel on 15/7/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSPersonnelListTreeCell.h"
#import "WSFuncsBean.h"

@class WSPersonnelListTreeView;

@protocol I_W_Cell;

@protocol WSPersonnelListTreeViewDelegate <NSObject>

@optional

- (void)personnelListTreeView:(WSPersonnelListTreeView *)personnelListTreeView withSubempStoreBean:(NSObject<I_W_Cell> *)dataItem;
- (void)resetFramePersonnelListTreeView:(WSPersonnelListTreeView *)personnelListTreeView;
- (void)setSelectedArray:(NSArray *)selectedArray;

@end

@interface WSPersonnelListTreeView : UIView<UITableViewDataSource,UITableViewDelegate,WSPersonnelListTreeCellDelegate>


@property (nonatomic ,assign) BOOL sourceTreelistReadOnly;
@property (nonatomic ,weak) id<WSPersonnelListTreeViewDelegate> delegate;
@property (nonatomic, strong) NSArray *dataArray;

- (id)initWithFrame:(CGRect)frame;

- (id)initWithFrame:(CGRect)frame withFuncsBean:(WSFuncsBean *)currentFuncsBean;

- (instancetype)initWithFrame:(CGRect)frame listStyle:(WSPersonnelListStyle)listStyle ;

- (void)setTreeListReadOnly:(BOOL)sourceTreelistReadOnly;
- (void)reloadDataForDisplayArray;

- (void)selectAll:(BOOL)isSelect;
- (void)setSelectArray:(NSArray *)selectArray;

- (void)resetSearchBar:(BOOL)isClearText;

- (WSPersonnelListStyle)getListStyle;

@end
