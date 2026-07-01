//
//  WSEmbeddedAcvtViewController.m
//  WinSFA
//  内嵌ACVT 
//  Created by xiajl on 14-11-6.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSEmbeddedAcvtViewController.h"
#import "WSImagePathTable.h"
#import "WSJSONBuilder.h"
#import "WSRequestHelper.h"
#import "WSEnvrionment.h"
#import "WSNestedAcvtModel.h"
#import "WSAcvtView.h"
#import "WSDataSourceManager.h"

@interface WSEmbeddedAcvtViewController ()

@end

@implementation WSEmbeddedAcvtViewController

- (void)createModel
{
    self.model = [[WSNestedAcvtModel alloc] init];
}

- (void)initAcvtModel
{
    [super initAcvtModel];
    
    ((WSNestedAcvtModel *)self.model).parentModel  = self.parentModel;
    
    self.hideNoDataAlert = YES;
}

- (void)setParentModel:(WSAcvtModel *)parentModel
{
    _parentModel = parentModel;
    ((WSNestedAcvtModel *)self.model).parentModel  = self.parentModel;
}


- (void)addToolBar {
    LogTrace();
    
    if((self.m_currentAcvt.isReadonly != nil && self.m_currentAcvt.isReadonly.integerValue == 1)
       || (self.m_currentAcvt.parentReadonly != nil && self.m_currentAcvt.parentReadonly.integerValue == 1)
       || self.uploadBtnHidden){
        return;
    }
    
    
    if (self.uploadButton == nil) {
        NSString *UploadString = NSLocalizedString(@"confirm",nil);
        
        self.uploadButton = [[UIBarButtonItem alloc]
                             initWithTitle:UploadString
                             style:UIBarButtonItemStyleDone
                             target:self
                             action:@selector(executeUpload)];

    }
    
    if(self.m_ParentViewController != nil) {
        self.m_ParentViewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.uploadButton, nil];
    }
    else{
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.uploadButton, nil];
    }
    
    
}

- (void)validateAndUpload
{
    
    if (![self executeValidate]) {
        return;
    }
    [self checkSameMainTitleTipAndUpload];
}

- (BOOL)uploadAcvtDatas
{
    if (self.isGpsReady) {
        [self addGPSData];
    }
    
    BOOL hasPhoto = [self.photoBrowseView.imageIDArray count] > 0? YES:NO;

    NSMutableDictionary *qstValuesDic =  (NSMutableDictionary *)[self.acvtview getAllPrepareSubmitData];
    WSAcvtModel *model = (WSAcvtModel *)self.model;
    
    NSArray *tableDatas = [self getTableDatasWithNewAcvtMD5:nil];

    NSString* postData = [WSJSONBuilder buildAcvtDatasbyFuncs:model.currentFuncs
                                                         acvt:model.currentAcvtBean
                                                      isPhoto:hasPhoto
                                                        Store:model.currentStore
                                                 qstValuesDic:qstValuesDic
                                                          md5:model.md5
                                                     submitId:model.md5
                                                       Others:self.m_othersDic
                                            addedAcvtForStore:model.currentNewStore
                                                   tableDatas:tableDatas
                                                   photoNames:nil
                                                    isNeedAdd:NO
                                                        isAdd:NO];
    
    id postDataDic = [postData mutableObjectFromJSONString];
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix, [WSJSONBuilder gen_uuid]];
    if ([model isSynchronizeRequest]) {
        notifyID = [NSString stringWithFormat:@"%@%@", notifyID, kForcibleSynchronizeRequest];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadDatasFinish:) name:notifyID object:nil];
    }

    NSMutableDictionary *jsonData;
    if ([postDataDic isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)postDataDic];
        jsonData =(NSMutableDictionary *)[mDic objectForKey:@"jsonData"];
        
        [jsonData setObject:model.md5 forKey:@"id"];
        
        // SFA-26855 【SFA泸州老窖】【iOS】上传陈列协议时，如果后台校验失败，再次新增陈列协议会上传两条记录
        if (![self.memo2 isEqualToString:@"newest"]) {
            if (self.parentModel && [self.parentModel isKindOfClass:[WSAcvtModel class]]) {
                if (!self.parentModel.anJsonDataDictionary) {
                    self.parentModel.anJsonDataDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
                }
                NSString * key = [NSString stringWithFormat:@"%@%@",QST_TYPE_AN,self.m_currentAcvt.acvtId];
                id dic = [self.parentModel.anJsonDataDictionary objectForKey:key];
                if ([dic isKindOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *mutableDic =  [NSMutableDictionary dictionaryWithDictionary:dic];
                    [mutableDic setObject:jsonData forKey:model.md5];
                    //AN + 嵌套问卷的avctID 做键
                    [self.parentModel.anJsonDataDictionary setValue:mutableDic forKey:key];
                }else{
                    
                    NSDictionary *dic = [NSDictionary dictionaryWithObject:jsonData forKey:model.md5];
                    [self.parentModel.anJsonDataDictionary setValue:dic forKey:key];
                }
            }
        }
    }
    
    //插入数据
    NSDate *bef = [NSDate date];
    //MSTD-7656
    //备注：因为上传的时候不能按千分位上传，所以存的时候我们需要判断一下是否要显示成千分位如果需要显示成千分位则按千分位存，这样取回显的时候才能按千分位的格式显示
    //当上传的值和保存的值不一样的时候才需要重新获取
    NSMutableDictionary *saveQstValuesDic = [NSMutableDictionary dictionaryWithDictionary:qstValuesDic];
    if (![self isSameUploadAndSaveData]) {
       saveQstValuesDic =  (NSMutableDictionary *)[self.acvtview  getAllPrepareSaveDataByIsIgnoreNullValue:nil resultdict:qstValuesDic];
    }
    if (![model saveAcvtDatasToDB:saveQstValuesDic useNewMd5:nil]) {
        return NO;
    }else{
        [self saveTBAcvtDatasToDB];
    }
    ////////////////////////////////////////////////////////////////////////////////ADD BY JIMMY LEE
    [[NSUserDefaults standardUserDefaults] setValue:self.md5 forKey:@"embedAcvtResultId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    ////////////////////////////////////////////////////////////////////////////////ADD BY JIMMY LEE
    NSDate *aft = [NSDate date];
    LogInfo(@"saveAcvtDatasToDB耗时：%f", [aft timeIntervalSinceDate:bef]);
    
    
    if (![self uploadNewAcvtDeletePhotos]) {
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(embeddedAcvtController:confirmData:)]) {
        [self.delegate embeddedAcvtController:self confirmData:jsonData];
    }
    
    if ([model isSynchronizeRequest]) {
        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
        [self popToParentOrHome];
    }

    
    return YES;
}

