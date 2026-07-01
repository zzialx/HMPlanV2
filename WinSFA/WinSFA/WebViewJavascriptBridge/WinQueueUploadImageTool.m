//
//  WinQueueUploadImageTool.m
//  WinSFA
//
//  Created by yuanji on 2023/1/30.
//  Copyright © 2023 WinChannel. All rights reserved.
//

#import "WinQueueUploadImageTool.h"
#import "WSRequestBase.h"
#import "WSJSONBuilder.h"
#import "WSNormalHttpResponse.h"

static dispatch_queue_t upload_image_queue() {
    
    static dispatch_queue_t win_upload_image_queue;
    static dispatch_once_t win_upload_image_queue_onceToken;
    dispatch_once(&win_upload_image_queue_onceToken, ^{
        win_upload_image_queue = dispatch_queue_create("com.winchannel.upload.image", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(win_upload_image_queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
    });
    return win_upload_image_queue;
}

static dispatch_semaphore_t upload_image_semaphore() {
    
    static dispatch_semaphore_t win_upload_image_semaphore;
    static dispatch_once_t win_upload_image_semaphore_onceToken;
    dispatch_once(&win_upload_image_semaphore_onceToken, ^{
        win_upload_image_semaphore = dispatch_semaphore_create(1);
    });
    return win_upload_image_semaphore;
}
//===================================================================================================================================================================================================

#pragma mark - 队列上传图片模型
@interface WinQueueUploadImageModel : NSObject

@property (nonatomic, strong) UIImage *image;   //图片
@property (nonatomic, copy) NSString *imageID;  //图片ID
@property (nonatomic, copy) NSString *imgUrl;   //图片地址(上传成功后记录)

@end

#pragma mark - 队列上传图片模型
@implementation WinQueueUploadImageModel

@end
//===================================================================================================================================================================================================

#pragma mark - 队列上传图片工具 延展(内部)
@interface WinQueueUploadImageTool ()

@property (nonatomic, strong) NSMutableArray *imageDataArray;   //照片数据数组
@property (nonatomic, assign) NSInteger completeCount;          //完成数量

@end
//===================================================================================================================================================================================================

#pragma mark - 队列上传图片工具
@implementation WinQueueUploadImageTool

#pragma mark - 共享实例
+ (instancetype)sharedInstance {
    
    static WinQueueUploadImageTool *queueUploadImageTool;
    static dispatch_once_t queueUploadImageTool_onceToken;
    dispatch_once(&queueUploadImageTool_onceToken, ^{
        queueUploadImageTool = [[WinQueueUploadImageTool alloc] init];
    });
    return queueUploadImageTool;
}

#pragma mark - 获取imageDataArray方法
- (NSMutableArray *)imageDataArray {
    
    if (!_imageDataArray) {
        _imageDataArray = [[NSMutableArray alloc] init];
    }
    return _imageDataArray;
}

#pragma mark - 上传方法
- (void)uploadWithImage:(UIImage *)image imageID:(NSString *)imageID {
    
    if (!image) {
        return;
    }
    if (!imageID || imageID.length == 0) {
        return;
    }
    
    WinQueueUploadImageModel *imageModel = [[WinQueueUploadImageModel alloc] init];
    imageModel.image = image;
    imageModel.imageID = imageID;
    imageModel.imgUrl = @"";
    [self.imageDataArray addObject:imageModel];
    
    __weak __typeof__(self) weakSelf = self;
    __block WinQueueUploadImageModel *model = imageModel;
    dispatch_async(upload_image_queue(), ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf startupUploadWithImageModel:model];
    });
}

#pragma mark - 清理缓存数据方法
- (void)clearCacheData {
    
    [self.imageDataArray removeAllObjects];
    self.completeCount = 0;
}

#pragma mark - 获取当前是否上传方法
- (BOOL)currentIsUpload {
    
    if (self.imageDataArray.count == 0) {
        return NO;
    }
    if (self.completeCount >= self.imageDataArray.count) {
        return NO;
    }
    return YES;
}

