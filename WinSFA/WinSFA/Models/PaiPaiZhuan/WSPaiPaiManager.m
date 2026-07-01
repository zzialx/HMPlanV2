//
//  WSPaiPaiManager.m
//  WinSFA
//
//  Created by zhangmin on 2019/12/6.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSPaiPaiManager.h"
#import "WSPaiPaiUploadCallBack.h"
#import "WSJSONBuilder.h"
#import "WSRequestHelper.h"
#import "WSRequestBase.h"
#import "WSStatisticsManager.h"
#import "WCBaseViewController.h"

static WSPaiPaiManager *instance;
//=============================================================================================================================================================================================

@interface WSPaiPaiManager ()

@property (nonatomic, strong) LenzEngine *engine;
@property (nonatomic, strong) LenzTaskInfo *taskInfo;
@property (nonatomic, strong) NSArray *businessDataIds;
@property (nonatomic, strong) NSMutableArray *uploadModelArray;

@end
//=============================================================================================================================================================================================

@implementation WSPaiPaiManager

#pragma mark - 获取uploadModelArray方法
- (NSMutableArray *)uploadModelArray {
    
    if (!_uploadModelArray) {
        _uploadModelArray = [NSMutableArray array];
    }
    return _uploadModelArray;
}

#pragma mark - 单例方法
+ (WSPaiPaiManager *)sharedInstance {
    
    if (!instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[WSPaiPaiManager alloc] init];
        });
    }
    return instance;
}

