//
//  WSDataGridComponentDataSource.h
//  WinSFA
//
//  Created by ZhengJiepeng on 13-7-24.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSTableItem.h"
#import "WSBaseDataGridComponentDataSource.h"
#import "WSPhotoGalleryViewController.h"
#import "WSAcvtViewController.h"
@class WSGridWidget;
@class WSAcvtDataGridComponentDataSource;

#define kGridGroupText @"T"

typedef NS_ENUM(NSInteger, WSGridDataSourceReplaceStatus) {
    
    WSGridDataSourceReplaceStatusNo,
    WSGridDataSourceReplaceStatusYES,
    WSGridDataSourceReplaceStatusNone
};

@protocol WSAcvtDataGridComponentDataSourceDelegate <NSObject>

- (void)acvtDataGridComponentDataSource:(WSAcvtDataGridComponentDataSource *)dataSource addedMoreProductWithCount:(NSInteger)count;
- (void)acvtDataGridComponentDataSource:(WSAcvtDataGridComponentDataSource *)dataSource addedSelectedProductWithCount:(NSInteger)count changeSerieLinkHeadTitle:(NSString *)title;
- (void)findAcvtQstViewByName:(NSString *)qstName value:(NSString *)value;
- (void)acvtDataGridComponentDataSource:(WSAcvtDataGridComponentDataSource *)dataSource didChange:(NSObject*)object;
- (void)executeInterAction:(WSInterAction *)interaction;
- (void)executeLuaScript:(NSString *)luaScript funcName:(NSString *)funcName;
- (void)executeGridParamLuaScript:(NSString *)luaScript;

@end

@interface WSAcvtDataGridComponentDataSource : WSBaseDataGridComponentDataSource <PhotoGalleryViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableDictionary *formulaDictionary;
@property (nonatomic, strong) NSMutableDictionary *maxValueFormulaDictionary;
@property (nonatomic, strong) NSMutableArray *formulaStringArray;
@property (nonatomic, strong) NSMutableArray *maxValueFormulas;
@property (nonatomic, strong) NSMutableDictionary *prod_cacheDataMDictionary;
@property (nonatomic, strong) NSMutableArray *prod_cacheDataDictKeysArray;
@property (nonatomic, assign) BOOL isReturn;
@property (nonatomic, weak) id<WSAcvtDataGridComponentDataSourceDelegate> delegate;

- (void) refreshCurrentTableItem;
- (id)initWithQst:(WSAcvtBean_qst *)aQst store:(WSStoreBean *)aStore func:(WSFuncsBean *)aFunc ownViewController:(UIViewController *)aController isInNewAcvt:(BOOL)isInNewAcvt;
- (NSString *)generateGridMd5WithAcvtGenid:(NSString *)gendid;
- (NSString *)getGridMd5;
- (void)addHeaderUI:(NSArray *)arrayUI;
- (BOOL)needShowScanButton;
- (void)loadLuaScriptWhenInit;
- (void)loadLuaScriptForSetValue;
- (BOOL)loadValidateLuaScript;
- (void)addMoreProduct:(NSArray *)moreProductArray;
- (void)delMoreProduct:(NSArray *)removedArray;
- (void)reloadDataSourceForDeletedAfter;
- (void) resetDataSource ;
- (void)loadLuaScriptToCompute;
- (void)loadLuaScriptToAddProduct;
- (void)loadLuaScriptToDelProductWithDelProds:(NSArray *)prods;
- (void)loadLuaScriptForInit;
- (void)reloadSubViewsValueWith:(NSString *)genId dis:(NSArray *)dis;
- (void)deleteDatasAtIndexSet:(NSIndexSet *)indexSet;
- (void)deleteProdsCache:(NSArray *)prods;
- (void)setValueWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)value;
- (void)setReadOnlyWithRowId:(NSString *)rowId col:(NSString *)paramCol param:(NSString *)value;
- (void)setReadonly:(BOOL)readonly  isInitFisrt:(BOOL)isFirst;
- (void)saveTableDataToDB;
- (void)deleteTableDataFromDB:(NSArray *)prodIds;
- (void)initTableDataAndCellData:(NSString *)param;
- (void)setDefautValueForUnit;
- (void)runAllColumsLuaScriptWhenValueChanged;
- (void)setMoreProdsDefaultColValueCacheDicForCurrentAcvtGrid;
- (NSDictionary *)getAcvtViewForGridDictionaryByIndexPath:(NSIndexPath *)indexPath isReadOnly:(BOOL)isReadOnly;
- (NSString *)getValueWithRowId:(NSString *)rowId col:(NSString *)colName param:(NSString *)param;
- (WSGridWidget *)getGridWidgetByRowId:(NSString *)rowId col:(NSString *)col;
- (WSGridWidget *)getGridWidgetByKey:(NSString *)key;
- (NSArray *)getGridWidgetAllKeys;
- (NSString *)getCurrentTabOpRowId;
- (void)setTextColorWithRowId:(NSString *)rowId col:(NSString *)paramCol colorHexString:(NSString *)colorHexString;

@end
