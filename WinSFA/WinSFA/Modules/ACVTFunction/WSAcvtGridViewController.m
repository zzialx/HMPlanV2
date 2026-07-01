 //
//  WSAcvtGridViewController.m
//  WinSFA
//
//  Created by yang on 15/10/21.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSAcvtGridViewController.h"
#import "WSAcvtBean.h"
#import "WSJSONBuilder.h"
#import "WSAcvtModel.h"
#import "WSRequestHelper.h"
#import "WSImagePathTable.h"
#import "WSBaseStoreAcvtDisTable.h"
#import "WSBaseAcvtDBService.h"
#import "WSPhotoLogicService.h"

@interface WSAcvtGridViewController ()

@property (nonatomic ,strong) NSArray *acvtArray;

@property (nonatomic ,strong) NSArray *acvtModelArray;

@end

@implementation WSAcvtGridViewController

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store
{
    self = [super initWithFuncs:funcs Store:store];
    
    if (self) {
        
        if (!funcs.paramArray || [funcs.paramArray count] < 1) {
            WSAcvtBean *acvtBean = [self.acvtArray firstObject];
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[acvtBean.qsts count]];
            
            for (WSAcvtBean_qst *qst in acvtBean.qsts) {
                WSFuncsBean_Param *param = [[WSFuncsBean_Param alloc] initFuncsParamWithAcvtQstBean:qst];
                [array addObject:param];
            }
            
            [funcs setParamArrayFromOut:array];
        }
        
        return self;
    }
    
    return nil;
}

- (NSArray *)acvtArray{
    if (!_acvtArray) {
        
        WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
        NSArray *filterArray = [service queryAcvtsWithStoreId:self.currentStore.Id filter:self.currentFuncs.filter];
        
        _acvtArray = filterArray;
        
    }
    return _acvtArray;
}

- (NSArray *)acvtModelArray
{
    if (!_acvtModelArray) {
        NSMutableArray *acvtModelArray = [NSMutableArray arrayWithCapacity:[self.acvtArray count]];
        for (WSAcvtBean *acvtBean in self.acvtArray) {
            WSAcvtModel *acvtModel = [[WSAcvtModel alloc] init];
            acvtModel.currentFuncs = self.currentFuncs;
            acvtModel.currentStore = self.currentStore;
            acvtModel.currentAcvtBean = acvtBean;
            acvtModel.isNewAddAcvt = NO;
            acvtModel.currentVisitAction = self.currentVisitAction;
            [acvtModel createMD5With:[acvtModel md5Param]];
            [acvtModelArray addObject:acvtModel];
        }
        
        _acvtModelArray = [NSArray arrayWithArray:acvtModelArray];
    }
    
    return _acvtModelArray;
    
}

#pragma mark - 获取本地数据库存储的数据

-(NSArray*)getDataBaseDatas
{
    [self.acvtModelArray enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL *stop) {
        WSAcvtModel *acvtModel = (WSAcvtModel *)obj;
        [acvtModel loadDataFromDataBase];
    }];
    
    return self.acvtModelArray;
}

//获取数据库的内容
-(NSString*)getDatasFromDataBaseWithParam:(WSFuncsBean_Param*)param Data:(WSAcvtBean*)acvtBean
{
    for (WSAcvtModel *acvtModel in self.acvtModelArray) {
        if ([acvtModel.currentAcvtBean.acvtId isEqualToString:acvtBean.acvtId]) {
            
            WSAcvtBean_qst *qstBean = [acvtBean getQstBeanByQstID:param.col];
            
            if (![param.tpy isEqualToString:COL_TYPPHOTO]) {
                
                if (acvtModel.qstDBValueDictionary) {
                    if ([acvtModel.qstDBValueDictionary objectForKey:qstBean.acvtQstId]) {
                        return [acvtModel.qstDBValueDictionary objectForKey:qstBean.acvtQstId];
                    }
                }
                
            }
            else {
                
                NSString *imageIndex = [WSPhotoLogicService getAcvtImageIndexWithFC:acvtModel.currentFuncs.fc acvtMD5:acvtModel.md5 acvtQstId:qstBean.acvtQstId];
                NSArray *imageObjectArray = [[WSImagePathTable sharedTable] queryWithImageIDX:imageIndex];
                
                if ([imageObjectArray count] > 0) {
                    NSArray *imageIDArray = [imageObjectArray valueForKeyPath:@"@unionOfObjects.img_path"];
                    return [imageIDArray componentsJoinedByString:@","];
                }
                
            }
            
            return nil;
        }
    }
    
    return nil;
}

