//
//  ProdGrideViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-23.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSProdGrideViewController.h"
#import "WSStoreBean_prod.h"
#import "WSProdBeanArray.h"
#import "WSProdBean.h"
#import "WSFuncsBean_Param.h"
#import "WSFptTable.h"
#import "WSCurrentTime.h"
#import "WSFuncsBean_opt.h"
#import "WSFuncsBean.h"
#import "MoreProductViewController.h"
#import "DataGridComponent.h"
#import "WSRequestHelper.h"
#import "WSJSONBuilder.h"
//#import "ConfigFileController.h"
#import "WSDictBean.h"
#import "WSDictBrand.h"
#import "WSSelectListView.h"
#import "UILabel+Additional.h"
#import "WSMultipleChoiceLabel.h"
#import "WSPhotoGalleryViewController.h"
#import <objc/runtime.h>
#import "PhotoTypeButton.h"
#import "WSAcvtButtonForTB.h"
#import "WSImagePathTable.h"
#import "WSFuncsBean_other.h"
#import "WSNavigationBar.h"
#import "WSDatePickerLabel.h"
#import "WSAcvtViewController.h"
#import "WSProductValidateBean.h"
#import "WSProductValidateBeanArray.h"

#import "WSBaseStoreProddisDBService.h"

#import "WSBaseProductDBService.h"

#import "WSEnvrionment.h"
#import "WSScanListViewController.h"
#import "WSBaseDictsDBService.h"
#import "WSQRTypeView.h"
#import "WSBaseStoreProdDisTable.h"
#import "WSNewAddProdsWithSeriesViewController.h"

#define RECEIVEMORE             @"receiveMoreProducts"

#define kAlertViewTagBase       850


#define kButtonGap    5.0f

const NSInteger kWSIndexInProductTable = 13;


@interface WSProdGrideViewController ()
{
    CGRect frameRect;
    BOOL _isFirstLoadView;
}

@property (nonatomic, strong) NSMutableDictionary *photoDic;
@property (nonatomic, strong) UIAlertView *datasChangeAlertView;
// 更多 扫描按钮
@property (nonatomic, strong) NSArray *productsList;

@property (nonatomic, strong) WSLuaScriptContext        *luaParserObj;

@property (nonatomic, assign) BOOL insertFptIsSucceed;

@property (nonatomic, assign) NSUInteger seacherSelectIndex;

@property (nonatomic, assign) CGFloat scrollViewChangeHeight;

@property (nonatomic, assign) CGFloat lastYPoint;

@property (nonatomic, assign) BOOL isMoreProdSelected;// 如果从更多产品中选择了产品，那么产品表格的值也属于改变


@property (nonatomic, assign) BOOL isAllProducts;
@property (nonatomic, strong) NSMutableArray    *lastAddMoreProductArray; // 上一次push过去的更多产品--保证更多产品删除后还能够添加
@end

@implementation WSProdGrideViewController
@synthesize moreProductArray;
@synthesize m_store_prod;
@synthesize iBrandId = _iBrandId;
-(NSMutableArray *)lastAddMoreProductArray{
    if (!_lastAddMoreProductArray) {
        _lastAddMoreProductArray = [[NSMutableArray alloc]init];
    }
    return _lastAddMoreProductArray;
}
-(void)insertProdDataWithIsAlterDB:(BOOL)isAlterDB
{
    if(!([self.currentFuncs.ds isEqualToString:DS_PROD] || [self.currentFuncs.ds isEqualToString:DS_PRODC]))
        return;
    NSMutableArray *proValues=[[NSMutableArray alloc]init];
    //产品数量
    
    BOOL isClear = NO;
    if (self.currentFuncs.opt.needSelect
        && [self.currentFuncs.opt.needSelect length] > 0) {
        isClear = YES;
    }
    
    NSInteger prodCount = [self.datas count];
    if ([[self.datas lastObject] isKindOfClass:[NSDictionary class]]) {
        --prodCount;
    }
    
    for(int i = 0 ; i < prodCount; i++)
    {
        NSMutableArray* prodRow = [[NSMutableArray alloc]init];
        NSArray* row = (NSArray*)[self.datas objectAtIndex:i];
        BOOL isInsert = NO;
        //idx
        [prodRow addObject:self.md5];
        //prod_id
        UILabel* prodLabel = [row objectAtIndex:0];
        [prodRow addObject:[NSString stringNotNilWithValue:prodLabel.productID]];
        
        //ui的行
        for(int m = 0 ; m < 62 ; m++)
        {
            [prodRow addObject:@"null"];
        }
        
        for(int j = 0 ; j < [row count] ;j++)
        {
            if([[row objectAtIndex:j] isKindOfClass:[UITextField class]])
            {
                //sid,pid,dist,pri,inv,aging,disp,sdisp,cmpt,oos,mtd,ord,gofa,otherdicts
                UITextField* view = (UITextField*)[row objectAtIndex:j];
                
                NSString *value = (view.text != nil && ![view.text isEqualToString:@""] && ![view.text isEqualToString:@"0.00"]) ? view.text : view.placeholder;
                if(view.tag < [prodRow count] && value !=nil && ![value isEqualToString:@""])
                {
                    NSInteger tag = (view.tag <= 12) ? view.tag : (view.tag+1); //Because wch_product 中有otherdics字段不知道何用
                    
                    [prodRow removeObjectAtIndex:tag];
                    [prodRow insertObject:value atIndex:tag];
                    isInsert = YES;
                }else if(value == nil||[value isEqualToString:@""]){
                    NSInteger tag = (view.tag <= 12) ? view.tag : (view.tag+1); //Because wch_product 中有otherdics字段不知道何用
                    [prodRow removeObjectAtIndex:tag];
                    [prodRow insertObject:@"null" atIndex:tag];
                    //NSLog(@"view.tag is %d",view.tag);
                }
            }
            
            
            
            if([[row objectAtIndex:j] isKindOfClass:[UIButton class]])
            {
                UIButton* button = (UIButton*)[row objectAtIndex:j];
                
                if ([button isKindOfClass:[WSAcvtButtonForTB class]]) {
                    int tag = kWSIndexInProductTable; //otherdics 在wch_product中的位置
                    NSDictionary *dic = [self.datas lastObject];
                    if ([dic isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *jsondata = [dic objectForKey:[NSString stringWithFormat:@"%ld", (long)button.tag]];
                        if (jsondata != nil) {
                            NSString *str = [jsondata JSONString];
                            if (str != nil && [str length] > 0) {
                                [prodRow replaceObjectAtIndex:tag withObject:str];
                            }
                            
                        }
                    }
                    
                }else  if ([button isKindOfClass:[WSQRTypeView class]]) {

                    WSQRTypeView* view = (WSQRTypeView*)[row objectAtIndex:j];
                    NSString *value = view.titleLabel.text;
                    if(view.tag < [prodRow count] && value !=nil && ![value isEqualToString:@""])
                    {
                        NSInteger tag = (view.tag <= 12) ? view.tag : (view.tag+1); //Because wch_product 中有otherdics字段不知道何用
                        [prodRow removeObjectAtIndex:tag];
                        [prodRow insertObject:value atIndex:tag];
                        isInsert = YES;
                    }else if(value == nil||[value isEqualToString:@""]){
                        NSInteger tag = (view.tag <= 12) ? view.tag : (view.tag+1); //Because wch_product 中有otherdics字段不知道何用
                        [prodRow removeObjectAtIndex:tag];
                        [prodRow insertObject:@"null" atIndex:tag];
                    }
                    
                }
                
                else{
                    NSInteger tag = (button.tag <= 12) ? button.tag : (button.tag+1); //Because wch_product 中有otherdics字段不知道何用
                    [prodRow removeObjectAtIndex:tag];
                    if(button.isSelected){
                        [prodRow insertObject:@"1" atIndex:tag];
                        isInsert = YES;
                    }else{
                        [prodRow insertObject:@"0" atIndex:tag];
                    }
                }
            }
            
            if([[row objectAtIndex:j] isKindOfClass:[WSDatePickerLabel class]])
            {
                
                UILabel* view = (UILabel*)[row objectAtIndex:j];
                NSString *value = view.text;
                if(view.tag < [prodRow count] && value !=nil && ![value isEqualToString:@""])
                {
                    NSInteger tag = (view.tag <= 12) ? view.tag : (view.tag+1); //Because wch_product 中有otherdics字段不知道何用
                    [prodRow removeObjectAtIndex:tag];
                    [prodRow insertObject:value atIndex:tag];
                    isInsert = YES;
                }else if(value == nil||[value isEqualToString:@""]){
                    NSInteger tag = (view.tag <= 12) ? view.tag : (view.tag+1); //Because wch_product 中有otherdics字段不知道何用
                    [prodRow removeObjectAtIndex:tag];
                    [prodRow insertObject:@"null" atIndex:tag];
                }
            }
            
            if ([[row objectAtIndex:j] isKindOfClass:[PhotoTypeButton class]]) {
                PhotoTypeButton *photoButton = (PhotoTypeButton *)[row objectAtIndex:j];
                
                if (photoButton.tag < [prodRow count] && photoButton.photoIDArray && [photoButton.photoIDArray count] > 0) {
                    NSInteger tag = (photoButton.tag <= 12) ? photoButton.tag : (photoButton.tag+1);
                    NSString *string = [photoButton.photoIDArray componentsJoinedByString:@","];
                    if (string && [string length] > 0) {
                        [prodRow removeObjectAtIndex:tag];
                        [prodRow insertObject:string atIndex:tag];
                    }else{
                        [prodRow removeObjectAtIndex:tag];
                        [prodRow insertObject:@"null" atIndex:tag];
                    }
                }
            }
            
            
            if ([[row objectAtIndex:j] isKindOfClass:[WSSelectListView class]]) {
                WSSelectListView *selectView = (WSSelectListView *)[row objectAtIndex:j];
                NSInteger tag = (selectView.tag <= 12) ? selectView.tag : (selectView.tag+1); //Because wch_product 中有otherdics字段不知道何用
                [prodRow removeObjectAtIndex:tag];
                
                NSString *selectItem = nil;
                switch (selectView.selectMode) {
                    case WSSelectListViewSelectModeSingleSelection:
                    {
                        NSArray *content = selectView.content;
                        if (content && [content count] > 0) {
                            if(selectView.selectedIndex>-1){
                                selectItem= [selectView.content objectAtIndex:selectView.selectedIndex];
                            }
                        }
                    }
                        break;
                    case WSSelectListViewSelectModeMultipleChoice:
                    {
                        selectItem = [selectView getSelectedContentString];
                        
                        if (selectItem && [selectItem isEqualToString:[selectView getDefaultString]]){
                            selectItem = nil;
                        }
                    }
                        break;
                    default:
                        break;
                }
                
                if(selectItem && selectItem.length>0){
                    [prodRow insertObject:selectItem atIndex:tag];
                    isInsert = YES;
                }else{
                    [prodRow insertObject:@"null" atIndex:tag];
                }

            }
            if (self.m_addedDataSources && isInsert) {
                // 下发的prdSpec节点数据
                // sid,pid,dist,pri,inv,aging,disp,sdisp,cmpt,oos,mtd,ord,gofa,item1,item2,item3,item4,item5,item6,item7,item8,item9,item10
                /*
                for (WSFuncsBean_Param *tmp_param in self.currentFuncs.paramArray) {
                    NSString *col = tmp_param.col;
                    NSInteger colSpec = [self getProdSpecIndexWithContent:col];
                    NSArray *specArray = [WSAppData getObjectbyKey:PRODSPEC];
                    if (![specArray containsObject:@"otherdicts"]) {
                        colSpec +=1;
                    }
                    
                    // 通过填写的列查找pid
                    __block NSString *pid = nil;
                    [prodRow enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSString *colValue = (NSString *)obj;
                        if (idx &&  (idx == colSpec) &&  ![colValue isEqualToString:@"null"]) {
                            pid = [prodRow objectAtIndex:1];
                        }
                    }];
                }
                 */
                /*和安卓逻辑保持一致*/
                NSString *pid = [prodRow objectAtIndex:1];
                NSArray *m_addProdIds = [self.m_addedDataSources valueForKeyPath:@"@distinctUnionOfObjects.Id"];
                [self.m_dataSources enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    WSProdBean *prodBean = (WSProdBean *)obj;
                    if (pid && [prodBean.Id  isEqualToString:pid]) {
                        if (![m_addProdIds containsObject:prodBean.Id]) {
                            [self.m_addedDataSources addObject:prodBean];
                        }
                    }
                }];
                
            }
        }
        if (isClear) {
            if (isInsert) {
                [proValues addObject:prodRow];
            }
        }else{
            
            [proValues addObject:prodRow];
        }
    }
    
    //fpt
    NSString *title = ((self.iBrandId == nil) ? @"null" : self.iBrandId);
    NSNumber* isPlan = [NSNumber numberWithBool:self.currentStore.plan];
    NSMutableArray *fptValues = [[NSMutableArray alloc] init];
    
    // FUNC_CODE
    NSString *fc = self.currentFuncs.fc;
    fc = [fc isKindOfClass:[NSString class]] ? fc : @"null";
    [fptValues addObject:fc];
    
    // FUNC_VIEW
    NSString *fv = self.currentFuncs.fv;
    fv = [fv isKindOfClass:[NSString class]] ? fv : @"null";
    [fptValues addObject:fv];
    
    // IS_PLANED
    NSString *isPlane = [isPlan stringValue];
    isPlane = [isPlane isKindOfClass:[NSString class]] ? isPlane : @"null";
    [fptValues addObject:isPlane];
    
    // ORG_ID
    [fptValues addObject:@"null"];
    
    // STORE_ID
    NSString *storeid = ((self.currentStore != nil) ? self.currentStore.Id : @"");
    storeid = [storeid isKindOfClass:[NSString class]] ? storeid : @"null";
    [fptValues addObject:storeid];
    
    // EMP_ID
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    empId = [empId isKindOfClass:[NSString class]] ? empId : @"null";
    [fptValues addObject:empId];
    
    // BIZ_DATE
    NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    bizDate = [bizDate isKindOfClass:[NSString class]] ? bizDate : @"null";
    [fptValues addObject:bizDate];
    
    // UPLOAD_DATE
    NSString *uploadDate = [WSCurrentTime getDateString];
    uploadDate = [uploadDate isKindOfClass:[NSString class]] ? uploadDate : @"null";
    [fptValues addObject:uploadDate];
    
    // UPLOAD_FLAG
    [fptValues addObject:@"0"];
    
    // IMG_IDX
    NSString *md5 = self.md5;
    md5 = [md5 isKindOfClass:[NSString class]] ? md5 : @"null";
    [fptValues addObject:md5];
    
    NSString *srid = @"null";
    if (self.currentStore
        && self.currentStore.srid
        && [self.currentStore.srid length] > 0) {
        srid = [self.currentStore.srid copy];
    }
    // SR_ID
    [fptValues addObject:srid];
    
    // get the MEMOs datas
    NSMutableDictionary *dicOtherInfo = nil;
    for (int i = 0; i < [self.currentFuncs.otherArray count]; i++) {
        WSFuncsBean_other *other = [self.currentFuncs.otherArray objectAtIndex:i];
        if (([other.tpy isEqualToString:OTHER_TPY_N] || [other.tpy isEqualToString:OTHER_TPY_T]) &&
            [other.col hasPrefix:@"memo"]) {
            UIView *infoView = [self.view viewWithTag:(OTHER_TEXTFIELD_TAG + i)];
            if ([infoView isKindOfClass:[UITextField class]]) {
                UITextField *field = (UITextField *)infoView;
                NSString *value = (field.text == nil) ?  @"" : field.text;
                if (dicOtherInfo == nil) {
                    dicOtherInfo = [[NSMutableDictionary alloc] init];
                }
                [dicOtherInfo setValue:value forKey:other.col];
            }else if ([infoView isKindOfClass:[UITextView class]]) {
                UITextView *textView = (UITextView *)infoView;
                NSString *value = (textView.text == nil) ?  @"" : textView.text;;
                if (dicOtherInfo == nil) {
                    dicOtherInfo = [[NSMutableDictionary alloc] init];
                }
                [dicOtherInfo setValue:value forKey:other.col];
            }
        }
        else if ([other.tpy isEqualToString:OTHER_TPY_C] && [other.col hasPrefix:@"memo"])
        {
            UIView *infoView = [self.view viewWithTag:(OTHER_SWITCH_TAG+i)];
            if ([infoView isKindOfClass:[UISwitch class]]) {
                UISwitch *swichView = (UISwitch *)infoView;
                NSString *flag = swichView.isOn ? @"1" : @"0";
                [dicOtherInfo setValue:flag forKey:other.col];
            }
        }else if ([other.tpy isEqualToString:OTHER_TPY_CS] && [other.col hasPrefix:@"memo"])
        {
            UIView *infoView = [self.view viewWithTag:(OTHER_BUTTON_TAG+i)];
            if ([infoView isKindOfClass:[UIButton class]]) {
                UIButton *option_btn = (UIButton *)infoView;
                NSString *flag = option_btn.isSelected ? @"1" : @"0";
                [dicOtherInfo setValue:flag forKey:other.col];
            }
        }
    }
    
    // MEMO"
    NSString *memo = [dicOtherInfo objectForKey:@"memo"];
    UIView *memoView = [self.view viewWithTag:MEMOTAG];
    if (memo == nil && memoView != nil) {
        memo = [(UITextField *)memoView text];
        if (memo == nil|| memo.length == 0) {
            memo = @"null";
        }
    }
    if (memo == nil) {
        memo = @"null";
    }
    [fptValues addObject:memo];
    
    // MEMO1 ~ MEMO10
    for (int i = 0; i < 10; i++) {
        NSString *memoi = [dicOtherInfo objectForKey:[NSString stringWithFormat:@"memo%d", i + 1]];
        memoi = [memoi isKindOfClass:[NSString class]] ? memoi : @"null";
        [fptValues addObject:memoi];
    }
    
    //title
    [fptValues addObject:title];
    
    if (isAlterDB) {
        BOOL insertFptDataIsSucceed = [[WSFptTable sharedTable] insertWithFptArray:fptValues product:proValues isClear:isClear];
        if (!insertFptDataIsSucceed) {
            _insertFptIsSucceed = insertFptDataIsSucceed;
        }
    }

}