- (BOOL)isSameUploadAndSaveData
{
    for (WSWidget *widget in self.acvtview.widgetArray) {
        WSAcvtBean_qst *qst = (WSAcvtBean_qst *)[widget xbuildInfo];
        if ([qst.qstType isEqualToString:QST_TYPE_N] && [qst.displayMode isEqualToString:QST_DISPLAYMODE_QUARTILE]) {
            return NO;
        }
    }
    return YES;
}
- (void)beginToVisitStore:(UIButton *)sender {
    
    self.currentUploadActionType = WSVisitActionType;
    if ([self executeValidate]) {
        
        NSString *AccessInforString = NSLocalizedString(@"update_data_tip",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:AccessInforString  tips:nil tapTarget:self action:nil];
        
        [self executeRealUpload];
        
    }else{
        self.currentUploadActionType = WSNormalActionType;
    }
    
    
    
}
//创建一个方法 获取该问卷的acvtdata --zhangmin MMSH-8185
- (NSDictionary *)getAcvtData  {
    [WSDataSourceManager sharedInstance].currentActiveModel = self.model;
    if (self.isGpsReady) {
        [self addGPSData];
    }
    
    BOOL hasPhoto = [self.photoBrowseView.imageIDArray count] > 0? YES:NO;
    
    NSMutableDictionary *qstValuesDic =  (NSMutableDictionary *)[self.acvtview getAllPrepareSubmitData];
    WSAcvtModel *model = (WSAcvtModel *)self.model;
    
    NSArray *tableDatas = [self getTableDatasWithNewAcvtMD5:nil];
    
    NSString* postData = [WSJSONBuilder buildAcvtDatasbyFuncs:model.currentFuncs
                                                         acvt:model.currentAcvtBean
                                                      isPhoto:hasPhoto
                                                        Store:model.currentStore
                                                 qstValuesDic:qstValuesDic
                                                          md5:model.md5
                                                     submitId:model.md5
                                                       Others:self.m_othersDic
                                            addedAcvtForStore:model.currentNewStore
                                                   tableDatas:tableDatas
                                                   photoNames:nil
                                                    isNeedAdd:NO
                                                        isAdd:NO];
    
    id postDataDic = [postData mutableObjectFromJSONString];
    NSMutableDictionary *jsonData;
    if ([postDataDic isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)postDataDic];
        jsonData =(NSMutableDictionary *)[mDic objectForKey:@"jsonData"];
        
        [jsonData setObject:model.md5 forKey:@"id"];
        [jsonData setObject:model.currentAcvtBean.acvtId forKey:@"acvtId"];
        if (self.parentModel && [self.parentModel isKindOfClass:[WSAcvtModel class]]) {
            if (!self.parentModel.anJsonDataDictionary) {
                self.parentModel.anJsonDataDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
            }
            NSString * key = [NSString stringWithFormat:@"%@%@",QST_TYPE_AN,self.m_currentAcvt.acvtId];
            id dic = [self.parentModel.anJsonDataDictionary objectForKey:key];
            if ([dic isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *mutableDic =  [NSMutableDictionary dictionaryWithDictionary:dic];
                [mutableDic setObject:jsonData forKey:model.md5];
                //AN + 嵌套问卷的avctID 做键
                [self.parentModel.anJsonDataDictionary setValue:mutableDic forKey:key];
            }else{
                
                NSDictionary *dic = [NSDictionary dictionaryWithObject:jsonData forKey:model.md5];
                [self.parentModel.anJsonDataDictionary setValue:dic forKey:key];
            }
        }
    }
    
    
    if (![model saveAcvtDatasToDB:qstValuesDic useNewMd5:nil]) {
        //        return NO;
    }else{
        [self saveTBAcvtDatasToDB];
    }
    
    if (qstValuesDic.count > 0) {
        return jsonData;
    }else {
        return nil;
    }
    
}
@end
