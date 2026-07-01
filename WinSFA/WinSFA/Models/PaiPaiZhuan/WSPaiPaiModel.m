//
//  WSPaiPaiModel.m
//  WinSFA
//
//  Created by zhangmin on 2019/12/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSPaiPaiModel.h"
#import "WSPaiPaiUploadCallBack.h"
#import "WSPaiPaiManager.h"
#import "WSJSONBuilder.h"
#import "WSRequestHelper.h"
#import "WSRequestBase.h"



@interface WSPaiPaiModel ()


@property (nonatomic, strong) LenzEngine *engine;
@property (nonatomic, strong) LenzTaskInfo *taskInfo;
@property(nonatomic,strong) NSArray * businessDataIds;

@property(nonatomic,strong)  NSString *notifyID;
@property(nonatomic,strong)  NSString *imageIndex;
@property(nonatomic,strong)  WSPaiPaiUploadCallBack *callback;

@property(nonatomic,strong)   WSOffLineUploadObject* currentObject;


@end

//static WSPaiPaiModel *instance;

@implementation WSPaiPaiModel

#pragma mark--上传到阿里云
- (void)uploadDataToAliyun {
    [WSPaiPaiManager sharedInstance].isTasking = YES;
    WSPaiPaiUploadCallBack *callback = [[WSPaiPaiUploadCallBack alloc] init];
    self.callback = callback;
    callback.successBlock = ^(BOOL success, NSArray * _Nonnull params) {
        [WSPaiPaiManager sharedInstance].isTasking = NO;
        if (success) {
            [[WSOffLineUploadTable sharedTable]  updateUploadFlagWithNotifyId:self.notifyID];
            [[WSPaiPaiManager sharedInstance] uploadFailedDatas];
        }
        
        LogInfo(@"WSPaiPaiModel uploadDataToAliyun successBlock success = %d params = %@", success, params);
    };
    
    LogInfo(@"WSPaiPaiModel uploadDataToAliyun currentPictures = %@", self.engine.currentPictures);
    [self.engine submitAnswerAndUploadFiles:self.engine.currentPictures callback:callback];
    //有一个失败就报错,新的设置
    [self.engine setValue:@(NO) forKeyPath:@"uploadTool.uploadAll"];
}
#pragma mark--在线上传
- (void)onlineUploadWithImageIndex:(NSString *)imageIndex withIds:(NSArray*)ids {
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
    
    NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:nil];
    NSString *str =   [ids JSONString];
    NSString *fileName = [NSString stringWithFormat:@"ppzImage@#%@",str];
    
    //插入到db中
    [[WSOffLineUploadTable sharedTable] insertUploadMedia:[params JSONString] Type:kOfflineTableDataType_P URL:URL_IMAGEUPLOAD MD5:imageIndex IsPhoto:YES NotifyName:notifyID photoFileName:fileName];
    

    self.imageIndex = imageIndex;
    self.notifyID = notifyID;
    self.businessDataIds = ids;
    self.taskInfo = [[WSPaiPaiManager sharedInstance] getLenzTaskInfo];
    self.engine = nil;
    if (self.taskInfo ==nil || self.businessDataIds.count != 3) {
        return;
    }
    self.engine = [[LenzEngine alloc] initWithTaskInfo:self.taskInfo businessDataIds:_businessDataIds];
    self.engine.maxTaskConcurrentCount = 32;
    [self uploadDataToAliyun];
    

}

#pragma mark--离线上传逻辑
//离线上传   ---创建LenzEngine
-(void)offlineUploadOneDataWithObj:(id)aFailedData {

    self.currentObject = aFailedData;
    
    WSOffLineUploadObject* object=(WSOffLineUploadObject*)aFailedData;
    NSString* l_notify = object.notify;
    NSString *l_fileName = object.photo_filename;
    NSString* l_MD5 = object.img_idx;
    
    if ([l_fileName hasPrefix:PPZ_Upload_Logo]) {
        //
        NSArray *arr = [l_fileName componentsSeparatedByString:@"@#"];
        NSString * ids =[arr lastObject];
        NSArray *idsArray  = [ids objectFromJSONString];
        
        self.businessDataIds = idsArray;
        self.imageIndex = l_MD5;
        self.notifyID = l_notify;
        self.taskInfo = [[WSPaiPaiManager sharedInstance] getLenzTaskInfo];
        self.engine = nil;
        if (self.taskInfo ==nil || self.businessDataIds.count != 3) {
            return;
        }
        self.engine = [[LenzEngine alloc] initWithTaskInfo:self.taskInfo businessDataIds:_businessDataIds];
        self.engine.maxTaskConcurrentCount = 32;
        [self uploadDataToAliyun]; //上传到ppz
        
    }
    
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


@end