-(BOOL)uploadDatas{
    LogTrace();
    
    if (self.abnormalReasonDict != nil)
    {
        [self.datas addObject:self.abnormalReasonDict];
    }
    
    // Get other view info
    NSMutableDictionary *dicOtherInfo = nil;
    for (int i = 0; i < [self.currentFuncs.otherArray count]; i++) {
        WSFuncsBean_other *other = [self.currentFuncs.otherArray objectAtIndex:i];
        if ([other.tpy isEqualToString:OTHER_TPY_N] ||[other.tpy isEqualToString:OTHER_TPY_T] ) {
            UIView *infoView = [self.view viewWithTag:(OTHER_TEXTFIELD_TAG+i)];
            if ([infoView isKindOfClass:[UITextField class]]) {
                UITextField *field = (UITextField *)infoView;
                NSString *value = (field.text == nil) ? @"" : field.text;
                if (dicOtherInfo == nil) {
                    dicOtherInfo = [[NSMutableDictionary alloc] init];
                }
                [dicOtherInfo setValue:value forKey:other.col];
            }else if ([infoView isKindOfClass:[UITextView class]]) {
                UITextView *textView = (UITextView *)infoView;
                NSString *value = (textView.text == nil) ?  @"" : textView.text;;
                if (dicOtherInfo == nil) {
                    dicOtherInfo = [[NSMutableDictionary alloc] init];
                }
                [dicOtherInfo setValue:value forKey:other.col];
            }
        }
        else if ([other.tpy isEqualToString:OTHER_TPY_C])
        {
            UIView *infoView = [self.view viewWithTag:(OTHER_SWITCH_TAG+i)];
            if ([infoView isKindOfClass:[UISwitch class]]) {
                UISwitch *swichView = (UISwitch *)infoView;
                int flag = swichView.isOn ? 1 : 0;
                [dicOtherInfo setValue:[NSNumber numberWithInteger:flag] forKey:other.col];
            }
        }else if ([other.tpy isEqualToString:OTHER_TPY_CS])
        {
            UIView *infoView = [self.view viewWithTag:(OTHER_BUTTON_TAG+i)];
            if ([infoView isKindOfClass:[UIButton class]]) {
                UIButton *option_btn = (UIButton *)infoView;
                int flag = option_btn.isSelected ? 1 : 0;
                [dicOtherInfo setValue:[NSNumber numberWithInteger:flag] forKey:other.col];
            }
        }
    }
    
    [self removeDeletedProdsWhenUpload];
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    
    
    BOOL hasPhoto = ([self.photoBrowseView.imageIDArray count] >0 || [self hasPhotoForAbnormalReason]) ?YES:NO;
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];

    NSString *postData =[WSJSONBuilder buildProdGrideDataByFuncs:self.currentFuncs
                                                         isPhoto:hasPhoto
                                                           datas:self.datas
                                                         dataIDs:/*[self.m_store_prod count] > 0 ? self.m_store_prod : */self.m_dataSources
                                                           Store:self.currentStore
                                                             md5:self.md5
                                                            memo:self.memoData
                                                       otherInfo:dicOtherInfo];
    
    
    BOOL insertPhotoDataIsSucceed = [self insertUploadData:postData URL:URL_UPLOAD MD5:self.md5 IsPhoto:hasPhoto NotifyName:notifyID];
    
    if (!insertPhotoDataIsSucceed) {
        return insertPhotoDataIsSucceed;
    }
    _insertFptIsSucceed = YES;
    [self insertProdDataWithIsAlterDB:YES];
    if (!_insertFptIsSucceed) {
        return NO;
    }
    
    if ([[self.datas lastObject] isKindOfClass:[NSDictionary class]]) {
        [self.datas removeLastObject];
    }
    [uploadMgr postRequestAcvtData:postData
                        notifyName:notifyID
                               md5:self.md5
              isSynchronizeRequest:NO];
    return YES;
}

-(BOOL)uploadPhotos{
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    
    for (NSString *key in [self.photoDataDic allKeys]) {
        
        NSMutableArray *acvtImagePathDicArray = [[NSMutableArray alloc] init];
        
        for (NSString *imageID in [self.photoDataDic objectForKey:key]) {
            
            NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
            if (filePath)
            {
                NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
                
                NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID];
                
                NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];
                
                BOOL insertPhotoDataIsSucceed = [self insertUploadMedia:[params JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:key IsPhoto:YES NotifyName:notifyID photoFileName:photoFileName];
                
                if (!insertPhotoDataIsSucceed) {
                    return insertPhotoDataIsSucceed;
                }
                NSArray* array=[NSArray arrayWithObjects:key,imageID,[WSAppData getObjectbyKey:APPDATA_BIZDATE],[WSCurrentTime getDateTime],@"0",nil];
                
                
                [acvtImagePathDicArray addObject:array];
                
                [uploadMgr uploadImageWithFilePath:filePath
                                            params:params
                                               url:URL_IMAGEUPLOAD
                                        notifyName:notifyID
                                               md5:key];
            }
        }
        if (acvtImagePathDicArray && [acvtImagePathDicArray count] > 0) {
            [[WSImagePathTable sharedTable] updateWithImageIDX:key withValuesArray:acvtImagePathDicArray];
        }
    }
    
    
    NSString *imageIndex = [NSString stringWithFormat:@"%@_%@", self.currentFuncs.fc, self.md5];
    
    NSMutableArray *dicValueArray = [[NSMutableArray alloc] init];
    
    for (NSString *imageID in self.photoBrowseView.imageIDArray) {
        
        NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
        if (filePath) {
            NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
            
            NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID];
            
            NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];
            BOOL insertPhotoDataIsSucceed = [self insertUploadMedia:[params JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:imageIndex IsPhoto:YES NotifyName:notifyID photoFileName:photoFileName];
            if (!insertPhotoDataIsSucceed) {
                return insertPhotoDataIsSucceed;
            }
            [uploadMgr uploadImageWithFilePath:filePath
                                        params:params
                                           url:URL_IMAGEUPLOAD
                                    notifyName:notifyID
                                           md5:imageIndex];
            
            
            NSArray* array=[NSArray arrayWithObjects:imageIndex,imageID,[WSAppData getObjectbyKey:APPDATA_BIZDATE],[WSCurrentTime getDateTime],@"0",nil];
            
            [dicValueArray addObject:array];
        }
        else
        {
            LogError(@"照片数据不存在，imageID:%@",imageID);
        }
    }
    
    if (!([self.photoBrowseView.imageIDArray count] > 0)) {
        LogError(@"photoBrowseView中无照片");
    }
    
    
    if (dicValueArray && [dicValueArray count] > 0) {
        [[WSImagePathTable sharedTable] updateWithImageIDX:imageIndex withValuesArray:dicValueArray];
    }
    else
    {
        [[WSImagePathTable sharedTable] deleteWithImageIDX:imageIndex];
    }
    if (![self uploadPhotosInButton]) {
        // xxxxxx
        return NO;
    }
    
    return YES;
}

- (BOOL)uploadPhotosInButton {
    NSInteger iMax = [self.datas count];
    NSInteger jMax = [self.currentFuncs.paramArray count];
    NSString *ds = @"prodId";
    for (NSInteger i = 0; i < iMax; i++) {
        NSArray *subdatas = [self.datas objectAtIndex:i];
        
        if ([subdatas isKindOfClass:[NSArray class]]) {
            NSMutableDictionary *celldic = [[NSMutableDictionary alloc] initWithCapacity:[self.currentFuncs.paramArray count]];
            if (i <self.m_store_prod.count) {
                id prod_object = [self.m_store_prod objectAtIndex:i];
                if ([prod_object isKindOfClass:[WSStoreBean_prod class]]) {
                    WSStoreBean_prod *store_prod = prod_object;
                    [celldic  setObject:[NSString stringWithFormat:@"%@@ ",store_prod.pid] forKey:ds];
                }else if ([prod_object isKindOfClass:[WSProdBean class]]){
                    WSProdBean *store_prod = prod_object;
                    [celldic  setObject:[NSString stringWithFormat:@"%@@ ",store_prod.Id] forKey:ds];
                }
            }
            
             for (int j = 0; j < jMax; j++) {
                id o = [subdatas objectAtIndex:j+1];
                if ([o isKindOfClass:[PhotoTypeButton class]]) {
                    PhotoTypeButton *button = (PhotoTypeButton *)o;
                    
                    
                    for (NSString *imageID in button.photoIDArray) {
                        
                        @autoreleasepool {
                            NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
                            if (filePath) {
                                
                                NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
                                WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
                                NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID];
                                
                                NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];
                                BOOL insertPhotoDataIsSucceed = [self insertUploadMedia:[params JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:button.imageMD5 IsPhoto:YES NotifyName:notifyID photoFileName:photoFileName];
                                if (!insertPhotoDataIsSucceed) {
                                    return insertPhotoDataIsSucceed;
                                }
                                
                                [uploadMgr uploadImageWithFilePath:filePath
                                                            params:params
                                                               url:URL_IMAGEUPLOAD
                                                        notifyName:notifyID
                                                               md5:button.imageMD5];
                            }
                        }
                    }
                }
            }
        }

    }
    return YES;
}

// MSTD-4956 系列选择，在选择某一品牌系列的时候点击右上角确定，直接回到所选产品页面，不用用户手动点击到所选产品页面再去上传，可简化操作。
- (void)gridSearchViewBackToAllSelectedProdsView
{
    [self insertProdDataWithIsAlterDB:NO];
    [self.firstGridSearchView redisPlayWith:self.m_addedDataSources];
    [self.firstGridSearchView setSelectedIndex:1];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.firstGridSearchView.selectedIndex inSection:0];
    [self.firstGridSearchView scrollToRowSelectIndexPath:indexPath];
}

