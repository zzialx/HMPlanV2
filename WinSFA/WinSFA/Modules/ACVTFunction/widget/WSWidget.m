//
//  WSWidget.m
//  WinSFA
//
//  Created by winchannel on 15/3/6.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSWidget.h"
#import "I_W_BuildInfo.h"
#import "I_W_DataSource.h"
#import "I_W_Validate.h"
#import "I_Lua_Target_Operator.h"
#import "WSInterAction.h"
#import "I_W_ValueChangeObject.h"
#import "I_W_ValueChangeChecker.h"
#import "I_W_Group_Validate.h"
#import "WSBaseModel.h"
#import "WSDataSourceManager.h"
#import "I_W_DisplayValue.h"
#import "UIColor+Additions.h"
#import "WSBaseDictsDBService.h"
#import "WSAcvtQstWidgetRelationTools.h"

@implementation WSWidget {
    
    WSAcvtQstWidgetRelationTools *_wsAcvtQstWidgetRelationTools;
}
@synthesize delegate;
@synthesize xvalidateobject;
@synthesize xbuildInfo;
@synthesize xdataSource;
@synthesize xdisplayValue;
@synthesize currentInterAction;
@synthesize isNeedValidate;
@synthesize parentViewOldRect;
@synthesize interActionDict;
@synthesize xgroupValidateObject;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        isNeedValidate = YES;
        interActionDict =[[NSMutableDictionary alloc] init];
        return self;
    }
    return nil;
}

- (void)buildDisplayContent {
    
    self.backgroundColor = [UIColor whiteColor];
}

