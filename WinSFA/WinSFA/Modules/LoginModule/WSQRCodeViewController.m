//
//  WSQRCodeViewController.m
//  WinSFA
//
//  Created by heju on 14-7-29.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

@import MessageUI;
#import "WSQRCodeViewController.h"
#import "WSQRModule.H"
#import "WSInterAction.h"
#import "WSPopViewController.h"
#import "WSBottomPopView.h"
#import "UINavigationController+Additions.h"


#define KHorizontalDisplayScale ([UIScreen mainScreen].bounds.size.width / 414.0)
#define KVerticalDisplayScale ([UIScreen mainScreen].bounds.size.height / 736.0)

#define kCustomBtnYoffSet ((49 / 736.0) * [UIScreen mainScreen].bounds.size.height)

#define IsIPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define k_QR_BgView_YOffset ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 60 : 60)
#define k_sendBtnYOffset ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? (IsIPhone4 ? 370 :450 ): 450)
#define k_QR_BgView_Width ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 295 * KHorizontalDisplayScale: 295)
#define k_QR_BgView_Height ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 400 * KVerticalDisplayScale : 400)
#define k_QR_With ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 200  : 200 * (1024/768))
#define k_QR_YOffset ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 104 * KVerticalDisplayScale : 104)
#define k_SmallLogo_YOffset ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 40 * KVerticalDisplayScale : 40)
#define k_SmallLogonWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 125 * KHorizontalDisplayScale : 125)
#define k_SmallLogonHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 33 * KVerticalDisplayScale : 33)

#define k_DownLoadLabelYOffset (IsIPhone4 ? 304 :330 )
#define k_DownLoadLabelWidth k_QR_BgView_Width
#define k_DownLoadLabelHeight 20
#define k_DownLoadLabelBottom k_QR_BgView_Height - ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 43 :43)


@interface WSQRCodeViewController ()<MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) NSString *noticeStr;

@end

@implementation WSQRCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
        self.title =  NSLocalizedString(@"product_qrcode", nil);
        self.isFromQst = NO;
        self.qrCodeWidth = INTERFACE_IS_PHONE ?  k_QR_With * KHorizontalDisplayScale :k_QR_With ;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, MAIN_BUTTON_WH, 44)];
    [backBtn setBackgroundColor:[UIColor clearColor]];
    [backBtn setImage:[UIImage scaledImageForName:@"icon_back" ofType:@"png"] forState:UIControlStateNormal];
