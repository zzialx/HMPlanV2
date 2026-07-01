//
//  WSDetalViewController.m
//  demo
//
//  Created by admin on 15/10/21.
//  Copyright (c) 2015年 zhiqingPC. All rights reserved.
//

#import "WSDetalViewController.h"
#import "WSRevertViewController.h"
#import "CellModel.h"
#import "RevertArrayModel.h"
#import "WSMsgsBean_msg.h"
#import "UIView+Extension.h"
#import "UIBarButtonItem+Extension.h"
#import "WSRequestHelper.h"
#import "WSMsgsBean.h"
#import "WSMsgContentMediaView.h"
#import "WSServiceDispatcher.h"
#import "WSDetailHeadView.h"
#import "WSMsgDetalTextView.h"
#import "WSMsgsBean_Component_msg.h"
#import "ImageHelper.h"
#import "WSImageBrowserView.h"
#import <MediaPlayer/MPMoviePlayerController.h>

#import "WSGetMsgHttpService.h"
#import "WSMsgBeanArray.h"
#import "WSBaseMsgTypeTable.h"
#import "WSBaseMsgTable.h"
#import "JFTakeCountButton.h"
#import "WSImageBrowserViewController.h"
#import "JSBadgeView.h"
#import "WSMessageDetailFileCell.h"
#import "UIViewController+ESSeparatorInset.h"
#import "WSDetailFileDownLoadView.h"
#import "WSVideoView.h"
#import "NSString+Additions.h"
#import "WSMJProgressHeader.h"
#import "WSRequestHelper.h"
#import "NSString+ServerUrl.h"
#import <WebKit/WebKit.h>

#define MARGIN_TOP ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10 : 15)
#define MARGIN_LEFT ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 15 : 15)
#define MSG_HEIGHT ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 16 : 20)
#define WCPADDING 20.0f
#define FONT_NAME @"Heiti SC"
#define FONT_SIZE ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 14 : 16)
#define kLeftVieWidth 200.0f
#define BROWSERVC_WIDTH 1024
#define BROWSERVC_HEIGNT 768
#define IMGVIE_HEIGHT ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 200 : 300)

@interface WSDetalViewController ()<WKUIDelegate>
{
    long long totalLength;


}


@property(nonatomic,strong) WSDetailHeadView * msgView;
@property(nonatomic,strong) WSMsgDetalTextView * detailTextView;
@property(nonatomic,strong) WSDetailFileDownLoadView * fileView;
@property(nonatomic,weak) UIView * detailView;
@property(nonatomic,weak) UILabel * fenGeLable;
@property(nonatomic,weak) UILabel * fenGeLable2;
@property(nonatomic,strong) UIImageView * imgView;
@property(nonatomic,strong) UIButton * downBtn;
@property(nonatomic,strong) UIBarButtonItem * rightBarButton;
@property(nonatomic,strong) NSMutableArray * chatArray;
@property(nonatomic,strong) UIScrollView * scrollView;
@property (nonatomic,strong) NSMutableArray *mediaViews;
@property (nonatomic, strong) UIView *bowserImageView;
@property (nonatomic, strong) WSServiceDispatcher *serviceDispatcher;
@property(nonatomic,strong)  WSVideoView * mpc; // 视频
@property(nonatomic,strong)  WSVideoView * soundView; // 音频

@property (nonatomic,strong) NSMutableArray * imgViewArrays;
@property(nonatomic,strong) NSMutableArray *imgArray;
@property(nonatomic,strong) UILabel * fileSize;
@property (nonatomic,copy)NSString *imageType;
@property (nonatomic, strong) UIView *coverView;
@property(nonatomic,strong) WSGetMsgHttpService * getMsgHttpService;
@property (nonatomic , assign) NSInteger unReadReplyCount;
@property (nonatomic , strong) UIImageView * selectImageView;
@property (nonatomic , strong) UIImageView * midImageView;
@property (nonatomic , strong) UIImageView * bottomImageView;

@end

@implementation WSDetalViewController