- (void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo {
    
    xbuildInfo = buildInfo;
}

- (void)loadDataSource:(NSObject<I_W_DataSource> *)datasource {
    
    xdataSource = datasource;
}

- (void)loadMaintainedData:(NSObject *)maintainedData {
    
    _maintainedData = maintainedData;
}

- (void)loadValidator:(NSObject<I_W_Validate> *)validateobjin {
    
    xvalidateobject = validateobjin;
}

- (void)loadGroupValidator:(NSObject<I_W_Group_Validate> *)groupValidateobjin {
    
    xgroupValidateObject = groupValidateobjin;
}

- (void)loadDisplayValue:(NSObject<I_W_DisplayValue> *)displayValueobjin {
    
    xdisplayValue = displayValueobjin;
}

- (BOOL)doValidateForWSWidght {
    
    if (xvalidateobject == nil) {
        return YES;
    }
    
    if (!isNeedValidate) {
        return YES;
    }
    
    if((![[xbuildInfo getISRequire] isEqualToString:@"1"]) && [[xbuildInfo getIsHidden] isEqualToString:@"1"]) {
        return YES;
    }
    
    if ([xvalidateobject respondsToSelector:@selector(executeValidate:withWidget:)]) {
        return [xvalidateobject executeValidate:xbuildInfo withWidget:self];
    }
    
    return NO;
}

- (NSObject *)doGroupValidateForWSWidght {
    
    if (xgroupValidateObject == nil) {
        return nil;
    }
    
    if (!isNeedValidate) {
        return nil;
    }
    
    if ([xgroupValidateObject respondsToSelector:@selector(executeGroupValidate:withAcvtView:)]) {
        WSAcvtView *acvtView = (WSAcvtView *)self.superview;
       return [xgroupValidateObject executeGroupValidate:xbuildInfo withAcvtView:acvtView];
    }
    
    return nil;
}

- (BOOL)doValidateForWSWidghtWithCopiedBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfoin {
    
    if ([xvalidateobject respondsToSelector:@selector(executeValidate:withWidget:)]) {
        return [xvalidateobject executeValidate:buildInfoin withWidget:self];
    }
    return NO;
}

- (NSObject *)getResultDirectly {
    
    return resultobject;
}

- (NSObject *)getResultData {
    
    return resultDict;
}

- (NSObject *)getResultPresentation {
    
    return nil;
}

- (NSObject *)getResultExecuteCheck{
    
    return _resultCheck;
}


- (NSObject *)getSearchCondition {
    
    return [self getResultDirectly];
}

- (NSObject *)getSearchStoreTypeWithCondition:(NSString *)condition {
    
    if ([condition length] > 0 && ![[self.xbuildInfo getIsHidden] isEqualToString:@"1"]) {
        
        NSRange range = [condition rangeOfString:QST_SEARCH_DISTANCE];
        if (range.location == NSNotFound) {
            
            if ([condition rangeOfString:QST_SEARCH_RANGE_SEPARATOR].location == NSNotFound) {
                
                WSAcvtBean_qst *qst = (WSAcvtBean_qst *)self.xbuildInfo;
                if ([qst.filter isEqualToString:@"storeType"]) {
                    
                    WSBaseDictsDBService *dictService = [[WSBaseDictsDBService alloc] init];
                    WSDictBean *db = [dictService queryDictWithID:condition];
                    return db.btyp.length > 0 ? db.btyp : @"";
                }
            }
        }
    }
    
    return @"";
}

- (void)resetFrame:(CGRect)frame {
    
}

-(void)widgetDidLoadFinish {
    
}

- (void)widgetDidExecutedAllInitScript {
    
}

- (void)widgetWillAppear {
    
}

- (void)reloadDisplayDataWithCertainConditon:(WSWidget *)widget {
    
}

- (void)loadComputeResult:(WSInterAction *)interAction {

}

- (void)makeCurrentWidgetActivity:(WSInterAction *)interaction {
    
    currentInterAction = interaction;
}

- (void)makeCurrentWidgetInactivity:(WSInterAction *)interaction {
        
    currentInterAction = interaction;
}

- (void)checkValueChange {
    
    if ([[xbuildInfo getIsHidden] isEqualToString:@"1"]) {
        return;
    }
    
    BOOL isValueChanged = [self.xvalueChangeChecker checkValueIsChange:self];
    if ([self.delegate respondsToSelector:@selector(widget:valueChanged:)]) {
        [self.delegate widget:self valueChanged:isValueChanged];
    }
    _originalValue = [self getResultDirectly];
}

- (void)readyToUpload {
    
}

- (void)executeValidate {
    
    [self doValidateForWSWidght];
}

- (void)reSetNeedValidate:(BOOL)needvalidate {
    
    if (needvalidate == YES) {
        [self setRequest:@"1"];
    }
    else {
        [self setRequest:@"0"];
    }
}

- (NSObject *)getOtherLuaExecuteParams {
    
    return nil;
}

- (void)reloadDisplayData {
    
}

- (void)reloadCurrentWidgetWithValue:(NSObject *)value {
    
}

- (void)reloadCurrentWidgetWithValue:(NSObject *)value andRequestNodeName:(NSString *)nodeName {
    
}

- (void)updateContent:(NSObject *)content {
    
}

- (void)setValueForCurrentObject:(NSObject *)objvalue {
    
    [self reloadCurrentWidgetWithValue:objvalue];
}

- (NSObject *)getValueForCurrentObject {
    
    return [self getResultDirectly];
}

- (NSObject *)getValuePresentationForCurrentObject {
    
    return [self getResultPresentation];
}

- (NSString *)getDescriptionForCurrentObject {
    return [xbuildInfo getQstDescription];
}

- (void)resetViewContent {
    
}

- (void)becomeFirstResponseder {
    
}

- (void) resignFirstResponseder{

}

- (NSObject *)getOriginalValue {
    
    return _originalValue;
}

- (NSObject *)getCurrentValue {
    
    return [self getResultDirectly];
}

- (BOOL)isEdited {
    
    return isEdited;
}

- (NSObject *)getDisplayValuePresentation {
    
    return [self getResultPresentation];
}

- (void)setValidDataSourceFromScript:(NSString *)validDataSource {
    
}

- (void)setReadonly:(NSString *)isReadonly {
    
    NSString *str = [self changeReadonly:isReadonly];
    if ([str isEqualToString:@"0"]) {
        
        WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
        if (model.currentStore.inReadonlyMode) {
            str = @"1";
        }
    }
    
    [xbuildInfo setIsReadOnly:str];
}

- (NSString *)changeReadonly:(NSString *)isReadonly {
    
    if ([isReadonly isEqualToString:@"true"]) {
        isReadonly = @"1";
    }
    else if ([isReadonly isEqualToString:@"false"]) {
        isReadonly = @"0";
    }
    return isReadonly;
}

- (NSString *)getReadonly {
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        return @"true";
    }
    else {
        return @"false";
    }
}

- (void)setWidgetHidden:(NSString *)isHidden {
    
    NSString *hiddenString = @"0";
    BOOL hidden = NO;
    if ([isHidden isEqualToString:@"1"] || [isHidden isEqualToString:@"true"]) {
        hiddenString = @"1";
        hidden = YES;
    }
    
    [xbuildInfo setIsHidden:hiddenString];
    
    self.hidden = hidden;
    if (self.hidden) {
        self.frame = CGRectZero;
    }
    else {
        self.frame = [xbuildInfo getLayOutInfo];
    }
    [self.superview layoutSubviews];
}

- (void)setRightViewHidden:(NSString *)isHidden {
    
}

- (void)needUploadData:(NSString *)needUploadData {
    
    NSString *needUpLoadDataString = @"1";
    if([needUploadData isEqualToString:@"0"] || [needUploadData isEqualToString:@"false"]){
        needUpLoadDataString = @"0";
    }
    [xbuildInfo needUploadData:needUpLoadDataString];
}

- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation {

}

- (NSObject *)getCurrentValuePresentation {
    
    return [self getResultPresentation];
}

- (void)setRequest:(NSString *)isRequest {
    
    NSString *isRequireString = nil;
    if ([isRequest isEqualToString:@"1"] || [[isRequest lowercaseString] isEqualToString:@"true"] || [[isRequest lowercaseString] isEqualToString:@"y"]) {
        isRequireString = @"1";
    }
    
    [xbuildInfo setIsRequire:isRequireString];
}