#pragma mark - 重写init方法
- (id)init {
    
    self = [super init];
    if (self) {
        _engineDic = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

#pragma mark - 注册拍拍赚方法
- (void)registerPaiPai {
    
    NSString *serverIP = [WSHttpURLHelper getCompleteURL:@""];
    if ([serverIP containsString:@"https://sfa-otc3.haleon.cn"] || [serverIP containsString:@"https://sfa-otc3.haleon.cn/otc-mobile"]) {
        [LenzEngine setMode:2 host:nil];
    }
    else {
        [LenzEngine setMode:1 host:@"https://gsk-uat.langjtech.com/business/api/trax/gsk"];
    }
    
    [LenzEngine registerCompanyId:@"00002"];
    [LenzEngine downloadModelIfNeeded];
}

#pragma mark - 获取拍拍赚任务列表方法
- (LenzTaskInfo *)getLenzTaskInfo {
    
    LogInfo(@"WSPaiPaiManager getLenzTaskInfo taskInfo = %@", self.taskInfo);
    if (self.taskInfo) {
        return self.taskInfo;
    }
    
    __weak typeof(self) wself = self;
    [LenzEngine getTaskInfo:^(NSArray<LenzTaskInfo *> *list, NSString *message) {
        
        if (list == nil || list.count == 0) {
            LogError(@"Trax Get Compnoy Task Info Fail--->%@", message);
        }
        else {
            
            for (LenzTaskInfo *item in list) {
                LogInfo(@"trax 下发的任务id---->%@", item.taskId);
            }
            
            NSString *bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
            LogInfo(@"WSPaiPaiManager getLenzTaskInfo bundleId = %@", bundleId);
            
            NSString *taskId = @"";
//            if ([bundleId isEqualToString:@"net.winchannel.sfa.otc"] ||
//                [bundleId isEqualToString:@"net.winchannel.sfa.otcnew"] ||
//                [bundleId isEqualToString:@"net.winchannel.sfa.otcclone"] ||
//                [bundleId isEqualToString:@"net.winchannel.sfa.gsksfaABM"] ||
//                [bundleId isEqualToString:@"net.winchannel.sfa.gsksfaABM"]) {
//                
//                taskId = [WSAppData getObjectbyKey:APPDATA_TASKINFO];
//                LogInfo(@"WSPaiPaiManager getLenzTaskInfo otcBundleId taskId = %@", taskId);
//            }
            taskId = [WSAppData getObjectbyKey:APPDATA_TASKINFO];
            LogInfo(@"WSPaiPaiManager getLenzTaskInfo otcBundleId taskId = %@", taskId);
//            else if ([bundleId isEqualToString:@"net.winchannel.sfa.fmcg"] ||
//                     [bundleId isEqualToString:@"net.winchannel.sfa.fmcgnew"] ||
//                     [bundleId isEqualToString:@"net.winchannel.sfa.gskfmcgABM"]) {
//            
//                taskId = @"607017f9f45845c08cbf41957429e9a5";
//                LogInfo(@"WSPaiPaiManager getLenzTaskInfo fmcgBundleId taskId = %@", taskId);
//            }
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskId == %@", taskId];
            NSArray *array = [NSMutableArray arrayWithArray:[list filteredArrayUsingPredicate:predicate]];
            LenzTaskInfo *lenzTaskInfoBean = [array firstObject];
            if (lenzTaskInfoBean) {
                
                wself.taskInfo = lenzTaskInfoBean;
                [wself uploadFailedDatas];
            }
            LogInfo(@"WSPaiPaiManager getLenzTaskInfo taskId = %@, list = %@ lenzTaskInfoBean = %@" , taskId, list, lenzTaskInfoBean);
        }
    }];
    
    return nil;
}

#pragma mark - 通过模型获取图片方法
- (UIImage *)getImageWithModel:(LTImageItem *)model {
    
    NSData *data = [NSData dataWithContentsOfFile:model.path];
    UIImage *image = [UIImage imageWithData:data];
    
    LogInfo(@"WSPaiPaiManager getImageWithModel: image = %@ path = %@", image, model.path);
    return image;
}

#pragma mark - 根据id删除图片方法
- (void)deleteImageWithImgID:(NSString *)imgID {

    NSArray *pictures = self.engine.currentPictures;
    NSMutableArray *newPictures = [[NSMutableArray alloc] init];
    for (int i = 0; i < pictures.count; ++i) {
        
        LTImageItem *item = [pictures objectAtIndex:i];
        NSString *name = [[item.name componentsSeparatedByString:@"."] firstObject];
        if ([imgID isEqualToString:name]) {
            continue;
        }
        
        [newPictures addObject:item];
    }

    LogInfo(@"WSPaiPaiManager deleteImageWithImgID: newPictures = %@", newPictures);
    [self.engine setCurrentPictures:newPictures];
}

#pragma mark - # 删除所有照片
- (void)deleteTraxAllImageList {
    
    NSMutableArray *newPictures = [[NSMutableArray alloc] init];
    [self.engine setCurrentPictures:newPictures];
}

#pragma mark - 创建拍拍赚引擎方法
- (BOOL)createEngineWithBusinessDataIds:(NSArray *)ids {
    
    LogInfo(@"WSPaiPaiManager createEngineWithBusinessDataIds: ids = %@", ids);
    
    if (self.taskInfo == nil) {
        
        LogInfo(@"WSPaiPaiManager createEngineWithBusinessDataIds: taskInfo==nil 没有获取到企业任务模型 重新获取");
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"获取拍拍赚任务失败，请稍后再试" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        [self getLenzTaskInfo];
        return NO;
    }
    
    LenzEngine *engine = [[LenzEngine alloc] initWithTaskInfo:self.taskInfo businessDataIds:ids];
    engine.maxTaskConcurrentCount = 32;
    self.engine = engine;
    self.businessDataIds = ids;
    
    LogInfo(@"WSPaiPaiManager createEngineWithBusinessDataIds: taskInfo!=nil engine = %@ businessDataIds = %@", self.engine, self.businessDataIds);
    if (self.engine == nil) {
        return NO;
    }
    return YES;
}

#pragma mark - # 针对嵌套问卷出现的trax拍照图片错乱问题优化
- (BOOL)createEngineWithBusinessDataIds:(NSArray *)ids engineKey:(NSString*)engineKey {
    
    LogInfo(@"WSPaiPaiManager createEngineWithBusinessDataIds: ids = %@", ids);
    
    if (self.taskInfo == nil) {
        
        LogInfo(@"WSPaiPaiManager createEngineWithBusinessDataIds: taskInfo==nil 没有获取到企业任务模型 重新获取");
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"获取拍拍赚任务失败，请稍后再试" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        [self getLenzTaskInfo];
        return NO;
    }
    
    LenzEngine *engine = [[LenzEngine alloc] initWithTaskInfo:self.taskInfo businessDataIds:ids];
    engine.maxTaskConcurrentCount = 32;
    self.engine = engine;
    self.businessDataIds = ids;
    [self.engineDic setObject:engine forKey:engineKey];
    
    LogInfo(@"WSPaiPaiManager createEngineWithBusinessDataIds: taskInfo!=nil engine = %@ businessDataIds = %@", self.engine, self.businessDataIds);
    if (self.engine == nil) {
        return NO;
    }
    return YES;
}

#pragma mark - 修改拍拍赚任务列表方法
- (void)modifyLenzTaskInfoWithTaskId:(NSString *)taskId {
    
    LogInfo(@"WSPaiPaiManager modifyLenzTaskInfoWithTaskId: taskId = %@", taskId);
    if (taskId.length <= 0) {
        return;
    }
    
    __weak typeof(self) wself = self;
    [LenzEngine getTaskInfo:^(NSArray<LenzTaskInfo *> *list, NSString *message) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskId == %@", taskId];
        NSArray *array = [NSMutableArray arrayWithArray:[list filteredArrayUsingPredicate:predicate]];
        LenzTaskInfo *lenzTaskInfoBean = [array firstObject];
        if (lenzTaskInfoBean) {
            wself.taskInfo = lenzTaskInfoBean;
        }
        
        LogInfo(@"WSPaiPaiManager modifyLenzTaskInfoWithTaskId: taskId = %@ list = %@ lenzTaskInfoBean = %@" , taskId, array, lenzTaskInfoBean);
    }];
}

#pragma mark - 离线上传拍拍赚图片方法
- (void)ppzUploadFailDataWithObj:(id)aFailedData {
    
    LogInfo(@"WSPaiPaiManager ppzUploadFailDataWithObj: aFailedData = %@", aFailedData);
    if (!aFailedData) {
        return;
    }
    
    if (self.taskInfo == nil) {
        
        LogInfo(@"WSPaiPaiManager ppzUploadFailDataWithObj: taskInfo==nil 没有获取到企业任务模型 重新获取");
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
        });
        //[self getLenzTaskInfo];
        return;
    }
    
    WSPaiPaiModel *ppModel = [[WSPaiPaiModel alloc] init];
    [ppModel offlineUploadOneDataWithObj:aFailedData];
    [self.uploadModelArray addObject:ppModel];
}

