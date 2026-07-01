//
//  JSONBuilder.m
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-8-11.
//  Copyright 2011年 Winchannel. All rights reserved.
//

#import "JSONBuilder.h"
#import "WSAppData.h"
#import "GTMBase64.h"
#import "WinSFA.h"
#import "WSCurrentTime.h"
#import "WSDictBean.h"
#import "WSAcvtBean.h"
#import "WSAcvtBean_qst.h"
#import "WSAcvtBean_qst_opt.h"
#import "WSFuncsBean_Param.h"
#import "WSStoreBean_prod.h"
#import "WSSugBean.h"
#import "WSSugBeanArray.h"
#import "WSSugReplyOptBean.h"
#import "WSInPlanStoreBean.h"
#import "WSArrangeScheduleViewController.h"
#import "WSStoreBean+Plan.h"
#import "GridCell.h"
#import "WSProdBean.h"
#import "WSSelectListView.h"
#import "UIDevice+IdentifierAddition.h"
#import "WSMultipleChoiceLabel.h"
#import "WSDictBeanArray.h"
#import "PhotoTypeButton.h"
#import "FileManager.h"
#import "WSDatePickerLabel.h"
#import "PhotoTypeButton.h"
#import "WSAcvtButtonForTB.h"
#import "WSCheckBox.h"
#import "WSRadioButton.h"
#import "WSSubmicsBean.h"
#import "WSCustomTimeTable.h"
#import "WSFuncsBeanArray.h"


#define JB_METHOD              @"method"
#define JB_ISSYNC              @"isSync"
#define JB_ISPLAN              @"isPlan"
#define JB_FV                  @"fv"
#define JB_ACCOUNT             @"account"
#define JB_INDEX               @"index"
#define JB_SYNCTIME            @"syncTime"
#define JB_SYNCDATE            @"syncDate"
#define JB_ISDATAENTRY         @"isDataEntry"       //是否为补录数据
#define JB_ENTRYTIME           @"entryTime"         //进离店时间
#define JB_STORE               @"store"
#define JB_ISUSABLE            @"isUsableness"
#define JB_SAVEFLAG            @"saveFlag"
#define JB_ID                  @"id"
#define JB_IMAGEINDEX          @"imageIndex"       //md5
#define JB_PHOTOSINDEX         @"photosIndex"
#define JB_EXTENSION           @"extension"
#define JB_PHOTO               @"photo"
#define JB_FUNCSTYPE           @"funcsTyp"
#define JB_SRID                @"srid"
#define JB_HIDVAL              @"hidVal"
#define JB_JSONDATA            @"jsonData"
#define JB_PARAM               @"param"
#define JB_DATE                @"date"
#define JB_TABLE               @"table"
#define JB_MEMO                @"memo"
#define JB_LOGINTIME           @"loginTime"
#define JB_IMEI                @"imei"
#define JB_PHONETIME           @"phoneTime"
#define JB_DATEBEGIN           @"date"
#define JB_DATEEND             @"date2"
#define JB_POSITION            @"positionobject"
#define JB_SRORGID             @"srorgid"

#define JB_PHOTOTYPE           @"photoType"

#define JB_SUBMITID            @"submitId"  //acvt md5

//add by wangdongyan 03-09 for 
#define JB_MOBILECLICKTIME     @"mobileClickTime"
  

@interface JSONBuilder ()
+ (NSDictionary *)buildBasicJsonDatabyFc:(NSString *)fc 
                                      fv:(NSString *)fv
                                 storeId:(NSString *)storeId
                                  isPlan:(BOOL)isPlan;


+ (NSDictionary *)buildBasicJsonDatabyFc:(NSString *)fc 
                                      fv:(NSString *)fv
                                 storeId:(NSString *)storeId;


@end

@implementation JSONBuilder



+ (NSString *)buildNewTaskByTaskName:(NSString *)name
                               empId:(NSString *)empId
                                 des:(NSString *)description
                             content:(NSString *)content
                        completeDate:(NSString *)completeDate
                          remindDate:(NSString *)remindDate
                          createDate:(NSString *)createDate
                           receivers:(NSArray *)receivers
                            syncDate:(NSString *)syncDate
                                 md5:(NSString *)md5

