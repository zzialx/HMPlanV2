//
//  SalesPersonInfoViewController.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-3-12.
//
//

#import "WSSalesPersonInfoViewController.h"
#import "WSSalesPersonInfoBean.h"
#import "WSRequestHelper.h"
#import "WSAppData.h"
#import "DataGridComponent.h"
#import "WSFuncsBean_other.h"
#import "WSVisitStoreActionTable.h"
#import "WSCheckBox.h"
#import "WSAcvtButtonForTB.h"
#import "WSSelectListView.h"
#import "WSMultipleChoiceLabel.h"
#import "WSFdtTable.h"
#include "WSJSONBuilder.h"

#define SPIUPDATA_NOTIFY @"spiupdata_notify"

@interface WSSalesPersonInfoViewController ()

@property (nonatomic, assign) BOOL hasFinishUpload;
/*
 *  回传给服务器
 *  why？who TM knows！
 *  后台 liyang 提出的需求
 */
@property (nonatomic, retain) NSMutableArray *sendBackToTheFuckingServer;

@end

@implementation WSSalesPersonInfoViewController
- (void)loadView {
    [super loadView];
    self.hasFinishUpload = NO;
    
    WSFdtObject *object = nil;
    if ([self.currentFuncs.otherArray count]) {
        NSArray* array=[[WSFdtTable sharedTable] queryFdtWithStoreId:self.currentStore.Id fc:self.currentFuncs.fc srid:self.currentStore.srid] ;
        if(array.count>0){
            object=[array firstObject];
        }
    }
    if(object){
        for (int i = 0; i < [self.currentFuncs.otherArray count]; i++) {
            WSFuncsBean_other *other = [self.currentFuncs.otherArray objectAtIndex:i];
            if (([other.tpy isEqualToString:OTHER_TPY_N] || [other.tpy isEqualToString:OTHER_TPY_T]) &&
                [other.col hasPrefix:@"memo"]) {
                
                UIView *infoView = [self.view viewWithTag:(OTHER_TEXTFIELD_TAG + i)];
                if ([infoView isKindOfClass:[UITextField class]]) {
                    UITextField *field = (UITextField *)infoView;
                    NSString *value = [object valueForKey:other.col];
                    if ([value isKindOfClass:[NSString class]]) {
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
        }
    }

}

- (NSArray *)getDatasSources {
    if (self.hasFinishUpload) {
        return self.m_dataSources;
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(finishRequest:)
                                                     name:SPIUPDATA_NOTIFY
                                                   object:nil];

        NSMutableDictionary *outPlan = [NSMutableDictionary dictionary];
        [outPlan setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] forKey:@"empId"];
        [outPlan setObject:@"pminpost" forKey:@"objId"];
        [outPlan setObject:[NSString stringNotNilWithValue:self.currentFuncs.filter] forKey:@"filter"];
        [outPlan setObject:[NSString stringNotNilWithValue:self.currentStore.Id] forKey:@"storeId"];
        WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
        
        [uploadMgr postRequestData:outPlan notifyName:SPIUPDATA_NOTIFY];
        UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        aiv.hidesWhenStopped = YES;
        [aiv startAnimating];
        [self querying_messageTips];

        
        return nil;
    }
}

-(void)setGrideViewData
{
    if([self.currentFuncs.paramArray count] < 1)
        return;
    //数据库数据
    if(self.m_dataSources == nil)
    {
        self.m_DataBaseDatas = [[NSMutableArray alloc]init];
    }
    //填充表头数据
    [self setColumnsDatasOfTitles];
    //设置表的宽度
    [self setColunmViewWidth];
    
    NSArray* l_dataSources = [self getDatasSources];
    //填充表内的数据
    if(self.m_dataSources == nil)
    {
        self.m_dataSources = [[NSMutableArray alloc] init];
        [self.m_dataSources addObjectsFromArray:l_dataSources];
        //NSLog(@"m_datasource is %@",self.m_dataSources);
    }
    
    NSInteger l_dataSourcesCount = [self.m_dataSources count];
    //去掉第一列的总数
    NSInteger l_datasColumns = 0;
    
    l_datasColumns = [self.titles count] - 1;
    
    //    [self.datas removeAllObjects];
    NSInteger startPosition = 0;
    //修改self.m_moreProdsCount!=0 为self.m_moreProdsCount>0 by yanguoshuai at 2012-04-09
    if(self.m_moreProdsCount > 0)
        startPosition = l_dataSourcesCount - self.m_moreProdsCount;
    if(self.m_moreProdsCount == NONEEXIST)
        startPosition = l_dataSourcesCount;
    
    for (NSInteger i = startPosition; i < l_dataSourcesCount; i++) {
        NSMutableArray *l_rowView = [[NSMutableArray alloc]  initWithCapacity:[self.titles count]];
        
        //插入行的第一列
        [l_rowView insertObject:[self setFirstColumnDataWithIndex:i Datas:self.m_dataSources] atIndex:0];
        
        for (NSInteger j = 0; j < l_datasColumns; j++) {
            
            WSFuncsBean_Param *param = [self.currentFuncs.paramArray objectAtIndex:j + 1];
            id data = [self.m_dataSources objectAtIndex:i];
            WSHTextField* l_textField = [self setGrideViewDataKindOfTextField:param data:data lastValue:l_dataSourcesCount  iRow:i  iColumn:j+1];
            if(l_textField != nil)
            {
                [self setDependedInfoWith:l_textField withParam:param withRow:i andColumn:j];
                
                if (param.listener)
                {
                    NSString *key = [NSString stringWithFormat:@"%ld%@",(long)i,param.col];
                    
                    if (l_textField) {
                        [self.formulaDictionary setObject:l_textField forKey:key];
                    }
                    
                }
                else if (param.value)
                {
                    NSString *originalKey = [NSString stringWithFormat:@"%ldvalue%@",(long)i,param.value];
                    NSString *desString = [NSString stringWithFormat:@"%ldcol",(long)i];
                    NSString *key = [originalKey stringByReplacingOccurrencesOfString:@"col" withString:desString];
                    
                    if (l_textField) {
                        [self.formulaDictionary setObject:l_textField forKey:key];
                    }
                    
                }
                [l_rowView addObject:l_textField];
            }
            
            UIButton* l_button = [self setGrideViewDataKindOfButton:param Data:[self.m_dataSources objectAtIndex:i] iRow:i  iColumn:j+1];
            //            l_button.tag = i;
            if(l_button != nil) {
                if ([l_button isKindOfClass:[WSCheckBox class]]) {
                    [self setDependedInfoWith:(WSCheckBox *)l_button withParam:param withRow:i andColumn:j];
                }
                [l_rowView addObject:l_button];
            }
            
            WSAcvtButtonForTB* l_badReason = (WSAcvtButtonForTB *)[self setGrideViewDataKindOfBadReason:param];
            
            if(l_badReason != nil)
            {
                l_badReason.tag = l_badReason.tag + i;
                [self setDependedInfoWith:l_badReason withParam:param withRow:i andColumn:j];
                [l_rowView addObject:l_badReason];
            }
            
            WSSelectListView *list = [self setGrideViewDataKindofSelectList:param Data:[self.m_dataSources objectAtIndex:i]];
            if (list != nil) {
                //                list.tag = i;
                [l_rowView addObject:list];
            }
            
            WSMultipleChoiceLabel *lable = (WSMultipleChoiceLabel *)[self setGrideViewDataKindofMultipleChoice:param Data:[self.m_dataSources objectAtIndex:i]];
            if (lable != nil) {
                [self setDependedInfoWith:lable withParam:param withRow:i andColumn:j];
                [l_rowView addObject:lable];
            }
            
            if ([param.tpy isEqualToString:COL_TYPPHOTO]) {
                PhotoTypeButton *button = [self setGrideViewDataKindOfPhotoButton:param Data:[self.m_dataSources objectAtIndex:i]];
                [self setDependedInfoWith:button withParam:param withRow:i andColumn:j];
                
                NSString* mImageIdx=[NSString stringWithFormat:@"%@_%@",self.currentFuncs.fc,self.md5];
                NSString* cellKey=[NSString stringWithFormat:@"%ld_%@", (long)i, param.col];
                button.imageMD5 = [Md5Manager getMd5ByEmpId:nil
                                                    sotreId:nil
                                                    bizDate:nil
                                                   funcCode:nil
                                                     acvtId:mImageIdx
                                                       memo:cellKey];
                [l_rowView addObject:button];
            }
        }
        
        [self.datas addObject:l_rowView];
    }
}

- (void)setColunmViewWidth {
    if(self.colWidth==nil) {
        NSMutableArray* colArray = [[NSMutableArray alloc]init];
        self.colWidth = colArray;
    }
    [self.colWidth removeAllObjects];
    
    NSInteger a_paramCount =[self.currentFuncs.paramArray count];
    
    for( int i = 0; i < a_paramCount; i++) {
        WSFuncsBean_Param *fb = nil;
        fb = [self.currentFuncs.paramArray objectAtIndex:i];
        
        if (fb.wcol != 0) {
            [self.colWidth addObject:[NSString stringWithFormat:@"%ld", (long)fb.wcol]];
        } else {
            [self.colWidth addObject:[NSString stringWithFormat:@"%d", 60]];
        }
    }
}

-(void)setColumnsDatasOfTitles
{
    if([self.titles count]==0)
    {
        //        if (![self.currentFuncs.fv isEqualToString:@"V20T02"] && ![self.currentFuncs.fv isEqualToString:@"V20T05"] )
//        {
//            NSString *item = nil;
//            if ([self.currentFuncs.ds isKindOfClass:[NSString class]] && ([self.currentFuncs.ds isEqualToString:DS_PROD] || [self.currentFuncs.ds isEqualToString:DS_PRODC])) {
//                item = NSLocalizedString(@"default_left_attach_header_label", nil);
//            } else {
//                item =  NSLocalizedString(@"table_dict_title_project", nil); //项目
//            }
//            [self.titles addObject:item];
//        }
        
        NSInteger paramCount = [self.currentFuncs.paramArray count];
        for(int i = 0 ; i < paramCount; i++)
        {
            WSFuncsBean_Param* fb_Param = [self.currentFuncs.paramArray objectAtIndex:i ];
            [self.titles addObject:fb_Param.name];
        }
        
    }
    
}

- (void)finishRequest:(id)sender {
    self.hasFinishUpload = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SPIUPDATA_NOTIFY
                                                  object:nil];
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    //NSLog(@"outplan is %@",info);
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    } else {
        
        NSDictionary *uploadState = [info objectFromJSONString];
        NSArray *pimnpostArray = [uploadState objectForKey:@"pminpost"];
        NSMutableArray *salesPersonInfoBeanArray = [[NSMutableArray alloc] init];
        self.sendBackToTheFuckingServer = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in pimnpostArray) {
            WSSalesPersonInfoBean *spb = [[WSSalesPersonInfoBean alloc] initWithObject:dic];
//            if (spb != nil) {
//                if ([spb.typ isKindOfClass:[NSString class]] && [spb.typ isEqualToString:self.currentFuncs.filter]) {
                    [salesPersonInfoBeanArray addObject:spb];
                    [_sendBackToTheFuckingServer addObject:dic];
//                }
//            }
        }
        
        
        [self.m_dataSources removeAllObjects];
        [self.m_dataSources addObjectsFromArray:salesPersonInfoBeanArray];
        [self setGrideViewData];
        for(UIView* view in self.contentScrollView.subviews)
        {
            if([view isKindOfClass:[DataGridComponent class]])
            {
                DataGridComponentDataSource *comData = [[DataGridComponentDataSource alloc]
                                                        init];
                
                comData.titles = self.titles;
                comData.data = self.datas;
                comData.columnWidth = self.colWidth;
                
                
                DataGridComponent *compView = [[DataGridComponent alloc]
                                               initWithFrame:
                                               CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height) data:comData];
                compView.frame = view.frame;
                //            [view addSubview:compView];
                //view = compView;
                [view removeFromSuperview];
                [self.view addSubview:compView];
            }
        }        
    }
}

