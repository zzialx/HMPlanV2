//
//  WSAcvtDataGridHttpService.m
//  WinSFA
//
//  Created by yang on 15/4/28.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAcvtDataGridHttpService.h"
#import "WSRequestHelper.h"
#import "WSOfflineDataDBService.h"
#import "WSJSONBuilder.h"
#import "WSAcvtDataGridComponentDataSource.h"
#import "WSGridPhotoButton.h"

#define PHOTO_MD5               @"photo_md5"
#define PHOTO_NOTIFY_NAME       @"photo_notify_ame"
#define PHOTO_FILE_NAME         @"photo_file_name"
#define PHOTO_ID                @"photo_id"


@implementation WSAcvtDataGridHttpService

#pragma mark - public methods


+ (NSString *)getAcvtGridJsonDataWithDataSource:(WSAcvtDataGridComponentDataSource *)dataSource acvtMD5:(NSString *)acvtMD5 tableMD5:(NSString *)tableMD5 isIgnoreNullValue:(BOOL)isIgnoreNullValue
{
    if (!dataSource) {
        return nil;
    }
    
    NSString *mc = dataSource.currentQst.mc;
    
    NSArray *photoArray = [WSAcvtDataGridHttpService preparePhotoDatasWithDataSource:dataSource];
    
    BOOL hasPhoto = [photoArray count] > 0 ? YES : NO;
    
    NSString *postData = nil;
    
    if ([dataSource.currentTableItem.ds isEqualToString:@"dicts"]) {
        postData = [WSJSONBuilder  buildAcvtDictGrideDataByFc:mc
                                                           fv:dataSource.currentFunc.fv
                                                       params:dataSource.currentTableItem.paramArray
                                                      isPhoto:hasPhoto
                                                        datas:dataSource.data
                                                      dataIDs:dataSource.dataSource
                                                        Store:dataSource.currentStore
                                                          md5:tableMD5
                                                      acvtMD5:acvtMD5
                                            isIgnoreNullValue:isIgnoreNullValue];
        
    } else if ([dataSource.currentTableItem.ds isEqualToString:DS_ACVT]) {
        postData = nil;
    } else {
        postData = [WSJSONBuilder buildAcvtProdGrideDataByFc:mc
                                                          fv:dataSource.currentFunc.fv
                                                      params:dataSource.currentTableItem.paramArray
                                                     isPhoto:hasPhoto
                                                       datas:dataSource.data
                                                     dataIDs:dataSource.dataSource
                                                       Store:dataSource.currentStore
                                                         md5:tableMD5
                                                     acvtMD5:acvtMD5
                                           isIgnoreNullValue:isIgnoreNullValue];
        
    }
    
    return postData;
    
}

+ (BOOL)uploadAcvtGridPhotosWithDataSource:(WSAcvtDataGridComponentDataSource *)dataSource acvtMD5:(NSString *)acvtMD5 tableMD5:(NSString *)tableMD5  operationType:(WSOperationAcvtType)acvtType
{
    if (dataSource == nil) {
        LogError(@"dataSource == nil 不执行插入数据库及上传操作");
        return YES;
    }
    
    NSArray *photoArray = [WSAcvtDataGridHttpService preparePhotoDatasWithDataSource:dataSource];
    
    BOOL hasPhoto = [photoArray count] > 0 ? YES : NO;
    
    if (hasPhoto)
    {
        NSDate *bef1 = [NSDate date];
        BOOL insertPhotoDataIsSucceed = [WSAcvtDataGridHttpService insertOutLinePhotos:photoArray];
        if (!insertPhotoDataIsSucceed) {
            return insertPhotoDataIsSucceed;
        }
        NSDate *aft1 = [NSDate date];
        LogInfo(@"insertOutLinePhotos耗时:%f", [aft1 timeIntervalSinceDate:bef1]);
        
        NSDate *bef2 = [NSDate date];

        if (acvtType == WSOnlySaveAcvtDataForCalendarType) {
            /*紧紧保存到 数据库  不进行上传*/
        }else {
            [WSAcvtDataGridHttpService uploadPhotos:photoArray];
        }
        
        NSDate *aft2 = [NSDate date];
        LogInfo(@"uploadPhotos耗时:%f", [aft2 timeIntervalSinceDate:bef2]);
    }
    return YES;
}

