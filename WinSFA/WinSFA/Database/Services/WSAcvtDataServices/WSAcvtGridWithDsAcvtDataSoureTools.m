//
//  WSAcvtGridWithDsAcvtDataSoureTools.m
//  WinSFA
//
//  Created by zhangmin on 2019/11/7.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSAcvtGridWithDsAcvtDataSoureTools.h"
#import "WSAcvtBean.h"
#import "WSJSONBuilder.h"
#import "WSAcvtModel.h"
#import "WSRequestHelper.h"
#import "WSImagePathTable.h"
#import "WSBaseStoreAcvtDisTable.h"
#import "WSBaseAcvtDBService.h"
#import "WSPhotoLogicService.h"
#import "WSGridWidget.h"
#import "WSBaseDictsDBService.h"
#import "WSDropListView.h"
#import "WSGridPhotoButton.h"



@implementation WSAcvtGridWithDsAcvtDataSoureTools

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store
{
    self = [super init];
    if (self) {
        self.currentFuncs = funcs;
        self.currentStore = store;
        
        if (!funcs.paramArray || [funcs.paramArray count] < 1) {
            WSAcvtBean *acvtBean = [self.acvtArray firstObject];
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[acvtBean.qsts count]];
            
            for (WSAcvtBean_qst *qst in acvtBean.qsts) {  
                WSFuncsBean_Param *param = [[WSFuncsBean_Param alloc] initFuncsParamWithAcvtQstBean:qst];
              
                if (param.iDependon) { //iDependon配置的是qstcod，要转为qstid。。。 因为列col 取的值是qstId;
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"qstCod == %@", param.iDependon];
                    NSArray *resultArray = [NSMutableArray arrayWithArray:[acvtBean.qsts filteredArrayUsingPredicate:predicate]];
                    if (resultArray.count > 0) {
                        WSAcvtBean_qst *dePendQst = [resultArray firstObject];
                        param.iDependon = dePendQst.qstId;
                    }
                }
                
                [array addObject:param];
            }
            
            [funcs setParamArrayFromOut:array];
        }
        
        
        [self initDataSource];
        [self getGridDisData];
        
        return self;
    }
    
    return nil;
}

-(NSMutableDictionary *)acvtGrid_cacheDataMDictionary {
    if (!_acvtGrid_cacheDataMDictionary) {
        _acvtGrid_cacheDataMDictionary = [NSMutableDictionary dictionary];
    }
    return _acvtGrid_cacheDataMDictionary;
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
            //            acvtModel.currentVisitAction = self.currentVisitAction;
            [acvtModel createMD5With:[acvtModel md5Param]];
            [acvtModelArray addObject:acvtModel];
        }
        
        _acvtModelArray = [NSArray arrayWithArray:acvtModelArray];
    }
    
    return _acvtModelArray;
    
}

- (NSObject *)getResultDirectly {
    
    NSArray *md5Arr =[self.acvtModelArray valueForKeyPath:@"self.md5"];
    NSString *md5Strings = [md5Arr componentsJoinedByString:@","];
    return md5Strings;
    
}
#pragma mark - 获取数据源