#pragma mark - 启动上传图片方法
- (void)startupUploadWithImageModel:(WinQueueUploadImageModel *)imageModel {
    
    LogInfo(@"WinQueueUploadImageTool startupUploadWithImageModel 0 imageID = %@", imageModel.imageID);
    
    dispatch_semaphore_wait(upload_image_semaphore(), DISPATCH_TIME_FOREVER);
    
    LogInfo(@"WinQueueUploadImageTool startupUploadWithImageModel 1 imageID = %@", imageModel.imageID);
    
    WCBaseRequestLocalInfo *requestLocalInfo = [[WCBaseRequestLocalInfo alloc] init];
    requestLocalInfo.uploadType = WCDatasUploadTypeDefault;
    requestLocalInfo.requestIsForPhoto = YES;
    
    NSString *empID = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *currentTime = [WSCurrentTime getTimeMillisString];
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *bizdate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithCapacity:7];
    [headers setValue:@"keep-alive" forKey:@"connection"];
    [headers setValue:@"UTF-8" forKey:@"Charset"];
    [headers setValue:@"JPEG" forKey:@"extension"];
    [headers setValue:@"F_PHOTO" forKey:@"method"];
    [headers setValue:[NSString stringNotNilWithValue:self.storeId] forKey:@"storeId"];
    [headers setValue:[NSString stringNotNilWithValue:self.uuidH5] forKey:@"imageIndex"];
    [headers setValue:[NSString stringNotNilWithValue:currentTime] forKey:@"uploadDate"];
    [headers setValue:[NSString stringNotNilWithValue:empID] forKey:@"account"];
    [headers setValue:[NSString stringNotNilWithValue:userName] forKey:@"winc-ua"];
    [headers setValue:[NSString stringNotNilWithValue:bizdate] forKey:@"syncDate"];
    [headers setValue:[NSString stringNotNilWithValue:[self.otherInfoDic objectForKey:@"addr"]] forKey:@"addr"];
    [headers setValue:[NSString stringNotNilWithValue:[self.otherInfoDic objectForKey:@"lat"]] forKey:@"lat"];
    [headers setValue:[NSString stringNotNilWithValue:[self.otherInfoDic objectForKey:@"lon"]] forKey:@"lon"];
    
    NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageModel.imageID];
    NSArray *allkeys = [params allKeys];
    for (NSString *key in allkeys) {
        NSString *value = [params objectForKey:key];
        [headers setValue:[NSString stringNotNilWithValue:value] forKey:key];
    }
    
    WCBaseRequest *request = [[WCBaseRequest alloc] init];
    request.localInfo = requestLocalInfo;
    [request setHttpHeaders:headers];
    [request registerResponseDataClassForLogBusiness:[WSNormalHttpResponse class]];
    
    NSMutableDictionary *bodyDataDictionary = [NSMutableDictionary dictionaryWithCapacity:4];
    [bodyDataDictionary setValue:[NSString stringNotNilWithValue:bizdate] forKey:@"syncDate"];
    [bodyDataDictionary setValue:[NSString stringNotNilWithValue:self.uuidH5] forKey:@"imageIndex"];
    [bodyDataDictionary setValue:[NSString stringNotNilWithValue:[params objectForKey:@"photoKey"]] forKey:@"photoKey"];
    if (empID && empID.length > 0) {
        [bodyDataDictionary setValue:@"1" forKey:empID];
    }
    
    NSString *uploadurl = [NSString stringWithFormat:@"%@&mobileUploadTime=%@", self.uploadURL, [WSCurrentTime getTimeMillisString]];
    __weak __typeof__(self) weakSelf = self;
    [request asyncSinglePostBodyData:bodyDataDictionary file:imageModel.image fileCompress:1.0f urlString:uploadurl
                             success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
           
        NSDictionary *jsonDictionary = response.jsonResponse;
        LogInfo(@"WinQueueUploadImageTool startupUploadWithImageModel 2-1 success jsonDictionary = %@ imageID = %@", jsonDictionary, imageModel.imageID);
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.completeCount++;
        imageModel.imgUrl = [NSString stringNotNilWithValue:[jsonDictionary objectForKey:@"imgUrl"]];
        
        if (strongSelf.uploadImageSuccessBlock) {
                            
            NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] initWithDictionary:strongSelf.otherInfoDic];
            [infoDic setValue:[NSString stringNotNilWithValue:[WSCurrentTime getDateString]] forKey:@"bizDate"];
            [infoDic setValue:[NSString stringNotNilWithValue:[WSCurrentTime getTimeMillisString]] forKey:@"mobileClickTime"];
            [infoDic setValue:[NSString stringNotNilWithValue:strongSelf.uuidH5] forKey:@"imageIndex"];
            [infoDic setValue:[NSString stringNotNilWithValue:imageModel.imageID] forKey:@"imgId"];
            [infoDic setValue:[NSString stringNotNilWithValue:[jsonDictionary objectForKey:@"imgUrl"]] forKey:@"serverUrl"];
            NSString *infoDicStr = [infoDic JSONString];
            BOOL isAll = ((strongSelf.imageDataArray.count >= strongSelf.completeCount) ? YES : NO);
            LogInfo(@"WinQueueUploadImageTool startupUploadWithImageModel 2-2 success infoDicStr = %@ isAll = %d", infoDicStr, isAll);
            
            strongSelf.uploadImageSuccessBlock(infoDicStr, isAll);
        }
        
        dispatch_semaphore_signal(upload_image_semaphore());
    }
                             failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        
        LogInfo(@"WinQueueUploadImageTool startupUploadWithImageModel 3-1 failure");
                
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.completeCount++;
        
        if (strongSelf.uploadImageFailureBlock) {

            BOOL isAll = ((strongSelf.imageDataArray.count >= strongSelf.completeCount) ? YES : NO);
            LogInfo(@"WinQueueUploadImageTool startupUploadWithImageModel 3-2 failure isAll = %d", isAll);
                    
            strongSelf.uploadImageFailureBlock(isAll);
        }
                    
        dispatch_semaphore_signal(upload_image_semaphore());
    }];
}

@end
//===================================================================================================================================================================================================