{
    NSMutableDictionary *taskInfo = [NSMutableDictionary dictionary];
    [taskInfo setObject:[NSString stringNotNilWithValue:md5] forKey:@"id"];
    [taskInfo setObject:[NSString stringNotNilWithValue:name] forKey:@"name"];
    [taskInfo setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    [taskInfo setObject:[NSString stringNotNilWithValue:description] forKey:@"des"];
    [taskInfo setObject:[NSString stringNotNilWithValue:content] forKey:@"content"];
    [taskInfo setObject:[NSString stringNotNilWithValue:completeDate] forKey:@"completeDate"];
    [taskInfo setObject:[NSString stringNotNilWithValue:remindDate] forKey:@"remindDate"];
    [taskInfo setObject:[NSString stringNotNilWithValue:createDate] forKey:@"createDate"];
    [taskInfo setObject:[NSString stringNotNilWithValue:syncDate] forKey:@"syncDate"];
    [taskInfo setObject:@"SPE_SEPTWOLVES_TASK"forKey:@"method"];
    
    [taskInfo setObject:receivers forKey:@"receiver"];
    
    // 添加 serverRequire 节点
    [taskInfo setObject:[WSAppData getObjectbyKey:SERVERREQUIRE] forKey:SERVERREQUIRE];
    
    return [taskInfo JSONRepresentation];
}

+ (NSString *)buildReplyByTaskId:(NSString *)taskId
                           empId:(NSString *)empId
                         content:(NSString *)content
                        syncDate:(NSString *)syncDate
{
    NSMutableDictionary *replyInfo = [NSMutableDictionary dictionary];
    [replyInfo setObject:[NSString stringNotNilWithValue:taskId] forKey:@"taskId"];
    [replyInfo setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    [replyInfo setObject:[NSString stringNotNilWithValue:content] forKey:@"content"];
    [replyInfo setObject:[NSString stringNotNilWithValue:syncDate] forKey:@"syncDate"];
    [replyInfo setObject:@"SPE_SEPTWOLVES_REPLY" forKey:@"method"];
    [replyInfo setObject:[WSAppData getObjectbyKey:SERVERREQUIRE] forKey:SERVERREQUIRE];
    
    return [replyInfo JSONRepresentation];
}

+ (NSString *)buildTaskCompleteStatusByTaskId:(NSString *)taskId
                                        empId:(NSString *)empId
                                     syncDate:(NSString *)syncDate
{
    NSMutableDictionary *completeInfo = [NSMutableDictionary dictionary];
    [completeInfo setObject:[NSString stringNotNilWithValue:taskId] forKey:@"taskId"];
    [completeInfo setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    [completeInfo setObject:[NSString stringNotNilWithValue:syncDate] forKey:@"syncDate"];
    [completeInfo setObject:@"SPE_SEPTWOLVES_STATUS" forKey:@"method"];
    [completeInfo setObject:[WSAppData getObjectbyKey:SERVERREQUIRE] forKey:SERVERREQUIRE];
    return [completeInfo JSONRepresentation];
    
}
+ (NSString *)buildTaskReadStatusByTaskId:(NSString *)taskId
                                    empId:(NSString *)empId
                                 syncDate:(NSString *)syncDate
{
    NSMutableDictionary *readInfo = [NSMutableDictionary dictionary];
    [readInfo setObject:[NSString stringNotNilWithValue:taskId] forKey:@"taskId"];
    [readInfo setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    [readInfo setObject:[NSString stringNotNilWithValue:syncDate] forKey:@"syncDate"];
    [readInfo setObject:@"SPE_SEPTWOLVES_READ_STATUS" forKey:@"method"];
    [readInfo setObject:[WSAppData getObjectbyKey:SERVERREQUIRE] forKey:SERVERREQUIRE];
    
    return [readInfo JSONRepresentation];
    
}

+ (NSString *)buildProdGrideDataforPadByFuncs:(WSFuncsBean *)func
                                      isPhoto:(BOOL)isPhoto
                                        datas:(NSArray *)datas
                                      dataIDs:(NSArray *)dataIDs
                                        Store:(WSStoreBean*)aStore
                                          md5:(NSString *)md5
                                         memo:(NSString *)memo{
    
    int iMax = [datas count];
    int jMax = [func.paramArray count];
    NSString *ds = @"prodId";
    NSMutableArray *comparray = [[NSMutableArray alloc]
                                 initWithCapacity:iMax];
    //NSLog(@"datas is %@",datas);
    for (int i = 1; i < iMax; i++) {
        NSArray *subdatas = [datas objectAtIndex:i];
        
        //NSLog(@"class is %@",[dataIDs objectAtIndex:i]);
        WSProdBean* pb = [dataIDs objectAtIndex:i-1];
        
        if ([subdatas isKindOfClass:[NSArray class]])
        {
            NSMutableDictionary *celldic = [[NSMutableDictionary alloc]
                                            initWithCapacity:[func.paramArray count]];
            
            
            [celldic setObject:[NSString stringWithFormat:@"%@@ ",pb.Id]
                        forKey:ds];
            
            for (int j = 0; j < jMax; j++)
            {
                GridCell *cell= [subdatas objectAtIndex:j+1];
                NSString *key = ((WSFuncsBean_Param *)[func.paramArray objectAtIndex:j]).col;
                if (cell.type == EGridText || cell.type == EGridNumber)
                {
                    if (cell.value == nil)
                    {
                        [celldic setObject:@"" forKey:key];
                    }
                    else
                    {
                        [celldic setObject:cell.value forKey:key];
                    }
                }
                else if (cell.type == EGridCheckBox)
                {
                    [celldic setObject:cell.value forKey:key];
                }

            }// end for
            [JSONBuilder removeNullValueWith:func.fc andDic:celldic];

            [comparray addObject:celldic];
        }// end if
    }   //end for
    
    
    NSDictionary *basicJson = [JSONBuilder
                               buildBasicJsonDatabyFc:func.fc
                               fv:func.fv
                               storeId:aStore.Id
                               isPlan:aStore.plan];
    
    NSMutableDictionary *ret = [[NSMutableDictionary alloc]
                                 initWithDictionary:basicJson];
    
    [ret setObject:md5 forKey:JB_ID];
    [ret setObject:md5 forKey:JB_IMAGEINDEX];
    [ret setObject:md5 forKey:JB_PHOTOSINDEX];
    [ret setObject:@"normal" forKey:JB_FUNCSTYPE];
    [ret setObject:[WSCurrentTime getTimeMillisString] forKey:JB_MOBILECLICKTIME];
    
    
    if (isPhoto) {
        [ret setObject:md5 forKey:JB_PHOTOSINDEX];
    }
    if (memo==nil) {
        [ret setObject:[NSDictionary
                         dictionaryWithObject:comparray forKey:JB_PARAM]
                forKey:JB_JSONDATA];
    }else{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setObject:comparray forKey:JB_PARAM];
        [dictionary setObject:[NSString stringNotNilWithValue:memo] forKey:JB_MEMO];
        [ret setObject:dictionary forKey:JB_JSONDATA];
    }
    
    if (aStore.storeAccessMode == WSStoreAccessModeSubEmp) {
        if (aStore.srid && [aStore.srid length] > 0) {
            [ret setValue:aStore.srid forKey:JB_SRID];
        }
    }
    
    return [ret JSONRepresentation];
}

+ (NSString *)buildProdGrideDataByFuncs:(WSFuncsBean *)func
                                isPhoto:(BOOL)isPhoto
                                  datas:(NSArray *)datas
                                dataIDs:(NSArray *)dataIDs
                                  Store:(WSStoreBean*)aStore
                                    md5:(NSString *)md5
                                   memo:(NSString *)memo
                              otherInfo:(NSDictionary *)aDicOtherInfo{
    
    return [JSONBuilder buildProdGrideDataByFc:func.fc
                                        fv:func.fv
                                    params:func.paramArray
                                   isPhoto:isPhoto
                                     datas:datas
                                   dataIDs:dataIDs
                                     Store:aStore
                                       md5:md5
                                      memo:memo
                                     otherInfo:aDicOtherInfo];
}

/*  
 * acvt 中 prod 表格数据
 */
+ (NSString *)buildAcvtProdGrideDataByFc:(NSString *)fc
                                  fv:(NSString *)fv
                              params:(NSArray *)aParamArray
                             isPhoto:(BOOL)isPhoto
                               datas:(NSArray *)datas
                             dataIDs:(NSArray *)dataIDs
                               Store:(WSStoreBean*)aStore
                                 md5:(NSString *)md5 {
    
    return [JSONBuilder buildAcvtProdGrideDataByFc:fc
                                                fv:fv
                                            params:aParamArray
                                           isPhoto:isPhoto
                                             datas:datas
                                           dataIDs:dataIDs
                                             Store:aStore
                                               md5:md5
                                           acvtMD5:nil];
}

/*
 * acvt 中 prod 表格数据,加acvtMD5标识
 */
+ (NSString *)buildAcvtProdGrideDataByFc:(NSString *)fc
                                      fv:(NSString *)fv
                                  params:(NSArray *)aParamArray
                                 isPhoto:(BOOL)isPhoto
                                   datas:(NSArray *)datas
                                 dataIDs:(NSArray *)dataIDs
                                   Store:(WSStoreBean*)aStore
                                     md5:(NSString *)md5
                                 acvtMD5:(NSString *)acvtMD5{
    
    
    int iMax = [datas count];
    int jMax = [aParamArray count];
    //    NSString *ds = @"prodId";
    NSMutableArray *comparray = [[NSMutableArray alloc]
                                 initWithCapacity:iMax];
    //NSLog(@"datas is %@",datas);
    for (int i = 0; i < iMax; i++) {
        NSArray *subdatas = [datas objectAtIndex:i];
        
        WSStoreBean *store = [dataIDs objectAtIndex:i];
        
        if ([subdatas isKindOfClass:[NSArray class]]) {
            NSMutableDictionary *celldic = [[NSMutableDictionary alloc]
                                            initWithCapacity:[aParamArray count]];
            
            
            [celldic setObject:[NSString stringWithFormat:@"%@@ ",store.Id]
                        forKey:@"prodId"];
            
            for (int j = 0; j < jMax; j++) {
                id o = [subdatas objectAtIndex:j+1];
                WSFuncsBean_Param *aParam = (WSFuncsBean_Param *)[aParamArray objectAtIndex:j];
                
                // ids配置的数据不回传服务端
                if (aParam.ids
                    && [aParam.ids length] > 0
                    &&  aParam.readonly) {
                    continue;
                }
                NSString *key = ((WSFuncsBean_Param *)[aParamArray objectAtIndex:j]).col;

                if ([o isKindOfClass:[UITextField class]]) {
                    
                    NSString *value = (((UITextField *)o).text)?((UITextField *)o).text:((UITextField *)o).placeholder;
                    if (value && [value length] > 0) {
                         [celldic setObject:value forKey:key];
                    }
                    
                }else if([o isKindOfClass:[UIButton class]]){
                    NSNumber *value = [NSNumber numberWithInt:[(UIButton *)o isSelected]];
                    
                    [celldic setObject:value forKey:key];
                }else if( [o isKindOfClass:[WSSelectListView class]] ){
                    WSSelectListView *list = (WSSelectListView *)o;
                    NSArray *valueArray = nil;
                    
                    if (list.selectMode == WSSelectListViewSelectModeSingleSelection) {
                        NSString *value = [NSString string];
                        if(list.selectedIndex>-1){
                            value = [list.content objectAtIndex:list.selectedIndex];
                            valueArray = [NSArray arrayWithObject:value];
                        }
                    }
                    else if (list.selectMode == WSSelectListViewSelectModeMultipleChoice) {
                        valueArray = [[list getSelectedContentString] componentsSeparatedByString:@","];
                    }
                    
                    WSDictBeanArray* dbArray = [WSAppData getObjectbyKey:DICTS];
                    NSArray* filterArray = [dbArray getDictsWithFilter:aParam.filter];
                    NSMutableArray *dictIdArray = [NSMutableArray array];
                    for (NSString *value in valueArray) {
                        for (WSDictBean *db in filterArray)
                        {
                            if ([db.name isKindOfClass:[NSString class]] && [db.name isEqualToString:value]) {
                                [dictIdArray addObject:db.Id];
                                break;
                            }
                        }
                    }
                    
                    if ([dictIdArray count] > 0) {
                        [celldic setObject:[dictIdArray componentsJoinedByString:@","] forKey:key];
                    }
                    else if ([valueArray count] > 0) {
                        [celldic setObject:[valueArray componentsJoinedByString:@","] forKey:key];
                    }
                    
                }else if ([o isKindOfClass:[WSMultipleChoiceLabel class]]){
                    WSMultipleChoiceLabel *label = (WSMultipleChoiceLabel*)o;
                    NSString *value = (label.iContent != nil) ? label.iContent : @"";
                    [celldic setObject:value forKey:key];
                } else if ([o isKindOfClass:[PhotoTypeButton class]]) {
                    PhotoTypeButton *button = (PhotoTypeButton *)o;
                    NSString *value = @"";
                    if ([button.photoIDArray count] > 0) {
                        value = button.imageMD5;
                    }
                    [celldic setObject:value forKey:key];
                } else if ([o isKindOfClass:[WSDatePickerLabel class]]) {
                    WSDatePickerLabel *dLab = (WSDatePickerLabel *)o;
                    NSString *value = dLab.text;
                    value = value ? value : @"";
                    [celldic setObject:value forKey:key];
                }
                // end if
            }// end for
            [JSONBuilder removeNullValueWith:fc andDic:celldic];

            [comparray addObject:celldic];
        }// end if
    }   //end for
    
    
    NSDictionary *basicJson = [JSONBuilder
                               buildBasicJsonDatabyFc:fc
                               fv:fv
                               storeId:aStore.Id
                               isPlan:aStore.plan];
    
    NSMutableDictionary *ret = [[NSMutableDictionary alloc]
                                initWithDictionary:basicJson];
    
    [ret setObject:md5 forKey:JB_ID];
    [ret setObject:md5 forKey:JB_IMAGEINDEX];
    [ret setObject:md5 forKey:JB_PHOTOSINDEX];
    [ret setObject:@"normal" forKey:JB_FUNCSTYPE];
    [ret setObject:[WSCurrentTime getTimeMillisString] forKey:JB_MOBILECLICKTIME];
#warning 需要为ACVT嵌入表格的TB表格数据上传新建ID
    if (acvtMD5 != nil && [acvtMD5 length] > 0) {
        [ret setObject:acvtMD5 forKey:JB_SUBMITID];
    }
    
    
    if (isPhoto) {
        [ret setObject:md5 forKey:JB_PHOTOSINDEX];
    }
    //    if (memo==nil) {
    [ret setObject:[NSDictionary
                    dictionaryWithObject:comparray forKey:JB_PARAM]
            forKey:JB_JSONDATA];
    //    }else{
    //
    //        NSArray* values = [NSArray arrayWithObjects:comparray,memo, nil];
    //        NSArray* keys = [NSArray arrayWithObjects:JB_PARAM,JB_MEMO, nil];
    //        [ret setObject:[NSDictionary dictionaryWithObjects:values forKeys:keys]
    //                forKey:JB_JSONDATA];
    //    }
    
    if (aStore.storeAccessMode == WSStoreAccessModeSubEmp) {
        if (aStore.srid && [aStore.srid length] > 0) {
            [ret setValue:aStore.srid forKey:JB_SRID];
        }
    }
    
    return [ret JSONRepresentation];
}

+ (NSString *)buildAcvtDictGrideDataByFc:(NSString *)fc
                                      fv:(NSString *)fv
                                  params:(NSArray *)aParamArray
                                 isPhoto:(BOOL)isPhoto
                                   datas:(NSArray *)datas
                                 dataIDs:(NSArray *)dataIDs
                                   Store:(WSStoreBean*)aStore
                                     md5:(NSString *)md5 {
    
    return [JSONBuilder buildDictDetailbyFc:fc
                                         fv:fv
                                     params:aParamArray
                                    isPhoto:isPhoto
                                      datas:datas
                                    dataIDs:dataIDs
                                      Store:aStore
                                        md5:md5
                                       memo:nil
                                  otherInfo:nil];
}

+ (NSString *)buildAcvtDictGrideDataByFc:(NSString *)fc
                                      fv:(NSString *)fv
                                  params:(NSArray *)aParamArray
                                 isPhoto:(BOOL)isPhoto
                                   datas:(NSArray *)datas
                                 dataIDs:(NSArray *)dataIDs
                                   Store:(WSStoreBean*)aStore
                                     md5:(NSString *)md5
                                 acvtMD5:(NSString *)acvtMD5{
    
    return [JSONBuilder buildDictDetailbyFc:fc
                                         fv:fv
                                     params:aParamArray
                                    isPhoto:isPhoto datas:datas
                                    dataIDs:dataIDs
                                      Store:aStore
                                        md5:md5
                                       memo:nil
                                    acvtMD5:acvtMD5
                                  otherInfo:nil];
}

+ (NSString *)buildProdGrideDataByFc:(NSString *)fc
                                  fv:(NSString *)fv
                              params:(NSArray *)aParamArray
                             isPhoto:(BOOL)isPhoto
                               datas:(NSArray *)datas
                             dataIDs:(NSArray *)dataIDs
                               Store:(WSStoreBean*)aStore
                                 md5:(NSString *)md5
                                memo:(NSString *)memo
                           otherInfo:(NSDictionary *)aDicOtherInfo{

    int iMax = [datas count];
    if ([[datas lastObject] isKindOfClass:[NSDictionary class]]){
         iMax--;
    }
    int jMax = [aParamArray count];
    NSMutableArray *comparray = [[NSMutableArray alloc] initWithCapacity:iMax];
    for (int i = 0; i < iMax; i++) {
        NSArray *subdatas = [datas objectAtIndex:i];
        
        NSString * stringID = nil;
        
        if(i < [dataIDs count]){
             id obj = [dataIDs objectAtIndex:i];
         
            if ([obj isKindOfClass:[WSStoreBean_prod class]]) {
                WSStoreBean_prod* store_prod = (WSStoreBean_prod*)obj;
                stringID = store_prod.pid;
            }else if([obj isKindOfClass:[WSProdBean class]]){
                WSProdBean* pb= (WSProdBean*)obj;
                stringID = pb.Id;
            }
        }else{
            LogError(@"数组【dataIDs】下标越界 index: %i",i);
        }

        if ([subdatas isKindOfClass:[NSArray class]])
        {
            NSMutableDictionary *celldic = [[NSMutableDictionary alloc] initWithCapacity:[aParamArray count]];
            

            [celldic setObject:[NSString stringWithFormat:@"%@@ ",stringID]
                                forKey:@"prodId"];
 
            for (int j = 0; j < jMax; j++) 
            {
                id o = [subdatas objectAtIndex:j+1];
                WSFuncsBean_Param *aParam = (WSFuncsBean_Param *)[aParamArray objectAtIndex:j];
                NSString *key = ((WSFuncsBean_Param *)[aParamArray objectAtIndex:j]).col;
                // ids配置的数据不回传服务端
                if (aParam.ids
                    && [aParam.ids length] > 0
                    && aParam.readonly) {
                    continue;
                }
                //NSLog(@"key is %@",key);
               
                if ([o isKindOfClass:[UITextField class]]) {
                   
                NSString *value = (((UITextField *)o).text)?((UITextField *)o).text:((UITextField *)o).placeholder;
                    

                    if(value==nil||[value isEqualToString:@""])
                        
                        [celldic setObject:@"" forKey:key];
                    else
                        [celldic setObject:value forKey:key];
                    
                }else if([o isKindOfClass:[UIButton class]]){

                    if ([o isKindOfClass:[WSAcvtButtonForTB class]]) {
                        NSDictionary *dic = [datas lastObject];
                        if ([dic isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *jsondata = [dic objectForKey:[NSString stringWithFormat:@"%d", ((UIButton *)o).tag]];
                            if (jsondata != nil) {
                                [celldic setObject:[jsondata JSONRepresentation] forKey:key];
                            }
                        }
                    }else{
                        NSNumber *value = [NSNumber numberWithInt:[(UIButton *)o isSelected]];
                        [celldic setObject:value forKey:key];
                    }

                    
                }else if( [o isKindOfClass:[WSSelectListView class]] ){
                    
                    WSSelectListView *list = (WSSelectListView *)o;
                    NSArray *valueArray = nil;
                    
                    if (list.selectMode == WSSelectListViewSelectModeSingleSelection) {
                        NSString *value = [NSString string];
                        if(list.selectedIndex>-1){
                            value = [list.content objectAtIndex:list.selectedIndex];
                            valueArray = [NSArray arrayWithObject:value];
                        }
                    }
                    else if (list.selectMode == WSSelectListViewSelectModeMultipleChoice) {
                        valueArray = [[list getSelectedContentString] componentsSeparatedByString:@","];
                    }
                    
                    WSDictBeanArray* dbArray = [WSAppData getObjectbyKey:DICTS];
                    NSArray* filterArray = [dbArray getDictsWithFilter:aParam.filter];
                    NSMutableArray *dictIdArray = [NSMutableArray array];
                    for (NSString *value in valueArray) {
                        for (WSDictBean *db in filterArray)
                        {
                            if ([db.name isKindOfClass:[NSString class]] && [db.name isEqualToString:value]) {
                                [dictIdArray addObject:db.Id];
                                break;
                            }
                        }
                    }
                    
                    if ([dictIdArray count] > 0) {
                        [celldic setObject:[dictIdArray componentsJoinedByString:@","] forKey:key];
                    }
                    else if ([valueArray count] > 0) {
                        [celldic setObject:[valueArray componentsJoinedByString:@","] forKey:key];
                    }
                
                }else if ([o isKindOfClass:[WSMultipleChoiceLabel class]]){
                    WSMultipleChoiceLabel *label = (WSMultipleChoiceLabel*)o;
                    NSString *value = (label.iContent != nil) ? label.iContent : @"";
                    [celldic setObject:value forKey:key];
                } else if ([o isKindOfClass:[PhotoTypeButton class]]) {
                    PhotoTypeButton *button = (PhotoTypeButton *)o;
                    NSString *value = @"";
                    if ([button.photoIDArray count] > 0) {
                        value = button.imageMD5;
                    }
                    [celldic setObject:value forKey:key];
                } else if ([o isKindOfClass:[WSDatePickerLabel class]]) {
                    WSDatePickerLabel *dLab = (WSDatePickerLabel *)o;
                    NSString *value = dLab.text;
                    value = value ? value : @"";
                    [celldic setObject:value forKey:key];
                }
                // end if
            }// end for
            
            celldic = [JSONBuilder removeNullValueWith:fc andDic:celldic];
            if (celldic) {
                [comparray addObject:celldic];
            }
            
        }// end if
    }   //end for
 

    NSDictionary *basicJson = [JSONBuilder buildBasicJsonDatabyFc:fc
                                                               fv:fv
                                                          storeId:aStore.Id
                                                           isPlan:aStore.plan];
    
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] 
                                initWithDictionary:basicJson];
    
    if (aStore.storeAccessMode == WSStoreAccessModeSubEmp) {
        if (aStore.srid && [aStore.srid length] > 0) {
            [ret setValue:aStore.srid forKey:JB_SRID];
        }
    }
    
    [ret setObject:md5 forKey:JB_ID];
    if(isPhoto){
        NSString* index=[NSString stringWithFormat:@"%@_%@",fc,md5];
        [ret setObject:index forKey:JB_IMAGEINDEX];
        [ret setObject:index forKey:JB_PHOTOSINDEX];
    }else{
        [ret setObject:@"" forKey:JB_IMAGEINDEX];
        [ret setObject:@"" forKey:JB_PHOTOSINDEX];
    }

    [ret setObject:@"normal" forKey:JB_FUNCSTYPE];
    [ret setObject:[WSCurrentTime getTimeMillisString] forKey:JB_MOBILECLICKTIME];
    
    if (aDicOtherInfo != nil) {
        aDicOtherInfo =  [JSONBuilder removeNullValueWith:fc andDic:[NSMutableDictionary dictionaryWithDictionary:aDicOtherInfo]];
    }

    if (memo==nil) {
        //        NSArray *array = [[NSArray alloc] init];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:comparray forKey:JB_PARAM];
        if (aDicOtherInfo != nil) {
            NSArray *keys = [aDicOtherInfo allKeys];
            for (NSString *key in keys) {
                NSString *value = [aDicOtherInfo objectForKey:key];
                [dic setObject:value forKey:key];
            }
        }
        [ret setObject:dic forKey:JB_JSONDATA];
    }
    else
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:comparray forKey:JB_PARAM];
        [dic setObject:[NSString stringNotNilWithValue:memo] forKey:JB_MEMO];
        if (aDicOtherInfo) {
            NSArray *keys = [aDicOtherInfo allKeys];
            for (NSString *key in keys) {
                NSString *value = [aDicOtherInfo objectForKey:key];
                [dic setObject:value forKey:key];
            }
        }
        [ret setObject:dic forKey:JB_JSONDATA];
    }
    return [ret JSONRepresentation];
}

