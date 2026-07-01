//
//  WSMsgContentMediaView.m
//  WinSFA
//
//  Created by heju on 15/6/2.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMsgContentMediaView.h"
#import "WCBaseViewController.h"
#import "WSServiceDispatcher.h"
#import "SDPieProgressView.h"
#import "NSString+ServerUrl.h"

//  （测试稳定后删除注释的代码）

//static const CGFloat MSGMDV_Download_button_width = 50.0f;
//static const CGFloat MSGMDV_Download_button_height = 50.0f;
//static const CGFloat MSGMDV_Download_button_margin = 10.0f;
//
//
//static const CGFloat MSGMDV_Download_progressView_width = 180.0f;
//
//static const CGFloat MSGMDV_Download_progressView_height = 10.0f;
//
//
//static const CGFloat MSGMDV_Download_Views_space = 10.0f;

#define K_MSGCMV_Tip_Color [UIColor colorWithRed:32/255.0f green:166/255.0f blue:249/255.0f alpha:1.0]

#define K_MSGCMV_Progress_TrackColor [UIColor colorWithRed:207/255.0f green:207/255.0f blue:207/255.0f alpha:1.0]



@interface WSMsgContentMediaView ()<WSServiceDispatcherDelegate,WCBaseViewControllerDelegate>{
    
}

@property (nonatomic, strong) UIProgressView *downloadProgressView;

@property (nonatomic, strong) UILabel *downTipLabel;

@property (nonatomic, strong) UILabel *progressLabel;

@property (nonatomic, assign) BOOL downLoadPasue;

@property (nonatomic, assign) BOOL pasue;

@property(nonatomic,strong) UIImageView * bgImageView;
@property (nonatomic , strong) SDPieProgressView * progressView;

@end

@implementation WSMsgContentMediaView
@synthesize dowloadedAttachment;

- (id)initWithFrame:(CGRect)frame  msg:(NSObject<I_W_BuildInfo> *)msg_BuildInfo{
    self = [super initWithFrame:frame];
    if (self) {
         _pasue = NO;
        _downLoadFilePath = [[NSString alloc] init];
       
        _interactionMap = [[NSMutableDictionary alloc] init];
        // to do something
        _msgBean_msg = msg_BuildInfo;
        
        _bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 3, frame.size.width, frame.size.height - 6 )];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_bgImageView];
        
        _progressView = [[SDPieProgressView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:_progressView];
        _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downloadButton setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        UIImage *bgImg = [UIImage imageNamed:@"fujian_download_bj"];
//        _downloadButton.contentMode = UIViewContentModeScaleAspectFit;
//        [_downloadButton setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];

        //[_downloadButton setBackgroundImage:bgImg forState:UIControlStateNormal];
        [_downloadButton setImage:bgImg forState:UIControlStateNormal];
        _downloadButton.titleLabel.font = [UIFont systemFontOfSize:UI_Font - 2];
        [_downloadButton.titleLabel setText:[NSString stringWithFormat:@"%0.2f%@",0.0f,@"%"]];
        [_downloadButton.titleLabel setTextColor:K_MSGCMV_Tip_Color];
//        CGFloat downloadButton_x = INTERFACE_IS_PHONE ? (MSGMDV_Download_button_margin * 2) :  (MSGMDV_Download_button_margin * 5);
//        [_downloadButton setFrame:CGRectMake(downloadButton_x , MSGMDV_Download_button_margin *1.5, MSGMDV_Download_button_width , MSGMDV_Download_button_height)];
        [self addSubview:_downloadButton];
        
//        CGFloat progressLabelWidth = INTERFACE_IS_PHONE ? 30:40;
//        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(_downloadButton.width * 0.25 + (INTERFACE_IS_PHONE ? 7 : 0 ) , _downloadButton.height * 0.25 + 6.0f , progressLabelWidth,20)];
//        _progressLabel.alpha = 0;
//        _progressLabel.font = [UIFont systemFontOfSize:UI_Font - 4];
//        _progressLabel.textAlignment = NSTextAlignmentCenter;
//        [_progressLabel setText:[NSString stringWithFormat:@"%0.2f%@",0.0f,@"%"]];
//        [_progressLabel setTextColor:K_MSGCMV_Tip_Color];
//        [self addSubview:_progressLabel];
   /*
        CGFloat spaceOfTipAndDownloadButton = INTERFACE_IS_PHONE ? 2*MSGMDV_Download_Views_space:15*MSGMDV_Download_Views_space;
        CGFloat downTipLabelWidth = INTERFACE_IS_PHONE ? 60:70;
        if ([[UIDevice getPreferredLanguage] isEqualToString:@"ja_JP"]) {
            downTipLabelWidth = INTERFACE_IS_PHONE ? 150:180;
        }
        _downTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(_downloadButton.origin.x + _downloadButton.width + spaceOfTipAndDownloadButton,_downloadButton.origin.y + 5.0f, downTipLabelWidth, 20)];
        _downTipLabel.text = NSLocalizedString(@"请下载...", nil);
        _downTipLabel.font = [UIFont systemFontOfSize:UI_Font - 2];
        _downTipLabel.textAlignment = NSTextAlignmentCenter;
        _downTipLabel.textColor =K_MSGCMV_Tip_Color ;
        [self addSubview:_downTipLabel];
    */
        
    /*
        CGFloat progressLabelWidth = INTERFACE_IS_PHONE ? 40:60;
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(_downTipLabel.origin.x +  _downTipLabel.width, _downloadButton.origin.y + 5.0f , progressLabelWidth,20)];
        _progressLabel.font = [UIFont systemFontOfSize:UI_Font - 2];
        [_progressLabel setText:[NSString stringWithFormat:@"%0.2f%@",0.0f,@"%"]];
        [_progressLabel setTextColor:K_MSGCMV_Tip_Color];
        [self addSubview:_progressLabel];
    */
        
    /*
        _downloadProgressView =[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [_downloadProgressView setFrame:CGRectMake(_downloadButton.origin.x + _downloadButton.width + spaceOfTipAndDownloadButton,  _downTipLabel.origin.y + _downTipLabel.height + 1.5*MSGMDV_Download_Views_space, MSGMDV_Download_progressView_width, MSGMDV_Download_progressView_height)];
        _downloadProgressView.progressTintColor = K_MSGCMV_Tip_Color;
        _downloadProgressView.trackTintColor = K_MSGCMV_Progress_TrackColor;
        [self addSubview:_downloadProgressView];
    */
       
    }
    return self;
}