#pragma mark - 上传失败数据方法
- (void)uploadFailedDatas {
    
    [[WSStatisticsManager sharedInstance] uploadStatisticsLogs];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        WSOffLineUploadTable *l_leaveStore = [WSOffLineUploadTable sharedTable];
        NSArray *l_failedDatas = [l_leaveStore queryWithUploadFlagType:Failed];
        LogInfo(@"WSPaiPaiManager uploadFailedDatas l_failedDatas = %@", l_failedDatas);
        
        if (l_failedDatas != nil && [l_failedDatas count] > 0) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                WSRequestHelper* l_WSRequestHelper = [WSRequestHelper shareInstance];
                for (WSOffLineUploadObject *object in l_failedDatas) {
                    [l_WSRequestHelper uploadFailedData:object];
                }
            });
        }
    });
}

#pragma mark - 在线上传拍拍赚图片方法
- (void)uploadPPzImagesWithImageIndex:(NSString *)imageIndex {

    WSPaiPaiModel *ppModel = [[WSPaiPaiModel alloc] init];
    [ppModel onlineUploadWithImageIndex:imageIndex withIds:self.businessDataIds];
    
    LogInfo(@"WSPaiPaiManager uploadPPzImagesWithImageIndex: imageIndex = %@ businessDataIds = %@", imageIndex, self.businessDataIds);
    [self.uploadModelArray addObject:ppModel];
}

