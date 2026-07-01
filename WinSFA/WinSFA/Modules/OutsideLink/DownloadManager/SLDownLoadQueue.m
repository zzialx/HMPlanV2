//
//  SLDownLoadQueue.m
//  SLMultiDownLoadManager
//
//  Created by sunlei on 16/8/3.
//  Copyright © 2016年 sunlei. All rights reserved.
//

#import "SLDownLoadQueue.h"
#import "DownLoadTools.h"
#import "SLSessionManager.h"
#import "SLFileManager.h"
#import "WSRichMediaTable.h"
#import "ZipArchive.h"
#import "BlockAlertView.h"

NSString *const DownLoadArchiveKey = @"DownLoadQueueArr";
NSString *const CompletedDownLoadArchiveKey = @"CompletedDownLoadQueueArr";

@implementation SLDownLoadQueue


-(instancetype)init{
    if (self = [super init]) {
        // MSTD-7215 实现该方式的时候没有考虑线程安全问题，该项目已经废弃，所以屏蔽该功能
//        [self reachability];
        _maxDownLoadTask = 3;
    }
    
    return self;
}
// 下载图片的队列
+(SLDownLoadQueue *)downLoadQueue2
{
    static SLDownLoadQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[SLDownLoadQueue alloc]init];
    });
    
    return queue;
}

+(SLDownLoadQueue *)downLoadQueue{

    static SLDownLoadQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[SLDownLoadQueue alloc]init];
    });
    
    return queue;
}

-(SLDownLoadModel *)nextDownLoadModel{
    
    for (SLDownLoadModel *model in self.downLoadQueueArr) {
        if (DownLoadStateWaiting == model.downLoadState) {
            return model;
        }
    }
    return nil;
}

//刷新下载
-(void)updateDownLoad{

    int i = 0;
    for (SLDownLoadModel *model in self.downLoadQueueArr) {
        if (DownLoadStateDownloading == model.downLoadState) {
            i++;
        }
    }
    //新增下载任务
    for (int m = 0; m < self.maxDownLoadTask - i; m++) {
        [self startDownload];
    }
}

#pragma mark - 添加下载任务到下载队列中

-(void)addDownTaskWithDownLoadModel:(SLDownLoadModel *)model{
    //SLog(@"%p",model);
    if (model) {
        SLDownLoadModel *modelTmp = model;
        //SLog(@"%p",modelTmp);
        
        modelTmp.downLoadTask = nil;
        modelTmp.downLoadState = DownLoadStateWaiting;
        
        modelTmp.totalByetes = 0.f;
        modelTmp.downLoadedByetes = 0.f;
        modelTmp.downLoadSpeed = 0.f;
        modelTmp.downLoadProgress = 0.f;
        
        modelTmp.isDelete = NO;
        modelTmp.isEditStatus = NO;
        
        //SLog(@"%@",modelTmp.fileUUID);
        [self.downLoadQueueArr addObject:modelTmp];
        [self updateDownLoad];
    }
}

//下载完成
-(void)completedDownLoadWithModel:(SLDownLoadModel *)model{
    
    //将已经下载完成的任务添加到下载完成数据源
    if ([self.downLoadQueueArr containsObject:model]) {
        //需要把此属性置空才能归档
        model.downLoadTask = nil;
        [self.completedDownLoadQueueArr addObject:model];
        [self.downLoadQueueArr removeObject:model];
    }
    
    //解压缩
    ZipArchive *zip = [[ZipArchive alloc] init];
    if ([zip UnzipOpenFile:model.filePath]){
        BOOL ret = [zip UnzipFileTo: model.toFilePath overWrite: YES];
        if (YES== ret){
            // 删除压缩包
            [[NSFileManager defaultManager] removeItemAtPath:model.filePath error:nil];
        }
        [zip UnzipCloseFile];
    }
    
    //入库-  拿到speID 查询到相应的记录, 为这条记录插入数据
    if (model.ModelFileType == 0) { //图片
        if (!self.isAllPause) {
            [[WSRichMediaTable sharedTable] updateTableWithKey:@"img_add" value:model.fileUUID ID:model.ID];
        }
       
        
    }else{
      if (!self.isAllPause) {
          [[WSRichMediaTable sharedTable] updateTableWithKey:@"h5_add" value:model.fileUUID ID:model.ID];
      }
    }
    
    [self updateDownLoad];
    [[NSNotificationCenter defaultCenter] postNotificationName:DownLoadResourceFinished object:model];
    
    //传参
    if (_downLoadCount) {
        _downLoadCount(_downLoadQueueArr,_completedDownLoadQueueArr);
    }
    
    //将下载完的的进行归档
    [DownLoadTools archiveDownLoadModelArrWithModelArr:self.completedDownLoadQueueArr withKey:CompletedDownLoadArchiveKey andPath:CompletedDownLoad_Archive];
}

