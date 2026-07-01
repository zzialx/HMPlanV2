//
//  WSVideoView.m
//  WinSFA
//
//  Created by mac on 17/2/21.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSVideoView.h"
#import "NSString+ServerUrl.h"
#import <WebKit/WebKit.h>

@interface WSVideoView ()<WKNavigationDelegate>

@property (nonatomic , strong) WKWebView * myWeb;
@property (nonatomic ,strong ) UIButton * downLoadBtn;
@property(nonatomic ,strong)MBProgressHUD*  m_HUD;
@property (nonatomic , strong)  WinAFHTTPRequestOperation *operation;


@end

@implementation WSVideoView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
        webViewConfig.allowsInlineMediaPlayback = YES;
        webViewConfig.mediaPlaybackRequiresUserAction = NO;//把手动播放设置NO ios(8.0, 9.0)
        webViewConfig.mediaPlaybackAllowsAirPlay = YES;//允许播放，ios(8.0, 9.0)
        _myWeb = [[WKWebView alloc]initWithFrame:self.bounds configuration:webViewConfig];
        _myWeb.opaque = NO;
        _myWeb.backgroundColor = [UIColor blackColor];
        _myWeb.navigationDelegate = self;
        [self addSubview:_myWeb];
        _downLoadBtn = [[UIButton alloc]initWithFrame:CGRectMake(_myWeb.width * 0.5 - 30, _myWeb.height * 0.5 - 30 , 60, 60)];
        [_downLoadBtn setImage:[UIImage imageNamed:@"play_btn@2x"] forState:UIControlStateNormal];
        _downLoadBtn.layer.cornerRadius = 30;
        [_downLoadBtn addTarget:self action:@selector(dowmLoadVideo) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_downLoadBtn];
    }
    return self;
}

-(void)setVideoUrl:(NSString *)videoUrl{
    NSArray * urlArray = [videoUrl componentsSeparatedByString:@","];
    _videoUrl = [urlArray firstObject];
}
// 下载文件
-(void)dowmLoadVideo{
    
    NSString * filePath = [self getfilePathWithFileName: [[self.videoUrl componentsSeparatedByString:@"/"] lastObject]];
    
    //如果视频文件已经存在，则直接播放视频
    if (self.isDownloadComplete) {
        
        [self.m_HUD hide:YES];
        self.downLoadBtn.hidden = YES;
        self.isDownloadComplete = YES;
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:filePath]];
        [self.myWeb loadRequest:request];
        
        return;
    }

    
    NSURL * url = [NSURL URLWithString:[self.videoUrl buildupUrl]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    __weak typeof(self) weakself = self;
    //不使用缓存，避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    //下载请求
    _operation = [[WinAFHTTPRequestOperation alloc] initWithRequest:request];
    //下载路径
    _operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];
    //下载进度回调
    [_operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        weakself.downLoadBtn.hidden = YES;

        weakself.m_HUD=[MBProgressHUD showHUDAddedTo:weakself withText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil) tips:NSLocalizedString(@"please_wait", nil) tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
    }];
    //成功和失败回调
    [_operation setCompletionBlockWithSuccess:^(WinAFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"成功"); // 下载成功进行播放
        weakself.isDownloadComplete = YES;
        [weakself.m_HUD hide:YES];
        weakself.downLoadBtn.hidden = YES;
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:filePath]];
        [weakself.myWeb loadRequest:request];
    } failure:^(WinAFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"失败"); // 提示网络不好
        weakself.isDownloadComplete = NO;
        [weakself.m_HUD hide:YES];
        weakself.downLoadBtn.hidden = NO;
        NSString *NOUploadDataString = NSLocalizedString(@"视频缓存失败！！！",nil);
        if ([weakself.type isEqualToString:@"Sound"]) {
            NOUploadDataString = NSLocalizedString(@"音频缓存失败！！！",nil);
        }
       [MBProgressHUD showHUDAddedTo:weakself withText:nil tips:NOUploadDataString tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:0.5f];

    }];
    [_operation start];
    
    //YIHAIKERRY-5255 益海嘉里-上海：公告信息：信息内容为视频时，播放视频时，一直显示loading
    self.m_HUD=[MBProgressHUD showHUDAddedTo:weakself withText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil) tips:NSLocalizedString(@"please_wait", nil) tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];


}

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

// 获取文档下载存储路径
-(NSString *)getfilePathWithFileName:(NSString * )fileName{
    
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * filepath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"downloadfile"]];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:filepath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    
    return [NSString stringWithFormat:@"%@/%@",filepath,fileName];
    
}

//判断本地是不是已经存在视频
- (void)checkfileSizeForPath{
    unsigned long long downloadedBytes = 0;
    NSString * filePath = [self getfilePathWithFileName: [[self.videoUrl componentsSeparatedByString:@"/"] lastObject]];
    downloadedBytes = [self fileSizeForPath:filePath];
    if (downloadedBytes > 0){
        self.isDownloadComplete = YES;
    }else{
        self.isDownloadComplete = NO;
    }
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
}
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
}

//如果视频没有下完，此时返回时取消并删除未完成的文件
- (void)cancelDowmLoadVideo{
    
    if (!self.isDownloadComplete) {
        
        [self.m_HUD hide:YES];
        [_operation cancel];
        NSString * filePath = [self getfilePathWithFileName: [[self.videoUrl componentsSeparatedByString:@"/"] lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
}

-(void)dealloc{
    
    _operation = nil;
    _m_HUD = nil;
    _myWeb = nil;
}
@end
