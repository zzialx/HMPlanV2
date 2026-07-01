//
//  WSDocDownLoadVController.m
//  WinSFA
//
//  Created by mac on 16/12/2.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSDocDownLoadVController.h"

#import "WSDownloadFileTable.h"

#define kLeftVieWidth 200.0f
#define TEXT_COLOR [UIColor colorWithHexString:@"666666"]

/*
    _downLoadFileObject.file_download_status  1 为开始下载  2 为暂停下载 3 断点续传继续下载  4 完成下载
 */
@interface WSDocDownLoadVController ()<UIDocumentInteractionControllerDelegate>
{
    UIImageView * _fileTypeImageView;  // 文件类型图片
    UILabel * _fileNameLabel;          // 文件名
    UIButton * _switchButton;
    WinAFHTTPRequestOperation *operation;
}
@property (nonatomic, strong) UIView * progressView;
@property (nonatomic, strong) UIButton *switchButton;

@property (nonatomic, strong) UILabel * progressLabel;
@property (nonatomic, strong) UILabel * fileDownLoadSize;
@property (nonatomic, copy) NSString * filePath;
@property (nonatomic, assign) BOOL firstLoad;

@end

@implementation WSDocDownLoadVController

-(instancetype)init{
    if (self = [super init]) {
        [self setupSubView];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.firstLoad = YES;
    self.title = NSLocalizedString(@"文件管理", nil);
    self.view.backgroundColor = [UIColor colorWithHexString:@"ededed"];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (!self.firstLoad) {
        return;
    }
    
    self.firstLoad = NO;
    [self backItemAction:@selector(backAction) target:self];
}

-(void)setupSubView{
    CGFloat viewWidth = INTERFACE_IS_PAD?self.view.width - kLeftVieWidth : self.view.width;
    
    _fileTypeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(viewWidth/2 - 48, 100, 118, 127)];
    [self.view addSubview:_fileTypeImageView];
    
    _fileNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, _fileTypeImageView.bottom + 20, self.view.width, 30)];
    _fileNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_fileNameLabel];
    _fileNameLabel.textColor = TEXT_COLOR;
    _progressView = [[UIView alloc]initWithFrame:CGRectMake(viewWidth/2 - 100, _fileNameLabel.bottom + 50, 150, 10)];
    _progressView.backgroundColor = TEXT_COLOR;
    [self.view addSubview:_progressView];
    
    _progressLabel = [[UILabel alloc]init];
    _progressLabel.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
    [_progressView addSubview:_progressLabel];
    
    _switchButton = [[UIButton alloc]initWithFrame:CGRectMake(_progressView.right + 20, _progressView.centerY - 20, 40, 40)];
    [_switchButton addTarget:self action:@selector(startOrStop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_switchButton];

    [_switchButton setBackgroundImage:[UIImage scaledImageForName:@"playbtn" ofType:@"png"] forState:UIControlStateNormal];

    _fileDownLoadSize = [[UILabel alloc]initWithFrame:CGRectMake(0, _switchButton.bottom + 10, 160, 20)];
    _fileDownLoadSize.centerX = _progressView.centerX;
    _fileDownLoadSize.textAlignment = NSTextAlignmentCenter;
    _fileDownLoadSize.font = [UIFont systemFontOfSize:INTERFACE_IS_PHONE?13:15];
    _fileDownLoadSize.textColor = [UIColor colorWithHexString:@"d4d4d4"];
    [self.view addSubview:_fileDownLoadSize];
    
    UILabel * fengexian = [[UILabel alloc]initWithFrame:CGRectMake(0, _fileDownLoadSize.bottom + 40, self.view.width, 1.5)];
    fengexian.backgroundColor = TEXT_COLOR;
    [self.view addSubview:fengexian];

}