+(id)removeNullValueWith:(NSString *)fc andDic:(NSMutableDictionary*)dic
{
    WSFuncsBeanArray* funcsArray=[WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean* fb=[funcsArray getFuncsBeanWithFC:fc];
    
    if(fb && (!fb.nullvalue || fb.nullvalue==0)){
        for(NSString* key in dic.allKeys){
            id object=[dic objectForKey:key];
            if([object isKindOfClass:[NSString class]]){
                NSString* string=(NSString*)object;
                if(string && string.length>0){
                    continue;
                }else{
                    [dic removeObjectForKey:key];
                }
            }else if ([object isKindOfClass:[NSNumber class]]){
                NSNumber* number=(NSNumber*)object;
                if(number && number.stringValue.length>0){
                    continue;
                }else{
                    [dic removeObjectForKey:key];
                }
            }
        }
    }
    // 如果当前表格的行没有填数据 不上传当前行相关数据
    if ([[dic allKeys] count] == 1) {
        NSString *key = [[dic allKeys] firstObject];
        if ([key isEqualToString:@"prodId"] || [key isEqualToString:@"dictId"]) {
            return nil;
        }
    }
    return dic;
}

+ (NSString *)  buildSalesPersonInfoGrideDataByFuncs:(WSFuncsBean *)func
                        isPhoto                     :(BOOL) isPhoto
                        datas                       :(NSArray *)datas
                        dataIDs                     :(NSArray *)dataIDs
                        Store                       :(WSStoreBean *)aStore
                        md5                         :(NSString *)md5
                        memo                        :(NSString *)memo
                        otherInfo                   :(NSDictionary *)aDicOtherInfo
{
    return [self buildSalesPersonInfoGrideDataByFuncs:func isPhoto:isPhoto datas:datas dataIDs:dataIDs Store:aStore md5:md5 memo:memo otherInfo:aDicOtherInfo sendBackData:nil];
}

+ (NSString *)  buildSalesPersonInfoGrideDataByFuncs:(WSFuncsBean *)func
                        isPhoto                     :(BOOL) isPhoto
                        datas                       :(NSArray *)datas
                        dataIDs                     :(NSArray *)dataIDs
                        Store                       :(WSStoreBean *)aStore
                        md5                         :(NSString *)md5
                        memo                        :(NSString *)memo
                        otherInfo                   :(NSDictionary *)aDicOtherInfo
                                        sendBackData:(id) sendBackData
{
    NSDictionary *basicJson = [JSONBuilder
                               buildBasicJsonDatabyFc:func.fc
                               fv:func.fv
                               storeId:aStore.Id
                               isPlan:aStore.plan];
    
    NSMutableDictionary *ret = [[NSMutableDictionary alloc]
                                initWithDictionary:basicJson];
    [ret setObject:md5 forKey:JB_ID];
    //    [ret setObject:md5 forKey:JB_IMAGEINDEX];
    //    [ret setObject:md5 forKey:JB_PHOTOSINDEX];
    [ret setObject:@"normal" forKey:JB_FUNCSTYPE];
    [ret setObject:[WSCurrentTime getTimeMillisString] forKey:JB_MOBILECLICKTIME];
    
    NSString *identifier = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    if (identifier != nil) {
        [ret setObject:identifier forKey:JB_IMEI];
    }
    
    [ret setObject: [[WSAppData getObjectbyKey:SERVERREQUIRE] JSONRepresentation] forKey:SERVERREQUIRE];
    if ([func.filter isKindOfClass:[NSString class]]) {
        [ret setObject:func.filter forKey:@"filter"];
    }
    if (sendBackData) {
        [ret setObject:sendBackData forKey:@"sendBackData"];
    }
    
    int iMax = [datas count];
    int jMax = [dataIDs count];
    //    NSString *ds = @"prodId";
    NSMutableArray *comparray = [[NSMutableArray alloc]
                                 initWithCapacity:iMax];
    //NSLog(@"datas is %@",datas);
    for (int i = 0; i < iMax; i++) {
        NSArray *subdatas = [datas objectAtIndex:i];
        
        if ([subdatas isKindOfClass:[NSArray class]])
        {
            NSMutableDictionary *celldic = [[NSMutableDictionary alloc]
                                            initWithCapacity:[dataIDs count]];
            
            for (int j = 0; j < jMax; j++)
            {
                id o = [subdatas objectAtIndex:j];
                WSFuncsBean_Param *aParam = (WSFuncsBean_Param *)[dataIDs objectAtIndex:j];
                // ids配置的数据不回传服务端
                if (aParam.ids
                    && [aParam.ids length] > 0
                    && aParam.readonly) {
                    continue;
                }
                NSString *key = ((WSFuncsBean_Param *)[dataIDs objectAtIndex:j]).col;
                
                if ([o isKindOfClass:[UILabel class]]) {
                    
                    NSString *value = (((UILabel *)o).text)?((UILabel *)o).text: @"";
                
                    if(value==nil||[value isEqualToString:@""])
                        
                        [celldic setObject:@"" forKey:key];
                    else
                        [celldic setObject:value forKey:key];
                    
                }else if ([o isKindOfClass:[UITextField class]]) {
                    
                    NSString *value = (((UITextField *)o).text)?((UITextField *)o).text:((UITextField *)o).placeholder;
                    
                    if(value==nil||[value isEqualToString:@""])
                        
                        [celldic setObject:@"" forKey:key];
                    else
                        [celldic setObject:value forKey:key];
                    
                }else if([o isKindOfClass:[UIButton class]]){
                    NSNumber *value = [NSNumber numberWithInt:[(UIButton *)o isSelected]];
                    
                    [celldic setObject:value forKey:key];
                }else if( [o isKindOfClass:[WSSelectListView class]] ){
                    WSSelectListView *list = (WSSelectListView *)o;
                    NSArray *valueArray = nil;
                    
                    if (list.selectMode == WSSelectListViewSelectModeSingleSelection) {
                        NSString *value = [NSString string];
                        if(list.selectedIndex>-1){
                            value = [list.content objectAtIndex:list.selectedIndex];
                            valueArray = [NSArray arrayWithObject:value];
                        }
                    }
                    else if (list.selectMode == WSSelectListViewSelectModeMultipleChoice) {
                        valueArray = [[list getSelectedContentString] componentsSeparatedByString:@","];
                    }
                    
                    WSDictBeanArray* dbArray = [WSAppData getObjectbyKey:DICTS];
                    NSArray* filterArray = [dbArray getDictsWithFilter:aParam.filter];
                    NSMutableArray *dictIdArray = [NSMutableArray array];
                    for (NSString *value in valueArray) {
                        for (WSDictBean *db in filterArray)
                        {
                            if ([db.name isKindOfClass:[NSString class]] && [db.name isEqualToString:value]) {
                                [dictIdArray addObject:db.Id];
                                break;
                            }
                        }
                    }
                    
                    if ([dictIdArray count] > 0) {
                        [celldic setObject:[dictIdArray componentsJoinedByString:@","] forKey:key];
                    }
                    else if ([valueArray count] > 0) {
                        [celldic setObject:[valueArray componentsJoinedByString:@","] forKey:key];
                    }
                    
                }else if ([o isKindOfClass:[WSMultipleChoiceLabel class]]){
                    WSMultipleChoiceLabel *label = (WSMultipleChoiceLabel*)o;
                    NSString *value = (label.iContent != nil) ? label.iContent : @"";
                    [celldic setObject:value forKey:key];
                } else if ([o isKindOfClass:[PhotoTypeButton class]]) {
                    PhotoTypeButton *button = (PhotoTypeButton *)o;
                    NSString *value = @"";
                    if ([button.photoIDArray count] > 0) {
                        value = button.imageMD5;
                    }
                    [celldic setObject:value forKey:key];
                } else if ([o isKindOfClass:[WSDatePickerLabel class]]) {
                    WSDatePickerLabel *dLab = (WSDatePickerLabel *)o;
                    NSString *value = dLab.text;
                    value = value ? value : @"";
                    [celldic setObject:value forKey:key];
                }
                // end if
            }// end for
            
            [comparray addObject:celldic];
        }// end if
    }   //end for
    
    
    if (memo==nil) {
//        NSArray *array = [[NSArray alloc] init];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:comparray forKey:JB_PARAM];
        if (aDicOtherInfo != nil) {
            NSArray *keys = [aDicOtherInfo allKeys];
            for (NSString *key in keys) {
                NSString *value = [aDicOtherInfo objectForKey:key];
                [dic setObject:value forKey:key];
            }
        }
        [ret setObject:dic forKey:JB_JSONDATA];
    }
    else
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:comparray forKey:JB_PARAM];
        [dic setObject:[NSString stringNotNilWithValue:memo] forKey:JB_MEMO];
        
        if (aDicOtherInfo) {
            NSArray *keys = [aDicOtherInfo allKeys];
            for (NSString *key in keys) {
                NSString *value = [aDicOtherInfo objectForKey:key];
                [dic setObject:value forKey:key];
            }
        }
        [ret setObject:dic forKey:JB_JSONDATA];
    }
    
    if (aStore.storeAccessMode == WSStoreAccessModeSubEmp) {
        if (aStore.srid && [aStore.srid length] > 0) {
            [ret setValue:aStore.srid forKey:JB_SRID];
        }
    }
    
    return [ret JSONRepresentation];
}

+ (NSString *)buildActivitybyFuncs:(WSFuncsBean *)func 
                              acvt:(WSAcvtBean *)acvt
                           isPhoto:(BOOL)isPhoto
                             Store:(WSStoreBean *)aStore
                             cells:(NSDictionary *)cells
                               md5:(NSString *)md5
                            Others:(NSDictionary*)aOthers
{
    NSString* l_storeId = aStore.Id;
    if ([aStore isKindOfClass:[WSStoreBean class]]) {
        if (aStore.iStoreIdentify != nil) {
            l_storeId = aStore.iStoreIdentify;
        }
    }
    
    if (aStore.Id == nil) {
        l_storeId = @"-1";
    }
    
    NSString *photosIndex = nil;
    
    NSMutableDictionary *acvtObj = [[NSMutableDictionary alloc] 
                                    init];
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithDictionary:[JSONBuilder buildBasicJsonDatabyFc:func.fc
                                                                                                                fv:func.fv
                                                                                                           storeId:l_storeId
                                                                                                            isPlan:YES]];
    NSMutableArray *qsts_notInCells = [NSMutableArray arrayWithArray:acvt.qsts];
    for(NSString* key in [cells allKeys])
    {
        NSArray* array = [key componentsSeparatedByString:@","];
        NSString* qstIdString = [array objectAtIndex:0];
        for(WSAcvtBean_qst* qst in acvt.qsts)
        {
            if(![qst.acvtQstId isEqualToString:qstIdString])
            {
                continue;
            }
            
            [qsts_notInCells removeObject:qst];
            
            
            if([qst.qstType isEqualToString:QST_TYPE_GE]) {
                NSDictionary *reslut = [cells objectForKey:key];
    
                if (reslut && [reslut isKindOfClass:[NSDictionary class]]) {
                    NSString *areaID = [reslut objectForKey:@"areaID"];
                    [acvtObj setObject:areaID forKey:[NSString stringWithFormat:@"%@%@", qst.qstType, qst.acvtQstId]];
                }
                else
                {
                    if (qst.defaultValue) {
                        [acvtObj setObject:qst.defaultValue forKey:[NSString stringWithFormat:@"%@%@", qst.qstType, qst.acvtQstId]];
                    }
                }
                continue;
            }
            
            if([qst.qstType isEqualToString:QST_TYPE_P]) {
                NSArray *imageIDArray = [cells objectForKey:key];
                if (imageIDArray && [imageIDArray count] > 0) {
                    //from Android,acvt问题为照片时，上传的value为fc_md5_qstId,用来唯一标识这个问题对应的照片，因此真正上传照片时，imageIndex应该为此值。外层的photosIndex参数和此值一样，目前存在一个问题就是服务器不支持多个问题为拍照，因此如果一个acvt配置的多个问题为拍照，photosIndex暂时先传第一个的value
                    photosIndex = [NSString stringWithFormat:@"%@_%@_%@", func.fc, md5, qst.acvtQstId];
                    [acvtObj setObject:photosIndex forKey:[NSString stringWithFormat:@"%@%@", qst.qstType, qst.acvtQstId]];
                    
                }
                continue;
            }
            
            if([qst.qstType isEqualToString:QST_TYPE_C] ||
               [qst.qstType isEqualToString:QST_TYPE_R] ||
               [qst.qstType isEqualToString:QST_TYPE_CN])
            {
                NSString* l_acvtKey = [NSString stringWithFormat:@"%@%@",qst.qstType,qstIdString];
                if([acvtObj objectForKey:l_acvtKey] != nil)
                {
                    if ([array count] > 1) {
                        NSString *preStr = [acvtObj objectForKey:l_acvtKey];
                        if (![preStr isEqualToString:[array objectAtIndex:1]]) {
                            NSString* value = [NSString stringWithFormat:@"%@,%@",preStr,[array objectAtIndex:1]];
                            [acvtObj setObject:value forKey:l_acvtKey];
                        }
                    }
                }
                else
                {
                    if (array.count > 1)
                    {
                        [acvtObj setObject:[array objectAtIndex:1] forKey:l_acvtKey];
                    }
                    else
                    {
                        id reslut = [cells objectForKey:key];
                        if (reslut && [reslut isKindOfClass:[NSString class]]) {
                            [acvtObj setObject:reslut forKey:l_acvtKey];
                        }else if (qst.defaultValue) {
                            [acvtObj setObject:qst.defaultValue forKey:l_acvtKey];
                        }
                    }
                }
                continue;
            }

            if ([qst.qstType isEqualToString:QST_TYPE_RD] ||
                [qst.qstType isEqualToString:QST_TYPE_CD]  )
            {
                NSString *value = [cells objectForKey:key];
                WSDictBeanArray* dbArray = [WSAppData getObjectbyKey:DICTS];
                NSArray* filterArray = [dbArray getDictsWithFilter:qst.filter];
                NSString *dictId = nil;
                
                NSArray *valueArray = [value componentsSeparatedByString:@","];
                NSMutableArray *dictIdArray = [NSMutableArray array];
                
                for (NSString *valueContent in valueArray) {
                    for (WSDictBean *db in filterArray)
                    {
                        if ([db.name isKindOfClass:[NSString class]] && [db.name isEqualToString:valueContent]) {
                            dictId = db.Id;
                            break;
                        }
                    }
                    
                    if(dictId)
                    {
                        [dictIdArray addObject:[NSString stringNotNilWithValue:dictId]];
                    }
                }
                if ([dictIdArray count] > 0) {
                    [acvtObj setObject:[dictIdArray componentsJoinedByString:@","] forKey:[NSString stringWithFormat:@"%@%@", qst.qstType, key]];
                }
                continue;
            }
            if ([qst.qstType isEqualToString:QST_TYPE_DV] && !qst.isHidden) {
                 NSString *value = [cells objectForKey:key];
                if (value && [value isKindOfClass:[NSString class]]) {
                    [acvtObj setObject:value forKey:[NSString stringWithFormat:@"%@%@", qst.qstType, key]];
                }
            }
            
            
            NSObject *content = [cells objectForKey:key];
            if (!content) {
                content = @"";
            }

            NSString *objKey = key;
            
            if([qst.qstType isEqualToString:QST_TYPE_N] ||
               [qst.qstType isEqualToString:QST_TYPE_NR] ||
               [qst.qstType isEqualToString:QST_TYPE_W]||
               [qst.qstType isEqualToString:QST_TYPE_T]||
               [qst.qstType isEqualToString:QST_TYPE_MI]||
               [qst.qstType isEqualToString:QST_TYPE_SCAN]||
               [qst.qstType isEqualToString:QST_TYPE_I] ||
               [qst.qstType isEqualToString:QST_TYPE_M])
            {
                if (!content || [((NSString*)content) length] <= 0)
                {
                    if (qst.defaultValue) {
                        content = qst.defaultValue;
                    }
                    
                }
                objKey = [NSString stringWithFormat:@"%@%@",qst.qstType,qst.acvtQstId];
                [acvtObj setObject:content forKey:objKey];
                continue;

            }
            if([qst.qstType isEqualToString:QST_TYPE_GG]  ||
               [qst.qstType isEqualToString:QST_TYPE_GF]  ||
               [qst.qstType isEqualToString:QST_TYPE_V]   ||
               [qst.qstType isEqualToString:QST_TYPE_WF]  ||
               [qst.qstType isEqualToString:QST_TYPE_SS]  ||
               [qst.qstType isEqualToString:QST_TYPE_D]   ||
               [qst.qstType isEqualToString:QST_TYPE_DT]   ||
               [qst.qstType isEqualToString:QST_TYPE_SED] ||
               [qst.qstType isEqualToString:QST_TYPE_PT]  ||
               [qst.qstType isEqualToString:QST_TYPE_RB]  ||
               [qst.qstType isEqualToString:QST_TYPE_BTN])
            {
                objKey = [NSString stringWithFormat:@"%@%@",qst.qstType,qst.acvtQstId];
                [acvtObj setObject:content forKey:objKey];
                continue;
            }
            
            if  ([qst.qstType isEqualToString:QST_TYPE_TV])
            {
                objKey = [NSString stringWithFormat:@"T%@", qst.acvtQstId];
                [acvtObj setObject:content forKey:objKey];
                continue;
            }
        }
    }
    
    //上传TB表格关系json
    
    if (aOthers
        && [aOthers count] > 0) {
        id object = [aOthers objectForKey:QST_TYPE_TB];
        if ([object isKindOfClass:[NSDictionary class]]) {
            [acvtObj addEntriesFromDictionary:(NSDictionary *)object];
        }
    }
    //上传AN问卷数据
    if (aOthers
        && [aOthers count] > 0) {
        id object = [aOthers objectForKey:QST_TYPE_AN];
        if ([object isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in object) {
                 [acvtObj addEntriesFromDictionary:(NSDictionary *)dic];
            }

        }
    }
    

    // 没有填写 则上传默认值
    for (WSAcvtBean_qst* qst in qsts_notInCells)
    {
        if (!qst.defaultValue) { continue; }
        
        NSString *content = qst.defaultValue;
        NSString *objKey = @"";
        BOOL needAdd = NO;
        
        if([qst.qstType isEqualToString:QST_TYPE_GG]  ||
           [qst.qstType isEqualToString:QST_TYPE_GF]  ||
           [qst.qstType isEqualToString:QST_TYPE_V]   ||
           [qst.qstType isEqualToString:QST_TYPE_WF]  ||
           [qst.qstType isEqualToString:QST_TYPE_SS]  ||
           [qst.qstType isEqualToString:QST_TYPE_D]   ||
           [qst.qstType isEqualToString:QST_TYPE_DT]   ||
           [qst.qstType isEqualToString:QST_TYPE_SED] ||
           [qst.qstType isEqualToString:QST_TYPE_PT]  ||
           [qst.qstType isEqualToString:QST_TYPE_GE]  ||
           [qst.qstType isEqualToString:QST_TYPE_C]   ||
           [qst.qstType isEqualToString:QST_TYPE_R]   ||
           [qst.qstType isEqualToString:QST_TYPE_RD]  ||
           [qst.qstType isEqualToString:QST_TYPE_CD]  ||
           [qst.qstType isEqualToString:QST_TYPE_DV]  ||
           [qst.qstType isEqualToString:QST_TYPE_N]   ||
           [qst.qstType isEqualToString:QST_TYPE_NR]  ||
           [qst.qstType isEqualToString:QST_TYPE_W]   ||
           [qst.qstType isEqualToString:QST_TYPE_T]   ||
           [qst.qstType isEqualToString:QST_TYPE_SCAN]||
           [qst.qstType isEqualToString:QST_TYPE_I]   ||
           [qst.qstType isEqualToString:QST_TYPE_BTN])
        {
            objKey = [NSString stringWithFormat:@"%@%@",qst.qstType,qst.acvtQstId];
            needAdd = YES;
        }
        
        if  ([qst.qstType isEqualToString:QST_TYPE_TV])
        {
            objKey = [NSString stringWithFormat:@"T%@", qst.acvtQstId];
            needAdd = YES;
        }
        if (needAdd)
        {
            [acvtObj setObject:content forKey:objKey];
        }
    }

    [ret setObject:[NSString stringNotNilWithValue:md5] forKey:JB_ID];
    [ret setObject:[NSString stringNotNilWithValue:md5] forKey:JB_SUBMITID];
    [ret setObject:[WSCurrentTime getTimeMillisString] forKey:JB_MOBILECLICKTIME];
    
    NSMutableDictionary* l_gps = [[NSMutableDictionary alloc]init];
    [ret setObject: l_gps forKey:JB_POSITION];
    
    if (photosIndex) {
        [ret setObject:photosIndex forKey:JB_IMAGEINDEX];
        [ret setObject:photosIndex forKey:JB_PHOTOSINDEX];
    }else{
        if(isPhoto){
            NSString* imageIndex=[NSString stringWithFormat:@"%@_%@_%@",func.fc,md5,acvt.acvtId];
            [ret setObject:imageIndex forKey:JB_IMAGEINDEX];
            [ret setObject:imageIndex forKey:JB_PHOTOSINDEX];
        }else{
            [ret setObject:@"" forKey:JB_IMAGEINDEX];
            [ret setObject:@"" forKey:JB_PHOTOSINDEX];
        }
    }

    
    NSMutableDictionary* l_acvtId =[NSMutableDictionary dictionaryWithObject:[NSString stringNotNilWithValue:acvt.acvtId] forKey:@"acvtId"];
    if (acvt.iOriginalAcvtId != nil && [acvt.iOriginalAcvtId length] > 0) {
        [l_acvtId setObject:acvt.iOriginalAcvtId forKey:@"originalAcvtId"];
    }
    [ret setObject:l_acvtId forKey:JB_HIDVAL];
    
    // For septwolves
    NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];;
    if (projectName && [projectName respondsToSelector:@selector(isEqualToString:)] && [projectName isEqualToString:@"stepwolf"]) {
         [l_acvtId setValue:[NSString stringNotNilWithValue:md5] forKey:@"md5"];
        [l_acvtId setValue: [NSString stringNotNilWithValue:projectName] forKey:@"project"];
    }
    
    [ret setObject:acvtObj forKey:JB_JSONDATA];
 
    if ([WSAppData getObjectbyKey:SERVERREQUIRE])
    {
         id serverRequire = [WSAppData getObjectbyKey:SERVERREQUIRE];
        [ret setObject:serverRequire  forKey:SERVERREQUIRE];
    }

    