-(instancetype)init{
    self = [super init];
    if (self) {
         _mediaDic = [[NSMutableDictionary alloc]init];
         _revertArray = [[NSMutableArray alloc]init];
         _chatArray = [[NSMutableArray alloc]init];
         _rightBarButton = [UIBarButtonItem new];
         _mediaViews = [[NSMutableArray alloc]init];
         _imgViewArrays = [[NSMutableArray alloc]init];
         _imgArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%@ dealloc", [self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeHiddenNotification object:nil];
}

-(void)endFullScreen{
    NSLog(@"退出全屏后显示状态栏");
    [self prefersStatusBarHidden];
    
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //YIHAIKERRY-5296 益海嘉里-上海：公告信息：视频播放成功后，点击全屏按钮，页面手机端的信息被APP页面遮挡，无法显示
    //监听UIWindow隐藏
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endFullScreen) name:UIWindowDidBecomeHiddenNotification object:nil];

    self.title = NSLocalizedString(@"information_details", nil);
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, MAIN_BUTTON_WH, 44)];
    [backBtn setBackgroundColor:[UIColor clearColor]];
    [backBtn setImage:[UIImage scaledImageForName:@"icon_back" ofType:@"png"] forState:UIControlStateNormal];
//    [backBtn setImage:[UIImage imageForName:@"icon_back_press.png"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    //added by miller
    if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -5;
        if (INTERFACE_IS_PHONE) {
            self.navigationItem.leftBarButtonItems = @[negativeSpacer, homeButtonItem];
        }else{
            self.navigationItem.leftBarButtonItems = nil;
        }
        
    }else{
        if (INTERFACE_IS_PHONE) {
            self.navigationItem.leftBarButtonItem = homeButtonItem;

        }else{
            self.navigationItem.leftBarButtonItem = nil;

        }
    }
    // IPAD 如果没有信息详情，需要加空白页显示
    if (self.model) {
        if (self.model.visitAddress) {
            [self setupWebViews];
            
        }else if (!self.msgIDFromWebView){
            
            [self setUpSubViews];
            
        }else {
            if ([self.msgIDFromWebView length] > 0) {
                [self getMessageWhenLoadFromWebView];
            }
        }

    }else{
        [self addEmptyView];
    }
}
- (void)setupWebViews {
    [self createScrollView];
    
    [self addMsgView];
    
    // 跳转到webView界面
    CGRect rect = CGRectMake(self.view.origin.x, CGRectGetMaxY(self.msgView.frame), self.view.size.width, self.view.size.height);
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKPreferences *preference = [[WKPreferences alloc] init];
    preference.minimumFontSize = 0;
    preference.javaScriptEnabled = YES;
    preference.javaScriptCanOpenWindowsAutomatically = YES;
    config.preferences = preference;
    config.allowsInlineMediaPlayback = YES;
    config.mediaTypesRequiringUserActionForPlayback = YES;
    config.allowsPictureInPictureMediaPlayback = YES;
    config.applicationNameForUserAgent = @"winchannel";
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    config.userContentController = wkUController;
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:rect configuration:config];
    webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:webView];
    
    NSURL * url = [NSURL URLWithString:self.model.visitAddress];
    NSURLRequest * webRequest = [NSURLRequest requestWithURL:url];
    [webView loadRequest:webRequest];
    [self.scrollView addSubview:webView];
    
    [self.scrollView setContentSize:CGSizeMake(0, CGRectGetMaxY(webView.frame)  +20)];
}

- (void)createScrollView {
    UIScrollView * scrollView;
    if (INTERFACE_IS_PAD) {
        if (self.isTopBanner) {
             scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, BROWSERVC_WIDTH - kLeftVieWidth - 40 , 300)];
        }else{
            scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, BROWSERVC_WIDTH - kLeftVieWidth - 40 , 300)];
            scrollView.backgroundColor = [UIColor clearColor];
            
//            UIImageView * topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, scrollView.width, 54)];
//            UIImage *image = [UIImage imageNamed:@"xxts_shang"];
//            topImageView.image = image ;
            
            //self.topImageView = topImageView;
//            UIImageView * midImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 54, scrollView.width, scrollView.bottom - 54 - 23)];
//            self.midImageView = midImageView;
//            midImageView.image = [UIImage imageNamed:@"xxts_zhong"];
//            UIImageView * bottomImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, scrollView.bottom - 23, scrollView.width, 33)];
//            self.bottomImageView = bottomImageView;
//            bottomImageView.image = [UIImage imageNamed:@"xxts_xia"];
            
            
            //[scrollView addSubview:topImageView];