-(void)setDownLoadFileObject:(WSDownloadFileObject *)downLoadFileObject{
    _downLoadFileObject = [[[WSDownloadFileTable sharedTable]queryWithFileURL:downLoadFileObject.file_url] firstObject];  // 每次去最新的数据，以免暂停时  返回前一页面再次进入 下载页面 状态未及时更新
    _fileNameLabel.text = downLoadFileObject.file_name;
    [self getfilePath];
    [self getFileImage];
    [self setProgress];
    [self startOrStop];

}
// 设置进度条
-(void)setProgress{
    unsigned long long downloadedBytes = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
        //获取已下载的文件长度
        
        downloadedBytes = [self fileSizeForPath:_filePath];
        
        CGFloat filesize = (CGFloat) [_downLoadFileObject.file_length longLongValue];
        CGFloat progress = 0;
        if (filesize > 0) {
            progress = (CGFloat)downloadedBytes / filesize;
        }
      
        [self.progressLabel setFrame:CGRectMake(0, 0,progress * self.progressView.width , self.progressView.height)];
        self.fileDownLoadSize.text = [NSString stringWithFormat:@"%@/%@",[self convertFileSize:downloadedBytes],[self convertFileSize:filesize]];
       
    }
    
}
// 获取文件类型的图片
-(void)getFileImage{
    NSString * fileType = [[_downLoadFileObject.file_name componentsSeparatedByString:@"."] lastObject];
    UIImage * image ;
    if ([fileType hasPrefix:@"ppt"]) {
        image = [UIImage scaledImageForName:@"icon_file_ppt" ofType:@"png"];
    }else if ([fileType hasPrefix:@"doc"]){
        image = [UIImage scaledImageForName:@"icon_file_doc" ofType:@"png"];

    }else if ([fileType hasPrefix:@"xls"]){
        image = [UIImage scaledImageForName:@"icon_file_xls" ofType:@"png"];

    }else if ([fileType hasPrefix:@"pdf"]){
        image = [UIImage scaledImageForName:@"icon_file_pdf" ofType:@"png"];

    }else if ([fileType hasPrefix:@"mp4"]){
        image = [UIImage scaledImageForName:@"mp4" ofType:@"png"];

    }else{
        image = [UIImage imageNamed:@"file.png"];

    }
    _fileTypeImageView.image = image;

}

// 获取文档下载存储路径
-(void)getfilePath{
    
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * filepath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"downloadfile"]];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:filepath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    
    _filePath = [NSString stringWithFormat:@"%@/%@",filepath,_downLoadFileObject.file_name];

}

// 转换文件大小
-(NSString *)convertFileSize:(long long)size{
    long long kb = 1024;
    long long mb = kb * 1024;
    long long gb = mb * 1024;
    
    if (size >= gb) {
        return [NSString stringWithFormat:@"%.1f GB", (float) size / gb];
    } else if (size >= mb) {
        float f = (float) size / mb;
        NSString * format = f > 100 ? @"%.0f MB" : @"%.1f MB";
        return [NSString stringWithFormat:format,f];
    } else if (size >= kb) {
        float f = (float) size / kb;
        NSString * format = f > 100 ? @"%.0f KB" : @"%.1f KB";
        return [NSString stringWithFormat:format,f];
    } else
        return [NSString stringWithFormat:@"%lld B", size];
}