//    NSLog(@"ret is = %@",[ret JSONRepresentation]);
        
      if (aStore.srid && [aStore.srid isKindOfClass:[NSString class]] && [aStore.srid length] > 0) {
            [ret setValue:aStore.srid forKey:JB_SRID];
      }else   if (aStore.storeAccessMode == WSStoreAccessModeSubEmp)
      {
          if (aStore.empId && [aStore.empId length] > 0) {
              [ret setValue:aStore.empId forKey:JB_SRID];
          }
          else if (aStore.orgId && [aStore.orgId length] > 0)
          {
              [ret setValue:aStore.orgId forKey:JB_SRORGID];
          }
      }

    return [ret JSONRepresentation];
}

+ (NSString *)buildDisplayPhotoDatasbyFuncs:(WSFuncsBean *)funcs
                                         HasPhoto:(BOOL)hasPhoto
                                            Store:(WSStoreBean *)aStore
                                            cells:(NSArray *)cells
                                              md5:(NSString *)md5
                                       notifyName:(NSString *)notifyName {
    
    NSString *l_storeId ;
    if(aStore.Id == nil)
        l_storeId = @"-1";
    else
        l_storeId = aStore.Id;
    NSMutableDictionary *ret = [[NSMutableDictionary alloc]
                                 initWithDictionary:[JSONBuilder
                                                     buildBasicJsonDatabyFc:@"SPE_PFIZER_PAYDISP"
                                                     fv:funcs.fv
                                                     storeId:l_storeId
                                                     isPlan:aStore.plan]];    

    [ret setObject:md5 forKey:JB_ID];
    [ret setObject:md5 forKey:JB_IMAGEINDEX];
    [ret setObject:md5 forKey:JB_PHOTOSINDEX];
    
    if (aStore.storeAccessMode == WSStoreAccessModeSubEmp) {
        if (aStore.srid && [aStore.srid length] > 0) {
            [ret setValue:aStore.srid forKey:JB_SRID];
        }
    }
    
    [ret setObject:[WSCurrentTime getTimeMillisString] forKey:JB_MOBILECLICKTIME];
    if ([WSAppData getObjectbyKey:SERVERREQUIRE])
    {
        [ret setObject:[WSAppData getObjectbyKey:SERVERREQUIRE] forKey:SERVERREQUIRE];
    }

    [ret setObject:cells forKey:JB_JSONDATA];
    
    return [ret JSONRepresentation];
}

+ (NSString *)buildNewProductbyFuncs:(WSFuncsBean *)func 
                                acvt:(WSAcvtBean *)acvt
                             isPhoto:(BOOL)isPhoto
                             Product:(WSNewProductBean *)aProduct
                               cells:(NSDictionary *)cells
                                 md5:(NSString *)md5
                              Others:(NSDictionary*)aOthers
{
    NSString* l_storeId ;
    if(aProduct == nil || aProduct.iStoreId == nil || [aProduct.iStoreId isEqualToString:@"<null>"])
        l_storeId = @"-1";
    else
        l_storeId = aProduct.iStoreId;
    NSMutableDictionary *acvtObj = [[NSMutableDictionary alloc] 
                                    init];
    NSMutableDictionary *ret = [[NSMutableDictionary alloc]
                                initWithDictionary:[JSONBuilder  buildBasicJsonDatabyFc:func.fc
                                                                                     fv:func.fv
                                                                                storeId:l_storeId]];
                                                     
    for(NSString* key in [cells allKeys])
    {
        NSArray* array = [key componentsSeparatedByString:@","];
        NSString* qstIdString = [array objectAtIndex:0];
        for(WSAcvtBean_qst* qst in acvt.qsts)
        {
            if([qst.acvtQstId isEqualToString:qstIdString])
            {
                if([qst.qstType isEqualToString:QST_TYPE_N]||[qst.qstType isEqualToString:QST_TYPE_W]||[qst.qstType isEqualToString:QST_TYPE_T]||[qst.qstType isEqualToString:QST_TYPE_SCAN])
                {
                    [acvtObj setObject:[cells objectForKey:key] forKey:[NSString stringWithFormat:@"%@%@",qst.qstType,qst.acvtQstId]];
                }
                if([qst.qstType isEqualToString:QST_TYPE_GG]||[qst.qstType isEqualToString:QST_TYPE_GF])
                {
                    [acvtObj setObject:[cells objectForKey:key] forKey:[NSString stringWithFormat:@"%@%@",qst.qstType,qst.acvtQstId]];
                }
                
                if([qst.qstType isEqualToString:QST_TYPE_V])
                {
                    [acvtObj setObject:[cells objectForKey:key] forKey:[NSString stringWithFormat:@"%@%@",qst.qstType,qst.acvtQstId]];
                }
                
                
                if([qst.qstType isEqualToString:QST_TYPE_C]||[qst.qstType isEqualToString:QST_TYPE_R])
                {
                    NSString* l_acvtKey = [NSString stringWithFormat:@"%@%@",qst.qstType,qstIdString];
                    if([acvtObj objectForKey:l_acvtKey] != nil)
                    {
                        NSString *preStr = [acvtObj objectForKey:l_acvtKey];
                        NSString* value = [NSString stringWithFormat:@"%@,%@",preStr,[array objectAtIndex:1]];
                        [acvtObj setObject:value forKey:l_acvtKey];
                    }else
                    {
                        [acvtObj setObject:[array objectAtIndex:1] forKey:l_acvtKey];
                    }
                }
                
            }
            
        }
    }
    
    [ret setObject:md5 forKey:JB_ID];

    [ret setObject:md5 forKey:JB_PHOTOSINDEX]; //MD5 is sname the JB_ID
    [ret setObject:@"normal" forKey:JB_FUNCSTYPE];
    [ret setObject:@"no imei" forKey:JB_IMEI];
    
    
    
    [ret setObject: [WSAppData getObjectbyKey:SERVERREQUIRE] forKey:SERVERREQUIRE];
    
    [ret setObject:[WSCurrentTime getTimeMillisString] forKey:JB_MOBILECLICKTIME];
    
    NSDictionary* l_acvtId =[NSDictionary dictionaryWithObject:acvt.acvtId forKey:@"acvtId"];
    [ret setObject:l_acvtId forKey:JB_HIDVAL];
    
    [ret setObject:acvtObj forKey:JB_JSONDATA];
   
    return [ret JSONRepresentation];
    
}

//更新是否需要使用自定义时间设置bizdate
+ (void) updateBizDateToDic:(NSMutableDictionary*)sourceDic withStoreId:(NSString*)storeId
{

    NSString *customEnterData = [[WSCustomTimeTable sharedTable] queueCustomEnterDateWithStoreId:storeId];
    if (customEnterData) {
        [sourceDic setObject:customEnterData forKey:JB_SYNCDATE];
        [sourceDic setObject:[NSNumber numberWithBool:YES] forKey:JB_ISDATAENTRY];
    }
}

+ (NSDictionary *)buildBasicJsonDatabyFc:(NSString *)fc
                                      fv:(NSString *)fv 
                                 storeId:(NSString *)storeId
                                  isPlan:(BOOL)isPlan{
    
    NSMutableDictionary *dictonary = [[NSMutableDictionary alloc]init];
    [dictonary setObject:[NSString stringNotNilWithValue:fc] forKey:JB_METHOD];
    [dictonary setObject:@"0" forKey:JB_ISSYNC];
    [dictonary setObject:[NSString stringWithFormat:@"%d",isPlan] forKey:JB_ISPLAN];
    [dictonary setObject:(fv != nil)?fv:[NSNull null] forKey:JB_FV];
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    [dictonary setObject:[NSString stringNotNilWithValue:empId] forKey:JB_ACCOUNT];
    [dictonary setObject:[NSString stringNotNilWithValue:fc] forKey:JB_INDEX];
    NSString *sysTime = [WSCurrentTime getTimeString];
    [dictonary setObject:[NSString stringNotNilWithValue:sysTime] forKey:JB_SYNCTIME];
    NSString *sysDate = [WSCurrentTime getDateString];
    [dictonary setObject: [NSString stringNotNilWithValue:sysDate] forKey:JB_SYNCDATE];
    [JSONBuilder updateBizDateToDic:dictonary withStoreId:storeId];
    [dictonary setObject:(storeId !=nil)?storeId:[NSNull null] forKey:JB_STORE];
    [dictonary setObject:@"1" forKey:JB_ISUSABLE];
    return dictonary;
}

+ (NSDictionary *)buildBasicJsonDatabyFc:(NSString *)fc 
                                      fv:(NSString *)fv
                                 storeId:(NSString *)storeId
{
    
    // modify at 2013 12 - 25
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    [dictionary setObject:[NSString stringNotNilWithValue:fc] forKey:JB_METHOD];
    [dictionary setObject:@"0" forKey:JB_ISSYNC];
    [dictionary setObject:(fv !=nil)?fv:[NSNull null] forKey:JB_FV];
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    [dictionary setObject:[NSString stringNotNilWithValue:empId] forKey:JB_ACCOUNT];
    [dictionary setObject:[NSString stringNotNilWithValue:fc] forKey:JB_INDEX];
    NSString *sysDate = [WSCurrentTime getDateString];
    [dictionary setObject:[NSString stringWithValue:sysDate] forKey:JB_SYNCDATE];
    [JSONBuilder updateBizDateToDic:dictionary withStoreId:storeId];
    [dictionary setObject:(storeId !=nil)?storeId:[NSNull null] forKey:JB_STORE];
    [dictionary setObject:@"1" forKey:JB_ISUSABLE];
    return dictionary;
}