#pragma mark - 执行下载
-(void)startDownload{
    
    SLDownLoadModel *model = [self nextDownLoadModel];
    
    if (nil == model) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    __block NSDate *oldDate = [NSDate date]; //记录上次的数据回传的时间
    __block float  downLoadBytesTmp = 0;     //记录上次数据回传的大小
    
    NSString *fullPath = [[SLFileManager getDownloadCacheDir] stringByAppendingPathComponent:model.fileUUID];
    
    if ([SLFileManager isExistPath:fullPath]) { //说明有缓存，该缓存文件是个XML文件，包含了关于下载有关的信息，在调用pause之后生成
        
        NSError *err = nil;
        NSData *resumeData = [NSData dataWithContentsOfFile:fullPath options:NSDataReadingMappedIfSafe error:&err];
        if (err) {
            SLog(@"%@",err.localizedDescription);
            return;
        }
        
        SLSessionManager *manager = [SLSessionManager sessionManager];
        NSProgress *downloadProgress = [[NSProgress alloc] init];
        model.downLoadTask = [manager downloadTaskWithResumeData:resumeData progress:&downloadProgress destination:^NSURL * (NSURL * targetPath, NSURLResponse * response) {
            
            //此处只会调用一次，当下载完成后调用
            model.downLoadState = DownLoadStateDownloadfinished;
            //model.downLoadedByetes = model.totalByetes;
            //model.downLoadProgress = 1;
            
            NSString *destinationStr = [[SLFileManager getDownloadRootDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",model.fileUUID]];
            
            model.filePath = destinationStr;
            //提取最后一个路径
            NSString *lastPath = [model.filePath lastPathComponent];
            //获取cache路径 + richMedia + 文件名
            NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDir = [path objectAtIndex:0];
            //文件路径
            NSString *toFilePath = [NSString stringWithFormat:@"%@/richMedia/%@",cachesDir,[lastPath stringByDeletingPathExtension]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if (![fileManager fileExistsAtPath:toFilePath]) {
                [fileManager createDirectoryAtPath:toFilePath withIntermediateDirectories:YES attributes:nil error:nil];
            } else {
                LogInfo(@"FileDir is exists.");
            }
            model.toFilePath = toFilePath;
            
            
            return [NSURL fileURLWithPath:destinationStr];
        } completionHandler:^(NSURLResponse * response, NSURL * filePath, NSError * error) {
            
            if (error) {
                model.downLoadState = DownLoadStateWaiting;
            }
            
            //此处在下载完成和取消下载的时候都会被调用
            [weakSelf updateDownLoad];
            
            //一定要做判断
            if (model.downLoadState == DownLoadStateDownloadfinished) {
                [weakSelf completedDownLoadWithModel:model];
            }
            
            
        }];
        
        model.downLoadedByetes = downloadProgress.completedUnitCount; //已经下载的
        model.totalByetes = downloadProgress.totalUnitCount; //总大小
        model.downLoadProgress = model.downLoadedByetes/model.totalByetes; //下载百分比进度
        
        NSDate *currentDate = [NSDate date];
        double num = [currentDate timeIntervalSinceDate:oldDate]; //时间差，就是本次block被调用的时间减去上一次该block被调用的时间
        if ( num >= 1) {
            model.downLoadSpeed = (model.downLoadedByetes - downLoadBytesTmp)/num;
            
            downLoadBytesTmp = model.downLoadedByetes;
            oldDate = currentDate;
        }
        
    }else{
        
        SLSessionManager *manager = [SLSessionManager sessionManager];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.downLoadUrlStr]];
        NSProgress *downloadProgress = [[NSProgress alloc] init];
        model.downLoadTask = [manager downloadTaskWithRequest:request progress:&downloadProgress destination:^NSURL * (NSURL *  targetPath, NSURLResponse * response) {
            
            //此处只会调用一次，当下载完成后调用
            model.downLoadState = DownLoadStateDownloadfinished;
            //model.downLoadedByetes = model.totalByetes;
            //model.downLoadProgress = 1;
            
            NSString *destinationStr = [[SLFileManager getDownloadRootDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",model.fileUUID]];
            
            
            model.filePath = destinationStr;
            //提取最后一个路径
            NSString *lastPath = [model.filePath lastPathComponent];
            //获取cache路径 + richMedia + 文件名
            NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDir = [path objectAtIndex:0];
            //文件路径
            NSString *toFilePath = [NSString stringWithFormat:@"%@/richMedia/%@",cachesDir,[lastPath stringByDeletingPathExtension]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if (![fileManager fileExistsAtPath:toFilePath]) {
                [fileManager createDirectoryAtPath:toFilePath withIntermediateDirectories:YES attributes:nil error:nil];
            } else {
                LogInfo(@"FileDir is exists.");
            }
            
            model.toFilePath = toFilePath;
            
            return [NSURL fileURLWithPath:destinationStr];
        } completionHandler:^(NSURLResponse * response, NSURL * filePath, NSError * error) {
            //此处在下载完成和取消下载的时候都会被调用
            
            //下载错误
            if (error) {
                model.downLoadState = DownLoadStateWaiting;
            }
            
            [weakSelf updateDownLoad];
            if (model.downLoadState == DownLoadStateDownloadfinished) {

                [weakSelf completedDownLoadWithModel:model];
                
            }
            
        }];
        //NSLog(@"===========%@",[NSThread currentThread]);
        model.downLoadedByetes = downloadProgress.completedUnitCount; //已经下载的
        model.totalByetes = downloadProgress.totalUnitCount; //总大小
        model.downLoadProgress = model.downLoadedByetes/model.totalByetes; //下载百分比进度
        
        NSDate *currentDate = [NSDate date];
        double num = [currentDate timeIntervalSinceDate:oldDate]; //时间差，就是本次block被调用的时间减去上一次该block被调用的时间
        if ( num >= 1) {
            model.downLoadSpeed = (model.downLoadedByetes - downLoadBytesTmp)/num;
            downLoadBytesTmp = model.downLoadedByetes;
            oldDate = currentDate;
        }

    }

    [model.downLoadTask resume]; //开始下载
    model.downLoadState = DownLoadStateDownloading;
}

#pragma mark - 恢复某一下载任务
-(void)resumeWithDownLoadModel:(SLDownLoadModel *)model{
    //如果在暂停状态或者等待下载状态则恢复下载
    if (DownLoadStatePause == model.downLoadState) {
        model.downLoadState = DownLoadStateWaiting;
    }
    [self updateDownLoad];
}

-(void)startDownloadAll{
    self.isAllPause = NO;
    for (SLDownLoadModel *model in self.downLoadQueueArr) {
        if (DownLoadStatePause == model.downLoadState) {
            model.downLoadState = DownLoadStateWaiting;
        }
    }
    
    [self updateDownLoad];
}

#pragma mark - 暂停下载
//暂停某个下载任务
-(void)pauseWithDownLoadModel:(SLDownLoadModel *)model{
    //如果在下载状态或者等待下载状态则暂停
    if ((DownLoadStateDownloading == model.downLoadState)||(DownLoadStateWaiting == model.downLoadState)) {
        //取消是异步的
        [model.downLoadTask cancelByProducingResumeData:^(NSData * resumeData) {
            NSString *cachePath = [[SLFileManager getDownloadCacheDir] stringByAppendingPathComponent:model.fileUUID];
            [resumeData writeToFile:cachePath atomically:YES];
        }];
        //置空，防止归档时出错
        model.downLoadTask = nil;
        //更改状态
        model.downLoadState = DownLoadStatePause;
      
    }
}

//暂停所有的下载任务
-(void)pauseAll{
    self.isAllPause = YES;

    for (SLDownLoadModel *model in self.downLoadQueueArr) {
        [self pauseWithDownLoadModel:model];
    }
    //更新下载
    [self updateDownLoad];
}

-(NSMutableArray *)downLoadQueueArr{
    
    if (!_downLoadQueueArr) {
        _downLoadQueueArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _downLoadQueueArr;
}

-(NSMutableArray *)completedDownLoadQueueArr{
    if (!_completedDownLoadQueueArr) {
        _completedDownLoadQueueArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _completedDownLoadQueueArr;
}

-(void)appWillTerminate{
    SLog(@"app将要被kill--%@",[NSThread currentThread]);
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    //将任务异步地添加到group中去执行
    dispatch_group_async(group,queue,^{
        [self pauseAll];
        SLog(@"取消完毕。。。。11");
    });
    
    dispatch_group_wait(group,DISPATCH_TIME_FOREVER);
    SLog(@"取消完毕了。。。。222");
    
    //给点时间进行异步暂停所有下载
//    sleep(30);
    
    //归档正在下载或等待下载的
    [DownLoadTools archiveDownLoadModelArrWithModelArr:self.downLoadQueueArr withKey:DownLoadArchiveKey andPath:DownLoad_Archive];
    
    //归档已经下载完的
    [DownLoadTools archiveDownLoadModelArrWithModelArr:self.completedDownLoadQueueArr withKey:CompletedDownLoadArchiveKey andPath:CompletedDownLoad_Archive];
    SLog(@"app将要被杀死。。。。222--%@",[NSThread currentThread]);
}

#pragma mark - 检测网络状态
- (void)reachability
{
    
    
    WinAFNetworkReachabilityManager *mgr = [WinAFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                break;
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                
                [[SLDownLoadQueue downLoadQueue] pauseAll];
                [[SLDownLoadQueue downLoadQueue2] pauseAll];

                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *title = NSLocalizedString(@"该资源只能WIFI下载", nil);
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                });

                
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                
                [[SLDownLoadQueue downLoadQueue] pauseAll];
                [[SLDownLoadQueue downLoadQueue2] pauseAll];

                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *title = NSLocalizedString(@"该资源只能WIFI下载", nil);
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                });
                
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                
                [[SLDownLoadQueue downLoadQueue] startDownloadAll];
                [[SLDownLoadQueue downLoadQueue2] startDownloadAll];

                break;
        }
    }];
    [mgr startMonitoring];
}
@end