- (void)serieLinkViewBackToAllSelectedProdsView
{
    [self insertProdDataWithIsAlterDB:NO];
    [self.serieLinkView redisplayWith:self.m_addedDataSources];
    [self.serieLinkView setSelectedBrandIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.serieLinkView.selectedBrandIndex inSection:0];
    [self.serieLinkView scrollToRowSelectIndexPath:indexPath];
}

//modify by wangdongyan 03-22 for
- (void)upload
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    //上传前判断
    if (self.currentFuncs.opt.needSelect
        && [self.currentFuncs.opt.needSelect length] > 0) {
        
        if ([self.currentFuncs.opt.needSelect integerValue] == 1) {
            if(self.firstGridSearchView && self.firstGridSearchView.selectedIndex != 1){
//                NSString *TakePhotoString = NSLocalizedString(@"请选择所有产品页面再上传！",@"请选择所有产品页面再上传！");
                NSString *TakePhotoString = NSLocalizedString(@"select_fill_upload",nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:TakePhotoString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                
                [self gridSearchViewBackToAllSelectedProdsView];
                
                return;
            }else if (self.firstGridSearchView && self.firstGridSearchView.selectedIndex == 1){
                
                for(WSProdBean* pb in self.m_dataSources)
                {
                    for(WSStoreBean_prod* sb_prod  in self.currentStore.prodArray)
                    {
                        if([pb.Id isEqualToString:sb_prod.pid] && ![self.m_store_prod  containsObject:sb_prod])
                        {
                            [self.m_store_prod addObject:sb_prod];
                            break;
                        }
                    }
                }
            }
        }else if ([self.currentFuncs.opt.needSelect integerValue] == 2){
                if(self.serieLinkView && self.serieLinkView.selectedBrandIndex != 0){
//                    NSString *TakePhotoString = NSLocalizedString(@"请选择所有产品页面再上传！",@"请选择所有产品页面再上传！");
                    NSString *TakePhotoString = NSLocalizedString(@"select_fill_upload",nil);
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:TakePhotoString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                    
                    [self serieLinkViewBackToAllSelectedProdsView];
                    
                    return;
                }else if (self.serieLinkView && self.serieLinkView.selectedBrandIndex == 0){
                    
                    for(WSProdBean* pb in self.m_dataSources)
                    {
                        for(WSStoreBean_prod* sb_prod  in self.currentStore.prodArray)
                        {
                            if([pb.Id isEqualToString:sb_prod.pid] && ![self.m_store_prod  containsObject:sb_prod])
                            {
                                [self.m_store_prod addObject:sb_prod];
                                break;
                            }
                        }
                    }
                }
        }
    }
    
    //判断是否未必填项
    if ([self.currentFuncs.required isEqualToString:@"R"])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *storeString=[[NSString alloc]initWithFormat:@"%@.plist",self.currentStore.name];
        NSString *WorkListFile=[documentsDirectory stringByAppendingPathComponent:storeString];
        
        NSMutableDictionary *WorkListDic=[[NSMutableDictionary alloc]initWithContentsOfFile:WorkListFile];
        for (int i=0; i<[[WorkListDic allKeys] count]; i++)
        {
            if ([self.currentFuncs.name isEqualToString:[[WorkListDic allKeys]objectAtIndex:i]])
            {
                if (![[WorkListDic objectForKey:[[WorkListDic allKeys]objectAtIndex:i]] isEqualToString:@"1"])
                {
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    
                    NSString *storeString=[[NSString alloc]initWithFormat:@"%@.plist",self.currentStore.name];;
                    
                    NSString *WorkListFile=[documentsDirectory stringByAppendingPathComponent:storeString];
                    
                    [WorkListDic setValue:@"1" forKey:[[WorkListDic allKeys]objectAtIndex:i ]];
                    
                    [WorkListDic writeToFile:WorkListFile atomically:YES];
                    break;
                }
            }
        }
    }
    
    /*校验页面是否有数据*/
