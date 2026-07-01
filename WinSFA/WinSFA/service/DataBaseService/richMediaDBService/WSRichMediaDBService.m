//
//  WSRichMediaDBService.m
//  WinSFA
//
//  Created by huzepei on 16/8/10.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRichMediaDBService.h"
#import "WSRichMediaTable.h"
#import "YYModel.h"
#import "WSRichItemModel.h"
#import "SLDownLoadQueue.h"
#import "WSHttpURLHelper.h"


#define kRichDictKey_id  @"id"

#define CACHE_DIR [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface WSRichMediaDBService()
//BaseURl
@property (nonatomic,copy) NSString *baseStr;

@end

@implementation WSRichMediaDBService

-(BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData
{
    BOOL ret = FALSE;
    
    NSMutableArray *dictArray = [NSMutableArray array];
    for (NSDictionary *oldDict in dicts) {
        NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
        newDict = [oldDict mutableCopy];
        [newDict setObject:[oldDict objectForKey:@"id"] forKey:@"speid"];
        [dictArray addObject:newDict];
    }
    
    // 下发的
    NSMutableArray * newArrays = [[NSArray yy_modelArrayWithClass:[WSRichItemModel class] json:dictArray] mutableCopy];
    
    //本地的富媒体数据库
    NSMutableArray * oldarr  = [[[WSRichMediaTable sharedTable] queryTableItems] mutableCopy];
    
    NSString *paths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *arrPath = [paths stringByAppendingString:@"/richMedia.plist"];
    
    if ([self is_file_exist:@"richMedia.plist"] && oldarr.count == 0) {  //如果当前文件存在
        NSArray *newPersonsArr = [NSKeyedUnarchiver unarchiveObjectWithFile:arrPath];
        NSString *str = [newPersonsArr yy_modelToJSONString];
        NSArray *arrDicts = [self dictionaryWithJsonString:str];
        BOOL a = [[WSRichMediaTable sharedTable] batchInsertToTableWithMap:nil Dicts:arrDicts];
        LogError(@"richMedia.plist, %d",a);
        
    }
    
    //本地的富媒体数据库
    NSMutableArray * oldArrays  = [[[WSRichMediaTable sharedTable] queryTableItems] mutableCopy];
    
    //3.比对
    NSMutableArray *tempArray = [NSMutableArray array];
    
    
    //需要更新的数据
    NSMutableArray *updateOldArray = [NSMutableArray array];
    NSMutableArray *updateNewArray = [NSMutableArray array];
    
    NSMutableArray *updateSQLArray = [NSMutableArray array];
    
    // 更新
    for (int i = 0; i < newArrays.count; i++) {
        
        WSRichItemModel *newItemModel = newArrays[i];
        
        for (WSRichItemModel *oldItemModel in oldArrays) {
            
            //更新
            if ([newItemModel.speid isEqualToString:oldItemModel.speid]) {
                
                [tempArray addObject:newItemModel.speid];
                
                if ((oldItemModel.h5_url && ![oldItemModel.h5_url isEqualToString:@""]) && (newItemModel.h5_url && ![newItemModel.h5_url isEqual:@""])) {
                    
                    if (![oldItemModel.h5_url isEqualToString:newItemModel.h5_url]) {
                        
                        // 如果不同--更新
                        [updateSQLArray addObject:[[WSRichMediaTable sharedTable] getUpdateSQLStringWithKey:@"h5_url" value:newItemModel.h5_url ID:oldItemModel.speid]];
                        
                        [updateOldArray addObject:oldItemModel.speid];
                        [updateNewArray addObject:newItemModel];
                        
                        // 如果 h5_add  为 “” 字符串，那么有可能把整个大文件夹删除，导致之前下载的数据全部为空。。
                        if (oldItemModel.h5_add && oldItemModel.h5_add.length > 0) {
                            // 删除旧的安装包
                            NSString *imgStr = [NSString stringWithFormat:@"%@/richMedia/%@",CACHE_DIR,oldItemModel.h5_add];
                            
                            [[NSFileManager defaultManager] removeItemAtPath:imgStr error:nil];
                             LogInfo(@"\n\n[ 删除富媒体（oldItemModel.h5_add） %@ 成功]\n\n",imgStr);
                            // 同时更新数据库 - 把已经删除的add从数据库中删除,便于更新.
                            [updateSQLArray addObject:[[WSRichMediaTable sharedTable] getUpdateSQLStringWithKey:@"h5_add" value:@"" ID:oldItemModel.speid]];
                        }
                        
                    }
                    if (![oldItemModel.img_url isEqualToString:newItemModel.img_url]) {
                        
                        // 如果不同--更新
                        [updateSQLArray addObject:[[WSRichMediaTable sharedTable] getUpdateSQLStringWithKey:@"img_url" value:newItemModel.img_url ID:oldItemModel.speid]];
                        
                        [updateOldArray addObject:oldItemModel.speid];
                        [updateNewArray addObject:newItemModel];
                        
                        if (oldItemModel.img_add && oldItemModel.img_add.length > 0) {
                            // 删除旧的安装包
                            NSString *imgStr = [NSString stringWithFormat:@"%@/richMedia/%@",CACHE_DIR,oldItemModel.img_add];
                            [[NSFileManager defaultManager] removeItemAtPath:imgStr error:nil];
                            LogInfo(@"\n\n[ 删除富媒体（oldItemModel.img_add） %@ 成功]\n\n",imgStr);

                            // 同时更新数据库 - 把已经删除的add从数据库中删除,便于更新.
                            [updateSQLArray addObject:[[WSRichMediaTable sharedTable] getUpdateSQLStringWithKey:@"img_add" value:@"" ID:oldItemModel.speid]];
                        }
                        
                    }
                    
                }
                //加条件
                if (![oldItemModel.memo isEqualToString:newItemModel.memo]) {
                    
                    [updateSQLArray addObject:[[WSRichMediaTable sharedTable] getUpdateSQLStringWithKey:@"memo" value:newItemModel.memo ID:oldItemModel.speid]];
                    
                    [updateOldArray addObject:oldItemModel.speid];
                    [updateNewArray addObject:newItemModel];
                    
                }
                if (![oldItemModel.typ isEqualToString:newItemModel.typ]) {
                    
                    [updateSQLArray addObject:[[WSRichMediaTable sharedTable] getUpdateSQLStringWithKey:@"typ" value:newItemModel.typ ID:oldItemModel.speid]];
                    
                    [updateOldArray addObject:oldItemModel.speid];
                    [updateNewArray addObject:newItemModel];
                    
                }
                if (![oldItemModel.name isEqualToString:newItemModel.name]) {
                    
                    [updateSQLArray addObject:[[WSRichMediaTable sharedTable] getUpdateSQLStringWithKey:@"name" value:newItemModel.name ID:oldItemModel.speid]];
                    
                    [updateOldArray addObject:oldItemModel.speid];
                    [updateNewArray addObject:newItemModel];
                    
                }
                if (![oldItemModel.share_url isEqualToString:newItemModel.share_url]) {
                    
                    [updateSQLArray addObject:[[WSRichMediaTable sharedTable] getUpdateSQLStringWithKey:@"share_url" value:newItemModel.share_url ID:oldItemModel.speid]];
                    
                    [updateOldArray addObject:oldItemModel.speid];
                    [updateNewArray addObject:newItemModel];
                    
                }
                if (![oldItemModel.type_ isEqualToString:newItemModel.type_]) {
                    
                    [updateSQLArray addObject:[[WSRichMediaTable sharedTable] getUpdateSQLStringWithKey:@"type_" value:newItemModel.type_ ID:oldItemModel.speid]];
                    
                    [updateOldArray addObject:oldItemModel.speid];
                    [updateNewArray addObject:newItemModel];
                    
                }
                
                break;
            }
        }
    }
    
    if ([updateSQLArray count] > 0) {
        [[WSRichMediaTable sharedTable] executeUpdateWithSqls:updateSQLArray];
    }
    
    //去重
    updateOldArray = [[updateOldArray valueForKeyPath:@"@distinctUnionOfObjects.self"] mutableCopy];
    updateNewArray = [[updateNewArray valueForKeyPath:@"@distinctUnionOfObjects.self"] mutableCopy];
    
    //增加的
    for (int i = 0; i < newArrays.count; i++) {
        
        WSRichItemModel *itemModel = newArrays[i];
        
        for (NSString *strID in tempArray){
            
            if ([itemModel.speid isEqualToString:strID]) {
                [newArrays removeObjectAtIndex:i];
                i--;
            }
            
        }
    }
    
    //增加的数据批量插入
    NSString *str = [newArrays yy_modelToJSONString];
    NSArray *arrDicts = [self dictionaryWithJsonString:str];
    
    [[WSRichMediaTable sharedTable] batchInsertToTableWithMap:nil Dicts:arrDicts];
    
    
    //删除的
    for (int i = 0; i < oldArrays.count; i++) {
        
        WSRichItemModel *itemModel = oldArrays[i];
        
        for (NSString *strID in tempArray){
            
            if ([itemModel.speid isEqualToString:strID]) {
                [oldArrays removeObjectAtIndex:i];
                i--;
            }
            
        }
    }
    
    
    //旧数据中去除ID相同就是删除的数据
    NSMutableArray *speIDs = [NSMutableArray array];
    for (WSRichItemModel *itemModel in oldArrays) {
        
        //删除文件
        if (itemModel.h5_add && itemModel.h5_add.length > 0 ) {
            // 删除旧的安装包
            NSString *imgStr = [NSString stringWithFormat:@"%@/richMedia/%@",CACHE_DIR,itemModel.h5_add];
            [[NSFileManager defaultManager] removeItemAtPath:imgStr error:nil];
            LogInfo(@"\n\n[ 删除富媒体（itemModel.h5_add） %@ 成功]\n\n",imgStr);

        }
        if (itemModel.img_add && itemModel.img_add.length > 0) {
            // 删除旧的安装包
            NSString *imgStr = [NSString stringWithFormat:@"%@/richMedia/%@",CACHE_DIR,itemModel.img_add];
            [[NSFileManager defaultManager] removeItemAtPath:imgStr error:nil];
            LogInfo(@"\n\n[ 删除富媒体（itemModel.img_add） %@ 成功]\n\n",imgStr);

        }
        
        if (itemModel.speid) {
            [speIDs addObject:itemModel.speid];
        }
    }
    //数据批量删除
    [[WSRichMediaTable sharedTable] batchDeleteFromTableWithNames:@[@"speid"] ArgumentsValues:@[speIDs]];
    
    //下载图片
    NSMutableArray *imgArr = [[[WSRichMediaTable sharedTable] queryTableItemsNotDownloadWithImg] mutableCopy];
    
    //点击下载的时候，比较下载队列与数据库未下载的是否匹配,不匹配的添加到下载队列(img) - 下载队列是后台下载队列.
    NSMutableArray *downLoadQueueArr_img = [SLDownLoadQueue downLoadQueue2].downLoadQueueArr;
    
    if (downLoadQueueArr_img.count != 0) {
        
        NSMutableIndexSet *idxSet1 = [[NSMutableIndexSet alloc] init];
        for (int k = 0; k < imgArr.count; k++) {
            WSRichItemModel *richItem = imgArr[k];
            for (int i = 0; i < downLoadQueueArr_img.count; i++) {
                
                SLDownLoadModel *downLoadModel = downLoadQueueArr_img[i];
                if ([downLoadModel.ID isEqualToString:richItem.speid]) {
                    
                    [idxSet1 addIndex:k];
                }
            }
        }
        [imgArr removeObjectsAtIndexes:idxSet1];
    }
    
    // 下载图片 - 添加到下载队列
    if (IOS7_OR_LATER) {
        //            [[SLDownLoadQueue downLoadQueue2] startDownloadAll];
        for (WSRichItemModel *richItem in imgArr) {
            SLDownLoadModel *downLoadModel = [[SLDownLoadModel alloc]init];
            if (richItem.img_url && ![richItem.img_url isEqualToString:@""]){
                
                NSString *fileName = [[NSUUID UUID] UUIDString];
                
                downLoadModel.ModelFileType = 0;
                downLoadModel.downLoadUrlStr = [WSHttpURLHelper getImageCompleteURL:richItem.img_url];
                
                downLoadModel.ID = richItem.speid;
                
                downLoadModel.fileUUID = [NSString stringWithFormat:@"img%@",fileName];
                
                [[SLDownLoadQueue downLoadQueue2] addDownTaskWithDownLoadModel:downLoadModel];
            }
        }
    }

    return ret;
}


-(NSString *)get_filename:(NSString *)name
{
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
            stringByAppendingPathComponent:name];
}
-(BOOL)is_file_exist:(NSString *)name
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    return [file_manager fileExistsAtPath:[self get_filename:name]];
}


-(NSString *)baseStr
{
    if (!_baseStr) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"configFile" ofType:@"plist"];
        NSMutableDictionary *configDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        _baseStr =  [configDict objectForKey:@"ServerIP"];
    }
    return _baseStr;
}

- (NSArray *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        LogInfo(@"json解析失败：%@",err);
        return nil;
    }
    return arr;
}
@end