#pragma mark - 获取数据源

- (void)initDataSource {
    
    if (!self.baseDataGridComponentDataSource) {
        self.baseDataGridComponentDataSource = [[WSBaseDataGridComponentDataSource alloc] initWithStore:self.currentStore func:self.currentFuncs ownViewController:self andCurrentTableItem:nil];
        
        self.m_dataSources = [NSMutableArray arrayWithArray:self.acvtArray];
        self.baseDataGridComponentDataSource.dataSource = self.m_dataSources;
        
        self.m_DataBaseDatas = [NSMutableArray arrayWithArray:[self getDataBaseDatas]];
        self.baseDataGridComponentDataSource.m_DataBaseDatas = self.m_DataBaseDatas;
        
    }else {
        self.m_DataBaseDatas = [NSMutableArray arrayWithArray:[self getDataBaseDatas]];
        self.baseDataGridComponentDataSource.dataSource = self.m_dataSources;
    }
    
}

-(NSString*)getDataSourcesWithIndex:(NSNumber*)aIndex Other:(NSArray*)aDicts
{
    WSAcvtBean *acvtBean = [aDicts objectAtIndex:[aIndex intValue]];
    return acvtBean.acvtName;
}

-(NSString*)getDataSourcesIdWithIndex:(NSNumber*)aIndex Other:(NSArray*)aDicts
{
    WSAcvtBean *acvtBean = [aDicts objectAtIndex:[aIndex intValue]];
    return acvtBean.acvtId;
}

#pragma mark - 获取服务端回显值

-(NSString*)getDefaultDataWithParam:(WSFuncsBean_Param*)aParam Others:(WSAcvtBean*)aAcvtBean
{
    if (!aParam.redis || aParam.redis.length==0)
    {
        if (aParam.idefault != nil && [aParam.idefault isKindOfClass:[NSString class]]) {
            return aParam.idefault;
        }else{
            return @"";
        }
    }
    
    NSString *acvtQstID = nil;
    
    for (WSAcvtBean_qst *qst in aAcvtBean.qsts) {
        if ([qst.qstId isEqualToString:aParam.col]) {
            acvtQstID = qst.acvtQstId;
            break;
        }
    }
    
    return [self getAcvtDisValueByAcvtBean:aAcvtBean acvtQstId:acvtQstID];
    
}

-(NSMutableArray *)DuplicateRemoval:(NSArray *)array{ // 数组去重
    
    NSMutableDictionary  *dict = [NSMutableDictionary dictionary];
    for (WSBaseStoreAcvtDisObject * object in array) {
        
        [dict setObject:object forKey:object.gen_id];
    }
    NSMutableArray * query = [NSMutableArray arrayWithCapacity:0];
    NSArray * allkeys = [dict allKeys];
    for (NSString  *str in allkeys) {
        [query addObject:[dict objectForKey:str]];
    }
    
    return query;
}