//    if (self.currentFuncs.opt.needSelect
//        && [self.currentFuncs.opt.needSelect length] > 0)
//    {
//        
//    }else{
        if (self.datas == nil || self.datas.count == 0) {
            BOOL isRequired = (self.currentFuncs.nullvalue == 0) ? YES : NO;
            if (isRequired) {
                NSString* title = NSLocalizedString(@"no_product", nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                return;
            }
        }
//    }

    
    /*校验数据是否合法*/
    if (![self validateData]) {
        return;
    }
    
    /*nullvalue为0时,表格为必填（至少有一个元素填写）*/
    if (![self isValidateGridRequried]) {
        return;
    }
    
    if (![self executeValidateLuaScrip]) {
        return;
    }
    
    //modify By wangdongyan 2012-02-27 for 当拍多张图片时，可以选择任意一张上传
    if ([self.currentFuncs.opt.isPic isEqualToString:QST_TYPE_R] && [self.photoBrowseView.imageIDArray count] < 1) {
        NSString *TakePhotoString = NSLocalizedString(@"pls_take_photo",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:TakePhotoString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    /////ADD for zhongliang
    WSFuncsBean_opt* fb_opt = self.currentFuncs.opt;
    if (fb_opt.isCode != nil) {
        [self checkDataComplete];
    }
    ///////////////////////////
    
    ///////////////////// For new require
    
    NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
    if (projectName != nil && [projectName isEqualToString:@"pfizer"]) {
        BOOL flag = [self checkDataIsvalied];
        if (!flag) return;
    }else{
        BOOL isFilled = [self checkIfRequiredFilled];
        if (!isFilled) return;
    }
    /////////////////////
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"uploading_prompt", nil)  tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
    
    [self performSelector:@selector(doUpload) withObject:nil afterDelay:0.01];
    
}

- (void)doUpload
{
    
    NSDate *before = [NSDate date];
    if (![self uploadDatas]) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }

    NSDate *after2 = [NSDate date];
    LogInfo(@"uploadDatas耗时：%f秒", [after2 timeIntervalSinceDate:before]);
    
    if (![self uploadPhotos]) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    [super uploadVisitAction];
    NSDate *after3 = [NSDate date];
    LogInfo(@"uploadPhotos耗时：%f秒", [after3 timeIntervalSinceDate:after2]);
    
    LogInfo(@"doUpload耗时：%f秒", [after3 timeIntervalSinceDate:before]);
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *tip = NSLocalizedString(@"add_upload_queue", nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
    
    [self backToParent];
}

-(BOOL)hasPhotoForAbnormalReason
{
    NSArray *keys = [self.photoDataDic allKeys];
    for (NSString *key in keys) {
        NSArray *photoArray = [self.photoDataDic objectForKey:key];
        if ([photoArray count] > 0) {
            return YES;
        }
    }
    return NO;
}

//辉瑞零售
- (BOOL)checkDataIsvalied
{
    NSInteger iMax = [self.datas count];
    NSInteger jMax = [self.currentFuncs.paramArray count];
    
    __block BOOL bFind = NO;
    
    [self.currentFuncs.paramArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        WSFuncsBean_Param *param = (WSFuncsBean_Param *)obj;
        if ([param.isfilled isKindOfClass:[NSString class]] && [param.isfilled isEqualToString:@"O"]) {
            bFind = YES;
            *stop = YES;
        }
    }];
    
    if (!bFind) return YES;
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:4];
    for (int i = 0; i < iMax; i++)
    {
        NSArray *subdatas = [self.datas objectAtIndex:i];
        if ([subdatas isKindOfClass:[NSArray class]])
        {
            
            for (int j = 0; j < jMax; j++)
            {
                WSFuncsBean_Param* param = (WSFuncsBean_Param *)[self.currentFuncs.paramArray objectAtIndex:j];
                if ([param.isfilled isKindOfClass:[NSString class]] && [param.isfilled isEqualToString:@"O"]) {
                    id o = [subdatas objectAtIndex:j+1];
                    if ([o isKindOfClass:[UITextField class]]) {
                        NSString *text = ((UITextField *)o).text;
                        NSString *placeholder = ((UITextField *)o).placeholder;
                        NSString *value = (text != nil && ![text isEqualToString:@""]) ? text : placeholder;
                        
                        BOOL isEqualZero = NO;
                        if ([param.tpy isEqualToString:COL_TYPNUM] && (value != nil) && ([value length] > 0)) {
                            float fvalue = [value floatValue];
                            if ((int)fvalue == 0) {
                                isEqualZero = YES;
                            }
                        }
                        
                        if(value == nil||[value isEqualToString:@""] || isEqualZero )
                        {
                            NSMutableDictionary *dicinfo = [dic objectForKey:param.col];
                            if (dicinfo == nil) {
                                NSMutableDictionary *newdic = [[NSMutableDictionary alloc] initWithCapacity:4];
                                if (param.name) {
                                    [newdic  setObject:param.name forKey:@"colname"];
                                }
                                
                                [newdic  setObject:[NSNumber numberWithInteger:0x01] forKey:@"colflag"];
                                if (newdic) {
                                    [dic  setObject:newdic forKey:param.col];
                                }
                                
                            }else{
                                NSNumber *flag = [dicinfo objectForKey:@"colflag"];
                                int nflag = [flag intValue] | 0x01;
                                [dicinfo  setObject:[NSNumber numberWithInteger:nflag] forKey:@"colflag"];
                            }
                        }else{
                            NSMutableDictionary *dicinfo = [dic objectForKey:param.col];
                            if (dicinfo == nil) {
                                NSMutableDictionary *newdic = [[NSMutableDictionary alloc] initWithCapacity:4];
                                [newdic  setObject:param.name forKey:@"colname"];
                                [newdic  setObject:[NSNumber numberWithInteger:0x10] forKey:@"colflag"];
                                
                                if (newdic) {
                                    [dic  setObject:newdic forKey:param.col];
                                }
                                
                            }else{
                                NSNumber *flag = [dicinfo objectForKey:@"colflag"];
                                int nflag = [flag intValue] | 0x10;
                                [dicinfo  setObject:[NSNumber numberWithInteger:nflag] forKey:@"colflag"];
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    NSMutableString *allzerocol = [[NSMutableString alloc] initWithCapacity:8];
    NSMutableString *notallzerocol = [[NSMutableString alloc] initWithCapacity:8];
    NSArray *items = [dic allValues];
    if (items && [items count] > 0) {
        for (NSDictionary *info in items) {
            NSString *name = [info objectForKey:@"colname"];
            NSNumber *flag = [info objectForKey:@"colflag"];
            if ([flag intValue] == 0x01) {
                if ([allzerocol length] == 0) {
                    [allzerocol appendString:name];
                }else{
                    [allzerocol appendFormat:@",%@", name];
                }
            }else if ([flag intValue] == 0x11){
                if ([notallzerocol length] == 0) {
                    [notallzerocol appendString:name];
                }else{
                    [notallzerocol appendFormat:@",%@", name];
                }
            }
        }
    }
    
    if ([allzerocol length] == 0 && [notallzerocol length] == 0) {
        return YES;
    }else{
        NSInteger tag = ([allzerocol length] > 0) ? (kAlertViewTagBase + 10) : ( kAlertViewTagBase + 20);
        NSString *caneclTitle = ([allzerocol length] > 0) ? nil : @"post_quit_no";
//        NSString *title = ([allzerocol length] > 0) ? [NSString stringWithFormat:@"所有产品%@均为0，请再次确认", allzerocol]:[NSString stringWithFormat:@"confirm_fill_data", notallzerocol];
        NSString *title = ([allzerocol length] > 0) ? [NSString stringWithFormat:NSLocalizedString(@"all_values_are_0", nil), allzerocol]:[NSString stringWithFormat:@"confirm_fill_data", notallzerocol];
        
        NSString *okTitle = NSLocalizedString(@"confirm", nil);
        
        BlockAlertView *alert = [BlockAlertView alertWithTitle:title message:nil];
        [alert setCancelButtonWithTitle:okTitle block:^{
            if(tag == (kAlertViewTagBase + 20))
            {
                [self uploadDatas];
                [self uploadPhotos];
            }
        }];
        [alert addButtonWithTitle:caneclTitle block:^{
            
        }];
        [alert show];
        
        return NO;
    }
}


- (void)checkDataComplete
{
    NSInteger iMax = [self.datas count];
    NSInteger jMax = [self.currentFuncs.paramArray count];
    
    NSString *item = nil;
    BOOL bFind = YES;
    for (int i = 0; i < iMax && bFind; i++) {
        NSArray *subdatas = [self.datas objectAtIndex:i];
        if ([subdatas isKindOfClass:[NSArray class]])
        {
            int m = 0;
            for (int j = 0; j < jMax; j++)
            {
                id o = [subdatas objectAtIndex:j+1];
                //                 NSString *key = ((FuncsBean_Param *)[self.currentFuncs.paramArray objectAtIndex:j]).col;
                if ([o isKindOfClass:[UITextField class]]) {
                    
                    NSString *value = ((UITextField *)o).text;
                    //add by wang
                    if(value==nil||[value isEqualToString:@""])
                    {
                        if (bFind) {
                            item = ((WSFuncsBean_Param *)[self.currentFuncs.paramArray objectAtIndex:j]).name;
                            bFind = NO;
                        }
                        m++;
                    }
                }
            }
            if (m == jMax) {
                bFind = YES;
                item = nil;
            }
        }
    }
    
    //    if (item != nil) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filename=[[NSString alloc]initWithFormat:@"%@_%@_%@.plist",[WSAppData getObjectbyKey:APPDATA_EMPID],self.currentStore.Id,[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    NSString *infofile=[documentsDirectory stringByAppendingPathComponent:filename];
    NSMutableDictionary *dics = [[NSMutableDictionary alloc] initWithContentsOfFile:infofile];
    if (dics != nil) {
        NSString *key = [NSString stringWithFormat:@"%@||%@||%@", [WSAppData getObjectbyKey:APPDATA_EMPID],self.currentStore.Id,self.currentFuncs.fc];
        NSMutableDictionary *info = [dics objectForKey:key];
        if (info != nil) {
            NSString *isCheck = (item == nil) ? @"0" : @"1";
            
            if (isCheck) {
                [info  setObject:isCheck forKey:@"fischecked"];
            }
            
            
            NSString *column = (item == nil) ? @"" : item;
            
            if (column) {
                [info  setObject:column forKey:@"fitem"];
            }
            
            
            if (info) {
                [dics  setObject:info forKey:key];
            }
            [dics writeToFile:infofile atomically:YES];
        }
    }
}

//
//- (NSString *)getPType {
//    NSString *brand = self.iBrandId;
//    
//    NSString *pType = self.currentFuncs.filter;
//    if ([brand length] > 0) {
//        pType = nil;
//    }
//    return pType;
//}
//
//- (NSString *)getIdStr {
//    return [self.currentStore.drId length] > 0 ? self.currentStore.drId:self.currentStore.Id;
//}
//
//- (void)getDataSorucesFromDb {
//    WSBaseProductDBService *baseProductDBSerice = [[WSBaseProductDBService alloc] init];
//    self.productsList = [baseProductDBSerice  queryAllProducts];
//    
//    if (!self.dataGridView.showSerieLinkHeadView) {
//        
//        NSString *pType = [self getPType];
//        NSString *idStr = [self getIdStr];
//        /*查询出更多的产品*/
//        self.moreProductArray = [NSMutableArray arrayWithArray:[baseProductDBSerice queryMoreProductsWithStoreId:idStr brand:self.iBrandId pType:pType params:self.currentFuncs.paramArray]];
//    }
//}

//- (NSArray *)getProductsFromDb {
//    WSBaseProductDBService *baseProductDBSerice = [[WSBaseProductDBService alloc] init];
//
//    
//    NSArray *products =  nil;
//    /*如果没有品牌/系列才走正常的分销规则*/
//    if ([self.currentFuncs.opt.needSelect length] == 0) {
//        NSString *idStr = [self getIdStr];
//        NSString *pType = [self getPType];
//        
//        products = [baseProductDBSerice queryProductsWithStoreId:idStr brand:self.iBrandId pType:pType params:self.currentFuncs.paramArray];
//    }
//    return products;
//}


//-(NSArray*)getDatasSources
//{
//
//    if ([WSEnvrionment getStoreDataFromDb]) {
//        
//        [self getDataSorucesFromDb];
//        
//        NSMutableArray *tempProductsArray= [[NSMutableArray alloc] init];
//        
//        if ([self.m_DataBaseDatas count] > 0) {
//            
//            NSString *md5 = self.md5;
//            NSArray *fptObjects = [[WSFptTable sharedTable] queryWithNames:@[@"IMG_IDX"] ArgumentsValue:@[[NSString stringNotNilWithValue:md5]]];
//            if ([fptObjects count] > 0) {
//                NSArray *prodIds = [self.m_DataBaseDatas valueForKeyPath:@"self.prod_id"];
//                WSBaseProductDBService *baseProdctDBService = [[WSBaseProductDBService alloc] init];
//                tempProductsArray =  [NSMutableArray arrayWithArray:[baseProdctDBService queryProductByIds:prodIds]];
//                
//            }
//        }
//        if (tempProductsArray && [tempProductsArray count] > 0) {
//            
//        }else {
//            [tempProductsArray addObjectsFromArray:[self performSelector:@selector(getDataBaseDatasFromServer)]];
//        }
//        
//        NSArray *moreProducts = [self.moreProductArray mutableCopy];
//        
//        //去重
//        for (WSProdBean *tmpPro in tempProductsArray) {
//            for (WSProdBean *prodObject  in moreProducts) {
//                if ([prodObject.Id isEqualToString:tmpPro.Id]) {
//                    [self.moreProductArray removeObject:prodObject];
//                }
//            }
//        }
//
//        if (tempProductsArray && [tempProductsArray count] > 0){
//            
//        }else{
//            NSMutableArray *tmpProducts= [NSMutableArray arrayWithArray:[self getProductsFromDb]];
//
//            [tempProductsArray addObjectsFromArray:tmpProducts];
//        }
//
//        NSArray *tempProducts = [NSArray arrayWithArray:tempProductsArray];
//        return tempProducts;
//    }
//    
//    if(self.moreProductArray == nil)
//    {
//        self.m_moreProdsCount = 0;
//        moreProductArray =[[NSMutableArray alloc]init];
//        
//    }else{
//        self.m_moreProdsCount = 0;
//        [self.moreProductArray removeAllObjects];
//        
//    }
//    if(self.m_store_prod == nil)
//    {
//        m_store_prod = [[NSMutableArray alloc] init];
//    }else{
//        
//        [self.m_store_prod removeAllObjects];
//    }
//    
//    BOOL useNewPTyp = NO;
//    NSArray *pTypArray = [self getProdTypeArray];
//    
//    if (pTypArray && [pTypArray count] > 0) {
//        useNewPTyp = YES;
//    }
//    
//    // 以前的,prodBean Array
//    NSMutableArray *products = [[NSMutableArray alloc] initWithArray:[self getProductsWithBrand:self.iBrandId]];
//    
//    //moreprod
//    if(self.m_moreProdsCount == 0)
//    {
//        
//        for(WSStoreBean_prod* sb_prod  in self.currentStore.prodArray)
//        {
//            for(WSProdBean* pb in products/*l_allProds.prodArray*/)
//            {
//                /*
//                NSLog(@"store_prod pid = %@ -- name = %@ -- id = %@", sb_prod.pid, pb.name, pb.Id);
//                 */
//                
//                if([pb.Id isEqualToString:sb_prod.pid])
//                {
//                    if (useNewPTyp) {
//                        if ([pTypArray containsObject:pb.pTyp]) {
////                            [self.moreProductArray addObject:pb];
//                            
//                            if (![self.moreProductArray containsObject:pb]) {
//                                [self.moreProductArray addObject:pb];
//                            }
//                        }
//                    }else{
//                        //本品，ptyp = 1
//                        if([self.currentFuncs.ds isEqualToString:DS_PROD]&&[pb.pTyp isEqualToString:@"1"]){
//                            NSPredicate* pre=[NSPredicate predicateWithFormat:@"self.brand=%@ AND self.Id=%@",pb.brand,pb.Id];
//                            NSArray* filter=[self.moreProductArray filteredArrayUsingPredicate:pre];
//                            if(filter.count==0){
//                                [self.moreProductArray addObject:pb];
//
//                            }
//
//                        }
//                        //竞品，ptyp = 2
//                        if([self.currentFuncs.ds isEqualToString:DS_PRODC]&&[pb.pTyp isEqualToString:@"2"]) {
//                            
//                            [self.moreProductArray addObject:pb];
//                        }
//                    }
//                    
//                    break;
//                }
//            }
//        }
//    }
//    
//    if (self.moreProductArray && [self.moreProductArray count] > 0) {
//        self.productsList = [NSMutableArray arrayWithArray:self.moreProductArray];
//    }
//    
//    
//    //datasource
//    int l_allProdCount = [products count];
//    NSMutableArray* l_prodArray = [[NSMutableArray alloc]init];
//    int currentStoreProdCount = [self.currentStore.prodArray count];
//    
//    for(int i = 0 ; i < currentStoreProdCount ;i++)
//    {
//        WSStoreBean_prod* s_prod = [self.currentStore.prodArray objectAtIndex:i];
//        for(int m = 0 ; m < l_allProdCount;m++)
//        {
//            WSProdBean* pb = [products objectAtIndex:m];
//            if([s_prod.pid isEqualToString:pb.Id])
//            {
//                int flag = 0;
//                for (int j = 0; j<[self.currentFuncs.paramArray count]; j++)
//                {
//                    
//                    WSFuncsBean_Param* param = (WSFuncsBean_Param *)[self.currentFuncs.paramArray objectAtIndex:j];
//                    if (param.col != nil && [param.col isEqualToString:@"otherdicts"]) {
//                        flag++;  //otherdicts 不用分销
//                        continue;
//                    }
//                    
//                    int l_specItemIndex = [self getSpecIndexbyParam:[self.currentFuncs.paramArray objectAtIndex:j]];
//                    NSString* itemValue ;
//                    if(s_prod.item == nil||l_specItemIndex == -1)
//                        itemValue = @"0";
//                    else {
//                        if ([s_prod.item count] > l_specItemIndex) {
//                            itemValue = [s_prod.item objectAtIndex:l_specItemIndex];
//                        } else {
//                            itemValue = @"0";
//                        }
//                    }
//                    if ([itemValue isEqualToString:@"1"])
//                    {
//                        flag++;
//                    }else
//                        break;
//                }
//                if (flag==[self.currentFuncs.paramArray count])
//                {
//                    
//                    if (useNewPTyp) {
//                        if (self.iBrandId) {
//                            if (![l_prodArray containsObject:pb]) {
//                                [l_prodArray addObject:pb];
//                            }
//                        }else {
//                            if ([pTypArray containsObject:pb.pTyp]) {
//                                if (![l_prodArray containsObject:pb]) {
//                                    [l_prodArray addObject:pb];
//                                }
//                            }
//                        }
//                    }else{
//                        if([self.currentFuncs.ds isEqualToString:DS_PROD]&&[pb.pTyp isEqualToString:@"1"]){
//                            NSPredicate* pre=[NSPredicate predicateWithFormat:@"self.brand=%@ AND self.Id=%@",pb.brand,pb.Id];
//                            NSArray* filter=[l_prodArray filteredArrayUsingPredicate:pre];
//                            if(filter.count==0){
//                                [l_prodArray addObject:pb];
//                            }
//                        }
//                        if([self.currentFuncs.ds isEqualToString:DS_PRODC]&&[pb.pTyp isEqualToString:@"2"])
//                            if (![l_prodArray containsObject:pb]) {
//                                [l_prodArray addObject:pb];
//                            }
//                    }
//                    if(self.m_moreProdsCount == 0)
//                        [self.m_store_prod addObject:s_prod];
//                }
//            }
//        }
//    }
//    
//    /**
//     *   见jira ZLFBM-39
//     *   竞品通过分销规则过滤后有数据则显示过滤后的数据，否则显示全部竞品数据（过滤后数据为零则认为竞品不存在分销规则，此时不考虑店的概念）
//     */
//    if ([self.currentFuncs.ds isEqualToString:DS_PRODC] && [l_prodArray count] < 1) {
//        
//        for(int m = 0 ; m < l_allProdCount;m++)
//        {
//            WSProdBean* pb = [products objectAtIndex:m];
//            if([pb.pTyp isEqualToString:@"2"])
//                [l_prodArray addObject:pb];
//        }
//        
//    }
//    
//    NSMutableArray *sourceProdArray = l_prodArray;
//    return sourceProdArray;
//}

- (void)deleteProds:(id)sender
{

    self.seacherSelectIndex = self.firstGridSearchView.selectedIndex;
    if (self.currentFuncs.opt.needSelect && [self.currentFuncs.opt.needSelect isEqualToString:@"1"]) {
        if (self.firstGridSearchView && self.firstGridSearchView.selectedIndex != 1) {
//            NSString *TakePhotoString = NSLocalizedString(@"请选择所有产品页面再删除！",@"请选择所有产品页面再删除！");
            NSString *TakePhotoString = NSLocalizedString(@"select_fill_delete",nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:TakePhotoString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
    }else if(self.currentFuncs.opt.needSelect && [self.currentFuncs.opt.needSelect isEqualToString:@"2"]){
        if (self.serieLinkView && self.serieLinkView.selectedBrandIndex != 0) {
//            NSString *TakePhotoString = NSLocalizedString(@"请选择所有产品页面再删除！",@"请选择所有产品页面再删除！");
            NSString *TakePhotoString = NSLocalizedString(@"select_fill_delete",nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:TakePhotoString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
    
    }
//    else{
//        
//        
//        return;
//    }
    DataGridComponent *compView = nil;
    
    for (UIView *view in [self.contentScrollView subviews]) {
        if ([view isKindOfClass:[DataGridComponent class]]) {
            compView = (DataGridComponent *)view;
            break;
        }
    }
    
    if (compView) {

        
//        if (compView.isAllowEdit) {
            BOOL isShowOrHideSelection = [compView isShowOrHideSelection];
            if (isShowOrHideSelection) {
                return;
            }
            
            if ([compView.mutableSelectionSet count] > 0) {
                NSString *stringcontent = [NSString stringWithFormat:@"确认要删除(%ld)个产品？" ,(unsigned long)[compView.mutableSelectionSet count]];
                BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(stringcontent,stringcontent)];
                [alert addButtonWithTitle:NSLocalizedString(@"confirm_label", nil) block:^{
                    NSLog(@"删除 %ld  条" , (unsigned long)[compView.mutableSelectionSet count]);
                    
                    NSMutableIndexSet *mutableIndexSet = [NSMutableIndexSet indexSet];
                    NSMutableArray *m_DataBaseDatasCopy = [self.m_DataBaseDatas copy];
            
                    if (self.currentFuncs.opt.needSelect.length == 0 || [self.currentFuncs.opt.needSelect isEqualToString:@"0"] ) {
                        self.m_addedDataSources = [self.m_dataSources mutableCopy];
                    }
                    NSMutableArray *prodIds = [NSMutableArray arrayWithCapacity:1];
                    for (NSString *index in compView.mutableSelectionSet) {
                        [mutableIndexSet addIndex:[index integerValue]];
                        WSProdBean *prodBean = [self.m_addedDataSources objectAtIndex:[index integerValue]];
                        [prodIds addObject:prodBean.Id];
                        
                    }
                    [self.m_addedDataSources removeObjectsAtIndexes:mutableIndexSet];
//                    NSString *title = ((self.iBrandId != nil) ? self.iBrandId : @"null");
//                    [[WSFptTable sharedTable] deleteProductWithStoreId:self.currentStore.Id fc:self.currentFuncs.fc title:title andSrid:self.currentStore.srid andProdIds:prodIds];
                    
                    
                    
                    self.deletedProdIds = prodIds;
                    
                    // 删除BaseStoreProdDisTable的产品，避免数据混乱（离店前上传的数据）
//                    WSBaseStoreProdDisTable *baseStoreProdDisTable = [WSBaseStoreProdDisTable sharedTable];
//                    [baseStoreProdDisTable deleteProddisDatasWithStoreId:self.currentStore.Id andProdIds:prodIds];
                    
                    for (NSString *pid in prodIds) {
                        for (WSProductObject *object in m_DataBaseDatasCopy) {
                            if ([pid isEqualToString:object.prod_id]) {
                                [self.m_DataBaseDatas removeObject:object];
                            }
                        }
                    }
                    
                    
                    for (NSString *pid in prodIds) {
                        for (NSString *keyStr in [self.prod_cacheDataMDictionary allKeys]) {
                            if ([keyStr rangeOfString:[NSString stringWithFormat:@"%@_", pid]].location != NSNotFound) {
                                [self.prod_cacheDataMDictionary removeObjectForKey:keyStr];
                            }
                        }
                    }
                    
                    if (prodIds.count > 0) {
                        for (WSProdBean * prod in self.lastAddMoreProductArray) {
                            if ([prodIds containsObject:prod.Id]) {
                                [self.moreProductArray addObject:prod];
                            }
                        }
                    }
                    
                    // 重新绘制表格及其其他视图
                    self.y_point = 0;
                    self.m_moreProdsCount = 0;
                    [self flushGridView];
//                    [compView allowsMultipleSelection:NO];
                    
                    compView.isSelecting = NO;
                    [compView allowsMultipleSelection:NO];
                    
                }];
                [alert addButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:^{
                    
                    
                }];
                [alert show];
           }else{
               [self showToast:NSLocalizedString(@"pls_select_product", nil)];
//                [compView allowsMultipleSelection:NO];
            }
//        }else{
//            [compView allowsMultipleSelection:YES];
//        }
    }
}

- (void)removeDeletedProdsWhenUpload {
    if ([self.deletedProdIds count] > 0) {

        NSMutableArray *prodIds = [NSMutableArray arrayWithArray:self.deletedProdIds];
        NSString *title = @"null";
        [[WSFptTable sharedTable] deleteProductWithStoreId:self.currentStore.Id fc:self.currentFuncs.fc title:title andSrid:self.currentStore.srid andProdIds:prodIds];
    }
}

- (BOOL)existProdspecdisNode {
    NSArray *prodspecdis = [WSAppData getObjectbyKey:PRODSPECDIS];
    if (prodspecdis  && [prodspecdis count] > 0) {
        return YES;
    }
    return NO;
}


- (NSArray *)getProductsWithBrand:(NSString *)aBrand // brand id
{
    WSProdBeanArray* allproducts = [WSAppData getObjectbyKey:PRODS];
    if (aBrand == nil || [aBrand length] < 1)
    {
        return allproducts.prodArray;
    }else{
        NSArray *products = [allproducts getProdsWithBrandId:aBrand];
        return products;
    }
}

- (NSString *)findBrandId {
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    NSString *brand  = [service queryBrandIdByFilter:self.currentFuncs.filter searchQuestion:self.currentFuncs.opt.searchQuestion];
    return brand;
}

-(NSString*)getDataSourcesWithIndex:(NSNumber*)aIndex Other:(NSArray*)aProds
{
    WSProdBean* prod = [aProds objectAtIndex:[aIndex intValue]];
    return prod.name;
}

-(NSString*)getDetailProductNameWithIndex:(NSNumber*)aIndex Other:(NSArray*)aProds
{
    WSProdBean* prod = [aProds objectAtIndex:[aIndex intValue]];
    return prod.prodName;
}

-(NSString*)getDefaultDataWithParam:(WSFuncsBean_Param*)aParam Others:(WSProdBean*)aProd
{
    return [self getRedisFromServerWithParam:aParam data:aProd];
}

//-(NSArray*)getDataBaseDatas
//{
//    NSString *title = ((self.iBrandId != nil) ? self.iBrandId : @"null");
//    
//    /*srid是否有值查询的时候 和 插入的时候逻辑一直*/
//    NSString *srid = nil;
//    if (self.currentStore.storeAccessMode == WSStoreAccessModeSubEmp) {
//        srid = self.currentStore.srid;
//    }
//    NSArray* l_array = [[WSFptTable sharedTable] queryProductWithStoreId:self.currentStore.Id fc:self.currentFuncs.fc title:title andSrid:srid];
//    return l_array;
//}
//
//-(NSArray*)getDataBaseDatasFromServer
//{
//    
//    //Note: 检测是否存在funccode，如果存在返回index，index == -1标示不存在。
//    int fcIndex = -1;
//    NSArray* spec = [WSAppData getObjectbyKey:PRODSPECDIS];
//    if (!spec || [spec count] < 1) {
//        spec = [WSAppData getObjectbyKey:PRODSPEC];
//    }
//    NSUInteger tmp = [spec indexOfObject:@"funccode"];
//    if (NSNotFound != tmp) {
//        fcIndex = tmp;
//    }
//    WSBaseProductDBService *baseProductDBSerice = [[WSBaseProductDBService alloc] init];
//    
//    NSString *funcCode = nil;
//    if (fcIndex > -1) {
//        funcCode = self.currentFuncs.fc;
//    }
//    NSString *storeId = self.currentStore.Id ?:@"-1";
//    NSString *drId = self.currentStore.drId ?: @"-1";
//    NSArray *dataSourceServer = [baseProductDBSerice queryRedisBrandSortProductWithFuncCode:funcCode StoreId:storeId drId:drId  genId:nil brand:self.currentFuncs.filter params:self.currentFuncs.paramArray];
//    
//    return dataSourceServer;
//
//    /*
//    WSBaseStoreProddisDBService *baseStoreProddisDBService = [[WSBaseStoreProddisDBService alloc] init];
//    NSArray *baseStoreProddiss = [baseStoreProddisDBService queryStoreProdDissWithStoreId:self.currentStore.Id];
//    
//    NSMutableArray *prod_idsArray = [NSMutableArray arrayWithCapacity:[baseStoreProddiss count]];
//    for (WSBaseStoreProdDisObject *bspdo in baseStoreProddiss) {
//        [prod_idsArray addObject:bspdo.prod_id];
//    }
//    
//    WSBaseProductDBService *baseProductDBService = [[WSBaseProductDBService alloc] init];
//    NSArray *prodsArray = [baseProductDBService queryProductByIds:prod_idsArray];
//    
//    return prodsArray;
//     */
// }

- (NSArray *)getImagePathFromDataBase
{
    NSMutableArray *imagePathArray = nil;
    
    NSArray *imageObjectArray = [[WSFptTable sharedTable]queryFptImagePathWithStoreId:self.currentStore.Id fc:self.currentFuncs.fc title:_iBrandId andSrid:self.currentStore.srid];
    if (imageObjectArray && [imageObjectArray count] > 0) {
        imagePathArray = [[NSMutableArray alloc] init];
        for (WSImagePathObject *object in imageObjectArray) {
            NSString *imageID = object.img_path;
            if (imageID && [imageID length] > 0) {
                [imagePathArray addObject:imageID];
            }
        }
    }
    
    return imagePathArray;
}

//获取数据库的内容
-(NSString*)getDatasFromDataBaseWithParam:(WSFuncsBean_Param*)aParam Data:(WSProdBean*)aProd
{
    if(self.m_DataBaseDatas == nil)
    {
        return nil;
    }
    for(WSProductObject* object in self.m_DataBaseDatas)
    {
        NSString* pID = object.prod_id;
        if([pID isEqualToString:aProd.Id])
        {
            NSString *cleanString = nil;
            NSString *roughString = [object valueForKey:aParam.col];
            NSRange range1 = [roughString rangeOfString:@"0"];
            NSRange range2 = [roughString rangeOfString:@"0."];
            while (range1.location == 0 && range2.location !=0 && ([roughString length] > 1)) {
                roughString = [roughString substringFromIndex:1];
                range1 = [roughString rangeOfString:@"0"];
                range2 = [roughString rangeOfString:@"0."];
            }
            cleanString = roughString;
            return cleanString;
        }
    }
    return nil;
    
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)dealloc
{
    if (INTERFACE_IS_PHONE) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - View lifecycle


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.contentScrollView.bounces = NO;
}


//modity by yanguoshuai at 2012-02-27
- (void)pushMoreProducts
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveMoreProducts:) name:RECEIVEMORE object:nil];
    
    for(WSProdBean* pb in self.m_dataSources)
    {
        [self.moreProductArray removeObject:pb];
    }
    
    UIViewController *moreProdVC = nil;
    
    // MENGNIU-1541 普通产品表格加入分类式添加更多产品的页面跳转
    if (self.baseDataGridComponentDataSource.currentTableItem.opt.prodtrees && self.baseDataGridComponentDataSource.currentTableItem.opt.prodtrees.length > 0) {
        self.baseDataGridComponentDataSource.moreProductArray = self.moreProductArray;
        moreProdVC = [[WSNewAddProdsWithSeriesViewController alloc] initWithDataGridComponentDataSource:self.baseDataGridComponentDataSource title:NSLocalizedString(@"more_product_label", nil)];
        moreProdVC.currentStore = self.currentStore;
    }else{
        moreProdVC = [[MoreProductViewController  alloc] initWithProductArray:self.moreProductArray title:NSLocalizedString(@"more_product_label", nil)];
    }

    [self setHidesBottomBarWhenPushed:YES];
    if(self.m_ParentViewController == nil)
        [self.navigationController pushViewController:moreProdVC animated:YES];
    else
        [self.m_ParentViewController.navigationController pushViewController:moreProdVC animated:YES];
}

-(void)receiveMoreProducts:(id)sender
{
    LogTrace();
    [[NSNotificationCenter defaultCenter]removeObserver:self name:RECEIVEMORE object:nil];
    
    NSArray* l_receiveProducts = nil;
    
    if (self.baseDataGridComponentDataSource.currentTableItem.opt.prodtrees && self.baseDataGridComponentDataSource.currentTableItem.opt.prodtrees.length > 0) {
        if ([[sender object] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultDic = (NSDictionary *)[sender object];
            
            NSArray *selectedMoreProductsArray = (NSArray *)[resultDic objectForKey:@"selectedProds"];
            NSDictionary *prodKeyValueCacheDataDic = (NSDictionary *)[resultDic objectForKey:@"prodKeyValueCacheData"];
            
            for (NSString *cacheKey in prodKeyValueCacheDataDic.allKeys) {
                [self.baseDataGridComponentDataSource.dataSourceCache setObject:[prodKeyValueCacheDataDic objectForKey:cacheKey] forKey:cacheKey];
            }
            
            l_receiveProducts = selectedMoreProductsArray;
            
        }
        else if ([[sender object] isKindOfClass:[NSArray class]]) {
            l_receiveProducts = (NSArray*)[sender object];
        }
    }else{
        if ([[sender object] isKindOfClass:[NSArray class]]) {
            l_receiveProducts = (NSArray*)[sender object];
        }
    }
    
    if([l_receiveProducts count] > 0){
        self.m_moreProdsCount = [l_receiveProducts count];
        
        self.isMoreProdSelected = YES;
    }
    else{
        self.m_moreProdsCount = -1;
        self.isMoreProdSelected = NO;
        return;
    }
    
    for(WSProdBean* pb in l_receiveProducts)
    {
        for(WSStoreBean_prod* sb_prod  in self.currentStore.prodArray)
        {
            if([pb.Id isEqualToString:sb_prod.pid])
            {
                [self.m_store_prod addObject:sb_prod];
                break;
            }
        }
    }
    [self.m_dataSources addObjectsFromArray:l_receiveProducts];
    [self.lastAddMoreProductArray addObjectsFromArray:l_receiveProducts];
    // 重新绘制表格及其其他视图
    self.y_point = 0;
    [self.contentScrollView removeAllSubviews];
    if (INTERFACE_IS_PHONE) {   // ipad 暂定不需要添加storenamelabel
        [self loadStoreNameLabel];
    }
    [self setGrideViewData];
    [self createDataGridView];
    [self addFuncsOtherBeanView];
    [self addOptView];
    self.contentScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.y_point);
    [self resetCheckBoxALL];
    [self refreshButtonAndGrid];
    
}
-(void)resetCheckBoxALL
{
    
    for(UIView* view in self.contentScrollView.subviews)
    {
        if([view isKindOfClass:[DataGridComponent class]])
        {
            
            @autoreleasepool {
                
                // MSTD-3562 为了一直显示checkBox，所以不重置DataGridComponent
                DataGridComponent *compView = nil;
                
                if (self.dataGridView) {
                    compView = self.dataGridView;

                }else{
                    DataGridComponentDataSource *comData = [[DataGridComponentDataSource alloc]
                                                            init];
                    comData.titles = self.titles;
                    comData.data = self.datas;
                    comData.columnWidth = self.colWidth;
                    comData.currentTableItem = [[WSTableItem alloc] initWithFuncsBean:self.currentFuncs];
                    
                    
                    
                    compView = [[DataGridComponent alloc]
                                                   initWithFrame:
                                                   CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height) data:comData];
                    compView.frame = view.frame;
                    [view removeFromSuperview];
                    
                    self.dataGridView = compView;
                    
                    [self.contentScrollView addSubview:compView];
                }
 
                
                //产品表格增加新产品则重新生成视图，导致原先的依赖关系被破坏。
                // add by xiajunling 2014-07-10 把表头视图里包含的多选项放到datas数组里 ，并监听按钮事件。 （支持CA类型）
                NSMutableArray *checkBoxArrayTemp = [NSMutableArray arrayWithCapacity:5];
                while ([compView.checkBoxArray count]>0) {
                    
                    id checkBoxObj = [compView.checkBoxArray firstObject];
                    if ([checkBoxObj isKindOfClass:[WSCheckBox class]]) {
                        
                        WSCheckBox *checkButton = (WSCheckBox *)checkBoxObj;
                        [checkButton addTarget:self action:@selector(checkBoxPressed:) forControlEvents:UIControlEventTouchUpInside];
                        
                        //判断是否表头checkBox 定义见 DataGridComponent.m ,目前表头嵌入checkBox只支持除第0列以外的列。
                        NSInteger column = checkButton.iColumn;
                        //获取列的类型 col属性值 好从m_DataBaseDatas里获取相应数据
                        WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:column - 1];
                        
                        //获取产品数量
                        NSInteger countPro = [self.m_dataSources count];
                        for (id objTemp in self.m_dataSources) {
                            if ( [objTemp isKindOfClass:[WSProdBean class]]) {
                                WSProdBean *prodBean = (WSProdBean *)objTemp;
                                
                                for (WSProductObject* object in self.m_DataBaseDatas) {
                                    NSString *prodID = [NSString stringWithFormat:@"%@",object.prod_id];
                                    NSString *colString = [NSString stringWithFormat:@"%@",[object valueForKey:param.col]];
                                    if ([prodBean.Id isEqualToString:prodID]
                                        && [colString isEqualToString:@"1"]) {
                                        countPro = countPro -1;
                                    }
                                }
                            }else if( [objTemp isKindOfClass:[WSDictBean class]]){
                                WSDictBean *dictBean = (WSDictBean *)objTemp;
                                for (NSDictionary * dicData in self.m_DataBaseDatas) {
                                    NSString *dict_id = [NSString stringWithFormat:@"%@",[dicData objectForKey:@"dict_id"]];
                                    NSString *colString = [NSString stringWithFormat:@"%@",[dicData objectForKey:param.col]];
                                    if ([dictBean.name isEqualToString:dict_id]
                                        && [colString isEqualToString:@"1"]) {
                                        countPro = countPro -1;
                                    }
                                }
                                
                            }
                        }
                        //所有产品都被选中，则全部选择项为选中状态
                        if (countPro < 1) {
                            [checkButton setSelected:YES];
                        }
                        
                        [checkBoxArrayTemp addObject:checkButton];
                    }
                    
                    [compView.checkBoxArray  removeObject:checkBoxObj];
                }
                
                compView.checkBoxArray = nil;
                
                if (!self.checkBoxesArrayOfHeaderView) {
                    self.checkBoxesArrayOfHeaderView = [NSMutableArray arrayWithCapacity:5];
                }
                [self.checkBoxesArrayOfHeaderView removeAllObjects];
                if ([checkBoxArrayTemp count]>0) {
                    [self.checkBoxesArrayOfHeaderView addObjectsFromArray:checkBoxArrayTemp];
                }
                
            }
            
        }
    }
    
}


-(NSDictionary*)md5Param
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:[super md5Param]];
    NSString *memo = nil;
    if (self.iBrandId == nil && (self.currentFuncs.filter != nil && [self.currentFuncs.filter length] > 0 && ![self.currentFuncs.filter isEqualToString:@"1"] && ![self.currentFuncs.filter isEqualToString:@"2"])) {
        self.iBrandId = [self findBrandId];
        memo = self.iBrandId;
    }else if (self.iBrandId && [self.iBrandId length] > 0){
        memo = self.iBrandId;
    }
    
    NSString *superMemo = [dic objectForKey:@"memo"];
    
    if (memo
        && [memo length] > 0
        && superMemo
        && [superMemo length] > 0) {
        memo = [NSString stringWithFormat:@"%@_%@",superMemo,memo];
        [dic setValue:memo forKey:@"memo"];
    }else if(memo
             && [memo length] > 0){
        [dic setValue:memo forKey:@"memo"];
    }
    return dic;
}

//modity by yanguoshuai at 2012-02-28
-(void)loadView
{
    [super loadView];
       
//    if ([self.currentFuncs.opt.isPic isEqualToString:QST_TYPE_R]) {
//        [self.photoBrowseView setIsPhotoNecessary:YES];
//    }
    
    frameRect = CGRectZero;
    _isFirstLoadView = YES;
    self.isAllProducts = YES;
}

- (void)setFuncsOtherBeanViewData
{
    WSFdtObject *object =nil;
    
    NSString *srid = nil;
    if (self.currentStore
        && self.currentStore.storeAccessMode == WSStoreAccessModeSubEmp
        && self.currentStore.srid
        && [self.currentStore.srid length] > 0) {
        
        srid = [self.currentStore.srid copy];
    }
    
    
    NSArray* array=[[WSFptTable sharedTable] queryFptWithStoreId:self.currentStore.Id  fc:self.currentFuncs.fc title:_iBrandId andSrid:srid];
    if(array.count>0){
        object=  [array firstObject];
    }
    
    
    // 根据otherArray配置来设置meno
    if ([self.currentFuncs.otherArray count]) {
        for (int i = 0; i < [self.currentFuncs.otherArray count]; i++)
        {
            WSFuncsBean_other *other = [self.currentFuncs.otherArray objectAtIndex:i];
            if (([other.tpy isEqualToString:OTHER_TPY_N] || [other.tpy isEqualToString:OTHER_TPY_T]) &&
                [other.col hasPrefix:@"memo"])
            {
                
                UIView *infoView = [self.view viewWithTag:(OTHER_TEXTFIELD_TAG + i)];
                if ([infoView isKindOfClass:[UITextField class]]) {
                    
                    UITextField *field = (UITextField *)infoView;
                    NSString *value = [object valueForKey:other.col];
                    if ([value isKindOfClass:[NSString class]])
                    {
                        field.text = value;
                    }
                }else if ([infoView isKindOfClass:[UITextView class]]) {
                    UITextView *textView = (UITextView *)infoView;
                    NSString *value = [object valueForKey:other.col];
                    if ([value isKindOfClass:[NSString class]])
                    {
                        textView.text = value;
                    }
                }
                
            }
            else if ([other.tpy isEqualToString:OTHER_TPY_C] && [other.col hasPrefix:@"memo"])
            {
                UIView *infoView = [self.view viewWithTag:(OTHER_SWITCH_TAG+i)];
                if ([infoView isKindOfClass:[UISwitch class]]) {
                    UISwitch *swichView = (UISwitch *)infoView;
                    NSString *value = [object valueForKey:other.col];
                    if (value) {
                        NSInteger num = [value integerValue];
                        [swichView setOn:(num ? YES : NO)];
                    }
                }
            }
            else if ([other.tpy isEqualToString:OTHER_TPY_CS])
            {
                UIView *infoView = [self.view viewWithTag:(OTHER_BUTTON_TAG+i)];
                if ([infoView isKindOfClass:[UIButton class]]) {
                    UIButton *option_btn = (UIButton *)infoView;
                    NSString *value = [object valueForKey:other.col];
                    if (value) {
                        NSInteger num = [value integerValue];
                        [option_btn setSelected:(num ? YES : NO)];
                    }
                }
            }
        }
    }
    // 根据opt配置来设置meno
    if (!object)
    {
        // 如果输入框的内容没有做修改 memoData将没有机会赋值 因此在此处给个默认值 此值未后台的数据 目的是 当没有做修改时  上传的事后台的原数据
        NSString *textStr = [object valueForKey:@"memo"];
        if (!textStr || [@"null" isEqualToString:textStr]) {
            textStr = @"";
        }
        UITextField *memoTextField = (UITextField*)[self.contentScrollView viewWithTag:MEMOTAG];
        memoTextField.text = textStr;
        if (self.memoData)
        {
            self.memoData = [NSMutableString stringWithString:textStr];
        }
    }
}

-(void)initializationBackItemAction
{
    if (self.currentFuncs && self.currentFuncs.isHomePageWillShow) {
        NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
        if (mobileHomeDic) {
            NSString *readTimeStr = [mobileHomeDic objectForKey:MobileHomePageReadingTimeKey];
            [self backItemAction:@selector(backAction) target:self withDelay:[readTimeStr intValue]];
            self.currentFuncs.isHomePageWillShow = NO;
        }
    }else {
        [self backItemAction:@selector(backAction) target:self];
    }
}

- (void)memoData:(id)sender
{
    [self.memoData setString:((UITextField*)sender).text];
}


//add by wang
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
        
    [self updataButtonTitle];

    [self recount];

}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
//    [self refreshButtonAndGrid];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (_isFirstLoadView) {
        [self refreshButtonAndGrid];
        [self setFuncsOtherBeanViewData];
        _isFirstLoadView = NO;
    }else{
        
    }
    
}