#pragma mark - private methods

+ (NSArray *)preparePhotoDatasWithDataSource:(WSAcvtDataGridComponentDataSource *)dataSource {
    
    if (dataSource == nil) return nil;
    
    NSInteger paramCount = [dataSource.currentTableItem.paramArray count];
    
    NSMutableArray *photosArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < paramCount; i++) {
        WSFuncsBean_Param *param = [dataSource.currentTableItem.paramArray objectAtIndex:i];
        if ([param.tpy isEqualToString:COL_TYPPHOTO]) {
            for (NSArray *rowArray in dataSource.data) {
                
                UIView *view = [rowArray objectAtIndex:i + 1];
                PhotoTypeButton *photoButton = nil;
                if ([view isKindOfClass:[PhotoTypeButton class]]) {
                    photoButton = (PhotoTypeButton *)view;
                } else if ([view isKindOfClass:[WSGridPhotoButton class]]) {
                    WSGridPhotoButton *gridPhotoButton = (WSGridPhotoButton *)view;
                    photoButton = gridPhotoButton.photoButton;
                }
                
                if ([photoButton.photoIDArray count] > 0) {
                    for (NSString *imageID in photoButton.photoIDArray) {
                        NSMutableDictionary *photoInfoDic = [[NSMutableDictionary alloc] init];
                        [photoInfoDic setObjectSafe:photoButton.imageMD5 forKey:PHOTO_MD5];//md5
                        NSString *notifyID = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix, [WSJSONBuilder gen_uuid]]; //notifyname
                        [photoInfoDic setObjectSafe:notifyID forKey:PHOTO_NOTIFY_NAME];
                        NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];//filename
                        [photoInfoDic setObjectSafe:photoFileName forKey:PHOTO_FILE_NAME];
                        [photoInfoDic setObjectSafe:imageID forKey:PHOTO_ID]; // imageID
                        
                        [photosArray addObject:photoInfoDic];
                    };
                }
            }
        }
    }
    return photosArray;
}

+ (BOOL)insertOutLinePhotos:(NSArray *)photosArray {
    
    for (NSDictionary *dic in photosArray) {
        
        NSString *imageID = [dic objectForKey:PHOTO_ID];
        NSString *md5 = [dic objectForKey:PHOTO_MD5];
        NSString *notifyName = [dic objectForKey:PHOTO_NOTIFY_NAME];
        NSString *photoFileName = [dic objectForKey:PHOTO_FILE_NAME];
        
        NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID];
        NSString *postData = [params JSONString];
        
        
        BOOL insertPhotoDataIsSucceed = [WSOfflineDataDBService insertUploadMedia:postData Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:md5 IsPhoto:YES NotifyName:notifyName photoFileName:photoFileName];
        
        if (!insertPhotoDataIsSucceed) {
            return insertPhotoDataIsSucceed;
        }
    }
    return YES;
}

+ (void)uploadPhotos:(NSArray *)photosArray {
    
    for (NSDictionary *dic in photosArray) {
        
        @autoreleasepool {
            if ([[WCNetworkEngine sharedInstance].uploadRequestManager.operationQueue operationCount] > kAutoUploadCount) {
                break;
            }
            
            NSString *imageID = [dic objectForKey:PHOTO_ID];
            
            NSString *md5 = [dic objectForKey:PHOTO_MD5];
            
            NSString *notifyID = [dic objectForKey:PHOTO_NOTIFY_NAME];
            
            NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
            
            WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
            
            
            [uploadMgr postRequestOnPhotoWithFilePath:filePath
                                                  md5:md5
                                               notify:notifyID
                                              imageID:imageID];
        }
        
    }
}


@end
