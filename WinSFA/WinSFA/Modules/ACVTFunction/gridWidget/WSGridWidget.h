//
//  WSGridWidget.h
//  WinSFA
//
//  Created by Alicia on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSAcvtDataGridComponentDataSource.h"
#import "WSScanListViewController.h"


#define kKeyRepeatProdIdSeparator       @"#pid#"
#define kKeyProdIdColSeparator          @"_"

@class WSBaseDropListView;
@class PhotoTypeButton;
@class WSCheckBox;
@class WSGridWidget;
@class WSFuncsBean;
@class WSStoreBean;
@protocol WSGridWidgetDelegate

@optional

- (NSString *)dataSourceGetGridMd5;

- (NSString *)dataSourceGetGridMc;

// 获取同种类型的所有控件
- (WSGridWidget *)dataSourceGetGroupViewByType:(NSString *)type;

- (void)dataSourceRunScriptWithWidgetKey:(NSString *)widegetKey;

- (void)dataSourceRunScriptWithParam:(WSFuncsBean_Param *)param WidgetKey:(NSString *)widgetKey luaFunctionName:(NSString *)functionName result:(NSString *)result scanListViewController:(WSScanListViewController *)scanListViewController;

- (void)dataSourceSetIsValueChanged:(BOOL)isValueChanged;

- (UIViewController *)dataSourceGetController;

- (void)dataSourceInterActionPhotoGalleryWithGridWidget:(WSGridWidget *)widget dic:(NSMutableDictionary *)dic;

- (void)dataSourceDidChange:(NSObject *)object;

// TODO
- (void)dataSourcePopDropListView:(WSBaseDropListView *)dropListView;

- (NSMutableArray *)dataSourceGetDropListRedisByParam:(WSFuncsBean_Param *)param parentId:(NSString *)parentId;

- (WSGridDataSourceReplaceStatus)dataSourceReplaceStatus:(WSHTextField *)textField replacementString:string columnTip:columnTip;

- (void)dataSourceTextFieldDidChanged:(WSHTextField *)textField;

@end

@interface WSGridWidget : NSObject

@property (nonatomic, strong) WSFuncsBean_Param *param;
// 行号
@property (nonatomic, assign) NSUInteger iRow;
// 列号
@property (nonatomic, assign) NSUInteger iColumn;
// 行 ID
@property (nonatomic, copy) NSString *rowId;    // 产品／字典项 ID
// 列名 - 如 item1
@property (nonatomic, copy) NSString  *m_col;
// 列显示名
@property (nonatomic, copy) NSString  *iColumnName;

@property (nonatomic, assign) BOOL isSupportDepend; // 是否依赖设置 见 gridWidget.plist 的 is_support_depend

// 组名，同类型控件在一个组里
@property (nonatomic, copy) NSString *groupName;

@property (nonatomic, copy) NSString *prodName;

@property (nonatomic, copy) NSString *widgetKey; // key 为 prodId_col

@property (nonatomic, strong) WSFuncsBean *funcsBean;

@property (nonatomic, strong) WSStoreBean *store;

@property (nonatomic, weak) id <WSGridWidgetDelegate> delegate;

- (instancetype)initWithParam:(WSFuncsBean_Param *)param
                     rowIndex:(NSUInteger)rowIndex
                  columnIndex:(NSUInteger)colIndex;

+ (NSString *)getGridWidgetKeyByRowId:(NSString *)rowId col:(NSString *)col;
+ (NSString *)getGridWidgetKeyByRowId:(NSString *)rowId col:(NSString *)col dictionary:(NSMutableDictionary *)dictionary;

- (void)add:(WSGridWidget *)gridWidget;
- (void)removeGridWidgetByKey:(NSString *)key;
- (WSGridWidget *)getGridWidgetByKey:(NSString *)key;
- (NSArray *)getGridWidgetAllKeys;
- (NSString *)getGridWidgetParentKeyByWidget:(WSGridWidget *)gridWidget;

- (void)setupView;
- (UIView *)getView;
- (NSString *)getValue;
- (NSString *)getValuePresentation;
- (NSString *)getUploadValue;
- (NSString *)getDBValue;
- (void)setValue:(NSString *)value;
- (void)setMaxValue:(NSString *)maxValue;
- (void)setMinValue:(NSString *)minValue;
- (void)setRequest:(BOOL)isRequest;
- (void)setReadonly:(BOOL)isReadonly;
- (void)setTextColorHexString:(NSString *)colorHexString;
- (CGFloat)getSum;


@end