- (void)refreshButtonAndGrid
{
    [self resetButtons];
    
    CGFloat storeNameLabelHeight =  (INTERFACE_IS_PHONE && self.currentStore) ? self.storeNameLabel.height : 0;
    
    CGFloat buttonHeight = [self.buttonArray count] > 0 ? [self.dataGridView attachedViewsHeight] + kButtonGap * 2 : 0;
    
    CGFloat selectViewHeight = self.currentFuncs.opt.needSelect.length > 0 ? 44 :0;
    
    CGFloat gridMaxHeight = self.view.bounds.size.height - storeNameLabelHeight - selectViewHeight - buttonHeight;
    
    [self reDrawGrideWithHeight:gridMaxHeight];
    
    [self fixFrameWithButtonArray:self.buttonArray];
    
    self.contentScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.y_point);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (UIButton *)moreProductButton
{
    if (_moreProductButton == nil) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectZero];
        [btn setTitle:NSLocalizedString(@"more_product_label",nil) forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(pushMoreProducts) forControlEvents:UIControlEventTouchUpInside];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
        btn.layer.cornerRadius = 2.5;
        btn.clipsToBounds = YES;
        UIColor *mainTintColor = MAIN_TINT_COLOT;
        if (!mainTintColor) {
            mainTintColor = [UIColor colorWithRed:16.0/255.0 green:127.0/255.0 blue:198.0/255.0 alpha:1.0];
        }
        [btn setBackgroundColor:mainTintColor];
        
        _moreProductButton = btn;
    }
    
    return _moreProductButton;
}

