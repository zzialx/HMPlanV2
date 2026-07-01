//
//  WSAcvtDataGridComponentView.m
//  WinSFA
//
//  Created by ZhengJiepeng on 13-7-24.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSAcvtDataGridComponentView.h"
#import "WSRequestHelper.h"
#import "WSAcvtDataGridComponentDataSource.h"
#import "PhotoTypeButton.h"
#import "WSCheckBox.h"
#import "WSOffLineUploadTable.h"
#import "WSAppData.h"
#import "WSJSONBuilder.h"
#import "WSFptTable.h"
#import "WSOfflineDataDBService.h"
#import "WSWidgetFactory.h"
#import "WSWidget.h"

#define PHOTO_MD5           @"photo_md5"
#define PHOTO_NOTIFY_NAME   @"photo_notify_ame"
#define PHOTO_FILE_NAME     @"photo_file_name"
#define PHOTO_ID            @"photo_id"
//===============================================================================================================================================================================

@interface WSAcvtDataGridComponentView ()

@property (nonatomic, strong) WSAcvtBean_qst *currentQst;
@property (nonatomic, strong) WSTableItem *currentTableItem;

@end
//===============================================================================================================================================================================

@implementation WSAcvtDataGridComponentView
@synthesize currentQst = _currentQst;
@synthesize currentTableItem = _currentTableItem;

- (NSMutableArray *)deletedProds {
    
    if (!_deletedProds) {
        _deletedProds = [[NSMutableArray alloc] init];
    }
    return _deletedProds;
}

- (WSAcvtDataGridComponentDataSource *)getAcvtDataSource {
    
    WSAcvtDataGridComponentDataSource *acvtDataSource = nil;
    if ([self.dataSource isKindOfClass:[WSAcvtDataGridComponentDataSource class]]) {
        acvtDataSource = (WSAcvtDataGridComponentDataSource *)self.dataSource;
    }
    return acvtDataSource;
}

- (void)deleteProdsWithIndex:(NSIndexSet *)indexSet andSelectionSet:(NSSet *)selectionSet {
    
    WSAcvtDataGridComponentDataSource *acvtDataSource = (WSAcvtDataGridComponentDataSource *)self.dataSource;
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:[acvtDataSource.dataSource count]];
    [mArray addObjectsFromArray:acvtDataSource.dataSource];

    NSArray *removedArray = [mArray objectsAtIndexes:indexSet];
    self.deletedProds = [removedArray mutableCopy];
    [acvtDataSource.addedEditingProds removeObjectsInArray:removedArray];
    
    WSWidget *widget = [[WSWidgetFactory shareInstance] createWidgetByWidgetInfo:[self getAcvtDataSource].currentQst];
    if ([acvtDataSource.addedEditingProds count] > 0) {
        widget.isEdited = YES;
    }
    else {
        widget.isEdited = NO;
    }
    
    [widget checkValueChange];

    [acvtDataSource delMoreProduct:removedArray];
    
    [mArray removeObjectsAtIndexes:indexSet];
    [acvtDataSource deleteProdsCache:self.deletedProds];
    acvtDataSource.dataSource = mArray;

    [acvtDataSource.formulaDictionary removeAllObjects];
    [acvtDataSource deleteDatasAtIndexSet:indexSet];

    if ([self.delegate respondsToSelector:@selector(dataGridComponent:deleteProds:)]) {
        [self.delegate dataGridComponent:self deleteProds:selectionSet];
    }
    
    [self setCellHeightToDic];
    
    [self.leftTableView reloadData];
    [self.rightTableView reloadData];
    [self.leftTableView  layoutIfNeeded];
    [self.rightTableView layoutIfNeeded];
    
    [acvtDataSource loadLuaScriptToDelProductWithDelProds:removedArray];
}

- (NSString *)acvtDataGridQstId {
    
    NSString *qstId;
    WSAcvtDataGridComponentDataSource *acvtDataSource = nil;
    if ([self.dataSource isKindOfClass:[WSAcvtDataGridComponentDataSource class]]) {
        
        acvtDataSource = (WSAcvtDataGridComponentDataSource *)self.dataSource;
        qstId = acvtDataSource.currentQst.acvtQstId;
    }
    return qstId;
}