- (NSString *)getAcvtDisValueByAcvtBean:(WSAcvtBean *)acvtBean acvtQstId:(NSString*)acvtQstId
{
    if(self.currentStore && self.currentStore.Id!=nil){
        
        WSBaseStoreAcvtDisTable *baseStoreAcvtDisTable = [WSBaseStoreAcvtDisTable sharedTable];
        NSArray *names = @[@"sid",@"acvtId",@"acvtQstId"];
        NSArray *values = @[[NSString stringNotNilWithValue:self.currentStore.Id],[NSString stringNotNilWithValue:acvtBean.acvtId],[NSString stringNotNilWithValue:acvtQstId]];
        NSArray *querys = [baseStoreAcvtDisTable  queryWithNames:names ArgumentsValue:values];
        if ([querys count] > 0) {
            
            WSBaseStoreAcvtDisObject *obj = (WSBaseStoreAcvtDisObject *)[querys firstObject];
            
            NSArray *filterArray = querys;
            
            if (self.md5 && obj.gen_id) {
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.gen_id = %@", self.md5];
                filterArray = [querys filteredArrayUsingPredicate:predicate];
                filterArray = [self DuplicateRemoval:filterArray]; // 查出来有重复数据，根据gen_id 去重下
            }
            
            NSArray *answerArray = [filterArray valueForKey:@"acvt_qst_answer"];
            
            NSPredicate *predicateNotNull = [NSPredicate predicateWithFormat:@"SELF != %@", [NSNull null]];
            answerArray = [answerArray filteredArrayUsingPredicate:predicateNotNull];
            return [answerArray componentsJoinedByString:@","];
        }
        
        /*
        for(WSStoreAcvtDisBean* f_sad in self.currentStore.acvtDisArray)
        {
            if(f_sad.m_p != nil&& [f_sad.m_p count] >= 4)
            {
                NSString* i_acvtId = [f_sad.m_p objectAtIndex:ACVTDIS_ACVTID];
                NSString* i_acvtQstId = [f_sad.m_p objectAtIndex:ACVTDIS_QSTID];
                if([i_acvtId isEqualToString:acvtBean.acvtId] && [i_acvtQstId isEqualToString:acvtQstId])
                {
                    return [f_sad.m_p objectAtIndex:ACVTDIS_VALUE];
                }
            }
        }
         */
        
    }else{
        
        WSBaseStoreAcvtDisTable *baseStoreAcvtDisTable = [WSBaseStoreAcvtDisTable sharedTable];
        NSArray *names = @[@"sid",@"acvtId",@"acvtQstId",@"gen_id"];
        NSArray *values = @[[NSNull null],[NSString stringNotNilWithValue:acvtBean.acvtId],[NSString stringNotNilWithValue:acvtQstId],[NSString stringNotNilWithValue:self.md5]];
        NSArray *querys = [baseStoreAcvtDisTable  queryWithNames:names ArgumentsValue:values];
        if ([querys count] > 0) {
            NSArray *answerArray = [querys valueForKey:@"acvt_qst_answer"];
            NSPredicate *predicateNotNull = [NSPredicate predicateWithFormat:@"SELF != %@", [NSNull null]];
            answerArray = [answerArray filteredArrayUsingPredicate:predicateNotNull];
            return [answerArray componentsJoinedByString:@","];
        }else {
            names = @[@"sid",@"acvtId",@"acvtQstId",@"gen_id"];
            values = @[[NSNull null],[NSString stringNotNilWithValue:acvtBean.acvtId],[NSString stringNotNilWithValue:acvtQstId],[NSNull null]];
            querys = [baseStoreAcvtDisTable  queryWithNames:names ArgumentsValue:values];
            if ([querys count] > 0) {
                WSBaseStoreAcvtDisObject *obj = (WSBaseStoreAcvtDisObject *)[querys firstObject];
                return obj.acvt_qst_answer;
            }
        }
        
        
    }
    return nil;
}


#pragma mark - upload