#pragma mark - 根据类型跳转拍拍赚相机方法
- (void)jumpToPPZCameraWithPZType:(NSString *)pztype withVc:(UIViewController *)VC extendParam:(NSDictionary *)extendParam {
    
    LogInfo(@"WSPaiPaiManager jumpToPPZCameraWithPZType:withVc: pztype = %@", pztype);
    
    //普通相机
    if ([pztype isEqualToString:PPCamera_Normal]|| [pztype isEqualToString:PPCamera_StoreFP]) {
        [[WSPaiPaiManager sharedInstance] jumpToNormalCameraWithVc:VC param:extendParam];
    }
    
    //拼接相机
    if ([pztype isEqualToString:PPCamera_connect]) {
        [[WSPaiPaiManager sharedInstance] jumpToConnectCameraWithVc:VC];
        return;
    }
}

#pragma mark - 跳转拼拍拍普通相机方法
- (void)jumpToNormalCameraWithVc:(UIViewController *)VC param:(NSDictionary *)param {
    BOOL tiltModelValue = YES;
    if ([param.allKeys containsObject:tiltKey]) {
        tiltModelValue = [[param objectForKey:tiltKey] boolValue];
    }
    LenzNormalCameraConfig *config = [LenzNormalCameraConfig config];
    config.tilt = tiltModelValue;
    config.vague = YES;
    config.saveToAlbum = NO;
    config.compressionLevel = 2;
    config.remake = YES;
    
    NSString *maxPhotoMark = [param objectForKey:PPZ_maxPhotoMark];
    if (maxPhotoMark.integerValue > 0) {
        config.maxCount = maxPhotoMark.integerValue;
    }
    
    __weak typeof(self) weakself = self;
    UIViewController *camera = [self.engine cameraWithConfig:config eachCapture:^(LTImageItem *model, NSString *imgId) {

        NSData *data = [NSData dataWithContentsOfFile:model.path];
        UIImage *image = [UIImage imageWithData:data];
        if (imgId.length == 0) {
            if (model.name.length > 0) {
                
                if ([model.name containsString:@"."]) {
                    imgId = [[model.name componentsSeparatedByString:@"."] firstObject];
                }
                else {
                    imgId = model.name;
                }
            }
        }
        
        LogInfo(@"WSPaiPaiManager jumpToNormalCameraWithVc: image = %@ imgId = %@ name = %@", image, imgId, model.name);
        if (image) {
            
            if ([weakself.delegate respondsToSelector:@selector(didFinishImage:withImgID:)]) {
                [weakself.delegate didFinishImage:image withImgID:imgId];
            }
        }
    }];
    
    if (!camera) {
        return;
    }
    
    camera.modalPresentationStyle = UIModalPresentationFullScreen;
    if ([VC isKindOfClass:[WCBaseViewController class]]) {
        WCBaseViewController *vc = (WCBaseViewController *)VC;
        [[vc getNavigationController] presentViewController:camera animated:YES completion:nil];
    }
    else {
        [VC presentViewController:camera animated:YES completion:nil];
    }
}

#pragma mark - 跳转拼拍拍赚拼接相机方法
- (void)jumpToConnectCameraWithVc:(UIViewController *)VC {

    LenzStitchCameraConfig *config = [LenzStitchCameraConfig config];
    config.navigationLeftButtonParams = @{@"icon" : @"icon_back", @"size" : [NSValue valueWithCGSize:CGSizeMake(40, 40)]};
    config.saveToAlbum = NO;
    config.compressionLevel = 2;
    
    __weak typeof(self) weakself = self;
    UIViewController *camera = [self.engine stitchCameraWithConfig:config eachCapture:^(LTImageItem *model, NSString *imgId) {}
                                                        completion:^(BOOL cancel, NSArray<LTImageItem *> *list, NSArray<LenzStitchInfo *> *stitchInfos) {
    
        if (cancel) {
            
            LogInfo(@"WSPaiPaiManager jumpToConnectCameraWithVc: cancel");
            [weakself.engine removeCurrentAnswer];
        }
        else {
            
            LogInfo(@"WSPaiPaiManager jumpToConnectCameraWithVc: list = %@", list);
            if ([weakself.delegate respondsToSelector:@selector(didFinishPhotoModelArray:)]) {
                [weakself.delegate didFinishPhotoModelArray:list];
            }
        }
    }];
    
    if (!camera) {
        return;
    }
    
    camera.modalPresentationStyle = UIModalPresentationFullScreen;
    [VC presentViewController:camera animated:YES completion:nil];
}