-(void)setBgImage:(UIImage *)bgImage{
    _bgImage = bgImage;
    [_bgImageView setImage:self.bgImage];
    
}

- (void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo {
    [super loadBuildInfo:buildInfo];
    
}

- (void)loadDataSource:(NSObject<I_W_DataSource> *)datasource {
    [super loadDataSource:datasource];
}

-(void)loadDisplayContent:(NSObject<I_W_BuildInfo> *)content {

    NSString *urlString  = [(WSMsgsBean_msg *)content  fileUrl];
    
    WSMediaInfo *mediaInfo = [[WSMediaInfo alloc] init];
    NSString *downloadFilePath =[urlString buildupUrl];
    self.downLoadFilePath = downloadFilePath;
    /**
     下载的url当做file_id
     */
    mediaInfo = [self queryMediaInfoFromeDbWithEmpId:[WSAppData getObjectbyKey:APPDATA_EMPID] fileId:downloadFilePath];
    /*0为未下载，需点击下载*/
    if ([mediaInfo getMediaDownloadStatus] == 1) {
        [self downloadMediaSource];
    } else if ([mediaInfo getMediaDownloadStatus] ==2 ){
        dowloadedAttachment = mediaInfo;
    } else if ([mediaInfo getMediaDownloadStatus] == 3) {
        [self downloadMediaSource];
    }
    
    [self setImageBtnStatusAndEvent:mediaInfo];
}


-(void)setImageBtnStatusAndEvent:(NSObject<IAttachment> *)mediaInfo{
    
    NSString *status_png_name;
    [_downloadButton removeTarget:self action:@selector(downloadMediaSource) forControlEvents:UIControlEventTouchUpInside];
    [_downloadButton removeTarget:self action:@selector(doPlay) forControlEvents:UIControlEventTouchUpInside];
    if (mediaInfo==nil) {
        status_png_name = [NSString  stringWithFormat:@"%@.png",@"icon_download_arrow"];
        [_downloadButton setHidden:NO];
        [_downloadButton setImage:[UIImage imageNamed:status_png_name] forState:UIControlStateNormal];
        [_downloadButton addTarget:self action:@selector(downloadMediaSource) forControlEvents:UIControlEventTouchUpInside];
        return;
    }
    
    if ([mediaInfo getMediaDownloadStatus]==0) {  //未下载
        status_png_name = [NSString  stringWithFormat:@"%@.png",@"icon_download_arrow"];
//        [_downloadProgressView setHidden:YES];
        [_downloadButton addTarget:self action:@selector(downloadMediaSource) forControlEvents:UIControlEventTouchUpInside];
    }
    if ([mediaInfo getMediaDownloadStatus]==1) { //正在下载
        [_downTipLabel setText:NSLocalizedString(@"downloading_label", nil)];
        /*cancel的时候会调用*/
        if (_pasue) {
            status_png_name = [NSString  stringWithFormat:@"%@.png",@"icon_download_arrow"];
        } else {
          //  status_png_name = [NSString  stringWithFormat:@"%@.png",@"download"];
//            status_png_name = nil;
            status_png_name = [NSString  stringWithFormat:@"%@.png",@"icon_download_arrow"];

        }
//         _progressLabel.alpha = 1;
        [_downloadButton setUserInteractionEnabled:YES];
        [_downloadButton removeTarget:self action:@selector(downloadMediaSource) forControlEvents:UIControlEventTouchUpInside];
        [_downloadButton addTarget:self action:@selector(excuterPauseOrResume:) forControlEvents:UIControlEventTouchUpInside];
        [_downloadButton setUserInteractionEnabled:YES];
//        [_downloadProgressView setHidden:NO];
    }
    if ([mediaInfo getMediaDownloadStatus]==2) { //下载成功
    /*
        [_downTipLabel setText:NSLocalizedString(@"已下载!", nil)];
        [_progressLabel setText:[NSString stringWithFormat:@"%0.f%@",1.0 * 100,@"%"]];
        [_downloadProgressView setProgress:1.0];
        status_png_name = [NSString  stringWithFormat:@"%@.png",@"playbtn"];
        [_downloadButton addTarget:self action:@selector(doPlay) forControlEvents:UIControlEventTouchUpInside];
        [_downloadButton setUserInteractionEnabled:YES];
     */
        status_png_name = nil;
//        [_progressLabel removeFromSuperview];
        [_progressView removeFromSuperview];

        [_downloadButton setBackgroundImage:nil forState:UIControlStateNormal];
        [_downloadButton addTarget:self action:@selector(doPlay) forControlEvents:UIControlEventTouchUpInside];
        [_downloadButton setUserInteractionEnabled:YES];
        if (self.downLoadFinish) {
            self.downLoadFinish ();
        }
    }
    if ([mediaInfo getMediaDownloadStatus]==3) { //下载失败
        status_png_name = [NSString  stringWithFormat:@"%@.png",@"icon_download_timeout"];
//        [_downloadProgressView setHidden:YES];
        [_downloadButton setUserInteractionEnabled:YES];
        [_downloadButton addTarget:self action:@selector(downloadMediaSource) forControlEvents:UIControlEventTouchUpInside];
    }
    [_downloadButton setImage:[UIImage imageNamed:status_png_name] forState:UIControlStateNormal];
}



#pragma mark Download/Play Method

- (void)doOperationWith:(WSInterAction *)interAction {
    
    if ([interAction direct_type] == DIRECT_TYPE_SERVICE_METHOD) {
         _serviceDispatcher = [[WSServiceDispatcher alloc] init];
        [_serviceDispatcher setDispatcherDelegate:self];
        [_serviceDispatcher executeDispatcher:interAction];
    } else if ([interAction direct_type] == DIRECT_TYPE_PRESENT) {
        if ([self.delegate respondsToSelector:@selector(executeAnyOperationWith:)]) {
            [self.delegate executeAnyOperationWith:interAction];
        }
        
    } else if ([interAction direct_type] == DIRECT_TYPE_PUSH) {
        if ([self.delegate respondsToSelector:@selector(executeAnyOperationWith:)]) {
            [self.delegate executeAnyOperationWith:interAction];
        }
    }
}

- (void)excuterPauseOrResume:(id)sener {
    UIImage *image  = nil;
    if (_pasue) {
        _pasue = NO;
        image = [UIImage imageForName:@"icon_download_arrow"];
        [_downloadExecutor executeCurrentTask];
    }else {
        _pasue = YES;
       image = [UIImage imageForName:@"icon_download_timeout"];
        [_downloadExecutor excuterCancel];
    }
    [_downloadButton setImage:image forState:UIControlStateNormal];
}


/*
 下载操作
 */
- (void)downloadMediaSource {
    /**
     获取下载的url
     */
    NSString *url = [_msgBean_msg getDefaultValue];
    WSInterAction *msgMediaInterAction = [self generateMsgContentMediaInterActionWith:url];
    WSMediaInfo *msgMediaInfo = [self generateMediaInfoWith:url];
    [_msgBean_msg setI_Media_Info:msgMediaInfo];
    [msgMediaInterAction setInner_param:_msgBean_msg];
    [self doDownLoadWith:msgMediaInterAction];
    
    [_downloadButton setUserInteractionEnabled:NO];
//    [_downloadProgressView setHidden:NO];
    [_downloadButton removeTarget:self action:@selector(downloadMediaSource) forControlEvents:UIControlEventTouchUpInside];
}

/*
 播放事件
 */
-(void)doPlay{
    
    WSInterAction  *interaction =[[WSInterAction alloc] init];
    
    currentInterAction = interaction;
 
    [interaction setDirect_type:DIRECT_TYPE_PUSH];
    
    [interaction setExecute_class:@"WSMediaViewController"];
    
    [interaction setExecute_class_param:dowloadedAttachment];
    
    [self doOperationWith:interaction];
}

- (void)doDownLoadWith:(WSInterAction *)interAction {
    _downloadExecutor = [[DownloadExecutor alloc] init];
    _currentbuildInfo = (NSObject<I_W_BuildInfo> *)[interAction inner_param];
    [_interactionMap setObject:interAction forKey:[[_currentbuildInfo getMediaInfo] getLoadingPath]];
    [_downloadExecutor setTaskExecuteId:[_currentbuildInfo getAcvtQstId]];
    [_downloadExecutor setDownloadFile:[_currentbuildInfo getMediaInfo]];
    [_downloadExecutor setCallBackDelegate:self];
    [_downloadExecutor executeCurrentTask];
}

/*
 生成抽象下载动作对象
 */
- (WSInterAction *)generateMsgContentMediaInterActionWith:(NSString *)url  {
    WSInterAction *interAction = [[WSInterAction alloc] init];
    [interAction setDirect_type:DIRECT_TYPE_SERVICE_METHOD];
    [interAction setExecute_class:@"WSDownloaderService"];
    [interAction setExecute_method_ns:@"executeFileDownload:"];
    [interAction setInner_param:nil];
    [interAction setViewId:url];
    [interAction setExecute_method_param:interAction];
    return interAction;
}

/*
 下载资源对象
 */
- (WSMediaInfo *)generateMediaInfoWith:(NSString *)urlString {
    NSArray *urlComponet;
    NSString *mediaType;
    NSString *mediaName = @"";
    if ([urlString length] > 0) {
        urlComponet = [urlString componentsSeparatedByString:@"."];
        mediaType = [urlComponet lastObject];
        
        NSArray *components = [urlString componentsSeparatedByString:@"/"];
        NSString *tmpfileName = [components lastObject];
        mediaName = [[tmpfileName componentsSeparatedByString:@"."] firstObject];
    }
    WSMediaInfo *mediaInfo = [[WSMediaInfo alloc] init];
    NSString *downloadFilePath =[urlString buildupUrl];
    self.downLoadFilePath = downloadFilePath;
    [mediaInfo setMedia_file_id:downloadFilePath];
    [mediaInfo setMedia_file_type: mediaType];
    [mediaInfo setMedia_file_url:downloadFilePath];
    [mediaInfo setMedia_file_name:[_msgBean_msg getQuestName]
];
    return mediaInfo;
}

- (WSMediaInfo *)queryMediaInfoFromeDbWithEmpId:(NSString *)empId  fileId:(NSString *)fileId {
    
    NSArray *names = @[@"empid",@"file_id"];
    NSArray *values = @[empId,fileId];
    NSArray *mediaArray = [[WSDownloadFileTable sharedTable] queryWithNames:names ArgumentsValue:values];
    WSDownloadFileObject *downloadFileObject = [mediaArray firstObject];
    if (downloadFileObject.file_id) {
        WSMediaInfo *mediaInfo = [[WSMediaInfo alloc] init];
        mediaInfo.media_file_id = downloadFileObject.file_id;
        mediaInfo.media_file_type = downloadFileObject.file_type;
        mediaInfo.media_file_url = downloadFileObject.file_url;
        mediaInfo.media_file_name = downloadFileObject.file_name;
        /*
         mediaInfo.media_file_local_save_path = downloadFileObject.file_save_path
         */
        /**
         获取的路径和生成的路径一样
         */
        NSString *filesavepath = [WSDownloadUtil getLocalFileAbsolutePathWithUrl:downloadFileObject.file_name fileTpye:downloadFileObject.file_type];
        mediaInfo.media_file_local_save_path = filesavepath;
        mediaInfo.status = [downloadFileObject.file_download_status integerValue];
        return mediaInfo;
    }
    return nil;
}




- (void)updateContent:(NSObject *)content {
    // to  do somegthing 更新附件信息
    WSInterAction *interAction = (WSInterAction *)content;
    NSObject<I_W_BuildInfo> *buildInfo = (NSObject<I_W_BuildInfo> *)[interAction execute_result];
    NSObject<IAttachment> *attachment = [buildInfo getMediaInfo];
//    [_downloadProgressView setHidden:NO];
//    [_downloadProgressView setProgress:[attachment getDownloadPercent]];
    NSLog(@"[attachment getDownloadPercent]---%0.f",[attachment getDownloadPercent] * 100);
//    [_progressLabel setText:[NSString stringWithFormat:@"%0.f%@",[attachment getDownloadPercent] * 100,@"%"]];
    dowloadedAttachment = attachment;
    _progressView.progress = [attachment getDownloadPercent];
    [self setImageBtnStatusAndEvent:attachment];
}

#pragma mark WSServiceDispatcherDelegate Methods

-(void)serviceBeginExecute:(WSInterAction *)interaction{
    LogInfo(@"benginExcute");
    
}

-(void)serviceExecuteEnd:(WSInterAction *)interaction{
    [self updateContent:interaction];
}

/**
 正在执行下载interAction
 */
-(void)serviceInExecute:(WSInterAction *)interaction{
    [self updateContent:interaction];
}

-(void)serviceExecuteEndWithError:(WSInterAction *)interaction{
}




#pragma mark -
#pragma mark I_Task_ExecutorDelegate method

-(void)executeBegin:(NSObject<I_Task_Execute> *)taskobj{
    
}

-(void)executeInRun:(NSObject<I_Task_Execute> *)taskobj{
    
    WSInterAction *interAction = [_interactionMap objectForKey:[[taskobj getDownloadFile] getLoadingPath]];
    
    NSObject<I_W_BuildInfo> *buildInfo = (NSObject<I_W_BuildInfo> *)[interAction  inner_param];
    
    [buildInfo setI_Media_Info:[taskobj getDownloadFile]];
    
    [interAction setExecute_result:buildInfo];
    [self updateContent:interAction];
    
    
}

-(void)executeInEnd:(NSObject<I_Task_Execute> *)taskobj{
    
    WSInterAction *interAction = [_interactionMap objectForKey:[[taskobj getDownloadFile] getLoadingPath]];
    
    NSObject<I_W_BuildInfo> *buildInfo = (NSObject<I_W_BuildInfo> *)[interAction  inner_param];
    
    [buildInfo setI_Media_Info:[taskobj getDownloadFile]];
    
    [interAction setExecute_result:buildInfo];
    [self updateContent:interAction];
    
}

- (void)executeError:(NSObject<I_Task_Execute> *)taskobj {
    
}


- (void)dealloc {
    [self.downloadExecutor excuterCancel];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