- (void)upload
{
    if (![self checkIfRequiredFilled]) {
        return;
    }
    
    if (![self validateData]) {
        return;
    }
    
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

- (BOOL)uploadDatas
{
    __block BOOL updateAcvtDataIsSucceed = YES;
    [self.datas enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *stop) {
        NSArray *uiArray = (NSArray *)obj;
        
        WSAcvtModel *model = [self.acvtModelArray objectAtIndex:idx];
        
        NSMutableDictionary *qstValueDic = [[NSMutableDictionary alloc] initWithCapacity: [uiArray count]];
        
        for (UIView *view in uiArray) {
            if ([view conformsToProtocol:@protocol(WSGettingValues)]) {
                
                WSFuncsBean_Param *param = nil;
                WSAcvtBean_qst *qstBean = nil;
                
                if ([view respondsToSelector:@selector(getTextValue)]) {
                    
                    param = [self.currentFuncs.paramArray objectAtIndex:[uiArray indexOfObject:view] - 1];
                    qstBean = [model.currentAcvtBean getQstBeanByQstID:param.col];
                    
                    NSString *valueString = nil;
                    if ([view isKindOfClass:[PhotoTypeButton class]]) {
                        valueString = [WSPhotoLogicService getAcvtImageIndexWithFC:model.currentFuncs.fc acvtMD5:model.md5 acvtQstId:qstBean.acvtQstId];
                    }else {
                        valueString = [(id<WSGettingValues>)view getTextValue];
                    }
                    
                    if (valueString) {
                        
                        NSString *key = [NSString stringWithFormat:@"%@%@", qstBean.qstType, qstBean.acvtQstId];
                        [qstValueDic setObject:valueString forKey:key];
                    }
                }
                
                if ([view isKindOfClass:[PhotoTypeButton class]]) {
                    
                    if (!qstBean) {
                        qstBean = [model.currentAcvtBean getQstBeanByQstID:param.col];
                    }
                    
                    PhotoTypeButton *photoButton = (PhotoTypeButton *)view;
                    if ([photoButton.deleteIDArray count] > 0) {
                        [self uploadDeletePhotoDatasWithAcvtModel:model qstBean:qstBean deleteImageIDArray:photoButton.deleteIDArray];
                    }
                }
            }
        }
        
        BOOL  updateSucceed = [self uploadAcvtDatasWithAcvtModel:model qstValueDic:qstValueDic];
        if (!updateSucceed) {
            updateAcvtDataIsSucceed = updateSucceed;
            *stop = YES;
        }
    }];
    return updateAcvtDataIsSucceed;
}

- (void)uploadDeletePhotoDatasWithAcvtModel:(WSAcvtModel *)acvtModel qstBean:(WSAcvtBean_qst *)qstBean deleteImageIDArray:(NSArray *)imageIDArray
{
    if (!imageIDArray || [imageIDArray count] <= 0) {
        return;
    }
    
    for (NSString *imageID in imageIDArray) {
        NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
        
        NSString *imageIndex = [WSPhotoLogicService getAcvtImageIndexWithFC:acvtModel.currentFuncs.fc acvtMD5:acvtModel.md5 acvtQstId:qstBean.acvtQstId];
        
        [[WSImagePathTable sharedTable] deleteWithImageIDX:imageIndex withImgKey:imageID];
        
        NSDictionary *params = [WSJSONBuilder buildDelImageParamsDicByImageID:imageID withImgIdx:imageIndex];
        
        [self insertUploadData:[params JSONString] URL:URL_UPLOAD MD5:imageIndex IsPhoto:NO NotifyName:notifyID];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePhotoFinish:) name:notifyID object:nil];
        [[WSRequestHelper shareInstance] uploadDatasDictionary:params urlString:URL_UPLOAD notifyName:notifyID md5:self.md5 isUpload:YES];
    }
}

- (BOOL)uploadAcvtDatasWithAcvtModel:(WSAcvtModel *)acvtModel qstValueDic:(NSDictionary *)qstValueDic
{
    
    BOOL hasPhoto = [self.photoBrowseView.imageIDArray count] > 0 ? YES:NO;
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix, [WSJSONBuilder gen_uuid]];
    
    //插入数据库
    NSDate *bef = [NSDate date];
    [acvtModel saveAcvtDatasToDB:qstValueDic useNewMd5:nil];
    NSDate *aft = [NSDate date];
    LogInfo(@"saveAcvtDatasToDB耗时：%f", [aft timeIntervalSinceDate:bef]);
    
    NSString* postData  = [WSJSONBuilder buildAcvtDatasbyFuncs:acvtModel.currentFuncs
                                                          acvt:acvtModel.currentAcvtBean
                                                       isPhoto:hasPhoto
                                                         Store:acvtModel.currentStore
                                                  qstValuesDic:qstValueDic
                                                           md5:acvtModel.md5
                                                      submitId:acvtModel.md5
                                                        Others:nil
                                                addedAcvtForStore:nil
                                                    tableDatas:nil
                                                    photoNames:nil
                                                     isNeedAdd:NO
                                                         isAdd:NO];
    
    
    BOOL insertAcvtGridDataIsSucceed = [self insertUploadData:postData URL:URL_UPLOAD MD5:acvtModel.md5 IsPhoto:hasPhoto NotifyName:notifyID];
    
    if (!insertAcvtGridDataIsSucceed) {
        return insertAcvtGridDataIsSucceed;
    }
    
    [[WSRequestHelper shareInstance] postRequestAcvtData:postData
                                              notifyName:notifyID
                                                     md5:acvtModel.md5
                                    isSynchronizeRequest:NO];
    
    
    return YES;

}