//            [scrollView addSubview:midImageView];
//            [scrollView addSubview:bottomImageView];
        }

    }else{
    
        scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    }
    scrollView.autoresizingMask =  UIViewAutoresizingFlexibleHeight;
    
    NSString *noreplay = [WSAppData getObjectbyKey:APPDATA_NOREPLY];
    if (noreplay == nil || ![noreplay isEqualToString:@"1"]) {
        WSMJProgressHeader *header = [WSMJProgressHeader headerWithRefreshingTarget:self refreshingAction:@selector(updataReplyInfo)];
        header.automaticallyChangeAlpha = YES;
        scrollView.mj_header = header;
    }
    
    
    [self.view addSubview:scrollView];
    
    self.scrollView = scrollView;
}

- (void)setUpSubViews
{
    [self createScrollView];
    
    // 添加 主要信息视图
    [self addMsgView];
    //添加 文件 视图 -----详情信息中 如果有文件附件 则显示 这个模块 如果没有则不显示此模
    NSString * message ;
    NSString * urlStr = nil;
    urlStr = self.model.url ? : self.model.fileUrl;
    
    if (urlStr) {
        
        NSArray *arr = [NSArray arrayWithObjects:@"png",@"jpg",@"bmp",@"gif",@"jpeg", nil];
//        NSRange range = NSRangeFromString(self.model.url);
//        range.length = range.length - 3;
//        message = [self.model.url substringFromIndex:(urlStr.length - 3)];
        
        NSArray *urlSegArray = [self.model.url componentsSeparatedByString:@"."];
        message = [urlSegArray lastObject];

        if ([arr containsObject:[message lowercaseString]] && self.model.fileUrl.length == 0) { // 只有图片
            // 添加信息详情视图
            [self addMsgDetalView];
            // 添加缩略图
            [self addImgView];
        }else if([arr containsObject:[message lowercaseString]] && self.model.fileUrl.length > 0){ //图片加文件
            [self addFileView];
            // 添加信息详情视图
            [self addMsgDetalView];
            
            [self addImgView];
        }else{ // 只有文件
            [self addFileView];
            
            [self addMsgDetalView];
        }
    }else{
        
        // 添加信息详情视图
        [self addMsgDetalView];
    }
    
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (INTERFACE_IS_PAD) self.scrollView.frame = CGRectMake(0, 0, BROWSERVC_WIDTH - kLeftVieWidth - 40 , 300);
   
    self.midImageView.frame = CGRectMake(0, 54, self.scrollView.width, self.scrollView.contentSize.height - 54 - 23);
  
    self.bottomImageView.frame = CGRectMake(0, self.scrollView.contentSize.height - 23, self.scrollView.width, 33);
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if (!self.msgIDFromWebView) {
        //Send request
        // IPAD 如果没有信息详情，不需要请求回复数据
        if (self.model) {
            // 请求回复数组的数据
            NSString *noreplay = [WSAppData getObjectbyKey:APPDATA_NOREPLY];
            if (noreplay == nil || ![noreplay isEqualToString:@"1"]) {
                //            MSTD-7386 董宏标准产品修改
                [self addRightButton:0];
                [self updataReplyInfo];
            }

        }
    }

    

    if (self.isHomePageShow && (self.model.url || self.model.fileUrl)) {
        NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
        
        NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
        if ( projectName != nil && [projectName isEqualToString:@"SKSHU"] && [[mobileHomeDic objectForKey:MobileHomePageReadingTimeKey] intValue] > 0) {
            [self showImageWhenHomePageShowWithTime:[[mobileHomeDic objectForKey:MobileHomePageReadingTimeKey] intValue]];
        }
        self.isHomePageShow = NO;
    }
}

-(void)updataReplyInfo{
    // 请求回复数组的数据

    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr getMSGWithId:self.model.Id NotifyName:PARTNERSMSG_NOTIFY];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(partnersCommentsFinished:) name:PARTNERSMSG_NOTIFY object:nil];
}

