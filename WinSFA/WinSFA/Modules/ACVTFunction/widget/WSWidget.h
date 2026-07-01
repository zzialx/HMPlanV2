//
//  WSWidget.h
//  WinSFA
//
//  Created by winchannel on 15/3/6.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "I_Lua_Target_Operator.h"
#import "I_W_ValueChangeObject.h"
@class WSInterAction;
@class WSStoreBean;
@class WSFuncsBean;
@class WSWidget;
@protocol I_W_BuildInfo;
@protocol I_W_DataSource;
@protocol I_W_Validate;
@protocol I_W_DisplayValue;
@protocol I_Lua_Target_Operator;
@protocol I_W_ValueChangeObject;
@protocol I_W_ValueChangeChecker;
@protocol I_W_Group_Validate;

@protocol WSWidgetDelegate <NSObject>

@optional
- (void)reloadWidgetWith:(NSString *)relatedId andCurrentWiget:(WSWidget *)widget;
- (void)reloadWidgetWithName:(NSString *)relatedWidgetName andValue:(NSObject *)value;
- (void)executeInterAction:(WSInterAction *)interaction;
- (void)executeAnyOperationWith:(WSInterAction *)interaction;
- (void)selectWithShortCutFunsbean:(WSFuncsBean *)bean withStoreBean:(WSStoreBean *)storeBean;
- (void)forOperation:(BOOL)openornot;
- (void)sendResultInterAction:(WSInterAction *)interaction;
- (void)executeDoNothing:(WSInterAction *)interaction;
- (void)executeLuaScript:(NSObject<I_W_BuildInfo> *)buildInfo widget:(WSWidget *)widget;
- (void)executeLuaScript:(NSObject<I_W_BuildInfo> *)buildInfo script:(NSString *)script widget:(WSWidget *)widget;
- (void)executeLuaScript:(NSObject<I_W_BuildInfo> *)buildInfo script:(NSString *)script funcName:(NSString *)funcName widget:(WSWidget *)widget;
- (void)executeGridParamLuaScript:(NSString *)luaScriptStr  widget:(WSWidget *)widget;
- (void)executeEditOnEnd:(NSObject<I_W_BuildInfo> *)buildInfo widget:(WSWidget *)widget;
- (void)widget:(WSWidget *)widget valueChanged:(BOOL)isValueChangedCompareWithOrigin;
- (BOOL)currentLuaExecuteIsFromAcvt;
//不同意获取用户位置信息
- (void)cancleAgreePrivacyPolicyMesage;

@end

@interface WSWidget : UIView<I_Lua_Target_Operator,I_W_ValueChangeObject>{
 
    NSString  *widigtkey;
    NSObject<I_W_BuildInfo> *xbuildInfo;
    NSObject<I_W_DataSource> *xdataSource;
    NSObject<I_W_DisplayValue> *xdisplayValue;
    NSObject<I_W_Validate> *xvalidateobject;
    NSObject<I_W_Group_Validate> *xgroupValidateObject;
    NSObject *_displayPo;
    NSObject *_maintainedData;
    NSMutableDictionary *resultDict;
    NSString *relatedWidgetId;
    NSObject *resultobject;
    NSObject *_resultCheck;
    __weak id<WSWidgetDelegate> delegate;
    WSInterAction *currentInterAction;
    NSMutableDictionary *interActionDict;
    BOOL isNeedValidate;
    CGRect parentViewOldRect;
    NSObject *_originalValue;
    BOOL isEdited;
}

@property (nonatomic, weak) id<WSWidgetDelegate>  delegate;
@property (nonatomic, assign) CGRect parentViewOldRect;
@property (nonatomic, assign) BOOL isNeedValidate;
@property (nonatomic, assign) BOOL isEdited;
@property (nonatomic, retain) NSObject<I_W_BuildInfo>  *xbuildInfo;
@property (nonatomic, retain) NSObject<I_W_DataSource> *xdataSource;
@property (nonatomic, retain) NSObject<I_W_DisplayValue>  *xdisplayValue;
@property (nonatomic, retain) NSObject<I_W_Validate>  *xvalidateobject;
@property (nonatomic, retain) NSObject<I_W_Group_Validate> *xgroupValidateObject;
@property (nonatomic, retain) NSObject<I_W_ValueChangeChecker>  *xvalueChangeChecker;
@property (nonatomic, retain) WSInterAction  *currentInterAction;
@property (nonatomic, strong) NSMutableDictionary  *interActionDict;
@property (nonatomic, strong) NSObject *resultCheck;
@property (nonatomic, assign) BOOL fixedHeight;
@property (nonatomic, copy) NSString *widgetType;
@property (nonatomic, assign) CGFloat realPercent;
@property (nonatomic, assign) BOOL isValueChangedToRunScript;
@property (nonatomic, strong) WSStoreBean *store;
@property (nonatomic, strong) WSFuncsBean *funcsBean;
@property (nonatomic, strong) NSString *tempEmpId;