//    [backBtn setImage:[UIImage imageForName:@"icon_back_press.png"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem=homeButtonItem;
    
    
    
    if (!_isNotSendMessage) {
        UIButton *shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, 24, 24)];
        [shareBtn setBackgroundColor:[UIColor clearColor]];
        [shareBtn setImage:[UIImage scaledImageForName:@"btn_share_white" ofType:@"png"] forState:UIControlStateNormal];
        [shareBtn addTarget:self action:@selector(shareProductInfo) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *shareBarItem = [[UIBarButtonItem alloc]initWithCustomView:shareBtn];
        self.navigationItem.rightBarButtonItem= shareBarItem;
    }

    
    if ([self.parentViewController isKindOfClass:[WSPopViewController class]]) {
        WSPopViewController *parent = (WSPopViewController *)self.parentViewController;
        [parent setConfirmButtonHidden:YES];
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    // Do any additional setup after loading the view.
    
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if (INTERFACE_IS_PAD) {
        UIColor *navBarTitleColor = [UIColor whiteColor]; //获取导航的颜色
        UIFont *navBarTitleFont = [UIFont fontForKey:NavigationBarTitleFont]; //获取导航的字体
        if (!navBarTitleFont) {
            navBarTitleFont = [UIFont mainFontOfSize:INTERFACE_IS_PAD ? 22 : 20];
        }
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor clearColor];
        
        //设置navigationbar的字体和颜色
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: navBarTitleColor, NSShadowAttributeName: shadow, NSFontAttributeName : navBarTitleFont} ];
    }

    UIColor *navigationColor = [UIColor colorWithHexString:@"#262626"];
     self.view.backgroundColor = navigationColor;
    //navigation bar background color
    if (navigationColor) {
        if (IOS7_OR_LATER) {
            //设置titlebar的背景色,大于等于7.0的情况
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageFromColor:navigationColor with:CGRectMake(0, 0, 1024, 64)] forBarMetrics:UIBarMetricsDefault];
        }
        else
        {
            //设置titlebar的背景色
            [self.navigationController.navigationBar  setTintColor:navigationColor];
        }
    }

    
    [self creatQRCodeView];
    
    if ([self.parentViewController isKindOfClass:[WSPopViewController class]]) {
        WSPopViewController *parent = (WSPopViewController *)self.parentViewController;
        [parent setConfirmButtonHidden:YES];
    }
}
- (void)viewWillDisappear:(BOOL)animated{

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    UIColor *navBarTitleColor = [UIColor colorForKey:NavigationBarTitleColor]; //获取导航的颜色
    if (!navBarTitleColor) {
        navBarTitleColor = [UIColor blackColor];
    }
    UIFont *navBarTitleFont = [UIFont fontForKey:NavigationBarTitleFont]; //获取导航的字体
    if (!navBarTitleFont) {
        navBarTitleFont = [UIFont mainFontOfSize:INTERFACE_IS_PAD ? 22 : 20];
    }
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    
    //设置navigationbar的字体和颜色
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: navBarTitleColor, NSShadowAttributeName: shadow, NSFontAttributeName : navBarTitleFont} ];
    UIColor *navBarBackgroudColor = [UIColor colorForKey:@"NavigationBarBackgroundColor"];
    if (navBarBackgroudColor) {
        if (IOS7_OR_LATER) {
            //设置titlebar的背景色,大于等于7.0的情况
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageFromColor:navBarBackgroudColor with:CGRectMake(0, 0, 1024, 64)] forBarMetrics:UIBarMetricsDefault];
        }
        else
        {
            //设置titlebar的背景色
            [self.navigationController.navigationBar  setTintColor:navBarBackgroudColor];
        }
    }
}

- (void)creatQRCodeView {

    // 二维码背景视图
    UIView *qrBgView = [[UIView alloc]initWithFrame:CGRectZero];
    
    if (self.isFromQst) {
        qrBgView.frame = CGRectMake((self.view.width - self.qrCodeWidth) / 2, (self.view.height - self.qrCodeWidth)/2 ,self.qrCodeWidth,self.qrCodeWidth);
        qrBgView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        
    }else {
        qrBgView.frame = CGRectMake((self.view.width - k_QR_BgView_Width) / 2,k_QR_BgView_YOffset ,k_QR_BgView_Width,k_QR_BgView_Height);
        qrBgView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
    }
    qrBgView.layer.cornerRadius = 8;
    qrBgView.layer.masksToBounds = YES;
    
    if (!self.isFromQst) {
        qrBgView.backgroundColor = [UIColor whiteColor];
    }else {
//        qrBgView
    }
    
    [self.view addSubview:qrBgView];
    
    // 生成的二维码
    if (!self.updateUrl) {
        self.updateUrl = [[NSUserDefaults standardUserDefaults] objectForKey:APPDATA_QR_URL];
        if (!self.updateUrl || [self.updateUrl isKindOfClass:[NSNull class]] || [self.updateUrl isEqualToString:@"null"]) {
            LogError(@"扫描二维码地址（updateUrl）不存在");
        }
    }
    UIImage *tdciImage = [[WSQRModule getInstance] generatQRImageForString:self.updateUrl imageSize:k_QR_With];
    UIImageView *qrImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    
    if (self.isFromQst) {
        qrImageView.frame = qrBgView.bounds;
    }else {
        qrImageView.frame = CGRectMake((k_QR_BgView_Width - self.qrCodeWidth )/2,k_QR_YOffset , self.qrCodeWidth, self.qrCodeWidth);
    }
    
    if (tdciImage) {
        [qrImageView setImage:tdciImage];
        [qrBgView  addSubview:qrImageView];
    } else {
        LogError(@"生成二维码图片不存在");
    }
    
    if (!self.isFromQst) {
        // 公司logo
        UIImageView *smallLogoImageView = [[UIImageView alloc]initWithFrame:CGRectMake((k_QR_BgView_Width-k_SmallLogonWidth)/2, k_SmallLogo_YOffset,k_SmallLogonWidth,k_SmallLogonHeight)];
        UIImage *smallLogoImage = [UIImage scaledImageForName:@"qr_logo_small" ofType:@"png"];
        [smallLogoImageView setImage:smallLogoImage];
        [qrBgView addSubview:smallLogoImageView];
        
        // 下载提示
        UILabel *downLoadLabel = [[UILabel alloc] initWithFrame:CGRectMake((k_QR_BgView_Width - k_DownLoadLabelWidth)/2, k_DownLoadLabelBottom - k_DownLoadLabelHeight, k_DownLoadLabelWidth, k_DownLoadLabelHeight)];
        downLoadLabel.textAlignment = NSTextAlignmentCenter;
        downLoadLabel.textColor = [UIColor colorWithHexString:@"#3f85f4"];
        downLoadLabel.text = NSLocalizedString(@"qrcode_notify", nil);
        if (_noticeStr) {
            downLoadLabel.text = _noticeStr;
        }
        downLoadLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15] ;
        downLoadLabel.adjustsFontSizeToFitWidth = YES;
        [qrBgView addSubview:downLoadLabel];
    }
    
    

    
}

