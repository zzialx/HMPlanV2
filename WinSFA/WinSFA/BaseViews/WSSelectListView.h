//
//  SelectListControl.h
//  SelectList
//
//  Created by Jiepeng Zheng on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    WSSelectListViewSelectModeSingleSelection = 0,
    WSSelectListViewSelectModeMultipleChoice
}WSSelectListViewSelectMode;

typedef enum {
    WSSelectLIstViewTypeDefaultShow= 0,
    WSSelectLIstViewTypePopShow  //新版下拉框在列表数组大于6个时，改为弹出列表页面。
}WSSelectListViewType;

@class WSSelectListView;

@protocol ZJPSelectListDelegate <NSObject>

@optional
- (void)selectListChange:(WSSelectListView *)aSelectListView;
- (void)selectListViewDidAppear:(WSSelectListView *)aSelectListView;
- (void)popupSelectListViewDidAppear:(WSSelectListView *)aSelectListView;
@end

@interface WSSelectListView : UITableView <UITableViewDelegate, UITableViewDataSource,WSValidateData,WSGettingValues>

//@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UIViewController *parentViewController;
@property (nonatomic, strong) NSMutableArray *content;
@property (nonatomic, strong) NSMutableArray *contentDicts;

@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic ,assign) BOOL sourceTableReadOnly;

@property (nonatomic, copy) NSString *title;
@property (nonatomic ,assign) BOOL isValueChange;
@property (nonatomic, assign)BOOL isShow;

@property (nonatomic, copy) NSString *iColumnName;
@property (nonatomic, copy) NSString *prodName;

@property (nonatomic, weak) id<ZJPSelectListDelegate> selectListDelegate;

@property (nonatomic, assign) WSSelectListViewSelectMode selectMode;
@property (nonatomic, assign) WSSelectListViewType  selectType;

@property (nonatomic, strong) NSMutableArray *selectedIndexArray;

- (id)initWithFrame:(CGRect)frame selectMode:(WSSelectListViewSelectMode)selectMode;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style selectMode:(WSSelectListViewSelectMode)selectMode;

- (NSString *)getSelectedContentString;


- (NSString *)currentSelectedContent;

/**
 *  列表初始化时显示的字符串（没有回显数据）
 *
 *  @return 
 */
- (NSString *)getDefaultString;

/**
 *  关闭下拉框
 */
- (void) closeSelectList;

- (void) flushTable;

#pragma mark - 依赖关系
//row and column
@property (nonatomic, assign) unsigned int m_nRow;  // 依赖的行号
@property (nonatomic, assign) unsigned int m_nColumn; // 依赖的列号

@property (nonatomic, assign)BOOL iIsObserver;

//是否被依赖
@property (nonatomic, assign) BOOL m_isDepended;

//前缀
@property (nonatomic, copy)NSString *iNotificationPrefix;

//行号
@property (nonatomic, assign)unsigned int iRow;

//列号
@property (nonatomic, assign)unsigned int iColumn;

//依赖类型
@property (nonatomic, assign)WSValidateDataDependType iDataType;

//存放多条消息
@property (nonatomic, strong)NSMutableDictionary *iDicNotificationName;

//逻辑类型
@property (nonatomic, assign)WSValidateDataLogicType iLogicType;

//WSValidateData function
- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType;


- (void)startObservingEntity;

- (BOOL)entityIsEnable;

//Getting value

- (NSString *)getTextValue;

- (BOOL)isValueLegal;

- (BOOL)textCheck;

@end