- (void)getMessageWhenLoadFromWebView
{
    self.getMsgHttpService = [[WSGetMsgHttpService alloc]init];

    __weak typeof(self) wself = self;

    [MBProgressHUD showHUDAddedTo:self.view withText:NSLocalizedString(@"加载中…", nil)  tips:nil tapTarget:self action:nil];

    [self.getMsgHttpService getMsgDataWithCompletionBlock:^(NSDictionary *dic, NSError *error) {

        [MBProgressHUD hideAllHUDsForView:wself.view animated:YES];

        WSMsgBeanArray * messageArray = [[WSMsgBeanArray alloc]initWithObject:[[WSBaseMsgTypeTable sharedTable] queryBaseMsgType]];
        WSMsgsBean_msg *currentMsgsBean_msg = [[WSMsgsBean_msg alloc]init];

        for (WSMsgsBean *msgsBean  in messageArray.msgArray) {

            for (WSMsgsBean_msg *msgsBean_msg in msgsBean.msg) {

                if ([msgsBean_msg.Id isEqualToString:wself.msgIDFromWebView]) {

                    currentMsgsBean_msg = msgsBean_msg ;
                    break;
                }
            }
        }

        if (currentMsgsBean_msg) {

            wself.model = currentMsgsBean_msg ;
            wself.msgBean = messageArray.msgArray;
            
            [wself setUpSubViews];
        }

        wself.getMsgHttpService = nil;
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 获取数据完成后 需要解析 出数据并转换成 回复数据模型
-(void)partnersCommentsFinished:(id)sender
{
    [self.scrollView.mj_header endRefreshing];
    [self.revertArray removeAllObjects];
    [self.chatArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PARTNERSMSG_NOTIFY object:nil];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    
    self.unReadReplyCount = 0;
    if (error.code != 0) {
        NSString *NONetWorkString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NONetWorkString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }else
    {
        
        
        NSString *info = [[sender userInfo] objectForKey:DATAS];
        NSDictionary* l_info = [info objectFromJSONString];
        NSArray* l_msgreplies = [l_info objectForKey:@"msgreplies"];
       // 计算未读回复的条数
        NSDictionary * dict = [[NSUserDefaults standardUserDefaults] objectForKey:LastReplyCount];
        NSString * keyString = [NSString stringWithFormat:@"%@_%@",[WSAppData getObjectbyKey:APPDATA_EMPID],self.model.Id];
        
        NSInteger replyCount = [dict[keyString] integerValue];
        // SFA-18337 此处取差的绝对值     //YIHAIKERRY-3226。换一种取绝对值的方法
        NSInteger l_msCount = l_msgreplies.count;
        self.unReadReplyCount =labs(l_msCount - replyCount);
        
#pragma -mark  这是更新的时间.....
        
        if(l_msgreplies != nil&& [l_msgreplies count]>0)
        {
            NSMutableArray * aryM = [NSMutableArray array];
            for(NSDictionary* content in l_msgreplies)
            {
                NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                NSString *rep = [content objectForKey:@"rep"];
                NSArray * ary = [rep componentsSeparatedByString:@":"];
                // 后台会多返回一个空格，后台暂不调整，所以手机端处理
                NSString * revertMsg = [rep substringFromIndex:[ary[0] length] + 2];
                [dict setValue:[NSString stringNotNilWithValue:ary[0]] forKey:@"userName"];
                [dict setValue:[NSString stringNotNilWithValue:revertMsg]  forKey:@"revertMsg"];
                NSString * reply_time = [content objectForKey:@"UPLOAD_DATE"];
                if (reply_time.length == 0) {
                    reply_time = [content objectForKey:@"reply_time"];
                }
                [dict setValue:[NSString stringNotNilWithValue:reply_time] forKey:@"reply_time"];
                RevertArrayModel * model = [RevertArrayModel cellWithDict:dict];
                [aryM addObject:model];
            }
            self.revertArray = aryM;
        }
        
    }
    self.navigationItem.rightBarButtonItem = nil;
    [self addRightButton:self.unReadReplyCount];
    return;
}


-(void)addRightButton:(NSInteger)count{
    UIButton * revert =[[UIButton alloc]init];
    if (count != 0) {
        JSBadgeView *badgeView = [[JSBadgeView alloc]initWithParentView:revert alignment:JSBadgeViewAlignmentTopRight];
        badgeView.badgeText = [NSString stringWithFormat:@"%ld",(long)count];
        if (count > 99) {
            badgeView.badgeText = @"99+";
        }
        badgeView.badgeTextShadowOffset = CGSizeMake(badgeView.width, badgeView.width);
    
//        badgeView.badgePositionAdjustment = CGPointMake(5, -5);
//        badgeView.badgeStrokeColor = [UIColor redColor];
        [badgeView setNeedsLayout];
//        revert.titleLabel.text = [NSString stringWithFormat:@"%zd回复",count];
    }

    [revert setTitleColor:MAIN_TINT_COLOT forState:UIControlStateNormal];
    revert.titleLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE - 2 ];
    [revert setTitle:[NSString stringWithFormat:NSLocalizedString(@"topic_reply", nil)] forState:UIControlStateNormal];
    UIImage *huifuImg = [UIImage imageNamed:@"info_huifu_bj" ];
    UIColor * color = [UIColor colorForKey:@"NavigationBarButtonTitleColor"];
    UIColor * witeColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    if (CGColorEqualToColor(color.CGColor,witeColor.CGColor)) {
        [revert setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    [revert setBackgroundImage:huifuImg forState:UIControlStateNormal];

    [revert addTarget:self action:@selector(reply) forControlEvents:UIControlEventTouchUpInside];
    [revert sizeToFit];
    
    UIBarButtonItem * revertbtn = [[UIBarButtonItem alloc]initWithCustomView:revert];

    self.rightBarButton = revertbtn;
    if (INTERFACE_IS_PAD) {
        WCBaseViewController *parentVC =(WCBaseViewController *)self.ownParentViewController;
        [parentVC getNavigationItem].rightBarButtonItem = revertbtn ;
    }else{
        self.navigationItem.rightBarButtonItem = revertbtn;
    }
}

// 添加 主要信息视图
-(void)addMsgView{
    
    CGSize textSize = CGSizeMake(self.scrollView.width - 2 * MARGIN_LEFT, CGFLOAT_MAX);
    CGSize size  = [self.model.title ws_sizeWithFont:[UIFont systemFontOfSize:INTERFACE_IS_PHONE ? 16 : 16] constrainedToWidth:textSize.width lineBreakMode:NSLineBreakByWordWrapping];

    CGFloat height = INTERFACE_IS_PHONE ? 77 : 80;
    self.msgView = [[WSDetailHeadView alloc]initWithFrame:CGRectMake(MARGIN_LEFT, 10, self.scrollView.width - 2 * MARGIN_LEFT,height + size.height - 20)];
    self.msgView.model =self.model;
    self.msgView.msgBean = self.msgBean;
    [self.scrollView addSubview:self.msgView];
    [self.scrollView setContentSize:CGSizeMake(0, self.msgView.size.height  +20 )];

}

// 添加 视屏 视图
-(void)addVideoView{
    CGFloat videoY = 0;
   if (self.fileView){
        videoY = CGRectGetMaxY(self.fileView.frame);
    }else{
        videoY = CGRectGetMaxY(self.msgView.frame);
    }
    WSVideoView *myVideo = [[WSVideoView alloc] initWithFrame:CGRectMake(MARGIN_LEFT , videoY + MARGIN_TOP , self.scrollView.width - 2 * MARGIN_LEFT, 122)];
    myVideo.videoUrl = self.model.video_url;
    myVideo.type = @"video";
    self.mpc = myVideo;
    [self.scrollView addSubview:myVideo];
    [self.mpc checkfileSizeForPath];

}

// 添加 音频 视图
-(void)addSoundView{
    CGFloat soundY = 0;
    if (self.mpc) {
        soundY = CGRectGetMaxY(self.mpc.frame);
    }else if (self.fileView){
        soundY = CGRectGetMaxY(self.fileView.frame);
    }else{
        soundY = CGRectGetMaxY(self.msgView.frame);
    }
    WSVideoView *mySound = [[WSVideoView alloc] initWithFrame:CGRectMake(MARGIN_LEFT , soundY + MARGIN_TOP , self.scrollView.width - 2 * MARGIN_LEFT, 122)];
    mySound.videoUrl = self.model.sound_url;
    mySound.type = @"Sound";

    self.soundView = mySound;
    [self.scrollView addSubview:mySound];
    
}

// 添加 文件 视图
-(void)addFileView{

    NSArray  *array = [self.model.fileName componentsSeparatedByString:@","];

    self.fileView = [[WSDetailFileDownLoadView alloc]initWithFrame:CGRectMake(MARGIN_LEFT, self.msgView.bottom, self.scrollView.width - 2 * MARGIN_LEFT,  self.model.componentMsgs.count * cell_Height_For_Row) withFiles:self.model.componentMsgs addFileNames:array];
    [self.scrollView addSubview:self.fileView];
    [self.scrollView setContentSize:CGSizeMake(0, CGRectGetMaxY(self.fileView.frame)  +20)];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"滑动");

}

/**
 *  信息详情界面
 */
-(void)addMsgDetalView{
    
    if(self.model.video_url){
        
        [self addVideoView];
    }
    
    if(self.model.sound_url){
        
        [self addSoundView];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing =INTERFACE_IS_PHONE ? 10 : 15;// 字体的行间距
//    MMSH-4408
//    SFA玛氏中国MWC- 【IOS:信息】账号csissyd1,一登录没有显示列表而是从信息列表一直跳转到信息的内容，并且信息的内容的行距很大
    paragraphStyle.paragraphSpacing = 2;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:FONT_SIZE],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    
    NSString * contString = self.model.cont;
    contString = [contString stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    contString = [contString stringByReplacingOccurrencesOfString:@"\\" withString:@""];

    NSAttributedString *desContent = [[NSAttributedString alloc] initWithString:[NSString stringNotNilWithValue:contString] attributes:attributes];
    
    CGFloat width = self.scrollView.width - 2 *MARGIN_LEFT;
    
    CGSize size = [desContent boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    
    CGFloat detailTextY = 0;
    if (self.soundView) {
        detailTextY = CGRectGetMaxY(self.soundView.frame);
    }else if (self.mpc){
        detailTextY = CGRectGetMaxY(self.mpc.frame);
    }else if(self.fileView){
        detailTextY = CGRectGetMaxY(self.fileView.frame);
    }else{
        detailTextY = CGRectGetMaxY(self.msgView.frame);

    }

    self.detailTextView  = [[WSMsgDetalTextView alloc]initWithFrame:CGRectMake(MARGIN_LEFT, detailTextY + MARGIN_TOP,width, size.height)];
    
    self.detailTextView.attributedText = desContent;
    [self.scrollView addSubview:self.detailTextView];
    [self.scrollView setContentSize:CGSizeMake(0, CGRectGetMaxY(self.detailTextView.frame) +20) ];
}


// 添加缩略图
-(void)addImgView{

    __block CGFloat imgViewHeight = 0.0f;
    
    CGFloat imgViewWidth = self.scrollView.width - 2 * MARGIN_LEFT;
    NSString * urlStr = nil;
    urlStr = self.model.url;
    if (urlStr ) {
         NSArray * medieArray = [urlStr componentsSeparatedByString:@","];
        for (int i = 0 ; i < medieArray.count; i++) {
            __block UIImageView * imgView = [[UIImageView alloc]init];
            imgView.width = imgViewWidth;
            imgView.clipsToBounds = YES;
            imgView.userInteractionEnabled = YES;
            UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scaleImg:)];
            [imgView addGestureRecognizer:gesture];
            [self.scrollView addSubview:imgView];
            [self.imgViewArrays addObject:imgView];
            [self.imgArray addObject:[UIImage imageForName:@"picture_loading_failed"]];

            imgView.centerX = (self.view.width - (INTERFACE_IS_PHONE ? 0 : kLeftVieWidth)) / 2 ;
            imgView.tag = i;
            NSString * url = [medieArray[i] buildupUrl] ;
            __block   NSMutableArray *imgTempArray = [[NSMutableArray alloc]init];
            
            [[WSRequestHelper shareInstance] downloadImageWithUrl:url imageView:imgView placeholderImage:[UIImage imageNamed:@"picture_loading"] progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
                if(error || !image){
                    imgView.image = [UIImage imageForName:@"picture_loading_failed"];
                } else {
                    UIImage * tempImage = [ImageHelper imageCompressForWidthScale:image targetWidth:imgViewWidth];
                     [imgTempArray addObject:tempImage];
                    imgViewHeight = tempImage.size.height;
                    imgView.image = image;
                }
                
                imgView.height = imgViewHeight;
                imgView.centerX = self.scrollView.width / 2 ;
                //判断当前回调是第几个图片
                NSInteger imageIndex = 0;
                NSArray * urlArray = [self.model.url componentsSeparatedByString:@","];
                for (int j=0; j<urlArray.count; j++) {
                    NSString * urlString = [[urlArray objectAtIndex:j] buildupUrl];
                    if (urlString) {
                        NSRange rang=[imageURL.absoluteString rangeOfString:urlString];
                        if(rang.location != NSNotFound){
                            imageIndex=j;
                            break;
                        }
                    }
                }
                // 按照实际顺序添加图片
                if (image) {
                    [self.imgArray replaceObjectAtIndex:imageIndex withObject:image];
                }else {
                    [self.imgArray replaceObjectAtIndex:imageIndex withObject:[UIImage imageForName:@"picture_loading_failed"]];
                }
                
                imgView.y = CGRectGetMaxY(self.detailTextView.frame) + MAIN_PADDING +imageIndex*imgView.bounds.size.height ;
                // 按照实际顺序排序
                for (NSInteger i = 0; i < self.imgViewArrays.count; i++) {
                    
                    UIImageView *tempImageView = [self.imgViewArrays objectAtIndex:i];
                    if (i == self.imgViewArrays.count - 1) {
                        [self.scrollView setContentSize:CGSizeMake(0, tempImageView.bottom  +20)];
                    }else{
                        
                        UIImageView * lastImageView = [self.imgViewArrays objectAtIndex:i+1];
                        lastImageView.y = tempImageView.bottom + MAIN_PADDING ;

                    }
                }

            }];
        }
        
    }
  
}
-(void)showcoverViewWithTime:(int)timer{
    
    WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *rootViewController = delegate.window.rootViewController;
    
    __block UIView *coverView = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
    
    [rootViewController.view addSubview:coverView];
    
    self.coverView = coverView;
    
    
    JFTakeCountButton *durationButton = [JFTakeCountButton initWithCount:timer
                                                               withTitle:nil
                                                          withTitleColor:[UIColor grayColor]
                                                           withTitleFont:[UIFont boldSystemFontOfSize:30.0f]
                                                               withBlock:^{
                                                                   [coverView removeFromSuperview];
                                                                   self.coverView = nil;
                                                               }];
    [durationButton startTakeCount];
    [durationButton setFrame:CGRectMake(0, 20, 60, 60)];
    [coverView addSubview:durationButton];

}
- (void)addTimeView:(int)timer{

    JFTakeCountButton *durationButton = [JFTakeCountButton initWithCount:timer
                                                               withTitle:nil
                                                          withTitleColor:[UIColor grayColor]
                                                           withTitleFont:[UIFont boldSystemFontOfSize:30.0f]
                                                               withBlock:^{
                                                                   UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchShowImageViewEnd:)];
                                                                   [self.bowserImageView addGestureRecognizer:gesture];
                                                               }];
    [durationButton startTakeCount];
    [durationButton setFrame:CGRectMake(0, 20, 60, 60)];
    [self.bowserImageView addSubview:durationButton];
}
- (void)showImageWhenHomePageShowWithTime:(int)timer
{
    NSString *urlStr = self.model.url ? : self.model.fileUrl;
    if (urlStr) {
        NSArray * medieArray = [urlStr componentsSeparatedByString:@","];
        NSString * url = [medieArray[0] buildupUrl];
        
        __block UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromKey:url];
        
        if (cacheImage) {
            [self scaleImageWithImageArray:@[cacheImage] index:0 withShowHomePage:INTERFACE_IS_PAD ? NO : YES];
            INTERFACE_IS_PAD ? [self showcoverViewWithTime:timer] : [self addTimeView:timer];
        }else {
            [[WSRequestHelper shareInstance] downloadImageWithUrl:url progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                // 处理下载进度
            } completed:^(UIImage *image, NSError *error, BOOL finished, NSURL *imageURL) {
                if(error){
                    cacheImage = [UIImage imageForName:@"picture_loading_failed"];
                } else {
                    cacheImage = image;
                }
            
                [self scaleImageWithImageArray:@[cacheImage] index:0 withShowHomePage:INTERFACE_IS_PAD ? NO : YES];
                INTERFACE_IS_PAD ? [self showcoverViewWithTime:timer] : [self addTimeView:timer];

                WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
                UIViewController *rootViewController = delegate.window.rootViewController;
                [rootViewController.view bringSubviewToFront:self.coverView];
                
            }];

        }
    }
}