- (UIButton *)rqProductButton
{
    if (_rqProductButton == nil) {
        
        /*_rqProductButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_rqProductButton setBackgroundColor:[UIColor whiteColor]];
        [_rqProductButton setImage:[UIImage imageNamed:@"qr_code"] forState:UIControlStateNormal];
        [_rqProductButton addTarget:self action:@selector(startScan:) forControlEvents:UIControlEventTouchUpInside];*/
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectZero];
        [btn setTitle:NSLocalizedString(@"scan",nil) forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(startScan:) forControlEvents:UIControlEventTouchUpInside];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
        btn.layer.cornerRadius = 2.5;
        btn.clipsToBounds = YES;
        UIColor *mainTintColor = MAIN_TINT_COLOT;
        if (!mainTintColor) {
            mainTintColor = [UIColor colorWithRed:16.0/255.0 green:127.0/255.0 blue:198.0/255.0 alpha:1.0];
        }
        [btn setBackgroundColor:mainTintColor];
        
        _rqProductButton = btn;
    }
    
    return _rqProductButton;
}

- (UIButton *)editProdctButton
{
    if (_editProdctButton == nil) {
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setFrame:CGRectZero];
        [deleteBtn setTitle:NSLocalizedString(@"delete_label",nil) forState:UIControlStateNormal];
        [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteProds:) forControlEvents:UIControlEventTouchUpInside];
        [deleteBtn.titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
        deleteBtn.layer.cornerRadius = 4;
        deleteBtn.clipsToBounds = YES;
        UIColor *mainTintColor = MAIN_TINT_COLOT;
        if (!mainTintColor) {
            mainTintColor = [UIColor colorWithRed:16.0/255.0 green:127.0/255.0 blue:198.0/255.0 alpha:1.0];
        }
        [deleteBtn setBackgroundColor:mainTintColor];
        
        _editProdctButton = deleteBtn;
    }
    
    return _editProdctButton;
}


/**
 *  是否显示更多按钮所在Toolbar
 */
- (void)resetButtons
{
    
    if (!self.buttonArray) {
        self.buttonArray = [NSMutableArray array];
    }else {
        for (UIButton *button in self.buttonArray) {
            [button removeFromSuperview];
        }
        
        [self.buttonArray removeAllObjects];
    }
    
    //"更多"按钮逻辑
    // 如果配置了isMore为0  不显示更多按钮的计算
    // 其他情况需要根据计算是否有更多产品来显示更多按钮

    BOOL isShowMoreButton = YES;
    NSString *isMore = self.currentFuncs.opt.isMore;
    
    if ([isMore isEqualToString:@"0"] || [self.moreProductArray count] < 1 || self.currentStore.inReadonlyMode) {
        isShowMoreButton = NO;
    }
    
    
    if (((self.currentFuncs.opt.needSelect && [self.currentFuncs.opt.needSelect length] > 0) || [self.currentFuncs.opt.deleteButton isEqualToString:@"1"]) &&
        ((self.isAllProducts) && [self.m_dataSources count] > 0)) {

        [self.buttonArray addObject:self.editProdctButton];

    }
    
    if (isShowMoreButton){

        [self.buttonArray addObject:self.moreProductButton];

        BOOL isShowScanButton = NO;
        
        NSString *isScan = self.currentFuncs.opt.isScan;
        
        if (isScan == nil || isScan.length <= 0) {
            for (WSProdBean *prodBean in self.moreProductArray) {
                if (prodBean.barcod && [prodBean.barcod length] > 0) {
                    isShowScanButton = YES;
                    break;
                }
            }
            
            if (isShowScanButton) {
                [self.buttonArray addObject:self.rqProductButton];
            }
        }
        else if (isScan && isScan.length > 0 &&[isScan isEqualToString:@"1"]) {
            isShowScanButton = YES;
            [self.buttonArray addObject:self.rqProductButton];
        }
        
    }
    
    [self resetNavBarButtons];
}

- (void)resetNavBarButtons
{

    self.uploadButton = nil;
    
    if (self.isAllProducts) {
        
        self.uploadButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageForName:@"icon_upload"] style:UIBarButtonItemStylePlain target:self action:@selector(upload)];
    }else{
        self.uploadButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"confirm", nil) style:UIBarButtonItemStylePlain target:self action:@selector(upload)];

    }

    //上传按钮移至右上角
    NSMutableArray *barButtonArray = [NSMutableArray array];
    if(self.m_ParentViewController != nil)
    {
        [barButtonArray addObject:self.uploadButton];
 
        self.m_ParentViewController.navigationItem.rightBarButtonItems = barButtonArray;
        
    }
    else
    {
        UIBarButtonItem  *buttonItem = self.uploadButton;
        [barButtonArray addObject:buttonItem];

        self.navigationItem.rightBarButtonItems = barButtonArray;
    }
    // 如果模块是只读的，那么就隐藏上传按钮  SFA-20241 增加上级的只读状态 逻辑 董宏
    if (self.currentStore.inReadonlyMode || self.currentFuncs.readonly == 1) {
        self.navigationItem.rightBarButtonItems = nil;
    }
}
    