//进出店json
+ (NSString *)buildEnterLeaveStorebyFuncs:(WSFuncsBean *)func
                                  isPhoto:(BOOL)isPhoto 
                                      Store:(WSStoreBean*)aStore
                                 jsonData:(NSDictionary *)jsonData
                                      md5:(NSString *)md5 {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970]*1000;
    
    
    NSMutableDictionary *enterleave = [[NSMutableDictionary alloc]init];
    [enterleave setObject:[NSString stringNotNilWithValue:func.fc] forKey:JB_METHOD];
    [enterleave setObject:[NSString stringNotNilWithValue:md5] forKey:JB_ID];
    [enterleave setObject:@"0" forKey:JB_ISSYNC];
    if ([aStore isKindOfClass:[WSStoreBean class]]) {
        NSNumber* isPlan = [NSNumber numberWithInt:aStore.plan];
        [enterleave setObject:[NSString stringNotNilWithValue:[isPlan stringValue]] forKey:JB_ISPLAN];
    }
    
    if (isPhoto) {
        NSString *photosIndex = [NSString stringWithFormat:@"%@_%@_%@", func.fc, func.fv, md5];
        [enterleave setObject:photosIndex forKey:JB_PHOTOSINDEX];
        [enterleave setObject:photosIndex forKey:JB_IMAGEINDEX];
    }else {
        [enterleave setObject:@"" forKey:JB_PHOTOSINDEX];
        [enterleave setObject:@"" forKey:JB_IMAGEINDEX];
    }
    
    [enterleave setObject:[NSString stringNotNilWithValue:func.fv] forKey:JB_FV];
    [enterleave setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:JB_ACCOUNT];
    [enterleave setObject:@"normal" forKey:JB_FUNCSTYPE];
    [enterleave setObject:[NSString stringNotNilWithValue:func.fv] forKey:JB_INDEX];
    [enterleave setObject:[WSCurrentTime getTimeStringbyMills:time] forKey:JB_SYNCTIME];
    [enterleave setObject:[NSNull null] forKey:JB_SRID];
    [enterleave setObject:[NSString stringNotNilWithValue:aStore.Id] forKey:JB_STORE];
    [enterleave setObject:jsonData forKey:JB_JSONDATA];
    [enterleave setObject:@"1" forKey:JB_ISUSABLE];
    [enterleave setObject:[WSCurrentTime getTimeMillisString] forKey:JB_MOBILECLICKTIME];
    
    id serverRequire = [WSAppData getObjectbyKey:SERVERREQUIRE];
    if (serverRequire)
    {
        [enterleave setObject:serverRequire  forKey:SERVERREQUIRE];
    }

    [enterleave setObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE] forKey:JB_SYNCDATE];
    if (aStore && aStore.Id && [[WSCustomTimeTable sharedTable] isCustomTimeWithStoreId:aStore.Id withNeedNoLeaveStore:NO withVisitId:md5]) {
        NSArray *array = [[WSCustomTimeTable sharedTable] queryCustomDateAndTimeWithStoreId:aStore.Id withNeedNoLeaveStore:NO withVisitId:md5];
        if (array) {
            [enterleave setObject:[array objectAtIndex:0] forKey:JB_SYNCDATE];
            [enterleave setObject:[array objectAtIndex:1] forKey:JB_ENTRYTIME];
            [enterleave setObject:[NSNumber numberWithBool:YES] forKey:JB_ISDATAENTRY];
        }
    }
    
    if ([aStore isKindOfClass:[WSStoreBean class]]) {
        if (aStore.sv) {
            [enterleave setObject:[NSDictionary dictionaryWithObject:[NSString stringNotNilWithValue:aStore.sv] forKey:@"sv"] forKey:JB_HIDVAL];
        }
    } 
    
    if ([aStore isKindOfClass: [WSStoreBean class]]) {
        
        if (aStore.storeAccessMode == WSStoreAccessModeSubEmp) {
            if (aStore.srid && [aStore.srid length] > 0) {
                [enterleave setValue:aStore.srid forKey:JB_SRID];
            }
            else if (aStore.orgId && [aStore.orgId length] > 0)
            {
                [enterleave setValue:aStore.orgId forKey:JB_SRORGID];
            }
        }else{
            if (aStore.srid && [aStore.srid length] > 0) {
                [enterleave setValue:aStore.srid forKey:JB_SRID];
            }
            else if (aStore.orgId && [aStore.orgId length] > 0)
            {
                [enterleave setValue:aStore.orgId forKey:JB_SRORGID];
            }
        
        }
    }
    
    return [enterleave JSONRepresentation];
}


+ (NSString*)buildUnleavedStore:(WSInoutStoreObject*)inOutStoreObj srid:(NSString*)srid
{
    if (!inOutStoreObj) {   return nil; }
    NSMutableDictionary  *uploadDic = [[NSMutableDictionary alloc] initWithCapacity:6];
    // 协访者ID
    [uploadDic setObject:[NSString stringNotNilWithValue:srid] forKey:@"srid"];
    
    [uploadDic setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] forKey:@"account"];
    [uploadDic setObject:[NSString stringNotNilWithValue:[inOutStoreObj biz_date]] forKey:@"syncDate"];
    [uploadDic setObject:[NSString stringNotNilWithValue:[inOutStoreObj func_code]] forKey:@"index"];
    [uploadDic setObject:[NSString stringNotNilWithValue:@"UN_LEAVE_STORES"] forKey:@"method"];
    [uploadDic setObject:[NSString stringNotNilWithValue:[inOutStoreObj store_id]] forKey:@"storeId"];
    
    return [uploadDic JSONRepresentation];
}

//
+ (NSString * )gen_uuid
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    
    LogInfo(@"gen_uuid:%@", uuid);
    return uuid;
}

+ (NSDictionary *)buildImageParamsDicByImageID:(NSString *)imageID
{

    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    NSString *imageIDString = imageID;
    if (!imageIDString) {
        imageIDString = [JSONBuilder gen_uuid];
    }
    
    [params setObject:imageIDString forKey:@"photo"];
    NSString *photoTmp = [[NSString md5:imageIDString] lowercaseString];
    if (photoTmp) {
        [params setObject:photoTmp forKey:@"photoKey"];
    }
    [params setObject:@"0" forKey:JB_ISSYNC];
    [params setObject:@"1" forKey:JB_SAVEFLAG];
    [params setObject:@"F_PHOTO" forKey:JB_INDEX];
    [params setObject:[WSCurrentTime getTimeString] forKey:JB_SYNCTIME];
    
    return params;
}

#warning 1
+ (NSDictionary *)buildDelImageParamsDicByImageID:(NSString *)imageID withImgIdx:(NSString*)imgIdx
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    NSString *imageIDString = imageID;
    if (!imageIDString) {
        imageIDString = [JSONBuilder gen_uuid];
    }
    
    [params setObject:@"deletePhoto" forKey:JB_METHOD];
    [params setObject:imgIdx forKey:@"imageIndex"];
    NSString *photoTmp = [[NSString md5:imageIDString] lowercaseString];
    if (photoTmp) {
        [params setObject:photoTmp forKey:@"photoKey"];
    }
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    [params setObject:empId forKey:@"empId"];
    [params setObject:[WSCurrentTime getDateString] forKey:JB_SYNCDATE];
    [params setObject:[WSCurrentTime getTimeMillisString] forKey:JB_MOBILECLICKTIME];
    
    return params;
}

+ (NSDictionary *)buildImageParamsDicByImageID:(NSString *)imageID
                                  andImageType:(NSString *)imageType
{
    
    NSString *imageIDString = imageID;
    if (!imageIDString) {
        imageIDString = [JSONBuilder gen_uuid];
    }
    
    NSDictionary *params = @{JB_PHOTOTYPE: imageType, @"photo":imageIDString};//JB_ID
    
    return params;
}

+ (NSDictionary *)buildImageParamsDicByImageID:(NSString *)imageID
                                andPhotoTypeId:(NSString *)photoTypeId
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:7];
    
    NSString *imageIDString = imageID;
    if (!imageIDString) {
        imageIDString = [JSONBuilder gen_uuid];
    }
    
    [params setObject:imageIDString forKey:@"photo"]; //JB_ID
    NSString *photoTmp = [[NSString md5:imageIDString] lowercaseString];
    if (photoTmp) {
        [params setObject:photoTmp forKey:@"photoKey"];
    }
    [params setObject:@"0" forKey:JB_ISSYNC];
    [params setObject:@"1" forKey:JB_SAVEFLAG];
    [params setObject:@"F_PHOTO" forKey:JB_INDEX];
    [params setObject:photoTypeId forKey:@"photoType"];
    [params setObject:[WSAppData getObjectbyKey:SERVERREQUIRE] forKey:SERVERREQUIRE];
    [params setObject:[WSCurrentTime getTimeString] forKey:JB_SYNCTIME];
    
    return params;
}

+ (NSString *)buildbuildAttendancebyFuncs:(WSFuncsBean *)func
                                     cols:(NSArray *)cols
                                    datas:(NSArray *)datas
                                  dataIDs:(NSArray *)dataIDs
                                dateBegin:(NSString *)dateBegin
                                  dateEnd:(NSString *)dateEnd
                                     memo:(NSString *)memo
                                      md5:(NSString *)md5 {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] 
                                        init];
    
    for (int i = 0; i < [datas count]; i++) {
        NSArray *rows = [datas objectAtIndex:i];
        
        NSMutableDictionary *celldic = [[NSMutableDictionary alloc] 
                                        init];
        [celldic setObject:[NSString stringNotNilWithValue:
                            [dataIDs objectAtIndex:i]]
                    forKey:JB_ID];
        
        for (int j = 1; j < [rows count]; j++) {
            UIButton *btn = (UIButton *)[rows objectAtIndex:j];
            [celldic setObject:[NSString stringWithFormat:@"%d",
                                [btn isSelected]]//[NSNumber numberWithInt:[btn isSelected]]
                        forKey:[NSString stringNotNilWithValue:
                                ((WSDictBean *)[cols objectAtIndex:j-1]).Id]];
        }
        
        [mutableArray addObject:celldic];
    }
    
    NSMutableDictionary *jsonData = [[NSMutableDictionary alloc] 
                                     init];
    
    [jsonData setObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE]
                 forKey:JB_DATE];
    if (memo) {
        [jsonData setObject:memo forKey:JB_MEMO];
    }
    
    
    [jsonData setObject:mutableArray
                 forKey:JB_TABLE];
    
    [jsonData setObject:[NSString stringNotNilWithValue:dateBegin]
                 forKey:JB_DATEBEGIN];
    
    [jsonData setObject:[NSString stringNotNilWithValue: dateEnd]
                 forKey:JB_DATEEND];
    
    NSDictionary *basicDic = [JSONBuilder buildBasicJsonDatabyFc:func.fc
                                                              fv:func.fv
                                                         storeId:@"NULL"
                                                          isPlan:NO];
    
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] 
                                initWithDictionary:basicDic];
    [ret setObject:jsonData forKey:JB_JSONDATA];
    
    [ret setObject:[WSCurrentTime getTimeMillisString] forKey:JB_PHONETIME];
    [ret setObject:@"NULL" forKey:JB_SRID];
    [ret setObject:[NSString stringNotNilWithValue:
                    [WSAppData getObjectbyKey:APPDATA_TIMEMS]]
            forKey:JB_LOGINTIME];
    [ret setObject:[WSCurrentTime getTimeMillisString]
            forKey:JB_HIDVAL];
    
       return [ret JSONRepresentation];
}


+(NSString *)buildMSG
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    [ret setObject:@"msgs" forKey:@"objId"];
    [ret setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    return [ret JSONRepresentation];
}