-(void)scaleImg:(UITapGestureRecognizer *)tap{
    self.selectImageView = (UIImageView *)tap.view;
    self.selectImageView.userInteractionEnabled = NO;
    NSInteger tag = tap.view.tag;
    
    [self scaleImageWithImageArray:self.imgArray index:tag withShowHomePage:NO];
}

- (void)scaleImageWithImageArray:(NSArray *)array index:(NSInteger)index withShowHomePage:(BOOL)isShowHomePage
{
//    WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
//    UIView *rootView = delegate.window.rootViewController.view;
    
    WSImageBrowserView * view = [[WSImageBrowserView alloc]initWithFrame:INTERFACE_IS_PAD ? CGRectMake(0, 0, BROWSERVC_WIDTH, BROWSERVC_HEIGNT) : kApplicationWinddow.bounds andImage:array andImageIndex:index];

    if (isShowHomePage == NO) {
        UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchShowImageViewEnd:)];
        [view addGestureRecognizer:gesture];
    }
    self.bowserImageView = view;
    
    if (INTERFACE_IS_PAD) {
        view.frame = CGRectMake((BROWSERVC_WIDTH - view.width)/2,view.size.height, view.size.width, view.size.height);
    } else {
        view.frame = CGRectMake(view.origin.x,view.size.height, kApplicationWinddow.bounds.size.width, kApplicationWinddow.bounds.size.height);
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        view.top = 0;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];

    } completion:^(BOOL finished) {

    }];
    
    [kApplicationWinddow addSubview:view];

}