- (void)initDataSource {
    
    self.m_dataSources = [NSMutableArray arrayWithArray:self.acvtArray];
    self.m_DataBaseDatas = [NSMutableArray arrayWithArray:[self getDataBaseDatas]];
}
#pragma mark - 回显值 先获取回显（本地和server，存到acvtGrid_cacheDataMDictionary中）
- (void)getGridDisData {
    
    for (int i = 0; i < self.acvtModelArray.count; i++) {
        
        WSAcvtModel *acvtModel = [self.acvtModelArray objectAtIndex:i];
        
        //服务器回显
        WSAcvtBean *acvtBean = [self.m_dataSources objectAtIndex:i];
        
        WSBaseStoreAcvtDisTable *baseStoreAcvtDisTable = [WSBaseStoreAcvtDisTable sharedTable];
        NSArray *names = @[@"sid",@"acvtId"];
        NSArray *values = @[[NSString stringNotNilWithValue:self.currentStore.Id],[NSString stringNotNilWithValue:acvtBean.acvtId]];
        
        NSArray *querys = [baseStoreAcvtDisTable  queryWithNames:names ArgumentsValue:values];
        
        for (WSBaseStoreAcvtDisObject *disObj in querys) {
            
            WSAcvtBean_qst * qstBean = [acvtBean getQstBeanByAcvtQstID:disObj.acvtqstid];
            
            NSString *key = [NSString stringWithFormat:@"%@_%@",acvtBean.acvtId,qstBean.qstId];

            if (![qstBean.qstType isEqualToString:QST_TYPE_P]){
                
                NSString *disValue = disObj.acvt_qst_answer;
                [self.acvtGrid_cacheDataMDictionary setObject:disValue forKey:key];
            
            }else {
                NSString *answers = disObj.acvt_qst_answer;
                NSArray *imageIDArray = [self photoUrlHandle:answers];
                 NSString *disValue = [imageIDArray componentsJoinedByString:@","];
                
                NSString *key = [NSString stringWithFormat:@"%@_%@",acvtBean.acvtId,qstBean.qstId];
                if (disValue) {
                    [self.acvtGrid_cacheDataMDictionary setObject:disValue forKey:key];
                }
            }
            
        }
        
        // 本地有回显， 则覆盖掉服务器
        NSArray *paramArray = self.currentFuncs.paramArray;
        for (WSFuncsBean_Param *param  in paramArray) {
            
            WSAcvtBean_qst *qstBean = [acvtBean getQstBeanByQstID:param.col];
            
            NSString *key = [NSString stringWithFormat:@"%@_%@",acvtBean.acvtId,qstBean.qstId];
            
            if (![param.tpy isEqualToString:COL_TYPPHOTO]) {
                
                if (acvtModel.qstDBValueDictionary) {
                    if ([acvtModel.qstDBValueDictionary objectForKey:qstBean.acvtQstId]) {
                        id localValue = [acvtModel.qstDBValueDictionary objectForKey:qstBean.acvtQstId];
                        if (localValue) {
                            [self.acvtGrid_cacheDataMDictionary setObject:localValue forKey:key];
                        }
                    }
                }
                
            } else {
                
                NSString *imageIndex = [WSPhotoLogicService getAcvtImageIndexWithFC:acvtModel.currentFuncs.fc acvtMD5:acvtModel.md5 acvtQstId:qstBean.acvtQstId];
                NSArray *imageObjectArray = [[WSImagePathTable sharedTable] queryWithImageIDX:imageIndex];
                
                if ([imageObjectArray count] > 0) {
                    NSArray *imageIDArray = [imageObjectArray valueForKeyPath:@"@unionOfObjects.img_path"];
                    NSString *imageIdsStr = [imageIDArray componentsJoinedByString:@","];
                    [self.acvtGrid_cacheDataMDictionary setObject:imageIdsStr forKey:key];
                    
                }
                
            }
        }
        
        
    }   //end for
    
    //////////////////////////////////////////////////////////////////////////////////////////
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


#pragma mark - 上传数据
- (BOOL)uploadAcvtGridDataWithGridWidgetsArray:(NSArray *)gridWidgetsArray  {
    
    NSArray *acvtModelArray = self.acvtModelArray;
    NSArray * aParamArray = self.currentFuncs.paramArray;
    __block BOOL updateAcvtDataIsSucceed = YES;
    
    NSInteger iMax = [gridWidgetsArray count]; //Ui控件数组
    NSInteger jMax = [aParamArray count];
    
    for (int i = 0; i < iMax; i++) {
        NSArray *subdatas = [gridWidgetsArray objectAtIndex:i]; //每一行表格的UI数组
        
        WSAcvtModel *model = [acvtModelArray objectAtIndex:i];
        NSMutableDictionary *qstValueDic = [[NSMutableDictionary alloc] initWithCapacity: [subdatas count]];
        
        for (int j = 0; j < jMax; j++) {
            
            WSGridWidget *gridWidget = [subdatas objectAtIndex:j+1];
            id view = nil;
            if ([gridWidget isKindOfClass:[WSGridWidget class]]) {
                view = [gridWidget getView];
            } else {
                view = (UIView *)gridWidget;
            }
            
            WSFuncsBean_Param *param = (WSFuncsBean_Param *)[aParamArray objectAtIndex:j];
            
            WSAcvtBean_qst *qstBean = [model.currentAcvtBean getQstBeanByQstID:param.col];
            
            NSString *key = [NSString stringWithFormat:@"%@%@", qstBean.qstType, qstBean.acvtQstId];
            
            if([view isKindOfClass:[WSHTextField class]]) {
                WSHTextField *textField = (WSHTextField*)view;
                NSString *value = textField.text;
                if (!value) {
                    value = @"";
                }
                [qstValueDic setObject:value forKey:key];
                
            } else if ([view isKindOfClass:[WSSelectListView class]]) {
                WSSelectListView *list = (WSSelectListView *)view;
                NSArray *valueArray = nil;
                
                if (list.selectMode == WSSelectListViewSelectModeSingleSelection) {
                    NSString *value = [NSString string];
                    if(list.selectedIndex>-1){
                        value = [list.content objectAtIndex:list.selectedIndex];
                        if ([value length] > 0) {
                            valueArray = [NSArray arrayWithObject:value];
                        }
                    }
                }
                else if (list.selectMode == WSSelectListViewSelectModeMultipleChoice) {
                    valueArray = [[list getSelectedContentString] componentsSeparatedByString:@","];
                }
                
                WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
                NSArray *filterArray = [service queryDictsForAcvtGridWithFilter:param.filter];
                
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
                    [qstValueDic setObject:[dictIdArray componentsJoinedByString:@","] forKey:key];
                } else if ([valueArray count] > 0) {
                    [qstValueDic setObject:[valueArray componentsJoinedByString:@","] forKey:key];
                } else if ([valueArray count] == 0) {
                    if ([list respondsToSelector:@selector(isValueChange)]) {
                        if ([list isValueChange]) {
                            [qstValueDic setObject:@"-1" forKey:key];
                        }
                    }
                }
                
            }else if ([view isKindOfClass:[WSDropListView class]]){
                WSDropListView *list = (WSDropListView *)view;
                NSString *value = [list getResultDirectly];
                
                if (value) {
                    [qstValueDic setObject:value forKey:key];
                }else {
                    /*用于删除内容上传*/
                    if ([list  respondsToSelector:@selector(isValueChange)]) {
                        if ([list isValueChange]) {
                            [qstValueDic setObject:@"" forKey:key];
                        }
                    }
                }
            }else if ([view isKindOfClass:[PhotoTypeButton class]]) {
                NSString *value = [WSPhotoLogicService getAcvtImageIndexWithFC:model.currentFuncs.fc acvtMD5:model.md5 acvtQstId:qstBean.acvtQstId];
                if (value) {
                    [qstValueDic setObject:value forKey:key];
                }
            }else {
                NSString *value = [gridWidget getDBValue];
                if ([value length] > 0) {
                    [qstValueDic setObject:value forKey:key];
                }
            }
            
            if ([view isKindOfClass:[PhotoTypeButton class]]) {
                
                PhotoTypeButton *photoButton = (PhotoTypeButton *)view;
                if ([photoButton.deleteIDArray count] > 0) {
                    
                    [self uploadDeletePhotoDatasWithAcvtModel:model qstBean:qstBean deleteImageIDArray:photoButton.deleteIDArray]; // 上传删除的图片
                }
                if ([photoButton.photoIDArray count] > 0) {
                    
                    [self uploadAcvtPhotosWithAcvtModel:model qstBean:qstBean imageIDArray:photoButton.photoIDArray];  //上传表格中的问卷图片
                }
            }
            
            
        }// end 子for
        //上传表格中的问卷
        BOOL  updateSucceed = [self uploadAcvtDatasWithAcvtModel:model qstValueDic:qstValueDic];
        if (!updateSucceed) {
            updateAcvtDataIsSucceed = updateSucceed;
            //            *stop = YES;
        }
    }   //end for
    
    
    return updateAcvtDataIsSucceed;
    
}
- (BOOL)uploadGridWidgetsArray:(NSArray *)gridWidgetsArray {
    NSArray * aParamArray = self.currentFuncs.paramArray;

    NSInteger iMax = [gridWidgetsArray count]; //Ui控件数组
    NSInteger jMax = [aParamArray count];
    for (int i = 0; i < iMax; i++) {
        NSArray *subdatas = [gridWidgetsArray objectAtIndex:i]; //每一行表格的UI数组
        for (int j = 0; j < jMax; j++) {
            WSGridWidget *gridWidget = [subdatas objectAtIndex:j+1];
            id view = nil;
            if ([gridWidget isKindOfClass:[WSGridWidget class]]) {
                view = [gridWidget getView];
            } else {
                view = (UIView *)gridWidget;
            }
            if ([view isKindOfClass:[PhotoTypeButton class]]) {
                PhotoTypeButton *photoButton = (PhotoTypeButton *)view;
                if ([photoButton.deleteIDArray count] > 0) {
                    [self uploadDeletePhotoDatasWithAcvtModel:nil qstBean:nil deleteImageIDArray:photoButton.deleteIDArray imageIndex:photoButton.imageMD5]; // 上传删除的图片
                }
            }
        }
    }
    
    return YES;
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

- (BOOL)uploadAcvtDatasWithAcvtModel:(WSAcvtModel *)acvtModel qstValueDic:(NSDictionary *)qstValueDic
{
    
//    BOOL hasPhoto = [self.photoBrowseView.imageIDArray count] > 0 ? YES:NO;
    BOOL hasPhoto = NO;
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
- (void)uploadDeletePhotoDatasWithAcvtModel:(WSAcvtModel *)acvtModel qstBean:(WSAcvtBean_qst *)qstBean deleteImageIDArray:(NSArray *)imageIDArray  imageIndex:(NSString*)imageIndex
{
    if (!imageIDArray || [imageIDArray count] <= 0) {
        return;
    }
    
    for (NSString *imageID in imageIDArray) {
        NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
        if(!imageIndex)
        {
            imageIndex = [WSPhotoLogicService getAcvtImageIndexWithFC:acvtModel.currentFuncs.fc acvtMD5:acvtModel.md5 acvtQstId:qstBean.acvtQstId];
            
            [[WSImagePathTable sharedTable] deleteWithImageIDX:imageIndex withImgKey:imageID];
        }
       
        NSDictionary *params = [WSJSONBuilder buildDelImageParamsDicByImageID:imageID withImgIdx:imageIndex];
        
        [self insertUploadData:[params JSONString] URL:URL_UPLOAD MD5:imageIndex IsPhoto:NO NotifyName:notifyID];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePhotoFinish:) name:notifyID object:nil];
        [[WSRequestHelper shareInstance] uploadDatasDictionary:params urlString:URL_UPLOAD notifyName:notifyID md5:acvtModel.md5 isUpload:YES];
    }
}