+ (NSString *)buildQueryMsg {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    
    [ret setObject:@"msgsQuery" forKey:@"objId"];
    id timeUpdate =[[NSUserDefaults standardUserDefaults] objectForKey:APPDATA_TIME_UPDATE];
    if ([timeUpdate isKindOfClass:[NSNumber class]]) {
        timeUpdate = [timeUpdate   stringValue];
    }
    [ret setObject: [NSString stringNotNilWithValue:timeUpdate] forKey:APPDATA_TIME_UPDATE];
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    [ret setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    return [ret JSONRepresentation];
}

+(NSString*)buildWorkReportbyFuncs:(WSFuncsBean*)func
                              Data:(NSArray*)datas
{

    NSMutableDictionary* postDictionary = [[NSMutableDictionary alloc]init];
    //method
    [postDictionary setObject:func.fc forKey:@"method"];
    //id
    NSString* empIdValue = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString* syncDateValue = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSString* idValue = [NSString stringWithFormat:@"%@%@%@",func.fc,empIdValue,syncDateValue];
    NSString* idValueMD5 = [NSString md5:idValue];
    [postDictionary setObject:idValueMD5 forKey:@"id"];
    //isSync
    NSNumber* isSync = [NSNumber numberWithInt:0];
    [postDictionary setObject:isSync forKey:@"isSync"];
    //fv
    [postDictionary setObject:func.fv forKey:@"fv"];
    //phoneTime
    [postDictionary setObject:[WSCurrentTime getTimeMillisString] forKey:@"phoneTime"];
    //account
    [postDictionary setObject:empIdValue forKey:@"account"];
    //funcsTyp
    [postDictionary setObject:@"normal" forKey:@"funcsTyp"];
    //index
    [postDictionary setObject:func.fc forKey:@"index"];
    //imei
    [postDictionary setObject:@"no imei" forKey:@"imei"];
    //syncTime
    [postDictionary setObject:[WSCurrentTime getTimeString] forKey:@"syncTime"];
    //syncDate
    [postDictionary setObject:[WSCurrentTime getDateString] forKey:@"syncDate"];
    //jsonData
    NSMutableDictionary* jsonDataDictionary = [[NSMutableDictionary alloc]init ];
   
    UITextField* f = nil;
    UITextView* tv = nil;;
    for(id data in datas)
    {
        if([data isKindOfClass:[UITextField class]])
        {
            f = data;
        }
        if([data isKindOfClass:[UITextView class]])
        {
            tv = data;
        }
    }
    
    [jsonDataDictionary setObject:tv.text forKey:@"cont"];
    if([f.text length]==0)
        [jsonDataDictionary setObject:@"" forKey:@"title"];
    else
        [jsonDataDictionary setObject:f.text forKey:@"title"];
    
    [jsonDataDictionary setObject:[datas objectAtIndex:1] forKey:@"reportToType"];
    
    [postDictionary setObject:[jsonDataDictionary JSONRepresentation] forKey:@"jsonData"];
    //store
    [postDictionary setObject:idValueMD5 forKey:@"store"];
    //hidVal
    [postDictionary setObject:[WSCurrentTime getTimeMillisString] forKey:@"hidVal"];
    //isUsableness
    NSNumber* isUsableness = [NSNumber numberWithInt:1];
    [postDictionary setObject:isUsableness forKey:@"isUsableness"];

    //loginTime
    [postDictionary setObject:[WSAppData getObjectbyKey:APPDATA_TIMEMS] forKey:@"loginTime"];
    
    return [postDictionary JSONRepresentation];
}

+(NSString*)buildCommentWithContent:(NSString*)aContent
                              MSGID:(NSString*)aMsgId
                          Receivers:(NSArray*)aReceives
{
        
    NSDictionary* l_hidVal = [NSDictionary dictionaryWithObject:aMsgId forKey:@"msgsId"];
    NSMutableDictionary *l_JSON = [[NSMutableDictionary alloc]init];
    [l_JSON setObject:@"0" forKey:@"isSync"];
    [l_JSON setObject:[WSCurrentTime getDateString] forKey:@"syncDate"];
    [l_JSON setObject:[WSAppData getObjectbyKey:APPDATA_TIMEMS] forKey:@"loginTime"];
    [l_JSON setObject:@"NOTICE_READED" forKey:@"index"];
    [l_JSON setObject:[WSCurrentTime getTimeString] forKey:@"syncTime"];
    [l_JSON setObject:@"NULL" forKey:@"fv"];
    [l_JSON setObject:@"NULL" forKey:@"store"];
    [l_JSON setObject:@"no imei" forKey:@"imei"];
    [l_JSON setObject:[NSDictionary dictionaryWithObject:aContent forKey:@"reply"] forKey:@"jsonData"];
    [l_JSON setObject:[WSAppData getObjectbyKey:APPDATA_TIMEMS] forKey:@"phoneTime"];
    [l_JSON setObject:@"normal" forKey:@"funcsTyp"];
    [l_JSON setObject:l_hidVal forKey:@"hidVal"];
    [l_JSON setObject:@"1" forKey:@"isUsableness"];
    [l_JSON setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"account"];
    [l_JSON setObject:@"NOTICE_READED" forKey:@"method"];
    [l_JSON setObject:@"NULL" forKey:@"isPlan"];
    if (aReceives != nil) {
        [l_JSON setObject:aReceives forKey:@"receivers"];
    }
    
    return [l_JSON JSONRepresentation];
}
+(NSString*)buildCommentWithContent:(NSString*)aContent
                              MSGID:(NSString*)aMsgId
                          Receivers:(NSArray*)aReceives
                           AcvtData:(NSString *)aAcvtData
{
    
    NSDictionary* l_hidVal = [NSDictionary dictionaryWithObject:aMsgId forKey:@"msgsId"];

    NSMutableDictionary *l_JSON = [[NSMutableDictionary alloc]init];
    [l_JSON setObject:@"0" forKey:@"isSync"];
    [l_JSON setObject:[WSCurrentTime getDateString] forKey:@"syncDate"];
    [l_JSON setObject:[WSAppData getObjectbyKey:APPDATA_TIMEMS] forKey:@"loginTime"];
    [l_JSON setObject:@"NOTICE_READED" forKey:@"index"];
    [l_JSON setObject:[WSCurrentTime getTimeString] forKey:@"syncTime"];
    [l_JSON setObject:@"NULL" forKey:@"fv"];
    [l_JSON setObject:@"NULL" forKey:@"store"];
    [l_JSON setObject:@"no imei" forKey:@"imei"];
    [l_JSON setObject:[NSDictionary dictionaryWithObject:aContent forKey:@"回复"] forKey:@"jsonData"];
    [l_JSON setObject:[WSAppData getObjectbyKey:APPDATA_TIMEMS] forKey:@"phoneTime"];
    [l_JSON setObject:@"normal" forKey:@"funcsTyp"];
    [l_JSON setObject:l_hidVal forKey:@"hidVal"];
    [l_JSON setObject:@"1" forKey:@"isUsableness"];
    [l_JSON setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"account"];
    [l_JSON setObject:@"NOTICE_READED" forKey:@"method"];
    [l_JSON setObject:@"NULL" forKey:@"isPlan"];
    [l_JSON setObject:[NSString stringNotNilWithValue:aAcvtData] forKey:@"acvtData"];
    if (aReceives !=nil) {
        [l_JSON setObject:aReceives forKey:@"recceivers"];
    }
    return [l_JSON JSONRepresentation];
}

+(NSString*)buildGetPartnersCommentsWithID:(NSString*)aMsgId
{
    NSMutableDictionary *l_JSON = [[NSMutableDictionary alloc]init];
    [l_JSON setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [l_JSON setObject:@"msgreplies" forKey:@"objId"];
    [l_JSON setObject:[NSString stringNotNilWithValue:aMsgId] forKey:@"messId"];
    
    return [l_JSON JSONRepresentation];
}

+(NSString*)buildBackGroundGPSWithLocation:(WSLocationDescribe *)locationDescribe
{
    NSMutableDictionary *l_jsonDic = [NSMutableDictionary dictionary];
    
    if (locationDescribe.location) {
        [l_jsonDic setValue:@"wgs84" forKey:GPS_TYPE];
        [l_jsonDic setObject:[NSNumber numberWithDouble:locationDescribe.location.coordinate.longitude] forKey:GPS_LON];
        [l_jsonDic setObject:[NSNumber numberWithDouble:locationDescribe.location.coordinate.latitude] forKey:GPS_LAT];
        [l_jsonDic setValue:[NSString stringNotNilWithValue:locationDescribe.detailAddress] forKey:GPS_LOC_ADDR];
        [l_jsonDic setObject:[NSNumber numberWithDouble:locationDescribe.location.altitude] forKey:GPS_HEI];
        [l_jsonDic setObject:[NSNumber numberWithDouble:locationDescribe.location.horizontalAccuracy] forKey:GPS_HO];
        [l_jsonDic setObject:[NSNumber numberWithDouble:locationDescribe.location.verticalAccuracy] forKey:GPS_VO];
        [l_jsonDic setObject:[NSNumber numberWithDouble:locationDescribe.location.speed] forKey:GPS_S];
        [l_jsonDic setObject:[NSNumber numberWithDouble:locationDescribe.location.course] forKey:GPS_D];
        if (locationDescribe.location.timestamp) {
            [l_jsonDic setObject:[NSNumber numberWithDouble:ABS([locationDescribe.location.timestamp timeIntervalSince1970])] forKey:GPS_LOC_TIME];
            [l_jsonDic setObject:[NSNumber numberWithDouble:ABS([locationDescribe.location.timestamp timeIntervalSinceNow]) * 1000] forKey:GPS_CACHE_DURATION];
        }
    }
    NSString *enable_gps = [CLLocationManager locationServicesEnabled] ? @"1" : @"0";
    [l_jsonDic setObject:enable_gps forKey:GPS_ENABLE_GPS];
    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    switch (status) {
        case NotReachable:
        {
            [l_jsonDic setObject:@"0" forKey:NETWORK_VALID];
            [l_jsonDic setObject:@"0" forKey:NETWORK_ENABLE_MOBILE];
            [l_jsonDic setObject:@"0" forKey:NETWORK_ENABLE_WIFI];
            [l_jsonDic setObject:@"" forKey:NETWORK_TYPE];

        }
            break;
            
        case ReachableViaWiFi:
        {
            [l_jsonDic setObject:@"1" forKey:NETWORK_VALID];
            [l_jsonDic setObject:@"0" forKey:NETWORK_ENABLE_MOBILE];
            [l_jsonDic setObject:@"1" forKey:NETWORK_ENABLE_WIFI];
            [l_jsonDic setObject:@"WIFI" forKey:NETWORK_TYPE];
        }
            break;
            
        case ReachableViaWWAN:
        {
            [l_jsonDic setObject:@"1" forKey:NETWORK_VALID];
            [l_jsonDic setObject:@"1" forKey:NETWORK_ENABLE_MOBILE];
            [l_jsonDic setObject:@"0" forKey:NETWORK_ENABLE_WIFI];
            [l_jsonDic setObject:@"MOBILE" forKey:NETWORK_TYPE];
        }
            break;
            
        default:
            break;
    }
    

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if(l_jsonDic){
        [dict setObject:l_jsonDic forKey:@"jsonData"];
    }
    id empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    if(empid){
        if ([empid isKindOfClass:[NSNumber class]]) {
            empid = [empid stringValue];
        }
    } else {
        empid = @"-1";
    }
    [dict setObject:empid forKey:@"account"];
    
    id times = [WSAppData getObjectbyKey:APPDATA_TIMEMS];
    if(times){
        [dict setObject:times forKey:@"hidVal"];
    }
    NSString *dateString = [WSCurrentTime getDateString];
    if(dateString){
        [dict setObject:dateString forKey:@"syncDate"];
    }
    NSString *millTimeString = [WSCurrentTime getTimeMillisString];
    if(millTimeString){
        [dict setObject:millTimeString forKey:@"mobileClickTime"];
    }
    [dict setObject:@"F_VISIT_LOCATION" forKey:@"method"];
    return [dict JSONRepresentation];
}

+(NSString*)buildBeaconWithUUid:(NSString*)beaconUuid
                    withStoreId:(NSString*)storeId
{
    NSMutableDictionary *l_jsonDic = [NSMutableDictionary dictionary];
    
    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    switch (status) {
        case NotReachable:
        {
            [l_jsonDic setObject:@"0" forKey:@"netValid"];
            [l_jsonDic setObject:@"0" forKey:@"enable_mobile"];
            [l_jsonDic setObject:@"0" forKey:@"enable_wifi"];
        }
            break;
            
        case ReachableViaWiFi:
        {
            [l_jsonDic setObject:@"1" forKey:@"netValid"];
            [l_jsonDic setObject:@"0" forKey:@"enable_mobile"];
            [l_jsonDic setObject:@"1" forKey:@"enable_wifi"];
            [l_jsonDic setObject:@"WIFI" forKey:@"net_type"];
        }
            break;
            
        case ReachableViaWWAN:
        {
            [l_jsonDic setObject:@"1" forKey:@"netValid"];
            [l_jsonDic setObject:@"1" forKey:@"enable_mobile"];
            [l_jsonDic setObject:@"0" forKey:@"enable_wifi"];
            [l_jsonDic setObject:@"MOBILE" forKey:@"net_type"];
        }
            break;
            
        default:
            break;
    }

    if (beaconUuid) {
        [l_jsonDic setObject:beaconUuid forKey:@"uuId"];
    }
    
    if (storeId) {
        [l_jsonDic setObject:storeId forKey:@"storeId"];
    }
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if(l_jsonDic){
        [dict setObject:l_jsonDic forKey:@"jsonData"];
    }
    id empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    if(empid){
        if ([empid isKindOfClass:[NSNumber class]]) {
            empid = [empid stringValue];
        }
    } else {
        empid = @"-1";
    }
    [dict setObject:empid forKey:@"account"];
    
    NSString *dateString = [WSCurrentTime getDateString];
    if(dateString){
        [dict setObject:dateString forKey:@"syncDate"];
    }
    NSString *millTimeString = [WSCurrentTime getTimeMillisString];
    if(millTimeString){
        [dict setObject:millTimeString forKey:@"mobileClickTime"];
    }
    [dict setObject:@"F_VISIT_BEACON" forKey:@"method"];
    return [dict JSONRepresentation];
}

+(NSString*)buildSendSuggestionWithTitle:(NSDictionary*)aDiction;
{
    
    NSString* aMD5 = [aDiction objectForKey:@"suggestionMd5"];
    NSString* aTitle = [aDiction objectForKey:@"title"];
    NSString* aContent = [aDiction objectForKey:@"content"];
    NSString* aFC = [aDiction objectForKey:@"suggestionFc"];
    
    NSMutableArray* l_optArray =  [[NSMutableArray alloc]init];
    NSArray* postCardS = [aDiction objectForKey:@"receiver"];
    WSSugBeanArray* l_sugbeanArray = [WSAppData getObjectbyKey:SUG];
    
        for(WSSugBean* allsb in l_sugbeanArray.sugArray)
        {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
            BOOL flag =NO;
            for(WSSugBean* sb in postCardS)
            {
                if([sb.m_name isEqualToString:allsb.m_name])
                {
                    [dic setObject:sb.m_pk forKey:@"receiverId"];
                    [dic setObject:@"1" forKey:@"opt"];
                    flag = YES;
                    break;
                }
            }
            if(!flag)
            {
                [dic setObject:allsb.m_pk forKey:@"receiverId"];
                [dic setObject:@"0" forKey:@"opt"];
            }
            
            [l_optArray addObject:dic];
        }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"senderId"];
    [dictionary setObject:[NSString stringNotNilWithValue:aMD5] forKey:@"messageId"];
    [dictionary setObject:[NSString stringNotNilWithValue:aTitle] forKey:@"title"];
    [dictionary setObject:[NSString stringNotNilWithValue:aContent] forKey:@"message"];
    [dictionary setObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE] forKey:@"syncDate"];
    [dictionary setObject:[NSString stringNotNilWithValue:aFC] forKey:@"method"];
    [dictionary setObject:[l_optArray JSONRepresentation] forKey:@"receiver"];
    return [dictionary JSONRepresentation];

}

+(NSString*)buildSendSuggestionReplay:(NSDictionary*)aDiction SUGs:(WSSugReplyBeanArray*)aSugBeanArray
{
    NSString* aMD5 = [aDiction objectForKey:@"suggestionMd5"];
    NSString* aContent = [aDiction objectForKey:@"content"];
    
    NSMutableArray* l_optArray =  [[NSMutableArray alloc]init];
    NSArray* postCardS = [aDiction objectForKey:@"receiver"];
    
    for(WSSugReplyOptBean* allsb in aSugBeanArray.optArray)
    {
        NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
        BOOL flag =NO;
        for(WSSugReplyOptBean* sb in postCardS)
        {
            if([sb.m_name isEqualToString:allsb.m_name])
            {
                [dic setObject:sb.m_pk forKey:@"receiverId"];
                [dic setObject:@"1" forKey:@"opt"];
                flag = YES;
                break;
            }
        }
        if(!flag)
        {
            [dic setObject:allsb.m_pk forKey:@"receiverId"];
            [dic setObject:@"0" forKey:@"opt"];
        }
        
        [l_optArray addObject:dic];
    }
    

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"senderId"];
    [dictionary setObject:[NSString stringNotNilWithValue:aMD5] forKey:@"messageId"];
    [dictionary setObject:[NSString stringNotNilWithValue:aContent] forKey:@"message"];
    [dictionary setObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE] forKey:@"syncDate"];
    [dictionary setObject:@"saveSugReply" forKey:@"method"];
    [dictionary setObject:[l_optArray JSONRepresentation] forKey:@"receiver"];
    return  [dictionary JSONRepresentation];
}


