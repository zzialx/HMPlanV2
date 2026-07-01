//
//  WSDropListView.h
//
//  Created by yang on 15/3/26.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "I_W_OptionDataItem.h"
#import "WSDropListViewMultilevelMenu.h"
#import "WSBaseDropListView.h"


@protocol WSValidateData,WSGettingValues;


@interface WSDropListView : WSBaseDropListView <UITableViewDelegate, UITableViewDataSource, WSValidateData, WSGettingValues>

@property (nonatomic, assign) BOOL isUseMultilevelMenu;//是否使用多级菜单view SFA DV类型控件 玛氏

@property (nonatomic, strong) NSMutableArray *multileveMenuArray;// 多级菜单的默认需要展示层级的所有数据
@property (nonatomic, strong) NSMutableArray *backShowLevelDataArray;// 多级菜单需要回显时候默认选中的各个层级数据

@property (nonatomic ,assign) BOOL isInGrid;
@property (nonatomic ,assign) BOOL isInGroup;


@property (nonatomic, copy) NSString *m_col;
@property (nonatomic, copy) NSString *iColumnName;
@property (nonatomic, copy) NSString *prodName;

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


// 更新按钮标题
- (void)updateButtonTitle;


- (void)setFont:(UIFont *)font;



#pragma mark - WSValidateData 依赖关系
//row and column
@property (nonatomic, assign) unsigned int m_nRow;

@property (nonatomic, assign) unsigned int m_nColumn;

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

#pragma mark - WSGettingValues

- (NSString *)getTextValue;

- (BOOL)isValueLegal;

- (BOOL)textCheck;

- (void)setSourceTableReadOnly:(BOOL)sourceTableReadOnly;

- (void)refreshListWithDataSourceArray:(NSArray *)dataSourceArray;

@end