//获取已下载的文件大小
- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}
//开始下载
- (void)startDownload {
    NSString *downloadUrl = _downLoadFileObject.file_url;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]];
    //检查文件是否已经下载了一部分
    unsigned long long downloadedBytes = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
        //获取已下载的文件长度
        
        downloadedBytes = [self fileSizeForPath:_filePath];
        if (downloadedBytes > 0) {
            NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
            [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
            request = mutableURLRequest;
        }
    }
    
    __weak typeof(self) weakself = self;
    //不使用缓存，避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    //下载请求
    operation = [[WinAFHTTPRequestOperation alloc] initWithRequest:request];
    //下载路径
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:_filePath append:YES];
    //下载进度回调
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        //下载进度
        float progress = ((float)totalBytesRead + downloadedBytes) / (totalBytesExpectedToRead + downloadedBytes);

            [weakself.progressLabel setFrame:CGRectMake(0, 0,progress * weakself.progressView.width , weakself.progressView.height)];
            [weakself.progressLabel layoutIfNeeded];
            NSString * downloadsize = [weakself convertFileSize:((float)totalBytesRead + downloadedBytes)];
            NSString * filesize = [weakself convertFileSize:(totalBytesExpectedToRead + downloadedBytes)];
           weakself.fileDownLoadSize.text = [NSString stringWithFormat:@"%@/%@",downloadsize,filesize];
            weakself.downLoadFileObject.file_length = [NSNumber numberWithInteger:((float)totalBytesRead + downloadedBytes)] ;
            weakself.downLoadFileObject.file_download_size = [NSNumber numberWithInteger:(totalBytesExpectedToRead + downloadedBytes)];
        
        NSLog(@"%f",progress);
    }];
    //成功和失败回调
    [operation setCompletionBlockWithSuccess:^(WinAFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"成功"); // 下载成功更改状态
        [weakself updataDataWithStatus:@"4"];
        weakself.downLoadFileObject.file_download_status = @"4";
        [weakself.switchButton setBackgroundImage:[UIImage scaledImageForName:@"playbtn" ofType:@"png"] forState:UIControlStateNormal];
        [weakself playAction];
    } failure:^(WinAFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"失败");
        [weakself updataDataWithStatus:@"1"]; // 如果下载失败，再次进入时重新下载

    }];
    [operation start];
}
// 下载操作
-(void)startOrStop{
    
    if ([_downLoadFileObject.file_download_status isEqualToString:@"1"]) { // 
        [self startDownload];
        _downLoadFileObject.file_download_status = @"2";
        [_switchButton setBackgroundImage:[UIImage scaledImageForName:@"download" ofType:@"png"] forState:UIControlStateNormal];
    }else if([_downLoadFileObject.file_download_status isEqualToString:@"2"]){
        [operation pause];
        _downLoadFileObject.file_download_status = @"3";
         [_switchButton setBackgroundImage:[UIImage scaledImageForName:@"needdownload" ofType:@"png"] forState:UIControlStateNormal];
    }else if([_downLoadFileObject.file_download_status isEqualToString:@"3"]){
        _downLoadFileObject.file_download_status = @"2";
        [_switchButton setBackgroundImage:[UIImage scaledImageForName:@"download" ofType:@"png"] forState:UIControlStateNormal];
        [self startDownload];

    }else{
        [self playAction];
        NSLog(@"播放");
    }
    
    [self updataDataWithStatus:self.downLoadFileObject.file_download_status];

}

/**
 *      执行播放操作
 */
-(void)playAction{

    NSURL * fileUrl =  [[NSURL alloc]initFileURLWithPath:_filePath];
    
    if (fileUrl) {
        // MSTD-6964
        [[UINavigationBar appearance] setTranslucent:YES];
        
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileUrl];
        
        [self.documentInteractionController setDelegate:self];
        
        [self.documentInteractionController presentPreviewAnimated:YES];
        
    }
    
    self.back();

}

// 更新数库
-(void)updataDataWithStatus:(NSString *)statue{
    
      [[WSDownloadFileTable sharedTable] updateWithFileURL:self.downLoadFileObject.file_url status:statue file_szie:self.downLoadFileObject.file_length downloadSize:self.downLoadFileObject.file_download_size ];
}

#pragma mark Document Interaction Controller Delegate Methods
- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
    [[UINavigationBar appearance] setTranslucent:NO];
}

// 如果刚好下载完成 就返回 有可能会崩溃，如果未下载完成 再次进去下载界面还需要继续下载所以把状态更新成 1  尽量继续下载  如果下载完成 block回调会刷新数据
-(void)dealloc{
    
    if (![self.downLoadFileObject.file_download_status isEqualToString:@"4"]) {
        [self updataDataWithStatus:@"1"];
    }
    [operation cancel];
    operation = nil;
}

@end