- (void)uploadWithAcvtMD5:(NSString *)acvtMD5 andId:(NSString *)idMD5 {
    
    WSAcvtDataGridComponentDataSource *acvtDataSource = [self getAcvtDataSource];
    if (acvtDataSource == nil) {
        return;
    }
    
    NSString *mc = acvtDataSource.currentQst.mc;
    NSDate *bef = [NSDate date];
    NSArray *photoArray = [self preparePhotoDatas];
    NSDate *aft = [NSDate date];
    BOOL hasPhoto = [photoArray count] > 0 ? YES : NO;
    NSString *notifyID = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix, [WSJSONBuilder gen_uuid]];
    BOOL isIgnoreNullValue = (acvtDataSource.currentFunc.nullvalue == 1) ? NO : YES;
    
    _insertAcvtDataGridIsSucceed = YES;
    
    if ([acvtDataSource.currentTableItem.ds isEqualToString:@"dicts"]) {
        
        NSString *postData = [WSJSONBuilder buildAcvtDictGrideDataByFc:mc fv:acvtDataSource.currentFunc.fv params:acvtDataSource.currentTableItem.paramArray
                                                               isPhoto:hasPhoto datas:acvtDataSource.data dataIDs:acvtDataSource.dataSource
                                                                 Store:acvtDataSource.currentStore md5:idMD5 acvtMD5:acvtMD5 isIgnoreNullValue:isIgnoreNullValue];
        _insertAcvtDataGridIsSucceed = [WSOfflineDataDBService insertUploadData:postData URL:URL_UPLOAD MD5:acvtMD5 IsPhoto:hasPhoto NotifyName:notifyID];
        if (!_insertAcvtDataGridIsSucceed) {
            return;
        }
        
        [[WSRequestHelper shareInstance] uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:notifyID md5:acvtMD5 isUpload:YES];
    }
    else {
        
        NSString *postData = [WSJSONBuilder buildAcvtProdGrideDataByFc:mc fv:acvtDataSource.currentFunc.fv params:acvtDataSource.currentTableItem.paramArray
                                                               isPhoto:hasPhoto datas:acvtDataSource.data dataIDs:acvtDataSource.dataSource Store:acvtDataSource.currentStore
                                                                   md5:idMD5 acvtMD5:acvtMD5 isIgnoreNullValue:isIgnoreNullValue];
        _insertAcvtDataGridIsSucceed = [WSOfflineDataDBService insertUploadData:postData URL:URL_UPLOAD MD5:acvtMD5 IsPhoto:hasPhoto NotifyName:notifyID];
        if (!_insertAcvtDataGridIsSucceed) {
            return;
        }
        
        [[WSRequestHelper shareInstance] uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:notifyID md5:acvtMD5 isUpload:YES];
    }
    
    if (hasPhoto) {
        
        NSDate *bef1 = [NSDate date];
        [self insertOutLinePhotos:photoArray];
        if (!_insertAcvtDataGridIsSucceed) {
            return;
        }
        
        NSDate *aft1 = [NSDate date];
        LogInfo(@"\n[ LogInfo -  insertOutLinePhotos耗时:%f ]\n", [aft1 timeIntervalSinceDate:bef1]);
        NSDate *bef2 = [NSDate date];
        [self uploadPhotos:photoArray];
        NSDate *aft2 = [NSDate date];
        LogInfo(@"\n[ LogInfo -  uploadPhotos耗时:%f ]\n", [aft2 timeIntervalSinceDate:bef2]);
    }
}

- (NSArray *)preparePhotoDatas {
    
    WSAcvtDataGridComponentDataSource *acvtDataSource = [self getAcvtDataSource];
    if (acvtDataSource == nil) {
        return nil;
    }
    
    NSInteger paramCount = [acvtDataSource.currentTableItem.paramArray count];
    NSMutableArray *photosArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < paramCount; i++) {
        
        WSFuncsBean_Param *param = [acvtDataSource.currentTableItem.paramArray objectAtIndex:i];
        if ([param.tpy isEqualToString:COL_TYPPHOTO]) {
            
            for (NSArray *rowArray in acvtDataSource.data) {
                
                UIView *view = [rowArray objectAtIndex:i + 1];
                if ([view isKindOfClass:[PhotoTypeButton class]]) {
                    
                    PhotoTypeButton *photoButton = (PhotoTypeButton *)view;
                    if ([photoButton.photoIDArray count] > 0) {
                        
                        for (NSString *imageID in photoButton.photoIDArray) {
                            
                            NSMutableDictionary *photoInfoDic = [[NSMutableDictionary alloc] init];
                            [photoInfoDic setObjectSafe:photoButton.imageMD5 forKey:PHOTO_MD5];
                            
                            NSString *notifyID = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix, [WSJSONBuilder gen_uuid]];
                            [photoInfoDic setObjectSafe:notifyID forKey:PHOTO_NOTIFY_NAME];
                            
                            NSString *photoFileName = [[SDImageCache sharedImageCache] cacheFileNameForKey:imageID];
                            [photoInfoDic setObjectSafe:photoFileName forKey:PHOTO_FILE_NAME];
                            [photoInfoDic setObjectSafe:imageID forKey:PHOTO_ID];
                            
                            [photosArray addObject:photoInfoDic];
                        };
                    }
                }
            }
        }
    }
    
    return photosArray;
}