- (void)backAction{
    
    if ([self.executeParam direct_type] == DIRECT_TYPE_PRESENT) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
         [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}
- (void)shareProductInfo{
    
    
    NSMutableArray *items = [NSMutableArray array];
    //获取微信appid
    NSDictionary * infoDic = [[NSBundle mainBundle]infoDictionary];
    NSArray *CFBundleURLTypes = [infoDic objectForKey:@"CFBundleURLTypes"];
    
    for (NSDictionary *obj in CFBundleURLTypes) {
         NSString *bundleURLName = obj[@"CFBundleURLName"];
        if ([bundleURLName isEqualToString:@"weixin"]) {
            
            NSArray *urlSchemes = obj[@"CFBundleURLSchemes"];
            NSString *appId = [urlSchemes firstObject];
            if (appId && appId.length > 0 ) {
                WSShareItem * item = [[WSShareItem alloc]initWithTitle:NSLocalizedString(@"wechat", nil)  Icon:@"icon_wechat"];
                [items addObject:item];
            }
        }
        if ([bundleURLName isEqualToString:@"mqq"]) {
            NSString *appId = (NSString *)[obj[@"CFBundleURLSchemes"] firstObject];
            if (appId && appId.length > 0) {
                WSShareItem * item = [[WSShareItem alloc]initWithTitle:NSLocalizedString(@"QQ好友", nil) Icon:@"icon_qq"];
                [items addObject:item];
            }
        }

        
        
    }
    
    

    WSShareItem * item2 = [[WSShareItem alloc]initWithTitle:NSLocalizedString(@"sms_lable", nil) Icon:@"icon_sms"];
    [items addObject:item2];
    __weak typeof(self) weakSelf = self;
    
    //添加popview
    [WSBottomPopView showToView:self.view.window withItems:(NSArray *)items andSelectBlock:^(WSShareItem *item) {
 
    }];

}

- (void)sendMessage{
    
    MFMessageComposeViewController *mcvc =[[MFMessageComposeViewController alloc]init];
    
    mcvc.messageComposeDelegate = self ;
    
    if ([MFMessageComposeViewController canSendAttachments]) {
        
        mcvc.body = self.updateUrl ;
        
        [self presentViewController:mcvc animated:YES completion:nil];
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"js_alert_title"
                                                        message:@"该设备不支持短信功能"
                                                       delegate:nil
                                              cancelButtonTitle:@"confirm"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}


#pragma MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
   [self dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultCancelled:
            LogInfo(@"Message was cancelled url :%@",self.updateUrl);
            break;
        case MessageComposeResultFailed:
             LogInfo(@"Message failed url :%@",self.updateUrl);
            break;
        case MessageComposeResultSent:
             LogInfo(@"Message was sent url :%@",self.updateUrl);
            break;
        default:
            break;
    }
}



@end