- (BOOL)uploadPhotos
{
    __block BOOL uploadAcvtPhotoIsSucceed = YES;
    [self.acvtArray enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *stop) {
        
        WSAcvtBean *acvtBean = (WSAcvtBean *)obj;
        
        BOOL hasPhoto = NO;
        
        for (WSAcvtBean_qst *qst in acvtBean.qsts) {
            if ([qst.qstType isEqualToString:QST_TYPE_P]) {
                
                hasPhoto = YES;
                
                NSArray *uiArray = [self.datas objectAtIndex:idx];
                UIView *view = [uiArray objectAtIndex:[acvtBean.qsts indexOfObject:qst] + 1];
                
                if ([view isKindOfClass:[PhotoTypeButton class]]) {
                    PhotoTypeButton *photoButton = (PhotoTypeButton *)view;
                    if ([photoButton.photoIDArray count] > 0) {
                        BOOL uploadSucceed = [self uploadAcvtPhotosWithAcvtModel:[self.acvtModelArray objectAtIndex:idx] qstBean:qst imageIDArray:photoButton.photoIDArray];
                        if (!uploadSucceed) {
                            uploadAcvtPhotoIsSucceed = uploadSucceed;
                            *stop = YES;
                        }
                    }
                }
                
                break;
            }
        }
        
        if (!hasPhoto) {
            *stop = YES;
        }
    }];
    return uploadAcvtPhotoIsSucceed;
}

- (BOOL)uploadAcvtPhotosWithAcvtModel:(WSAcvtModel *)acvtModel qstBean:(WSAcvtBean_qst *)qstBean imageIDArray:(NSArray *)imageIDArray
{
    
    NSString *imageIndex = [WSPhotoLogicService getAcvtImageIndexWithFC:acvtModel.currentFuncs.fc acvtMD5:acvtModel.md5 acvtQstId:qstBean.acvtQstId];
    
    NSMutableArray *dicValueArrayAcvt = [[NSMutableArray alloc] init];
    
    for (NSString *imageID in imageIDArray) {
        NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
        
        if (filePath) {
            
            NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
            
            NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID];
            NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];
            
             BOOL insertPhotoDataIsSucceed = [self insertUploadMedia:[params JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:imageIndex IsPhoto:YES NotifyName:notifyID photoFileName:photoFileName];
           
            if (!insertPhotoDataIsSucceed) {
                return insertPhotoDataIsSucceed;
            }
            [[WSRequestHelper shareInstance] uploadImageWithFilePath:filePath
                                                              params:params
                                                                 url:URL_IMAGEUPLOAD
                                                          notifyName:notifyID
                                                                 md5:imageIndex];
            
            
            NSArray* array = [NSArray arrayWithObjects:imageIndex,imageID,[WSAppData getObjectbyKey:APPDATA_BIZDATE],[WSCurrentTime getDateTime],@"0",nil];
            
            [dicValueArrayAcvt addObject:array];
        }
    }
    
    if (dicValueArrayAcvt && [dicValueArrayAcvt count] > 0) {
        [[WSImagePathTable sharedTable] updateWithImageIDX:imageIndex withValuesArray:dicValueArrayAcvt];
    }
    else
    {
        [[WSImagePathTable sharedTable] deleteWithImageIDX:imageIndex];
    }

    return YES;
}

- (void)deletePhotoFinish:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    
    NSString *info = [[notification userInfo] objectForKey:DATAS];
    NSDictionary *dic = [info objectFromJSONString];
    if ([[dic objectForKey:@"result"] isEqualToString:@"0"]) {
        [[WSOffLineUploadTable sharedTable] updateUploadFlagZeroWithNotifyId: notification.name];
    }
}

@end