+(NSString*)buildGetSuggestionTitleAndContent
{
    NSMutableDictionary *l_JSON = [NSMutableDictionary dictionary];
    [l_JSON setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [l_JSON setObject:@"mysuggestionlist" forKey:@"objId"];
    return [l_JSON JSONRepresentation];
}

+(NSString*)buildGetSuggestionReplyListWithMsgId:(NSString*)aMsgId
{
    NSMutableDictionary *l_JSON = [NSMutableDictionary dictionary];
    [l_JSON setObject:[NSString stringNotNilWithValue:aMsgId] forKey:@"messageId"];
    [l_JSON setObject:@"suggestioninfo" forKey:@"objId"];
    [l_JSON setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    
    return [l_JSON JSONRepresentation];
}


+(NSString*)buildModifyStoreInfo:(NSDictionary*)aDic
                           Store:(WSStoreBean*)aStore
{
    NSString* l_md5 = [NSString md5:[aDic JSONRepresentation]];
    NSMutableDictionary *dictioanry = [NSMutableDictionary dictionary];
    [dictioanry setObject:@"F_STORE_INFO" forKey:@"method"];
    [dictioanry setObject:[NSString stringNotNilWithValue:l_md5] forKey:@"id"];
    [dictioanry setObject:@"0" forKey:@"isSync"];
    [dictioanry setObject:@"1" forKey:@"isPlan"];
    [dictioanry setObject:@"V_STORE_INFO" forKey:@"fv"];
    [dictioanry setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"account"];
    [dictioanry setObject:@"normal" forKey:@"funcsTyp"];
    [dictioanry setObject:@"F_STORE_INFO" forKey:@"index"];
    [dictioanry setObject:@"no imei" forKey:@"imei"];
    [dictioanry setObject:[WSCurrentTime getDateString] forKey:@"syncDate"];
    [dictioanry setObject:[WSCurrentTime getTimeMillisString] forKey:@"mobileClickTime"];
    [dictioanry setObject:[aDic JSONRepresentation] forKey:@"jsonData"];
    [dictioanry setObject:[NSString stringNotNilWithValue:aStore.Id] forKey:@"store"];
    [dictioanry setObject:[WSCurrentTime getTimeMillisString] forKey:@"hidVal"];
    [dictioanry setObject:@"1" forKey:@"isUsableness"];
    [dictioanry setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    return [dictioanry JSONRepresentation];
}

+ (NSString *)buildDictDetailbyFuncs:(WSFuncsBean *)func
                             isPhoto:(BOOL)isPhoto
                               datas:(NSArray *)datas
                             dataIDs:(NSArray *)dataIDs
                               Store:(WSStoreBean *)aStore
                                 md5:(NSString *)md5
                                memo:(NSString *)memo
                           otherInfo:(NSDictionary *)aDicOtherInfo{
    return [JSONBuilder buildDictDetailbyFc:func.fc
                                         fv:func.fv
                                     params:func.paramArray
                                    isPhoto:isPhoto
                                      datas:datas
                                    dataIDs:dataIDs
                                      Store:aStore
                                        md5:md5
                                       memo:memo
                                  otherInfo:aDicOtherInfo];
}

+ (NSString *)buildDictDetailbyFc:(NSString *)fc
                               fv:(NSString *)fv
                           params:(NSArray *)aParamArray
                          isPhoto:(BOOL)isPhoto
                            datas:(NSArray *)datas
                          dataIDs:(NSArray *)dataIDs
                            Store:(WSStoreBean *)aStore
                              md5:(NSString *)md5
                             memo:(NSString *)memo
                        otherInfo:(NSDictionary *)aDicOtherInfo
{
    
    return [JSONBuilder buildDictDetailbyFc:fc
                                         fv:fv
                                     params:aParamArray
                                    isPhoto:isPhoto
                                      datas:datas
                                    dataIDs:dataIDs
                                      Store:aStore
                                        md5:md5
                                       memo:memo
                                    acvtMD5:nil
                                  otherInfo:aDicOtherInfo];
}

+ (NSString *)buildDictDetailbyFc:(NSString *)fc
                               fv:(NSString *)fv
                           params:(NSArray *)aParamArray
                          isPhoto:(BOOL)isPhoto
                            datas:(NSArray *)datas
                          dataIDs:(NSArray *)dataIDs
                            Store:(WSStoreBean *)aStore
                              md5:(NSString *)md5
                             memo:(NSString *)memo
                          acvtMD5:(NSString *)acvtMD5
                        otherInfo:(NSDictionary *)aDicOtherInfo
{
    int iMax = [datas count];
    
    // cailei stepwolf
    if ([[datas lastObject] isKindOfClass:[NSDictionary class]]){
        iMax--;
    }
    int jMax = [aParamArray count];
    
    NSMutableArray *comparray = [[NSMutableArray alloc] initWithCapacity:iMax];
    
    for (int i = 0; i < iMax; i++) {
        if (i > ([datas count] - 1)) {
            continue;
        }
        NSArray *subdatas = [datas objectAtIndex:i];
        if (i > ([dataIDs count] - 1)) {
            continue;
        }
        WSDictBean *dictBean=[dataIDs objectAtIndex:i];
       
        if ([subdatas isKindOfClass:[NSArray class]]){
            NSMutableDictionary *celldic = [[NSMutableDictionary alloc]
                                            initWithCapacity:[aParamArray count]];
            
            [celldic setObject:dictBean.Id forKey:@"dictId"];
            
            for (int j = 0; j < jMax; j++)
            {
                if (j+1 > ([subdatas count] - 1)) {
                    continue;
                }
                id obj = [subdatas objectAtIndex:j+1];
                if (j > ([aParamArray count] - 1)) {
                    continue;
                }
                
                WSFuncsBean_Param *aParam = (WSFuncsBean_Param *)[aParamArray objectAtIndex:j];
                // ids配置的数据不回传服务端
                if (aParam.ids
                    && [aParam.ids length] > 0
                    && aParam.readonly) {
                    continue;
                }
                NSString *key = aParam.col;
                if ([obj isKindOfClass:[UITextField class]]) {
                    NSString *value = (((UITextField *)obj).text);//?((UITextField *)o).text:((UITextField *)o).placeholder;
                    WSHTextField *currentTextField = (WSHTextField *)obj;
                    
                    // 检查进行输入动作的文本框的value是否包含 计划外搜索的数字
                    // 若包含 则重置为空
                    if (!currentTextField.isValueChange) {
                        NSUserDefaults *saveUserDefault = [NSUserDefaults standardUserDefaults];
                        NSMutableString *saveString = [saveUserDefault objectForKey:@"WSCustomQuerySearchString"];
                        NSArray *saveArray = [saveString componentsSeparatedByString:@","];
                        for (NSString *string  in  saveArray) {
                            if (string && value && [string isEqualToString:value]) {
                                value = @"";
                                break;
                            }
                        }
                        [saveUserDefault synchronize];
                    }
                    
                    if(value==nil){
                        [celldic setObject:@"" forKey:key];
                    }else {
                        [celldic setObject:value forKey:key];
                    }
                    
                }else if([obj isKindOfClass:[WSCheckBox class]]){
                    
                    NSNumber *value = [NSNumber
                                       numberWithInt:[(UIButton *)obj isSelected]];
                    
                    [celldic setObject:value.stringValue forKey:key];
                }else if([obj isKindOfClass:[WSRadioButton class]]){
                    
                    NSNumber *value = [NSNumber
                                       numberWithInt:[(UIButton *)obj isSelected]];
                    
                    [celldic setObject:value forKey:key];
                    NSLog(@"%@",[celldic description]);
                }else if( [obj isKindOfClass:[WSSelectListView class]] )
                {
//                    WSSelectListView *list = (WSSelectListView *)obj;
//                    if (list.selectedIndex > ([list.content count] - 1)) {
//                        continue;
//                    }
//                    NSString *value = [NSString string];
//                    if(list.selectedIndex>-1){
//                        value= [list.content objectAtIndex:list.selectedIndex];
//                    }
//                    [celldic setObject:value forKey:key];
                    WSSelectListView *list = (WSSelectListView *)obj;
                    NSArray *valueArray = nil;
                    
                    if (list.selectMode == WSSelectListViewSelectModeSingleSelection) {
                        NSString *value = [NSString string];
                        if(list.selectedIndex>-1){
                            value = [list.content objectAtIndex:list.selectedIndex];
                            valueArray = [NSArray arrayWithObject:value];
                        }
                    }
                    else if (list.selectMode == WSSelectListViewSelectModeMultipleChoice) {
                        valueArray = [[list getSelectedContentString] componentsSeparatedByString:@","];
                    }
                    
                    WSDictBeanArray* dbArray = [WSAppData getObjectbyKey:DICTS];
                    NSArray* filterArray = [dbArray getDictsWithFilter:aParam.filter];
                    NSMutableArray *dictIdArray = [NSMutableArray array];
                    for (NSString *value in valueArray) {
                        for (WSDictBean *db in filterArray)
                        {
                            if ([db.name isKindOfClass:[NSString class]] && [db.name isEqualToString:value]) {
                                [dictIdArray addObject:db.Id];
                                break;
                            }
                        }
                    }
                    
                    if ([dictIdArray count] > 0) {
                        [celldic setObject:[dictIdArray componentsJoinedByString:@","] forKey:key];
                    }
                    else if ([valueArray count] > 0) {
                        [celldic setObject:[valueArray componentsJoinedByString:@","] forKey:key];
                    }
                    
                }else if( [obj isKindOfClass:[WSMultipleChoiceLabel class]])
                {
                    WSMultipleChoiceLabel *lable = (WSMultipleChoiceLabel *)obj;
                    NSString *value = ((lable.iContent != nil) ? lable.iContent : @"");
                    [celldic setObject:value forKey:key];
                }else if ([obj isKindOfClass:[PhotoTypeButton class]]){
                    PhotoTypeButton *pbtn = (PhotoTypeButton *)obj;
                    NSString *imageMD5 = @"";
                    if ([pbtn isValueLegal]) {
                        imageMD5 = pbtn.imageMD5;
                    }
                    [celldic setObject:imageMD5 forKey:key];
                }else if([obj isKindOfClass:[WSDatePickerLabel class]]){
#warning WSDatePickerLabel
                    WSDatePickerLabel *dLab = (WSDatePickerLabel *)obj;
                    NSString *value = dLab.text;
                    value = value ? value : @"";
                    [celldic setObject:value forKey:key];
                }else{
                    // cailei : the round button for abnormal reason
                    NSDictionary *dic = [datas lastObject];
                    if ([dic isKindOfClass:[NSDictionary class]]) {
                        NSLog(@"%d", ((UIButton *)obj).tag);
                        
                        NSDictionary *jsondata = [dic objectForKey:[NSString stringWithFormat:@"%d", ((UIButton *)obj).tag]];
                        
                        if (jsondata) {
                            [celldic setObject:[jsondata JSONRepresentation] forKey:key];
                        }
                    }
                    
                }// end if
            }// end for
            celldic = [JSONBuilder removeNullValueWith:fc andDic:celldic];
            if (celldic) {
                [comparray addObject:celldic];
            }
        }// end if
    }   //end for
    //
    
    BOOL isPlan = ([aStore isKindOfClass:[WSStoreBean class]]) ? aStore.plan : YES;
    NSDictionary *basicJson = [JSONBuilder buildBasicJsonDatabyFc:fc
                                                               fv:fv
                                                          storeId:aStore.Id
                                                           isPlan:isPlan/*aStore.plan*/];
    
    NSMutableDictionary *ret = [[NSMutableDictionary alloc]
                                initWithDictionary:basicJson];
    
    [ret setObject:md5 forKey:JB_ID];
    
    NSString* photoIndex=[NSString stringWithFormat:@"%@_%@",fc,md5];
    if (isPhoto) {
        [ret setObject:photoIndex forKey:JB_IMAGEINDEX];
        [ret setObject:photoIndex forKey:JB_PHOTOSINDEX];
    }else{
        [ret setObject:@"" forKey:JB_IMAGEINDEX];
        [ret setObject:@"" forKey:JB_PHOTOSINDEX];
    }

    [ret setObject:@"normal" forKey:JB_FUNCSTYPE];
    [ret  setObject:[WSCurrentTime getTimeMillisString] forKey:JB_MOBILECLICKTIME];
    
    if (acvtMD5 != nil && [acvtMD5 length] > 0) {
        [ret setObject:acvtMD5 forKey:JB_SUBMITID];
    }
    

    if (memo==nil) {
        //        NSArray *array = [[NSArray alloc] init];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:comparray forKey:JB_PARAM];
        if (aDicOtherInfo != nil) {
            NSArray *keys = [aDicOtherInfo allKeys];
            for (NSString *key in keys) {
                NSString *value = [aDicOtherInfo objectForKey:key];
                [dic setObject:value forKey:key];
            }
        }
        [ret setObject:dic forKey:JB_JSONDATA];
    }
    else
    {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:comparray forKey:JB_PARAM];
        [dic setObject:[NSString stringNotNilWithValue:memo] forKey:JB_MEMO];
        if (aDicOtherInfo != nil) {
            NSArray *keys = [aDicOtherInfo allKeys];
            for (NSString *key in keys) {
                NSString *value = [aDicOtherInfo objectForKey:key];
                [dic setObject:value forKey:key];
            }
        }
        [ret setObject:dic forKey:JB_JSONDATA];
    }

    if (aStore.storeAccessMode == WSStoreAccessModeSubEmp) {
        if (aStore.srid && [aStore.srid length] > 0) {
            [ret setValue:aStore.srid forKey:JB_SRID];
        }
        else if (aStore.orgId && [aStore.orgId length] > 0)
        {
            [ret setValue:aStore.orgId forKey:JB_SRORGID];
        }
    }else{
        if ([aStore.srid isKindOfClass:[NSString class]]) {
            // 主管拜访时，所拜访门店的下属id
            [ret setValue:aStore.srid forKey:JB_SRID];
        }
    }

    
    return [ret JSONRepresentation];
}


+ (NSString *)buildDictDetailforPadbyFuncs:(WSFuncsBean *)func
                                   isPhoto:(BOOL)isPhoto
                                     datas:(NSArray *)datas
                                   dataIDs:(NSArray *)dataIDs
                                     Store:(WSStoreBean *)aStore
                                       md5:(NSString *)md5
                                      memo:(NSString *)memo
{
    int iMax = [datas count];
    int jMax = [func.paramArray count];
    
    NSMutableArray *comparray = [[NSMutableArray alloc]
                                 initWithCapacity:iMax];
    
    for (int i = 1; i < iMax; i++) {
        NSArray *subdatas = [datas objectAtIndex:i];
        WSDictBean *dictBean=[dataIDs objectAtIndex:i-1];
        if ([subdatas isKindOfClass:[NSArray class]]){
            NSMutableDictionary *celldic = [[NSMutableDictionary alloc]
                                            initWithCapacity:[func.paramArray count]];
            
            [celldic setObject:dictBean.Id forKey:@"dictId"];
            
            for (int j = 0; j < jMax; j++)
            {
                GridCell *cell= [subdatas objectAtIndex:j+1];
                NSString *key = ((WSFuncsBean_Param *)[func.paramArray objectAtIndex:j]).col;
                if (cell.type == EGridText || cell.type == EGridNumber)
                {
                    if (cell.value == nil)
                    {
                        [celldic setObject:@"" forKey:key];
                    }
                    else
                    {
                        [celldic setObject:cell.value forKey:key];
                    }
                }
                else if (cell.type == EGridCheckBox)
                {
                    [celldic setObject:cell.value forKey:key];
                }
             }// end for
            
            [JSONBuilder removeNullValueWith:func.fc andDic:celldic];

            [comparray addObject:celldic];
        }// end if
    }   //end for
    
    
    NSDictionary *basicJson = [JSONBuilder
                               buildBasicJsonDatabyFc:func.fc
                               fv:func.fv
                               storeId:aStore.Id
                               isPlan:aStore.plan];
    
    NSMutableDictionary *ret = [[NSMutableDictionary alloc]
                                 initWithDictionary:basicJson];
    
    if (aStore.storeAccessMode == WSStoreAccessModeSubEmp) {
        if (aStore.srid && [aStore.srid length] > 0) {
            [ret setValue:aStore.srid forKey:JB_SRID];
        }
    }
    
    [ret setObject:md5 forKey:JB_ID];
    [ret setObject:md5 forKey:JB_IMAGEINDEX];
    [ret setObject:md5 forKey:JB_PHOTOSINDEX];
    [ret setObject:@"normal" forKey:JB_FUNCSTYPE];
    [ret  setObject:[WSCurrentTime getTimeMillisString] forKey:JB_MOBILECLICKTIME];
    
    
    if (isPhoto) {
        [ret setObject:md5 forKey:JB_PHOTOSINDEX];
    }
    if (memo==nil) {
        [ret setObject:[NSDictionary
                         dictionaryWithObject:comparray forKey:JB_PARAM]
                forKey:JB_JSONDATA];
    }else{
        NSMutableDictionary *dictonary = [NSMutableDictionary dictionary];
        [dictonary setObject:comparray forKey:JB_PARAM];
        [dictonary setObject:[NSString stringNotNilWithValue:memo] forKey:JB_MEMO];
        [ret  setObject:dictonary forKey:JB_JSONDATA];
    }
    
    
    return [ret JSONRepresentation];
}


//三棵树 主管协防 计划外搜索
+ (NSString *)buildOutPlanOfHelpVistRequst:(NSDictionary *)aDic {
    NSMutableDictionary* l_dic = [[NSMutableDictionary alloc]init];
    [l_dic setObject:[NSString stringNotNilWithValue:[aDic objectForKey:@"empId"]] forKey:@"empId"];
    [l_dic setObject:[NSString stringNotNilWithValue:[aDic objectForKey:@"objId"]] forKey:@"objId"];
    [l_dic setObject:[NSString stringNotNilWithValue:[aDic objectForKey:@"name"]] forKey:@"name"];
    [l_dic setObject:@"no cellid" forKey:@"cellId"];
    [l_dic setObject:[NSString stringNotNilWithValue:[aDic objectForKey:@"compress"]] forKey:@"compress"];
    if ([aDic objectForKey:@"orgId"]) {
        [l_dic setObject:[NSString stringNotNilWithValue:[aDic objectForKey:@"orgId"]] forKey:@"orgId"];
    }
    return [l_dic JSONRepresentation];
}

+(NSString*)buildCustomerRequest:(NSDictionary*)aDic
{
    NSMutableDictionary* l_dic = [[NSMutableDictionary alloc]init];
    [l_dic setObject:[aDic objectForKey:@"empId"] forKey:@"empId"];
    [l_dic setObject:@"lowerlevelstore" forKey:@"objId"];
    [l_dic setObject:[aDic objectForKey:CQ_KEYWORD] forKey:@"keyWord"];
    return [l_dic JSONRepresentation];
}

+(NSString*)buildCustomerStoreRequest:(NSDictionary*)aDic
{
    return nil;
}

+(NSString*)buildMSGReceivers:(NSDictionary*)aDic
{
    NSMutableDictionary* l_dic =[[NSMutableDictionary alloc]init];
    [l_dic setObject:[aDic objectForKey:@"empId"] forKey:@"empId"];
    [l_dic setObject:[aDic objectForKey:@"msgId"] forKey:@"msgId"];
    [l_dic setObject:@"msgEmpList" forKey:@"objId"];
    return [l_dic JSONRepresentation];
}

+(NSString*)buildExceptionInfo:(NSDictionary*)aDic
{
    NSString* l_empId ;
    if([FileManager getUserDefaults:APPDATA_EMPID] == nil)
        l_empId = @"0";
    else
        l_empId = (NSString*)[FileManager getUserDefaults:APPDATA_EMPID];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSArray arrayWithObject:aDic] forKey:@"value"];
    [dictionary setObject:[WSCurrentTime getDateString] forKey:@"date"];
    [dictionary setObject:@"l" forKey:@"type"];
    [dictionary setObject:l_empId forKey:@"empId"];
    return [dictionary JSONRepresentation];
}
//add by wangdongyan 04-12 for 6200服务器路线管理
+ (NSString *)buildRoadsManagerRequest:(NSDictionary *)aDictionary
{

    NSMutableDictionary *roadDic = [NSMutableDictionary dictionaryWithCapacity:2];
    [roadDic addEntriesFromDictionary:aDictionary];
    [roadDic setObject:@"1" forKey:@"compress"];
    [roadDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    return [roadDic JSONString];

}

+ (NSString *)buildAllStoreScheduleRequest:(NSDictionary *)aDictionary
{
    NSMutableDictionary *roadDic=[[NSMutableDictionary alloc]init];
    [roadDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [roadDic setObject:[aDictionary objectForKey:@"month"] forKey:@"month"];
    [roadDic setObject:[aDictionary objectForKey:@"objId"] forKey:@"objId"];
    return [roadDic JSONRepresentation];
    
}

+ (NSString *)buildCalendarRequest:(NSDictionary *)aDictionary
{
    NSMutableDictionary *roadDic=[[NSMutableDictionary alloc]init];
    [roadDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [roadDic setObject:[aDictionary objectForKey:@"month"] forKey:@"month"];
    [roadDic setObject:[aDictionary objectForKey:@"year"] forKey:@"year"];
    [roadDic setObject:[aDictionary objectForKey:@"objId"] forKey:@"objId"];
    return [roadDic JSONRepresentation];
    
}
//上传拜访计划 
+ (NSString *)buildStoreScheduleData:(WSArrangeScheduleViewController *)vc {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:vc.currentFuncs.method forKey:JB_METHOD];
    [dic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:JB_ACCOUNT];
    [dic setObject:[WSCurrentTime getTimeMillisString] forKey:JB_MOBILECLICKTIME];
    [dic setObject:[WSAppData getObjectbyKey:SERVERREQUIRE] forKey:SERVERREQUIRE];
    
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    [dic setObject:[dateFormat stringFromDate:[NSDate date]] forKey:@"syncDate"];
    
    NSMutableDictionary *itemdic = [NSMutableDictionary dictionary];
    
    if([vc.currentFuncs.ds isEqualToString:STORE]){
        
        [itemdic setObject:[dateFormat stringFromDate:vc.currentSch.date] forKey:@"syncDate"];
        
        NSMutableString *storeids = [[NSMutableString alloc] init];
        
        for (WSStoreBean *store in vc.currentSch.tasks) {
            if (store.bPlanned) {
                [storeids appendString:[NSString stringWithFormat:@"%@,", store.Id]];
            }
        }
        if (storeids.length)
        {
            storeids = (NSMutableString *)[storeids substringToIndex:storeids.length - 1];
        }
        if(storeids.length>0){
            [itemdic setObject:storeids forKey:@"storeIds"];
        }else{
            [itemdic setObject:@"-1" forKey:@"storeIds"];
        }
        
    }else{
        
        [itemdic setObject:[dateFormat stringFromDate:vc.currentSch.date] forKey:@"docDate"];
        
        NSMutableString *orgIds = [[NSMutableString alloc] init];
        NSMutableString *empids = [[NSMutableString alloc] init];
        
        for (WSSubempstoreBean *bean in vc.currentSch.tasks) {
            if (bean.bPlanned) {
                [orgIds appendString:[NSString stringWithFormat:@"%@,", bean.orgId]];
                if(bean.Id){
                    [empids appendString:[NSString stringWithFormat:@"%@,", bean.Id]];
                }else{
                    [empids appendString:@"null,"];
                }
            }
        }
        if (orgIds.length)
        {
            orgIds = (NSMutableString *)[orgIds substringToIndex:orgIds.length - 1];
        }
        if (empids.length)
        {
            empids = (NSMutableString *)[empids substringToIndex:empids.length - 1];
        }
        [itemdic setObject:orgIds forKey:@"orgIds"];
        [itemdic setObject:empids forKey:@"empIds"];
    }
    
    NSMutableArray *scheduleArray = [[NSMutableArray alloc] init];
    [scheduleArray addObject:itemdic];
    [dic setValue:scheduleArray forKey:JB_JSONDATA];
    
    NSString *ret = [dic JSONRepresentation];
    
    return ret;
}




+ (NSString *)buildMarketActivityWithDic:(NSDictionary *)aDic acvtBean:(WSAcvtBean *)aBean functionBean:(WSFuncsBean *)aFuncsBean withMd5:(NSString *)aMd5
{

    NSDictionary* l_acvtId =[NSDictionary dictionaryWithObject:aBean.acvtId forKey:@"acvtId"];
    NSMutableDictionary *dicUpload = [NSMutableDictionary dictionary];
    [dicUpload setObject:@"0" forKey:JB_ISSYNC];
    [dicUpload setObject:[WSCurrentTime getDateString] forKey:JB_SYNCDATE];
    [dicUpload setObject:[NSString stringNotNilWithValue:aFuncsBean.fc] forKey:JB_INDEX];
    [dicUpload setObject:[NSString stringNotNilWithValue:aFuncsBean.fv] forKey:JB_FV];
    [dicUpload setObject:@"-1" forKey:JB_STORE];
    [dicUpload setObject:[WSCurrentTime getTimeMillisString] forKey:JB_MOBILECLICKTIME];
    [dicUpload setObject:@"no imei" forKey:JB_IMEI];
    [dicUpload setObject:[NSString stringNotNilWithValue:aMd5] forKey:JB_PHOTOSINDEX];
    [dicUpload setObject:aDic forKey:JB_JSONDATA];
    [dicUpload setObject:[NSString stringNotNilWithValue:aMd5] forKey:JB_ID];
    [dicUpload setObject:[WSAppData getObjectbyKey:SERVERREQUIRE] forKey:SERVERREQUIRE];
    [dicUpload setObject:aBean.acvtId forKey:JB_SRID];
    [dicUpload setObject:@"normal" forKey:JB_FUNCSTYPE];
    [dicUpload setObject:l_acvtId forKey:JB_HIDVAL];
    [dicUpload setObject:@"1" forKey:@"isUsableness"];
    [dicUpload setObject:[WSAppData getObjectbyKey:APPDATA_EMPID]forKey:JB_ACCOUNT];
    [dicUpload setObject:[NSString stringNotNilWithValue:aFuncsBean.fc] forKey:JB_METHOD];
    [dicUpload setObject:[NSNull null] forKey:JB_ISPLAN];
    [dicUpload setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];

    
    return [dicUpload JSONRepresentation];
}


+ (NSString *)buildPfizerBusinessStringWithDic:(NSDictionary *)aDic functionBean:(WSFuncsBean *)aFuncsBean withMd5:(NSString *)aMd5;

{
  
    NSDictionary *dic = [[NSDictionary alloc] init];
    NSMutableDictionary *dicUpload = [NSMutableDictionary dictionary];
    [dicUpload setObject:@"0" forKey:JB_ISSYNC];
    [dicUpload setObject:[WSCurrentTime getDateString] forKey:JB_SYNCDATE];
    [dicUpload setObject:[NSString stringNotNilWithValue:aFuncsBean.fc] forKey:JB_INDEX];
    [dicUpload setObject:[NSString stringNotNilWithValue:aFuncsBean.fv] forKey:JB_FV];
    [dicUpload setObject:[WSCurrentTime getTimeMillisString] forKey:JB_MOBILECLICKTIME];
    [dicUpload setObject:@"no imei" forKey:JB_IMEI];
    [dicUpload setObject:[NSString stringNotNilWithValue:aMd5] forKey:JB_PHOTOSINDEX];
    [dicUpload setObject:aDic forKey:JB_JSONDATA];
    [dicUpload setObject:[NSString stringNotNilWithValue:aMd5] forKey:JB_ID];
    [dicUpload setObject:[WSAppData getObjectbyKey:SERVERREQUIRE] forKey:SERVERREQUIRE];
    [dicUpload setObject:@"normal" forKey:JB_FUNCSTYPE];
    [dicUpload setObject:dic forKey:JB_HIDVAL];
    [dicUpload setObject:@"1" forKey:@"isUsableness"];
    [dicUpload setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:JB_ACCOUNT];
    [dicUpload setObject:[NSString stringNotNilWithValue:aFuncsBean.fc] forKey:JB_METHOD];
    [dicUpload setObject:[NSNumber numberWithBool:NO] forKey:JB_ISPLAN];
    [dicUpload setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    return [dicUpload JSONRepresentation];
    
}


+ (NSString *)buildSendRedMessageWithMsgId:(NSString *)aMsgId andNotifyName:(NSString *)aNotifyName andMD5:(NSString *)aMd5
{
    LogTrace();
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *syncDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:16];
    
    //isSync
    [dic setObject:[NSNumber numberWithInt:0] forKey:@"isSync"];
    [dic setObject:@"0" forKey:@"compress"];
    id obj = [WSAppData getObjectbyKey:SERVERREQUIRE];
    if (obj != nil) {
        [dic setObject:obj forKey:SERVERREQUIRE];
    }
    
    [dic setObject:[NSString stringNotNilWithValue:syncDate] forKey:@"syncDate"];
    [dic setObject:@"normal" forKey:@"funcsTyp"];
    [dic setObject:@"NOTICE_READED" forKey:@"index"];
    NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] initWithCapacity:8];
    [msgDic setObject:[NSString stringNotNilWithValue:aMsgId] forKey:@"msgsId"];
    [dic setObject:msgDic forKey:@"hidVal"];
    [dic setObject:[WSCurrentTime getTimeMillisString] forKey:@"mobileClickTime"];
    [dic setObject:[NSString stringNotNilWithValue:empId] forKey:@"account"];
    [dic setObject:@"NOTICE_READED" forKey:@"method"];
    [dic setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    
    NSString *strPost = [dic JSONRepresentation];
    return strPost;
}

+ (NSString *)buildAppQuitReport
{
    LogTrace();
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:8];
    NSObject *exitAppStatus = [FileManager getUserDefaults:EXIT_APP_STATUS_USERDEFAULT_KEY];
    NSObject *timestamp = [FileManager getUserDefaults:EXIT_APP_TIMESTAMP_USERDEFAULT_KEY];
    NSObject *versionCode = [FileManager getUserDefaults:EXIT_APP_VERSION_USERDEFAULT_KEY];
    NSObject *empId = [FileManager getUserDefaults:EXIT_APP_ACCOUNT_USERDEFAULT_KEY];
    NSObject *svnVersion = [FileManager getUserDefaults:EXIT_APP_AKU_USERDEFAULT_KEY];
    NSObject *syncDate = [FileManager getUserDefaults:EXIT_APP_SYNCDATE_USERDEFAULT_KEY];
    
    if (exitAppStatus
        && timestamp
        && versionCode
        && empId
        && svnVersion
        && syncDate) {
        
        [dic setObject:exitAppStatus forKey:@"exitAppStatus"];
        [dic setObject:timestamp forKey:@"id"];
        [dic setObject:syncDate forKey:@"syncDate"];
        [dic setObject:timestamp forKey:@"mobileClickTime"];
        [dic setObject:svnVersion forKey:@"AKU"];
        [dic setObject:empId forKey:@"account"];
        [dic setObject:@"APP_START" forKey:@"method"];
        [dic setObject:versionCode forKey:@"version"];
        
        NSString *jsonString = [dic JSONRepresentation];
        
        return jsonString;
    }
    
    return nil;
}


@end