- (void)buildDisplayContent;
- (void)resetFrame:(CGRect)frame;
- (void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo;
- (void)loadDataSource:(NSObject<I_W_DataSource> *)datasource;
- (void)loadMaintainedData:(NSObject *)maintainedData;
- (void)loadValidator:(NSObject<I_W_Validate> *)validateobjin;
- (void)loadGroupValidator:(NSObject<I_W_Group_Validate> *)groupValidateobjin;
- (void)loadDisplayValue:(NSObject<I_W_DisplayValue> *)displayValueobjin;
- (BOOL)doValidateForWSWidght;
- (NSObject *)doGroupValidateForWSWidght;
- (BOOL)doValidateForWSWidghtWithCopiedBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfoin;
- (NSObject *)getResultData;
- (NSObject *)getResultDirectly;
- (NSObject *)getResultExecuteCheck;
- (NSObject *)getResultPresentation;
- (NSObject *)getSearchCondition;
- (NSObject *)getSearchStoreTypeWithCondition:(NSString *)condition;
- (void)reloadDisplayData;
- (void)reloadDisplayDataWithCertainConditon:(WSWidget *)widget;
- (void)loadComputeResult:(WSInterAction *)interAction;
- (void)makeCurrentWidgetActivity:(WSInterAction *)interaction;
- (void)makeCurrentWidgetInactivity:(WSInterAction *)interaction;
- (void)widgetDidLoadFinish;
- (void)widgetDidExecutedAllInitScript;
- (void)widgetWillAppear;
- (void)reloadCurrentWidgetWithValue:(NSObject *)value;
- (void)reloadCurrentWidgetWithValue:(NSObject *)value andRequestNodeName:(NSString *)nodeName;
- (void)updateContent:(NSObject *)content;
- (void)resetViewContent;
- (void) becomeFirstResponseder;
- (void) resignFirstResponseder;
- (void)checkValueChange;
- (void)setBottomLineLeftPadding:(CGFloat)padding;
- (void)setBottomLineColor:(UIColor *)color;
- (void)setBottomLineHidden:(BOOL)hidden;
- (NSObject *)getDisplayValuePresentation;
- (void)setValidDataSourceFromScript:(NSString *)validDataSource;
- (void)setReadonly:(NSString *)isReadonly;
- (NSString *)changeReadonly:(NSString *)isReadonly;
- (NSString *)getReadonly;
- (void)setWidgetHidden:(NSString *)isHidden;
- (void)setRightViewHidden:(NSString *)isHidden;
- (void)needUploadData:(NSString *)needUploadData;
- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation;
- (NSObject *)getCurrentValuePresentation;
- (void)setRequest:(NSString *)isRequest;
- (NSString *)getAcvtQstIdByName;
- (void)getGpsAndUploadData:(NSString *)acvtQstId;
- (void)setDefaultValue:(NSString *)defaultValue;
- (NSString *)getDefaultValue;
- (NSString *)getCurrentValueForID;
- (void)setFilter:(NSString *)filter;
- (NSString *)getFilter;
- (NSString *)getServerRedisValue;
- (void)performClickButton:(id)sender;
- (void)setPhotoWaterMark:(NSString *)photoWaterMark;
- (void)updateWidgetOpts:(NSString *)conditions;
- (void)setStoreId:(NSString *)storeId;
- (void)setEmpId:(NSString *)empId;
- (NSString *)callGridMethodWithParams:(NSString *)params;
- (void)setLocationType:(NSString *)locationType;
- (void)setIsSupperLocalPhoto:(NSString *)isSupperLocalPhoto;
- (void)setMinimum:(NSString *)minimum;
- (void)setMaximum:(NSString *)maximum;
- (void)setMaxMinValue:(NSString *)params;
- (void)setMinDate:(NSString *)dateString;
- (NSString *)getPrintData;
- (void)showStoreFence:(NSString *)distanceRange;
- (NSString *)getBitmapPath;
- (NSObject *)getPrepareSaveData;
- (id)requestServerByQst:(NSString *)param;
- (void)refreshQstByServer:(NSArray *)resultArray;
- (void)setViewTitleAndAnswerColor:(NSString *)colorStr;
- (BOOL)isScanResultLuaHandleWithScanResult:(NSString *)scanResult;
- (void)longPressDeleteCallback;
- (void)readyToUpload;
- (NSString *)getDataCount;
- (NSString *)getServerGenId;
- (void)setTakePhotoType:(NSString *)photoType;
- (void)setLenzActivityType:(NSString *)lenzActivityType;
- (void)setParam:(NSString *)param;
- (NSMutableDictionary *)getNotReqTipData;
- (void)setCheckType:(NSString *)checkType;
- (void)setLenzTiltModel:(NSString *)tiltType;
- (void)showConfirmDialog:(NSString *)dialog;
- (void)setHeaderValue:(NSString*)value;
- (NSString*)getMemo;
- (void)setEndEditCheckLuaState:(NSString*)value;
- (void)showAlertDialog:(NSString *)dialog;
@end