- (void)touchShowImageViewEnd:(UIView *)view {
    if (self.bowserImageView) {
        [UIView animateWithDuration:0.25 animations:^{
            self.bowserImageView.top = self.bowserImageView.height;
            [[UIApplication sharedApplication] setStatusBarHidden:NO];

        } completion:^(BOOL finished) {
            [self.bowserImageView removeFromSuperview];
            self.bowserImageView = nil;
            self.selectImageView.userInteractionEnabled = YES;

        }];

    }
}
-(void)reply{
    
    // UIViewController 也可以自定义 这个controller  添加回复模块
    WSRevertViewController * revertCtrl = [[WSRevertViewController alloc]initWithMSG:self.model];
    
    revertCtrl.inputStr = [self.revertArray copy];
    
    NSString *totalStr = [NSString stringWithFormat:NSLocalizedString(@"%zd", nil),revertCtrl.inputStr.count];
    revertCtrl.title = [NSString stringWithFormat:@"%@(%@)",NSLocalizedString(@"topic_reply", nil),totalStr];

    [self.navigationController pushViewController:revertCtrl animated:YES];
    
    if (self.unReadReplyCount != 0) {
        NSMutableDictionary * dict = [[[NSUserDefaults standardUserDefaults] objectForKey:LastReplyCount] mutableCopy];
        if (!dict) {
            dict = [[NSMutableDictionary alloc]init];
        }
        NSString * keyString = [NSString stringWithFormat:@"%@_%@",[WSAppData getObjectbyKey:APPDATA_EMPID],self.model.Id];
        [dict setObject:@(self.revertArray.count) forKey:keyString];
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:LastReplyCount];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}



- (void)backAction{
    
    if(self.model.video_url && !self.mpc.isDownloadComplete){
        
        [self.mpc cancelDowmLoadVideo];
    }

    // MSTD-7125
    [self backToParent];
}


@end