- (void)fixFrameWithButtonArray:(NSArray *)buttonArray
{
    if ([buttonArray count] < 1) {
        return;
    }
    
    CGFloat buttonWidth = (self.view.width - kButtonGap * 2 - kButtonGap * ([buttonArray count] - 1)) / [buttonArray count];
    CGFloat buttonHeight = [self.dataGridView attachedViewsHeight];
    
    CGFloat x = kButtonGap;
    
    for (UIButton *button in buttonArray) {
        // 如果只有一个删除按钮则固定在页面最下方
        if ([buttonArray count] < 2) {
            // SFA-28250 SFA东莞鸿兴：送样产品反馈：添加产品按钮遮挡“备注”问题 (当当前y_point值大于按钮处于页面最下方的y值时，需要用y_pointn，否则按钮会遮挡其他控件)
            CGFloat currentY_Point = self.view.frame.size.height - 2*kButtonGap - buttonHeight;
            self.y_point = self.y_point > currentY_Point ? self.y_point : currentY_Point;
        }
        
        button.frame = CGRectMake(x, self.y_point + kButtonGap, buttonWidth, buttonHeight);
        [self.contentScrollView addSubview:button];
        x += buttonWidth + kButtonGap;
    }
    
    if (!FLOAT_IS_EQUAL(self.lastYPoint, self.y_point)) {
        self.y_point += buttonHeight + MAIN_PADDING;
        self.lastYPoint = self.y_point;
    }

    
}


- (void)updataButtonTitle
{
    return;
    if (self.resonButtons == nil)
        return;
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"WCOptionalSource" ofType:@"plist"];
    NSDictionary *sourceDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *updateType = [sourceDic objectForKey:@"dicttitleupdatetype"];
    if ([updateType isEqualToString:@"photo"]) {
        NSMutableArray *datasArray = [NSMutableArray arrayWithArray:self.datas];
        if (self.abnormalReasonDict)
        {
            [datasArray addObject:self.abnormalReasonDict];
        }
        NSString *postData = [WSJSONBuilder buildDictDetailbyFuncs:self.currentFuncs
                                                           isPhoto:0 datas:datasArray
                                                           dataIDs:self.m_dataSources
                                                             Store:self.currentStore
                                                               md5:@""
                                                              memo:self.memoData
                                                         otherInfo:nil];
        NSDictionary *jsonData = [[postData objectFromJSONString] objectForKey:@"jsonData"];
        NSArray *paramArray = [jsonData objectForKey:@"param"];
        
        for (int i = 0; i < [paramArray count]; i++)
        {
            NSDictionary *dic = [paramArray objectAtIndex:i];
            NSString *otherdictsDic = [dic objectForKey:@"otherdicts"];
            
            UIButton *button = [self.resonButtons objectAtIndex:i];
            int num = 0;
            if (otherdictsDic)
            {
                NSString *photoKey = [[otherdictsDic objectFromJSONString] objectForKey:@"photo"];
                if ([button isKindOfClass:[UIButton class]])
                {
                    num = [(NSArray *)[self.photoDataDic objectForKey:photoKey] count];
                }
                NSLog(@"y");
            }
            
            NSString *title = [NSString stringWithFormat:@"拍照(%d)", num];
            [button setTitle:title forState:UIControlStateNormal];
            
        }
    }
    
}

//- (PhotoTypeButton *)setGrideViewDataKindOfPhotoButton:(FuncsBean_Param *)aParam {
//    if ([aParam.tpy isEqualToString:COL_TYPPHOTO]) {
//
//        PhotoTypeButton *button = [[[PhotoTypeButton alloc] init] autorelease];;
//////        button.tag = [self getSpecIndexbyParam:aParam];
////        [button setTitle:@"camera_capture" forState:UIControlStateNormal];
////        [button addTarget:self action:@selector(switchToPhotoView:) forControlEvents:UIControlEventTouchUpInside];
//
//        return button;
//    }
//    return nil;
//}

//- (void)switchToPhotoView:(id)sender {
//    WSPhotoGalleryViewController *pgVc = [[WSPhotoGalleryViewController alloc] initWithImageArray:nil];
//    [self.navigationController pushViewController:pgVc animated:YES];
//}


#pragma mark - add wxt
- (NSString *)getIdentifyFromData:(WSProdBean *)aData
{
    return aData.Id;
}


- (BOOL)shouldCustomInteractivePopGestureRecognizerDelegate
{
    return YES;
}

- (BOOL)shouldPauseBackAction
{
    if ([self respondsToSelector:@selector(isValueChange)]) {
        if ([self performSelector:@selector(isValueChange)]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)backAction {
    self.isClickedBackAction =YES;
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if (([self respondsToSelector:@selector(isValueChange)] && !self.currentStore.inReadonlyMode) || self.isMoreProdSelected) {
        if ([self performSelector:@selector(isValueChange)] ||self.isMoreProdSelected) {
            
            BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"back_confirm2", nil)];
            
            [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
            [alert addButtonWithTitle:NSLocalizedString(@"upload_label", nil) block:^{
                if (self.mSearchGridviewuploadDataSources) {
                    [self.mSearchGridviewuploadDataSources removeAllObjects];
                }
                [self upload];
            }];
            [alert addButtonWithTitle:NSLocalizedString(@"give_up", nil) block:^{
                [self clearNoUploadProds];
                [self.navigationController popViewControllerAnimated:YES];
                
            }];
            [alert show];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) clearNoUploadProds
{
    if (self.mSearchGridviewuploadDataSources ) {
        NSMutableArray *prodIds = [NSMutableArray arrayWithCapacity:1];
        
        for (WSProdBean *prodBean in self.m_addedDataSources) {
            BOOL haveProd = NO;
            for (WSProductObject *prodObject in self.mSearchGridviewuploadDataSources) {
                if ([prodBean.Id isEqualToString:prodObject.prod_id]) {
                    haveProd = YES;
                    break;
                }
            }
            if (!haveProd) {
                 [prodIds addObject:prodBean.Id];
            }
        }
        if ([prodIds count] > 0) {
            NSString *title = ((self.iBrandId != nil) ? self.iBrandId : @"null");
            [[WSFptTable sharedTable] deleteProductWithStoreId:self.currentStore.Id fc:self.currentFuncs.fc title:title andSrid:self.currentStore.srid andProdIds:prodIds];
        }
    }
}

#pragma mark alert Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView == _datasChangeAlertView)
    {
        switch (buttonIndex)
        {
            case 0:
                
                break;
            case 1:
                [self upload];
                break;
            case 2:
                [self.navigationController popViewControllerAnimated:YES];
                break;
            default:
                break;
        }
        
    }
    else if(alertView.tag != ALERT_CAMERA_TAG)
    {
        if (alertView.tag == (kAlertViewTagBase + 10))
        { //不存储
            return;
        }
        else if(alertView.tag == (kAlertViewTagBase + 20))
        {
            if (buttonIndex == 0)
            { //确定
                [self uploadDatas];
                [self uploadPhotos];
            }
        }
    }
}

#pragma  mark - 条形码扫描按钮事件
- (void) startScan:(id)sender
{
    LogTrace();
    
    BOOL isProdsContainsBarcode = NO;
    
    for (WSProdBean *prodBean in self.productsList) {
        if (prodBean.barcod && [prodBean.barcod length] > 0) {
            isProdsContainsBarcode = YES;
            break;
        }
    }
    
    if (isProdsContainsBarcode) {
        WSScanListViewController *scanlist = [[WSScanListViewController alloc]init];
        //    scanlist.pType = self.baseDataGridComponentDataSource.pType;
        
        [scanlist setVisibleProducts:self.m_dataSources andAllProducts:self.productsList];
        
        __weak WSProdGrideViewController * w_datasourceself = self;
        
        [scanlist showQRViewControllerToViewController:self WithBlock:^(NSArray *aQRlist) {
            
            //        NSMutableArray *resultProdBean = [NSMutableArray array];
            
            //        for (WSProdBean *prodBean in w_datasourceself.productsList) {
            //            for (NSString *barCodeStr in aQRlist) {
            //                if (prodBean.barcod &&[prodBean.barcod isEqualToString:barCodeStr]) {
            //                    [resultProdBean addObject:prodBean];
            //                }
            //            }
            //        }
            //
            if (aQRlist) {
                __strong WSProdGrideViewController * s_datasourceself = w_datasourceself;
                [s_datasourceself resetGridDataView:aQRlist];
            }
            
        }];
    }else{
        BlockAlertView *blockAlertView = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"no_barcode",nil)];
        [blockAlertView addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
            
        }];
        
        [blockAlertView show];
    }
    
}

- (void) resetGridDataView:(NSArray *)receiveProducts
{
    
    LogTrace();
    NSMutableArray *newDataSource = [NSMutableArray arrayWithArray:self.m_dataSources];
    [newDataSource addObjectsFromArray:receiveProducts];
    self.m_dataSources = newDataSource;
    
    if([receiveProducts count] > 0)
        self.m_moreProdsCount = [receiveProducts count];
    else
        self.m_moreProdsCount = -1;
    
    if (self.m_moreProdsCount > 0) {
        [self showToast:[NSString stringWithFormat:NSLocalizedString(@"add_product_success", nil),(long)self.m_moreProdsCount]];
    }else{
        [self showToast:NSLocalizedString(@"no_add_product", nil)];
        return;
    }
    
    for(WSProdBean* pb in receiveProducts)
    {
        for(WSStoreBean_prod* sb_prod  in self.currentStore.prodArray)
        {
            if([pb.Id isEqualToString:sb_prod.pid])
            {
                [self.m_store_prod addObject:sb_prod];
                break;
            }
        }
    }
    
    if (self.moreProductArray && [self.moreProductArray count] > 0) {
        
        NSMutableArray *arrayList = [NSMutableArray arrayWithArray:receiveProducts];
        
        while ([arrayList count] > 0) {
            
            WSProdBean *beanProduct = [arrayList firstObject];
            // 扫描按钮 是有更多按钮，并且 更多产品有数据时，才会显示 --- 同安卓逻辑
            for (WSProdBean *bean in self.moreProductArray) {
                if ([beanProduct.Id isEqualToString:bean.Id]) {
                    [self.moreProductArray removeObject:bean];
                    break;
                }
            }
            [arrayList removeObject:beanProduct];
        }
        
    }
    // 重新绘制表格及其其他视图
    self.y_point = 0;
    [self.contentScrollView removeAllSubviews];
    [self setGrideViewData];
    [self createDataGridView];
    [self addFuncsOtherBeanView];
    [self addOptView];
    self.contentScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.y_point);
    [self resetCheckBoxALL];
    self.y_point += 40;
    [self refreshButtonAndGrid];
    
    
//    [self setGrideViewData];
//    [self resetCheckBoxALL];
    
}

- (void) showToast:(NSString *)message
{
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];

}

#pragma mark - 不凡帝定制
#pragma mark 临时数据源 根据马悦要求，要求囊括所有数据.
- (NSArray *)getProdDatasSourcesTemp {
    
    LogTrace();
    WSProdBeanArray *prodBeanArray = [WSAppData getObjectbyKey:PRODS];
    NSArray *brandProdArray = [NSArray arrayWithArray: prodBeanArray.prodArray];
    
    /*
     *  过滤是否竞品
     */
    NSString *ds = self.currentFuncs.ds ;
    NSArray *brandPTypeProdArray = nil;
    if ([ds isEqualToString:DS_PRODC]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.pTyp = %@", @"2"];
        brandPTypeProdArray = [brandProdArray filteredArrayUsingPredicate:predicate];
        
    } else if ([ds isEqualToString:DS_PROD]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.pTyp = %@", @"1"];
        brandPTypeProdArray = [brandProdArray filteredArrayUsingPredicate:predicate];
    }
    
    return brandPTypeProdArray;
}