#pragma mark - 跳转trax照相机方法(带参数)
- (void)jumpToPPZCameraWithPZType:(NSString *)pztype withVc:(UIViewController *)VC engineKey:(NSString*)engineKey extendParam:(NSDictionary*)extendParam {

    LogInfo(@"engine内存地址：%@",self.engine);

    //普通相机
    if ([pztype isEqualToString:PPCamera_Normal] || [pztype isEqualToString:PPCamera_StoreFP]) {

        if (engineKey) {
            self.engine = [self.engineDic objectForKey:engineKey];
            [self jumpToNormalCameraWithVc:VC extendParam:extendParam];
        }
    }

    //拼接相机
    if ([pztype isEqualToString:PPCamera_connect]) {

        if (engineKey) {
            self.engine = [self.engineDic objectForKey:engineKey];
            [self jumpToConnectCameraWithVc:VC];
        }
    }
}

#pragma mark - 跳转trax普通相机方法(带参数)
- (void)jumpToNormalCameraWithVc:(UIViewController *)VC extendParam:(NSDictionary*)extendParam {

    LogInfo(@"trax 普通拍照");

    BOOL tiltModelValue = YES;
    NSInteger pzMax = 0;
    if (extendParam) {

        if ([extendParam.allKeys containsObject:tiltKey]) {
            tiltModelValue = [[extendParam objectForKey:tiltKey] boolValue];
        }

        if ([extendParam.allKeys containsObject:pzMaxKey]) {
            pzMax = [[extendParam objectForKey:pzMaxKey] integerValue];
        }
    }

    LenzNormalCameraConfig *config = [LenzNormalCameraConfig config];
    config.tilt = tiltModelValue;
    config.vague = YES;
    config.saveToAlbum = NO;
    config.compressionLevel = 2;
    config.remake = YES;
    config.maxCount = pzMax;

    __weak typeof(self) weakself = self;
    UIViewController *camera = [self.engine cameraWithConfig:config eachCapture:^(LTImageItem *model, NSString *imgId) {

        LogInfo(@"trax 拍照成功");

        NSData *data = [NSData dataWithContentsOfFile:model.path];
        UIImage *image = [UIImage imageWithData:data];

        if (imgId.length == 0) {

            if (model.name.length>0) {

                if ([model.name containsString:@"."]) {
                    imgId = [[model.name componentsSeparatedByString:@"."] firstObject];
                }
                else {
                    imgId = model.name;
                }
            }
        }

        LogInfo(@"trax 拍照id：%@", imgId);
        if (image) {

            if ([weakself.delegate respondsToSelector:@selector(didFinishImage:withImgID:)]) {
                [weakself.delegate didFinishImage:image withImgID:imgId];
            }
        }
    }];

    if (!camera) {
        LogInfo(@"trax camera is nil");
        return;
    }

    if ([VC isKindOfClass:[WCBaseViewController class]]) {

        WCBaseViewController *vc = (WCBaseViewController *)VC;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [[vc getNavigationController] presentViewController:camera animated:YES completion:nil];
        LogInfo(@"trax presentViewController 相机1");
    }
    else {

        camera.modalPresentationStyle = UIModalPresentationFullScreen;
        [VC presentViewController:camera animated:YES completion:nil];
        LogInfo(@"trax presentViewController 相机2");

    }
}

@end
//=============================================================================================================================================================================================