- (void)insertOutLinePhotos:(NSArray *)photosArray {
    
    WSAcvtDataGridComponentDataSource *acvtDataSource = [self getAcvtDataSource];
    if (acvtDataSource == nil) {
        return;
    }
    
    for (NSDictionary *dic in photosArray) {
        
        NSString *imageID = [dic objectForKey:PHOTO_ID];
        NSString *md5 = [dic objectForKey:PHOTO_MD5];
        NSString *notifyName = [dic objectForKey:PHOTO_NOTIFY_NAME];
        NSString *photoFileName = [dic objectForKey:PHOTO_FILE_NAME];
        
        NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID];
        NSString *postData = [params JSONString];
        
        _insertAcvtDataGridIsSucceed = [WSOfflineDataDBService insertUploadMedia:postData Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:md5 IsPhoto:YES NotifyName:notifyName photoFileName:photoFileName];
        if (!_insertAcvtDataGridIsSucceed) {
            return;
        }
    }
}

- (void)uploadPhotos:(NSArray *)photosArray {
    
    WSAcvtDataGridComponentDataSource *acvtDataSource = [self getAcvtDataSource];
    if (acvtDataSource == nil) {
        return;
    }
    
    for (NSDictionary *dic in photosArray) {
        
        @autoreleasepool {
            NSString *imageID = [dic objectForKey:PHOTO_ID];
            NSString *md5 = [dic objectForKey:PHOTO_MD5];
            NSString *notifyID = [dic objectForKey:PHOTO_NOTIFY_NAME];
            NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
            WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
            [uploadMgr postRequestOnPhotoWithFilePath:filePath md5:md5 notify:notifyID imageID:imageID];
        }
    }
}

- (void)seletedItems:(NSIndexSet *)selectedItems {
    
    if ([selectedItems count] > 0) {
        
            WSAcvtDataGridComponentDataSource *acvtDataSource = (WSAcvtDataGridComponentDataSource*)self.dataSource;
            if ([acvtDataSource.currentTableItem.ds isEqualToString:DS_PROD] || [acvtDataSource.currentTableItem.ds isEqualToString:DS_PRODC]) {
                
                NSMutableArray *prodIds = [NSMutableArray arrayWithCapacity:1];
                [selectedItems enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    
                    WSProdBean *prodBean = [acvtDataSource.dataSource objectAtIndex:idx];
                    [prodIds addObject:prodBean.Id];
                    
                    for (WSProdBean *prodBeanforEditing in acvtDataSource.addedEditingProds) {
                        
                        if ([prodBeanforEditing.Id isEqualToString:prodBean.Id]) {
                            [acvtDataSource.addedEditingProds removeObject:prodBeanforEditing];
                            break;
                        }
                    }
                }];
                
                NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:[acvtDataSource.dataSource count]];
                [mArray addObjectsFromArray:acvtDataSource.dataSource];
                [mArray removeObjectsAtIndexes:selectedItems];
                
                acvtDataSource.dataSource = mArray;
                
                NSString *title = @"null";
                [[WSFptTable sharedTable] deleteProductWithStoreId:acvtDataSource.currentStore.Id fc:acvtDataSource.currentTableItem.mc title:title andSrid:acvtDataSource.currentStore.srid andProdIds:prodIds];
                [acvtDataSource reloadDataSourceForDeletedAfter];
        }
    }
}

- (void)removeDeletedProdsWhenUpload {
    
    if ([self.deletedProds count] > 0) {
        
        WSAcvtDataGridComponentDataSource *acvtDataSource = (WSAcvtDataGridComponentDataSource*)self.dataSource;
        NSMutableArray *prodIds = [self.deletedProds valueForKeyPath:@"@distinctUnionOfObjects.Id"];
        [acvtDataSource deleteTableDataFromDB:prodIds];
    }
}

- (void)setReadonly:(BOOL)readonly isInitFisrt:(BOOL)isFirst {
    
    self.isReadOnly = readonly;
    
    [self allowsMultipleSelection:NO];
    
    [self.serieLinkHeadView isReadonly:readonly];
    [self.steadySerieLinkHeadView isReadonly:readonly];

    if (readonly) {
        [[self getAcvtDataSource] setReadonly:readonly isInitFisrt:isFirst];
    }
    else {
        [[self getAcvtDataSource] setReadonly:NO isInitFisrt:isFirst];
    }
}

@end
//===============================================================================================================================================================================