- (void)newAddMoreProductToGrideView {
    LogTrace();
    
    /*更多产品中过滤掉dataSource中的产品*/
    NSArray *dataSourceProdIdArray = [self.m_dataSources valueForKeyPath:@"@distinctUnionOfObjects.Id"];
    NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"NOT (SELF.Id in %@)", dataSourceProdIdArray];
    self.moreProductArray = [NSMutableArray arrayWithArray:[self.moreProductArray filteredArrayUsingPredicate:thePredicate]];
    
    if (!self.currentFuncs.paramArray
        || [self.currentFuncs.paramArray count] < 1) {
        
        return;
    }
    
    if ([self.moreProductArray count] < 1) {
        
        return;
    }
    NSMutableArray *prodArray = [[NSMutableArray alloc] initWithCapacity:2];
    
    if ([self.currentFuncs.ds  isEqualToString:DS_PROD] || [self.currentFuncs.ds  isEqualToString:DS_PRODC]) {
        
        // PRODSPECDIS可能会有funccode
        // PRODSPECDIS 节点的服务端协议字段 sid,pid,funccode 【2014-09-28确认】
        BOOL haveFunc_code = YES;
        NSArray* spec = [WSAppData getObjectbyKey:PRODSPECDIS];
        if (!spec || [spec count] < 1) {
            haveFunc_code = NO;
            spec = [WSAppData getObjectbyKey:PRODSPEC];
        }
        
        NSArray *m_dsIds = [self.m_dataSources valueForKeyPath:@"@distinctUnionOfObjects.Id"];
        if ([self isRedisMoreHome]) {
            
            //
            // SFA-10827 新需求 SFA葵花药业--后台参数列参数param配置添加sort排序字段后，手机端需按照此参数进行数据回显的降序排序
            // 回显更多中的产品根据某一列值的大小进行降序排序
            //
            NSString *sortByColParamStr = nil;
            
            for (WSFuncsBean_Param *param in self.currentFuncs.paramArray) {
                if (param.sort > 0) {
                    sortByColParamStr = param.col;
                    break;
                }
            }
            
            /*查询回显时候用storeId*/
            WSBaseStoreProddisDBService *baseStoreProddisDBService = [[WSBaseStoreProddisDBService alloc] init];
            NSArray *baseStoreProddiss = nil;
            if (haveFunc_code) {
                baseStoreProddiss = [baseStoreProddisDBService queryStoreProdDissWithFuncCode:self.currentFuncs.fc storeId:self.currentStore.Id sortByColParam:sortByColParamStr isOrderByDesc:YES];
                //                baseStoreProddiss = [baseStoreProddisDBService queryStoreProdDissWithFuncCode:self.currentFuncs.fc storeId:self.currentStore.Id];
            }else {
                [baseStoreProddisDBService queryStoreProdDissWithStoreId:self.currentStore.Id sortByColParam:sortByColParamStr isOrderByDesc:YES];
                //                [baseStoreProddisDBService queryStoreProdDissWithStoreId:self.currentStore.Id];
            }
            
            
            for (WSBaseStoreProdDisObject *bspDisObj in baseStoreProddiss)
            {
                for ( WSProdBean *moreProd in self.moreProductArray)
                {
                    NSString *bspStore_id = bspDisObj.store_id;
                    NSString *bspProd_id = bspDisObj.prod_id;
                    if ([bspStore_id isEqualToString:self.currentStore.Id]
                        && [bspProd_id isEqualToString:moreProd.Id]) {
                        
                        for (WSFuncsBean_Param *param  in self.currentFuncs.paramArray) {
                            
                            BOOL showServiceData = NO;
                            
                            if ([self serverRedisWith:param]) {
                                showServiceData = YES;
                            }else{
                                LogInfo("因为更多产品的服务端数据回显功能关闭，以至于不能查找服务端下发数据，所以无法回显在首页。");
                            }
                            if ([param.tpy isEqualToString:COL_TYPLNR]) {
                                
                                showServiceData = NO;
                                LogInfo(@"更多产品的LNR采集项类型不作为回显首页的条件。");
                            }
                            if (showServiceData) {
                                NSString *itemValue = nil;
                                if (haveFunc_code) {
                                    
                                    if ([bspDisObj.funccode length] > 0) {
                                        if ([bspDisObj.funccode isEqualToString:self.currentFuncs.fc]) {
                                            itemValue = [bspDisObj valueForKey:param.col];
                                            itemValue = [itemValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                        }
                                        
                                    }else {
                                        itemValue = [bspDisObj valueForKey:param.col];
                                        itemValue = [itemValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                    }
                                }else if(!haveFunc_code){
                                    itemValue = [bspDisObj valueForKey:param.col];
                                    itemValue = [itemValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                }
                                
                                if (itemValue
                                    && [itemValue length] > 0
                                    && ![itemValue isEqualToString:@"null"]) {
                                    if (![m_dsIds containsObject:moreProd.Id]) {
                                        [prodArray  addObject:moreProd];
                                    }
                                    break;
                                }
                            }
                        }
                        
                    }
                }
            }
            if ([prodArray count] > 0) {
                [self.moreProductArray removeObjectsInArray:prodArray];
            }
        }
        
//        
//        if ([self nativeRedis] && [self.m_DataBaseDatas count] > 0) {
//            
//            for (WSProductObject *productObject in self.m_DataBaseDatas) {
//                
//                for ( WSProdBean *moreProd in self.moreProductArray) {
//                    if ([moreProd.Id isEqualToString:productObject.prod_id]) {
//                        for (WSFuncsBean_Param *param in self.currentFuncs.paramArray) {
//                            if ([param.tpy isEqualToString:COL_TYPLNR]) {
//                                continue;
//                            }
//                            
//                            NSString *value = [productObject valueForKey:param.col];
//                            
//                            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//                            
//                            if (value
//                                && [value length] > 0
//                                && ![value isEqualToString:@"null"] && ![m_dsIds containsObject:moreProd.Id]) {
//                                [prodArray  addObject:moreProd];
//                                break;
//                            }
//                        }
//                    }
//                }
//            }
//            
//        }
        
        if ([prodArray count] > 0) {
            
            //产品表格里如果有分销规则，则按分销规则对产品进行排序
            /*过滤去除和查出产品Id一样的数据*/
            NSArray *queryRedisMoreProductIds = [prodArray valueForKeyPath:@"@distinctUnionOfObjects.Id"];
            NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"NOT (SELF.Id in %@)", queryRedisMoreProductIds];
            self.m_store_prod = [NSMutableArray arrayWithArray:[self.moreProductArray filteredArrayUsingPredicate:thePredicate]];
            /*分销规则的 和查出回显更多的*/
            NSMutableArray *dataSource = [NSMutableArray arrayWithArray:self.m_dataSources];
            [dataSource addObjectsFromArray:prodArray];
            self.m_dataSources = dataSource;
        }
        
    }else if ([self.currentFuncs.ds isEqualToString:DICTS]) {
        //TODO 暂无需求，不处理
        
    }

    
}

- (void) addMoreProductToGrideView
{
    LogTrace();
    [self newAddMoreProductToGrideView];
    
//    if (self.moreProductArray && [self.moreProductArray count] > 0) {
//        self.productsList = [NSMutableArray arrayWithArray:self.moreProductArray];
//    } else {
//        WSBaseProductDBService *baseProductDBSerice = [[WSBaseProductDBService alloc] init];
//        self.productsList = [baseProductDBSerice  queryAllProducts];
//    }
    
    // SFA-11924 及 SFA-3961 扫码不需要根据分销规则过滤
    NSString *pType = self.baseDataGridComponentDataSource.pType;
    if ([pType length] > 0) {
        WSBaseProductDBService *baseProductDBSerice = [[WSBaseProductDBService alloc] init];
        NSString *condition = pType;
        if ([self.iBrandId length] > 0) {
            condition = [condition stringByAppendingFormat:@"@%@", self.iBrandId];
        }
        self.productsList = [baseProductDBSerice queryProductsWithCondition:condition];
    }
}

#pragma mark -  new filter more

- (NSArray *) getProdTypeArray{
    //排除 filter 配置的是品牌模式
    /* 旧的过滤方法
    if (!self.iBrandId ||  [self.iBrandId length] < 1) {
        
        NSString *filter = self.currentFuncs.filter;
        if (filter && [filter length] > 0) {
            return [filter componentsSeparatedByString:@","];
        }
    }
     */
    
    
    NSString *filter = self.currentFuncs.filter;
    if (filter && [filter length] > 0) {
        return [filter componentsSeparatedByString:@","];
    }
    
    return  [NSArray array];
}

#pragma maark - delete action

- (NSUInteger) getProdSpecIndexWithContent:(NSString*)content
{
    
    if (!content || [content length] < 1) {
        return NSNotFound;
    }
    
    NSArray* ps = [WSAppData getObjectbyKey:PRODSPEC];
    if (ps) {
        return [ps indexOfObject:content];
    }
    
    return NSNotFound;
}

- (void)flushGridView
{
    self.showAddedProds = YES;
    [self.m_dataSources removeAllObjects];
    [self.datas removeAllObjects];
    [self.m_dataSources addObjectsFromArray:self.m_addedDataSources];
    [self flushProdsGridView];
}

- (void)flushProdsGridView
{
    [self.contentScrollView removeAllSubviews];
    if (INTERFACE_IS_PHONE) {   // ipad 暂定不需要添加storenamelabel
        [self loadStoreNameLabel];
    }
    [self loadGridViewSearchBar];
    if (self.seacherSelectIndex) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.seacherSelectIndex inSection:0];
        [self.firstGridSearchView scrollToRowSelectIndexPath:indexPath];
        
    }
    
    [self reLayoutButtonAndGridViewWithIsAllProducts:YES];
    [self resetCheckBoxALL];

}

#pragma mark - 执行校验lua脚本

- (BOOL)executeValidateLuaScrip
{
    NSString *scriptString = self.currentFuncs.script;
    
    if (scriptString && [scriptString length] > 0 && [scriptString rangeOfString:@"function checkProductValidateInTable()"].length > 0) {
        WSLuaScriptContext *luaParserObjTest = [[WSLuaScriptContext alloc] initWithFuncsBean:self.currentFuncs
                                                                               withStoreBean:self.currentStore
                                                                                    withAcvt:nil];
        luaParserObjTest.luaScriptStr = scriptString;
        __weak __typeof(self) wself = self;
        __block NSString *errorInfo = nil;
        
        [luaParserObjTest initializationWithVariableParamsBlock:^NSString *(id firstObj, ...) {
            
            __strong __typeof(wself) sself = wself;
            
            NSString *dependTableFc = nil;
            NSString *dependColName = nil;
            NSString *validateGroupNames = nil;
            NSString *currentColName = nil;
            
            va_list argsList;
            if (firstObj) {
                va_start(argsList, firstObj);
                id secondObj;
                secondObj = va_arg(argsList, id);
                
                id thirdObj;
                thirdObj = va_arg(argsList, id);
                
                id fourthObj;
                fourthObj = va_arg(argsList, id);
                va_end(argsList);
                
                if ([firstObj isKindOfClass:[NSString class]]) {
                    dependTableFc = [NSString stringWithFormat:@"%@",firstObj];
                }
                
                if([secondObj isKindOfClass:[NSString class]]){
                    dependColName = [NSString stringWithFormat:@"%@",secondObj];
                }
                
                if([thirdObj isKindOfClass:[NSString class]]){
                    validateGroupNames = [NSString stringWithFormat:@"%@",thirdObj];
                }
                
                if([fourthObj isKindOfClass:[NSString class]]){
                    currentColName = [NSString stringWithFormat:@"%@",fourthObj];
                }

                LogInfo(@"dependTableName = %@", dependTableFc);
                LogInfo(@"dependColName = %@", dependColName);
                LogInfo(@"validateGroupNames = %@", validateGroupNames);
                LogInfo(@"currentColName = %@", currentColName);
                
                
                NSArray *groupNameArray = [validateGroupNames componentsSeparatedByString:@","];
                
                WSProductValidateBeanArray *array = [WSAppData getObjectbyKey:PRODUCT_VALIDATE];
                for (NSString *groupName in groupNameArray) {
                    WSProductValidateBean *groupProdBean = [array getGroupProductByGroupName:groupName];
                    BOOL isUpload = [sself isProductUploaded:groupProdBean.prodId fc:dependTableFc colName:dependColName];
                    if (isUpload) {
                        NSArray *skuProdArray = [array getSKUProductArrayByGroupName:groupName];
                        NSInteger skuSum = 0;
                        for (WSProductValidateBean *skuProdBean in skuProdArray) {
                            if ([sself isProductFilled:skuProdBean.prodId colName:currentColName]) {
                                skuSum += [skuProdBean.fenzhi integerValue];
                            }
                        }
                        
                        if (skuSum < [groupProdBean.fenzhi integerValue]) {
                            errorInfo = groupProdBean.tip;
                            break;
                        }
                    }
                }
            }
            
            return @"1";
        }];
        WSLuaScriptEnter *luaEnter = [[WSLuaScriptEnter alloc] init];
        [luaEnter initializationLuaContextWithLuaScriptContext:luaParserObjTest];
        [luaEnter runCheckProductValidateInTable];
        
        if ([errorInfo length] > 0) {
            [MBProgressHUD showHUDAddedTo:self.view withText:errorInfo tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:2.0];
            return NO;
        }
    }
    
    return YES;
}

/** 
 * prodID对应的产品在fc对应的表格中，colName列的数据是否填写并上传。
 **/
- (BOOL)isProductUploaded:(NSString *)prodID fc:(NSString *)fc colName:(NSString *)colName
{
    BOOL result = NO;
    
    NSArray *prodArray = [[WSFptTable sharedTable] queryProductWithStoreId:self.currentStore.Id fc:fc title:nil andSrid:nil];
    
    for (WSProductObject *prodObj in prodArray) {
        if ([prodObj.prod_id isEqualToString:prodID]) {
            
            NSString *value = [prodObj valueForKey:colName];
            
            if ([value length] > 0 && value) {
                result = YES;
            }
            
            break;
        }
    }
    
    
    return result;
}

- (BOOL)isProductFilled:(NSString *)prodID colName:(NSString *)colName
{
    BOOL result = NO;
    
    NSInteger prodCount = [self.datas count];
    if ([[self.datas lastObject] isKindOfClass:[NSDictionary class]]) {
        --prodCount;
    }
    
    for(int i = 0 ; i < prodCount; i++)
    {
        NSArray* row = (NSArray*)[self.datas objectAtIndex:i];
        
        //prod_id
        UILabel* prodId = [row objectAtIndex:0];
        if ([prodId.productID isEqualToString:prodID]) {
            
            WSFuncsBean_Param *paramBean = nil;
            
            for (WSFuncsBean_Param *param in self.currentFuncs.paramArray) {
                if ([param.col isEqualToString:colName]) {
                    paramBean = param;
                    break;
                }
            }
            
            if (paramBean) {
                NSInteger index = [self getSpecIndexbyParam:paramBean];
                UIView *findView = nil;
                for (int j = 0; j < [row count]; j ++) {
                    UIView *view = [row objectAtIndex:j];
                    if (view.tag == index) {
                        findView = view;
                        break;
                    }
                }
                
                if ([findView isKindOfClass:[UIButton class]]) {
                    UIButton *button = (UIButton *)findView;
                    if (button.isSelected) {
                        result = YES;
                    }
                }
                
            }
            
            
            break;
        }
        
    }
    
    return result;
}
- (void)reLayoutButtonAndGridViewWithIsAllProducts:(BOOL)isAllProducts {
    self.isAllProducts = isAllProducts;
    
    [self initDataSource];
    [self setGrideViewData];
    [self createDataGridView];
    [self addFuncsOtherBeanView];
    [self addOptView];
    [self refreshButtonAndGrid];
    self.contentScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.y_point );
}

@end