- (NSArray *)getDataBaseDatas {
    return nil;
}

- (NSString*)getDatasFromDataBaseWithParam:(WSFuncsBean_Param*)aParam Data:(id)aStoreInfo {
    return nil;
}

- (NSString *)getDataSourcesWithIndex:(NSNumber*)aIndex Other:(NSArray*)aProds {
    WSSalesPersonInfoBean *spinfo = [aProds objectAtIndex:[aIndex intValue]];
    return spinfo.col1;
}

- (NSString*)getDefaultDataWithParam:(WSFuncsBean_Param*)aParam Others:(id)aInfoObject {
    return [aInfoObject valueForKey:aParam.col];
}


- (void)upload {
    
    if ([self.currentFuncs.required isEqualToString:@"R"]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *storeString=[[NSString alloc]initWithFormat:@"%@.plist",self.currentStore.name];
        NSString *WorkListFile=[documentsDirectory stringByAppendingPathComponent:storeString];
        
        NSMutableDictionary *WorkListDic=[[NSMutableDictionary alloc]initWithContentsOfFile:WorkListFile];
        for (int i=0; i< [[WorkListDic allKeys] count]; i++) {
            if ([self.currentFuncs.name isEqualToString:[[WorkListDic allKeys]objectAtIndex:i]]) {
                if (![[WorkListDic objectForKey:[[WorkListDic allKeys] objectAtIndex:i]] isEqualToString:@"1"]) {
                    
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
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"uploading_prompt", nil)  tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
    
    if (![self insertDictData]) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    if (![self uploadDatas]) {
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    
//  [self uploadPhotos];
    [self backToParent];
}

- (BOOL)insertDictData {
    
    NSString *storeid = ((self.currentStore != nil) ? self.currentStore.Id : @"");
    NSNumber *isPlan = [NSNumber numberWithBool:self.currentStore.plan];
    
    NSMutableArray *fdtValues = [[NSMutableArray alloc] init];
    
    // FUNC_CODE
    NSString *fc = self.currentFuncs.fc;
    fc = [fc isKindOfClass:[NSString class]] ? fc : @"null";
    [fdtValues addObject:fc];
    
    // FUNC_VIEW
    NSString *fv = self.currentFuncs.fv;
    fv = [fv isKindOfClass:[NSString class]] ? fv : @"null";
    [fdtValues addObject:fv];
    
    // IS_PLANED
    NSString *isPlane = [isPlan stringValue];
    isPlane = [isPlane isKindOfClass:[NSString class]] ? isPlane : @"null";
    [fdtValues addObject:isPlane];
    
    // ORG_ID
    [fdtValues addObject:@"null"];
    
    // STORE_ID
    storeid = [storeid isKindOfClass:[NSString class]] ? storeid : @"null";
    [fdtValues addObject:storeid];
    
    // EMP_ID
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    empId = [empId isKindOfClass:[NSString class]] ? empId : @"null";
    [fdtValues addObject:empId];
    
    // BIZ_DATE
    NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    bizDate = [bizDate isKindOfClass:[NSString class]] ? bizDate : @"null";
    [fdtValues addObject:bizDate];
    
    // UPLOAD_DATE
    NSString *uploadDate = [WSCurrentTime getDateString];
    uploadDate = [uploadDate isKindOfClass:[NSString class]] ? uploadDate : @"null";
    [fdtValues addObject:uploadDate];
    
    // UPLOAD_FLAG
    [fdtValues addObject:@"0"];
    
    // IMG_IDX
    NSString *md5 = self.md5;
    md5 = [md5 isKindOfClass:[NSString class]] ? md5 : @"null";
    [fdtValues addObject:md5];
    
    // SR_ID
    NSString *srid = (self.currentStore.srid && [self.currentStore.srid length] > 0 ) ? [self.currentStore.srid copy] : @"null";
    [fdtValues addObject:srid];

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
    }
    
    // MEMO"
    NSString *memo = [dicOtherInfo objectForKey:@"memo"];
    memo = [memo isKindOfClass:[NSString class]] ? memo : @"null";
    [fdtValues addObject:memo];
    
    // MEMO1 ~ MEMO10
    for (int i = 0; i < 10; i++) {
        NSString *memoi = [dicOtherInfo objectForKey:[NSString stringWithFormat:@"memo%d", i + 1]];
        memoi = [memoi isKindOfClass:[NSString class]] ? memoi : @"null";
        [fdtValues addObject:memoi];
    }
    
    // MSTD-6968 TITLES
    [fdtValues addObject:@"null"];
    
    return [[WSFdtTable sharedTable] insertWithFdtArray:fdtValues Dict:nil];
}

- (BOOL)uploadDatas {
    
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
    }
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];

//    BOOL hasPhoto = [self.photoDataArr count] > 0 ? YES : NO;
    BOOL hasPhoto = [self.photoBrowseView.imageIDArray count] > 0 ? YES : NO;
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
    NSString *postData = [WSJSONBuilder buildSalesPersonInfoGrideDataByFuncs:self.currentFuncs
                                                                   isPhoto:hasPhoto
                                                                     datas:self.datas
                                                                   dataIDs:self.currentFuncs.paramArray
                                                                     Store:self.currentStore
                                                                       md5:self.md5
                                                                      memo:self.memoData
                                                                 otherInfo:dicOtherInfo
                                                              sendBackData:self.sendBackToTheFuckingServer];
    
    BOOL insertAcvtDataIsSucceed = [self insertUploadData:postData URL:URL_UPLOAD MD5:self.md5 IsPhoto:hasPhoto NotifyName:notifyID];
    
    if (!insertAcvtDataIsSucceed) {
        return insertAcvtDataIsSucceed;
    }
    [uploadMgr postRequestAcvtData:postData
                      notifyName:notifyID
                             md5:self.md5
              isSynchronizeRequest:NO];

    if (self.currentVisitAction) {
        [[WSVisitStoreActionTable sharedTable]  updateAction:self.currentVisitAction toStatus:ActionDone];
    }
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *tip = NSLocalizedString(@"add_upload_queue", nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
    return YES;
}

@end