- (NSString *)getAcvtQstIdByName {
    
    return [xbuildInfo getAcvtQstId];
}

- (void)getGpsAndUploadData:(NSString *)acvtQstId {
    
}

- (void)setDefaultValue:(NSString *)defaultValue {
    
    [xbuildInfo setDefaultValue:defaultValue];
}

- (NSString *)getDefaultValue {
    
    return [xbuildInfo getDefaultValue];
}

- (NSObject *)getCurrentValueForID {
    
    return [self getResultDirectly];
}

- (void)setFilter:(NSString *)filter {
    
    [xbuildInfo setFilterCondition:filter];
}

- (NSString *)getFilter {
    
    return [xbuildInfo getFilterCondition];
}

- (NSString *)getServerRedisValue {
    
    if ([xdisplayValue respondsToSelector:@selector(getServerRedisValue:)]) {
        
        NSObject *value = [xdisplayValue getServerRedisValue:xbuildInfo];
        if ([value isKindOfClass:[NSString class]]) {
            return (NSString *)value;
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            return [(NSArray *)value componentsJoinedByString:@","];
        }
        else {
            return [value description];
        }
    }
    
    return nil;
}

- (void)setPhotoWaterMark:(NSString *)photoWaterMark{
    
}

- (void)performClickButton:(id)sender {
    
}

- (void)updateWidgetOpts:(NSString *)conditions{
    
}

- (void)setBottomLineColor:(UIColor *)color {
    
}

- (void)setBottomLineLeftPadding:(CGFloat)padding {
    
}

- (void)setBottomLineHidden:(BOOL)hidden {
    
}

- (void)setStoreId:(NSString *)storeId{
    
}

- (void)setEmpId:(NSString *)empId{
    
}

- (NSString *)callGridMethodWithParams:(NSString *)params {
    return nil;
}

- (void)setLocationType:(NSString *)locationType {
    
}

- (void)setIsSupperLocalPhoto:(NSString *)isSupperLocalPhoto {
    
}

- (void)setMinimum:(NSString *)minimum {
    [xbuildInfo setSnumx:minimum];
}

- (void)setMaximum:(NSString *)maximum {
    [xbuildInfo setMumx:maximum];
}

- (void)setMaxMinValue:(NSString *)params {

}

- (void)setMinDate:(NSString *)dateString {
    
}

- (NSString *)getPrintData {
    
    NSString *qstName = [xbuildInfo getQuestName];
    NSString *value = (NSString *)[self getResultPresentation];
    return [NSString stringWithFormat:@"%@:%@",qstName,value];
}

- (void)showStoreFence:(NSString *)distanceRange
{
    
}

- (NSString *)getBitmapPath {
    
    return nil;
}

- (id)requestServerByQst:(NSString *)param {
    
    if ([xbuildInfo isKindOfClass:[WSAcvtBean_qst class]]) {
        
        WSAcvtBean_qst *qst = (WSAcvtBean_qst *)xbuildInfo;
        if (qst.ds.length > 0) {
            
            NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:[WSAppData getObjectbyKey:APPDATA_EMPID], @"empId", qst.ds, @"objId", param, @"extras", nil];
            _wsAcvtQstWidgetRelationTools = [[WSAcvtQstWidgetRelationTools alloc] init];
            [_wsAcvtQstWidgetRelationTools getRealtimeDataWithParamDic:paramDic andRealtimeRequestFinishCallback:^(id resultDic) {
                
                NSArray *resultArray = [NSArray arrayWithArray:[resultDic objectForKey:qst.ds]];
                if ([resultDic objectForKey:@"flag"]) {
                    [self refreshQstByServer:resultArray];
                }
            }];
        }
    }
    return nil;
}

- (void)setViewTitleAndAnswerColor:(NSString *)colorStr {
    
}

- (NSObject *)getPrepareSaveData {
    
    return nil;
}

- (NSString *)getDataCount {
    
    return nil;
}

- (void)setTakePhotoType:(NSString *)photoType {
   
}

- (void)setLenzActivityType:(NSString *)lenzActivityType {
    
}

- (void)setParam:(NSString *)param {
    
}

- (BOOL)isScanResultLuaHandleWithScanResult:(NSString *)scanResult {
    
    return NO;
}

- (void)longPressDeleteCallback {
    
}

- (NSString *)getServerGenId {
    
    return nil;
}

- (NSObject *)getEmpId {
    
    return self.tempEmpId;
}

- (NSMutableDictionary *)getNotReqTipData {
    
    return nil;
}

- (void)setCheckType:(NSString*)checkType{
    
}

- (void)setLenzTiltModel:(NSString*)tiltType{
    
}

- (void)showConfirmDialog:(NSString *)dialog {
    
}
- (void)setHeaderValue:(NSString*)value{
    
}
- (NSString*)getMemo{
    return nil;
}
- (void)setEndEditCheckLuaState:(NSString*)value{
    
}
- (void)showAlertDialog:(NSString *)dialog{
    
}

@end
