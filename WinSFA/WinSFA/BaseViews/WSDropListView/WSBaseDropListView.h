//
//  WSBaseDropListView.h
//  WinSFA
//
//  Created by Alicia on 2018/3/20.
//  Copyright © 2018年 WinChannel. All rights reserved.
//


#import <UIKit/UIKit.h>


typedef enum {
    WSDropListViewSelectModeSingleSelection = 0,
    WSDropListViewSelectModeMultipleChoice
} WSDropListViewSelectMode;

typedef enum {
    WSDropListViewTypeDefaultShow = 0,
    WSDropListViewTypeSearchBarShow = 1,
    WSDropListViewTypePopShow,  //新版下拉框在列表数组大于6个时，改为弹出列表页面。
    WSDropListViewTypeServerSearchBarShow // 下拉框数据需要实时请求
} WSDropListViewType;


@class WSBaseDropListView;


@protocol WSDropListViewDelegate <NSObject>

@optional
- (void)dropListViewDidChangeSelect:(WSBaseDropListView *)dropListView;
- (void)dropListViewDidAppear:(WSBaseDropListView *)dropListView;
- (void)popupDropListViewDidAppear:(WSBaseDropListView *)dropListView;
@end

@interface WSBaseDropListView : UIView



@property (nonatomic, strong) NSString *filterStr;//过滤条件
@property (nonatomic, strong) NSArray *dataSourceArray;
@property (nonatomic, strong) NSArray *dataItemIDArray;
@property (nonatomic ,assign) BOOL sourceTableReadOnly;

@property (nonatomic, copy) NSString *title;
@property (nonatomic ,assign) BOOL isValueChange;
@property (nonatomic, assign)BOOL isShow;


@property (nonatomic, weak) id<WSDropListViewDelegate> dropListDelegate;

@property (nonatomic, assign) WSDropListViewSelectMode selectMode;
@property (nonatomic, assign) WSDropListViewType  selectType;

@property (nonatomic, strong) NSObject<I_W_OptionDataItem> *selectedItem;  //for single select
@property (nonatomic, strong) NSMutableArray *selectedItemArray;
@property (nonatomic, strong) NSMutableArray *tempSelectedItemArray;   //for not sure multiple choice
@property (nonatomic, strong) NSString *limitNum;
@property (nonatomic, strong) NSString *searchObjId;    // only works in WSDropListViewTypeServerSearchBarShow
@property (nonatomic, strong) NSString *searchStoreId;  // only works in WSDropListViewTypeServerSearchBarShow
@property (nonatomic, assign) NSInteger maxNum; // 多选中可以选择的最大数量

@property (nonatomic ,assign) BOOL isScrollToBottomToEnableButton; // SFA-8316 只有滚动到底时确认按钮才可用
@property (nonatomic, assign) BOOL isParentSelected;  // MN-1776 有级联关系的控件父级是否已选


- (id)initWithFrame:(CGRect)frame selectMode:(WSDropListViewSelectMode)selectMode;

- (void)setUpSelectionByItemIDArray:(NSArray *)dataItemIDArray;

//获取所选内容id,多个选项时用","分隔
-(NSString *)getResultDirectly;

//获取所选内容name,多个选项时用","分隔
- (NSString *)getResultPresentation;

- (void)flushTable;

#pragma mark - # 选中item获取Memo
- (NSString*)getSelectItemMemo;


@end