- (void)uploadDeletePhotoDatasWithAcvtModel:(WSAcvtModel *)acvtModel qstBean:(WSAcvtBean_qst *)qstBean deleteImageIDArray:(NSArray *)imageIDArray
{
    [self uploadDeletePhotoDatasWithAcvtModel:acvtModel qstBean:qstBean deleteImageIDArray:imageIDArray imageIndex:nil];
}

#pragma -mark -



-(BOOL) insertUploadData:(NSString*)aPostDate
                     URL:(NSString*)aUrl
                     MD5:(NSString*)aMd5
                 IsPhoto:(BOOL)aIsPhoto
              NotifyName:(NSString*)aNotifyName

{
    
    return [[WSOffLineUploadTable sharedTable] insertUploadData:aPostDate URL:aUrl MD5:aMd5 IsPhoto:aIsPhoto NotifyName:aNotifyName];
    
}
-(BOOL) insertUploadMedia:(NSString *)aPostDate
                     Type:(NSString *)type
                      URL:(NSString *)aUrl
                      MD5:(NSString *)aMd5
                  IsPhoto:(BOOL)aIsPhoto
               NotifyName:(NSString *)aNotifyName
            photoFileName:(NSString *)photoFileName
{
    return [[WSOffLineUploadTable sharedTable] insertUploadMedia:aPostDate Type:type URL:aUrl MD5:aMd5 IsPhoto:aIsPhoto NotifyName:aNotifyName photoFileName:photoFileName];
    
}


- (void)deletePhotoFinish:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    
    NSString *info = [[notification userInfo] objectForKey:DATAS];
    NSDictionary *dic = [info objectFromJSONString];
    if ([[dic objectForKey:@"result"] isEqualToString:@"0"]) {
        [[WSOffLineUploadTable sharedTable] updateUploadFlagZeroWithNotifyId: notification.name];
    }
}


#pragma mark - 照片url处理方法 urlStr:链接字符串  图片问题的serverdis是否是正确的
- (NSMutableArray *)photoUrlHandle:(NSString *)urlStr
{
    NSArray *imageUrlArray = [urlStr componentsSeparatedByString:@","];
    NSMutableArray *urlArray = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < imageUrlArray.count; ++i)
    {
        NSString *url = [imageUrlArray objectAtIndex:i];
        url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //新：imageIndex@photoKey@url // 旧：photoKey@url
        NSArray *strArray = [url componentsSeparatedByString:@"@"];
        if (strArray.count < 2) {
            continue;
        }
        [urlArray addObject:url];
        
    }
    
    if (urlArray.count > 0){
        return urlArray;
    }
    
    return nil;
}


@end
