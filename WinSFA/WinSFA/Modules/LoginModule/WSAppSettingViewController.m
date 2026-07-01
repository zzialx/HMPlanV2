//
//  AppSettingViewController.m
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-8-15.
//  Copyright 2011年 Winchannel. All rights reserved.
//

#import "WSAppSettingViewController.h"
#import "WinSFA.h"
#import "WSCurrentTime.h"
#import <QuartzCore/QuartzCore.h>
#import "WSDiagnosticTestViewController.h"
#import "SaasEnterViewController.h"
#import "WSAppDelegate.h"
#import "WSPlistHelper.h"
#import "WSQRModule.h"
#import "WSQRCodeViewController.h"
#import "UIDevice+Addtional.h"
#import "WSAppGuidanceViewController.h"
#import "WSDeveloperViewController.h"
#import "JFDEntryObject.h"
#import "WSModifyPasswdViewController.h"
#import "WSEnvrionment.h"
#import "WSManuallyUploadViewController.h"
#import "FileManager.h"
#import "WSRichMediaTable.h"
#import "SLDownLoadQueue.h"
#import "WSReportFormController.h"
#import "WSLoginViewController.h"
#import "WSEMSDKManager.h"
#import "WSFuncsBeanArray.h"
#import "NSString+Additions.h"
#import "WSChartConst.h"
#import "WCUserDefaultHelper.h"
#import "WSHotLineViewController.h"
#import "LEOAssistiveTouch.h"
#import "WSRequestHelper.h"
#import "WSChatMessageUploadController.h"
#import "WSEnvrionment.h"
#import "WSAppSettingModel.h"
#import "WCBaseViewController+Tools.h"
#import "WinFilingInfoViewController.h"
#import "WSAcvtModel.h"

#define k_LogoImageWidth            ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? SCREEN_WIDTH : 385)
#define k_LogoImageXOffSet          ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 0 : (SCREEN_WIDTH - 385)/2)
#define k_HeaderWidthHeightRatio    ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 0.4125 : 0.1289)
#define k_TableViewRowHeight        ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 44.0 : 60.0)
#define k_CopyightFontSize          ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 11.0 : 13.0)
#define k_QuitButtonWidth           290.0f
#define k_QuitButtonHeight          40.0f
#define alterLoginTag               777
#define k_ClearCacheAlertViewTag    8888
#define k_UserHeaderWH              48
#define k_UserNameHeight            20
#define KHeadportraitBoderWidth     83
#define KHeadportraitBoderMinY      20
#define kManualUploadCountTipWidth  20
#define EMP_INFO_KEY                @"APP_EMP_INFO"
#define APP_SETTING_COLOR           ([UIColor colorForKey:@"WSAppSettingCell"] ? : MAIN_TEXT_COLOR)
#define APP_SETTINGCELLLINE_COLOR   ([UIColor colorForKey:@"WSAppSettingCellLineColor"] ? : [UIColor colorWithRed:224.0f/255 green:224.0f/255 blue:224.0f/255 alpha:1.0f])
#define APP_SETTING_FONT            [UIFont fontForKey:@"WSAppSettingCell"] ? : [UIFont systemFontOfSize:UI_Font]

@interface WSAppSettingViewController()

@property (nonatomic, assign) BOOL isChartVisible;
@property (nonatomic, assign) BOOL hasNewVersion;
@property (nonatomic, strong) NSMutableArray *brotherFuncs;
@property (nonatomic, strong) UIImageView * headImageView;
@property (nonatomic, strong) UISwitch *onlineConsultationSwitch;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong)SaasEnterViewController *saasEnterViewController;

@end

@implementation WSAppSettingViewController
@synthesize mTableView;
@synthesize label;
@synthesize URLlabel;
@synthesize headImageView;

- (void)viewDidUnload{
    self.mTableView = nil;
    [super viewDidUnload];
}

- (id)initAppSetting
{
    self = [super init];
    
    if (self) {
        self.isChartVisible=NO;
    }
    return self;
}

- (void)loadTableViewDataSource {
    self.brotherFuncs = [NSMutableArray array];
    

    // Section 1
    NSMutableArray *section1Array = [NSMutableArray array];
    
    // 版本信息
    WSAppSettingModel *versionModel = [[WSAppSettingModel alloc] init];
    versionModel.leftText = NSLocalizedString(@"version_info",nil);
    NSString *svnVersion = [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName];
    NSString *myVersion = [NSString stringWithFormat:@"%@:v%@(%@)",
                           APP_DISPLAY_NAME,
                           [WSEnvrionment getAppSystemVersion],
                           svnVersion];
    versionModel.rightText = myVersion;
    versionModel.leftIconName = @"bbxx_icone";
    [section1Array addObject:versionModel];
    
    // 我的信息
    WSFuncsBean *myInfoBean = [self getMyInfoFuncsBean];
    if (myInfoBean) {
        _isChartVisible = YES;
        WSAppSettingModel *myInfoModel = [[WSAppSettingModel alloc] init];
        myInfoModel.leftText = NSLocalizedString(@"my_info", nil);
        myInfoModel.leftIconName = @"myinfo_inco";
        myInfoModel.selectMethodName = @"gotoMyInfo";
        [section1Array addObject:myInfoModel];
    }
    
    // 手动上传
    WSAppSettingModel *manullyUploadModel = [[WSAppSettingModel alloc] init];
    manullyUploadModel.leftText = NSLocalizedString(@"manually_upload", nil);
    manullyUploadModel.leftIconName = @"sdsc_icone";
    manullyUploadModel.rightCellMethodName = @"addRightViewForManuallyUpload:cellHeight:";
    manullyUploadModel.selectMethodName = @"gotoManuallyUpload";
    [section1Array addObject:manullyUploadModel];
    
    // 数据备份 2017-11-08-MSTD-6643
    NSString *messageBackupStatus = [[NSUserDefaults standardUserDefaults] objectForKey:IS_SUPPORT_MESSAGE_BACKUP];
    if ([messageBackupStatus isEqualToString:@"1"])
    {
        WSAppSettingModel *messageBackupModel = [[WSAppSettingModel alloc] init];
        messageBackupModel.leftText = NSLocalizedString(@"Communication Data Backup", nil);
        messageBackupModel.leftIconName = @"gtjlbf_icone";
        messageBackupModel.selectMethodName = @"gotoChat";
        [section1Array addObject:messageBackupModel];
    }
    
    // 扫码
//    // YIHAIKERRY-3059 添加用户登录判断，未登录不显示二维码
//    NSString *updateUrl =  [[NSUserDefaults standardUserDefaults] objectForKey:APPDATA_QR_URL];
//    if (!(!updateUrl || [updateUrl isKindOfClass:[NSNull class]] || [updateUrl isEqualToString:@"null"])) {
//        WSAppSettingModel *qrCodeModel = [[WSAppSettingModel alloc] init];
//        qrCodeModel.leftText = NSLocalizedString(@"product_qrcode", nil);
//        qrCodeModel.leftIconName = @"rjewm_icone";
//        qrCodeModel.selectMethodName = @"gotoSoftwareCode";
//        [section1Array addObject:qrCodeModel];
//    }
    
    // Section 2
    NSMutableArray *section2Array = [NSMutableArray array];
    
    // 诊断日志
    WSAppSettingModel *diagnoseModel = [[WSAppSettingModel alloc] init];
    diagnoseModel.leftText = NSLocalizedString(@"btn_diagnosis", nil);
    diagnoseModel.leftIconName = @"zdcs_icone";
    diagnoseModel.selectMethodName = @"gotoDiagnostic";
    [section2Array addObject:diagnoseModel];
    
    // 删除缓存
    WSAppSettingModel *clearCacheModel = [[WSAppSettingModel alloc] init];
    clearCacheModel.leftText = NSLocalizedString(@"del_cache", nil);
    clearCacheModel.leftIconName = @"qlsj_icone";
    clearCacheModel.selectMethodName = @"gotoClearCache";
    [section2Array addObject:clearCacheModel];
    
    // 未测试此处逻辑 没有环境

    for (WSFuncsBean * funcBean in self.currentFuncs.iParentFuncsBean.funcsArray) {
        if ([funcBean.filter isEqualToString:@"tradocument"] ||[funcBean.fv isEqualToString:@"FV_ROLE_SWITCH"] ) {
            [self.brotherFuncs addObject:funcBean];
            
            WSAppSettingModel *brotherFuncsModel = [[WSAppSettingModel alloc] init];
            brotherFuncsModel.leftText = NSLocalizedString(funcBean.name, nil);
            brotherFuncsModel.leftIconName = [NSString stringWithFormat:@"about_%@",funcBean.fv];
            brotherFuncsModel.selectMethodName = @"gotoBrotherFuncs";
            [section2Array addObject:brotherFuncsModel];
        }
    }

    // 修改密码
    if (![WSEnvrionment getHideModifyPassword]) {
        WSAppSettingModel *modifyPasswordModel = [[WSAppSettingModel alloc] init];
        modifyPasswordModel.leftText = NSLocalizedString(@"modify_password_label", nil);
        modifyPasswordModel.leftIconName = @"xgmm_icone";
        modifyPasswordModel.selectMethodName = @"gotoModifyPassword";
        [section2Array addObject:modifyPasswordModel];
    }
    
    // 检查升级
    if ([[WSEnvrionment getSaasUrl] length] > 0) {
        WSAppSettingModel *checkUpgradeModel = [[WSAppSettingModel alloc] init];
        checkUpgradeModel.leftText = NSLocalizedString(@"check_upgrade", nil);
        checkUpgradeModel.leftIconName = @"jcxbb_icone";
        checkUpgradeModel.selectMethodName = @"gotoCheckUpgrade";
        checkUpgradeModel.rightCellMethodName = @"addRightViewForCheckUpgrade:cellHeight:";
        [section2Array addObject:checkUpgradeModel];
    }
    

    // 关于我们
    WSAppSettingModel *aboutUsModel = [[WSAppSettingModel alloc] init];
    aboutUsModel.leftText = NSLocalizedString(@"about_our",nil);
    aboutUsModel.leftIconName = @"gywm_icone";
    aboutUsModel.selectMethodName = @"gotoAboutUs";
    [section2Array addObject:aboutUsModel];
    
    
    // Section 3
    
    NSString *online_Consultation = [[NSUserDefaults standardUserDefaults] objectForKey:ONLINE_CONSULTATION];
    NSString *hotline = [WSEnvrionment getHotline];
    
    NSMutableArray *tempDataArray = [NSMutableArray arrayWithObjects:section1Array, section2Array, nil];
    
    if ((!online_Consultation || online_Consultation.length <= 0) && (!hotline ||  [hotline length] <= 0)) {
        
    } else {
        NSMutableArray *section3Array = [NSMutableArray array];
        // 在线咨询
        if (online_Consultation && online_Consultation.length > 0 && ((WSAppDelegate *)[UIApplication sharedApplication].delegate).sfaHasLogin) {
            WSAppSettingModel *consultModel = [[WSAppSettingModel alloc] init];
            consultModel.leftText = NSLocalizedString(@"online_consult", nil);
            consultModel.leftIconName = @"zxzx_icone";
            consultModel.rightCellMethodName = @"addRightViewForConsult:cellHeight:";
            consultModel.selectMethodName = @"gotoOnlineConsult";
            
            [section3Array addObject:consultModel];
            
            [self initOnlineConsultationSwitch];
        }
        
        // 营销通客服热线
        if (hotline && [hotline length] > 0) {
            WSAppSettingModel *hotlineModel = [[WSAppSettingModel alloc] init];
            hotlineModel.leftText = NSLocalizedString(@"service_hotline",nil);
            hotlineModel.rightText = hotline;
            hotlineModel.leftIconName = @"about_hotline";
            NSString *online_Consultation = [[NSUserDefaults standardUserDefaults] objectForKey:ONLINE_CONSULTATION];
            if (online_Consultation.length > 0) {
                hotlineModel.selectMethodName = @"gotoOnlineConsult";
            }else
                hotlineModel.selectMethodName = @"gotoHotline";
            hotlineModel.drawStylepe = WSAppSettingDrawStylePhone;
            [section3Array addObject:hotlineModel];
        }
        [tempDataArray addObject:section3Array];
    }
    self.dataArray = [tempDataArray copy];
}


- (WSFuncsBean *)getMyInfoFuncsBean {
    WSFuncsBean *myInfoBean = nil;
    WSFuncsBeanArray* fba = [WSAppData getObjectbyKey:FUNCS];
    NSArray * array = fba.hidefuncsArray;
    _isChartVisible = NO;
    //WSFuncsBean * bean= [fba getHideFuncsBeanWithFC:@"FAC_828"];
    for (WSFuncsBean * bean in array) {
        if([bean.filter isEqualToString:EMP_INFO_KEY]){
            myInfoBean = bean;
            break;
        }
    }
    return myInfoBean;
}


- (void)initOnlineConsultationSwitch
{
    if (!_onlineConsultationSwitch) {
        _onlineConsultationSwitch = [[UISwitch alloc] init];
        NSNumber *onlineConsultationSwitchStateNumber = [[NSUserDefaults standardUserDefaults] objectForKey:ONLINE_CONSULTATION_SWITCH_STATE];
        BOOL onlineConsultationSwitchIsOn = [onlineConsultationSwitchStateNumber boolValue];
        
        [_onlineConsultationSwitch setOn:onlineConsultationSwitchIsOn animated:NO];
        
        [_onlineConsultationSwitch addTarget:self action:@selector(onlineConsultationSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)onlineConsultationSwitchValueChanged:(id)sender
{
    if (_onlineConsultationSwitch.on) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:ONLINE_CONSULTATION_SWITCH_STATE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //        [LEOAssistiveTouch show];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:ONLINE_CONSULTATION_SWITCH_STATE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //        [LEOAssistiveTouch hide];
    }
    
    [self showOnlineConsultationBtn];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"about", Nil);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableview) name:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    [self loadTableViewDataSource];
    
    
    UIImage *image = [UIImage imageNamed:@"appname_about.png"];
    
    CGFloat headerHeight = self.view.width * k_HeaderWidthHeightRatio ;
    UIImageView *sysNameLogo = [[UIImageView alloc] initWithFrame:CGRectMake(k_LogoImageXOffSet, 0, k_LogoImageWidth, headerHeight)];
    self.headImageView=sysNameLogo;
    sysNameLogo.image=image;
    //
    UIView* headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, headerHeight)];
    headView.backgroundColor=[UIColor whiteColor];
    
    
    if(self.isChartVisible){
        //背景图片
        UIImageView * backImageView=[[UIImageView alloc]initWithFrame:headView.bounds];
        backImageView.image=[UIImage scaledImageForName:@"my_bj" ofType:@"jpg"];
        backImageView.contentMode = UIViewContentModeScaleAspectFill;
        backImageView.clipsToBounds = YES;
        [headView addSubview:backImageView];
        
        
        //图像外圆框
        UIImageView * headportrait=[[UIImageView alloc]initWithFrame:CGRectMake((headView.bounds.size.width - KHeadportraitBoderWidth )/2.0, KHeadportraitBoderMinY, KHeadportraitBoderWidth, KHeadportraitBoderWidth)];
        headportrait.image=[UIImage scaledImageForName:@"headportrait_bg" ofType:@"png"];
        headportrait.contentMode = UIViewContentModeScaleAspectFit;
        [headView addSubview:headportrait];
        
        //头像
        sysNameLogo.frame=CGRectMake((headportrait.center.x - k_UserHeaderWH/2.0) , (headportrait.center.y - k_UserHeaderWH/2.0) + 1 , k_UserHeaderWH , k_UserHeaderWH );
        sysNameLogo.layer.cornerRadius=k_UserHeaderWH/2;//裁成圆角
        sysNameLogo.layer.masksToBounds=YES;
        
        //名称
        //取得该商店对应业代聊天账号
        WSUserInfo * storeUserInfo=[[WSEMSDKManager sharedInstance] getUserInfo];
        UILabel * nameLab=[[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(sysNameLogo.frame) + MAIN_PADDING + 10, self.view.bounds.size.width, k_UserNameHeight)];
        nameLab.backgroundColor=[UIColor clearColor];
        nameLab.font=FONT_SIZE_PINGFANG_MEDIUM(15);
        nameLab.textAlignment=NSTextAlignmentCenter;
        nameLab.textColor=[UIColor blackColor];
        nameLab.text=storeUserInfo.wsname;
        [headView addSubview:nameLab];
        
    }else{
        sysNameLogo.contentMode = UIViewContentModeScaleAspectFit;
    }
    [headView addSubview:sysNameLogo];
    
    
    CGFloat footViewHeight = 0;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, footViewHeight)];
    BOOL isLoginSuccess = [[[NSUserDefaults standardUserDefaults] objectForKey:APP_LOGIN_SUCCESS] boolValue];
    if (isLoginSuccess) {
        
        UIButton *quitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        quitButton.frame = CGRectMake((SCREEN_WIDTH - k_QuitButtonWidth) / 2, 0, k_QuitButtonWidth, k_QuitButtonHeight);
        [quitButton setBackgroundColor:WARNING_BTN_COLOR];
        quitButton.layer.cornerRadius = 4.0f;
        quitButton.layer.masksToBounds = YES;
        quitButton.clipsToBounds = YES;
        [quitButton setTitle:NSLocalizedString(@"logout", nil) forState:UIControlStateNormal];
        [quitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [quitButton addTarget:self action:@selector(logOut:) forControlEvents:UIControlEventTouchUpInside];
        [footView addSubview:quitButton];
        
        footViewHeight += k_QuitButtonHeight + 10;
    }
    
    UILabel *copyrightLabel = [[UILabel alloc]initWithFrame:CGRectMake(MAIN_PADDING, footViewHeight, self.view.bounds.size.width - 2 * MAIN_PADDING, k_UserNameHeight)];
    copyrightLabel.font = [UIFont systemFontOfSize:k_CopyightFontSize];
    copyrightLabel.textColor = [UIColor colorWithHexString:@"#b2b2b2"];
    copyrightLabel.textAlignment = NSTextAlignmentCenter;
    copyrightLabel.text = NSLocalizedString(@"copyright", nil);
    [footView addSubview:copyrightLabel];
    
    footViewHeight += k_UserNameHeight;
    
    UILabel *recordLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 260) / 2, footViewHeight, 260, k_UserNameHeight)];
    recordLabel.font = [UIFont systemFontOfSize:k_CopyightFontSize];
    recordLabel.textColor = [UIColor colorWithHexString:@"#b2b2b2"];
    recordLabel.textAlignment = NSTextAlignmentCenter;
    recordLabel.text = @"ICP备案号:沪ICP备16047252号-16A  >";
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recordLabelTap:)];
    [recordLabel addGestureRecognizer:tapGestureRecognizer];
    recordLabel.userInteractionEnabled = YES;
    [footView addSubview:recordLabel];
    
    footViewHeight = CGRectGetMaxY(recordLabel.frame) + 10.0f;
    footView.frame = CGRectMake(0, 0, self.view.bounds.size.width, footViewHeight);
    
    self.mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.mTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.mTableView.delegate = self;
    self.mTableView.dataSource = self;
    self.mTableView.tableHeaderView = headView;
    self.mTableView.tableFooterView = footView;
    self.mTableView.separatorColor = APP_SETTINGCELLLINE_COLOR;
    self.mTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.mTableView];
    
    NSString *isNeedFirstTimeGuide = [WSPlistHelper valueForKey:@"isNeedFirstTimeGuide" withPlistName:kConfilgFileName];
    if (isNeedFirstTimeGuide != nil && [isNeedFirstTimeGuide isEqualToString:@"YES"]) {
        
        NSString *string = NSLocalizedString(@"func_intro", nil);
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:string style:UIBarButtonItemStylePlain target:self action:@selector(showFunctionIntroduction)];
        self.navigationItem.rightBarButtonItem = barItem;
    }
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, MAIN_BUTTON_WH, 44)];
    [backBtn setBackgroundColor:[UIColor clearColor]];
    [backBtn setImage:[UIImage scaledImageForName:@"icon_back" ofType:@"png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem=homeButtonItem;
}

#pragma mark - 实现备案号点击方法
- (void)recordLabelTap:(UITapGestureRecognizer *)sender {
  
    WinFilingInfoViewController *vc = [[WinFilingInfoViewController alloc] init];
    vc.title = NSLocalizedString(@"my_icp_title", nil);
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self.mTableView reloadData];
    // SFA-5712 没有聊天功能不用刷新头像图片
    if(self.headImageView && self.isChartVisible){
        [self refreshHeadImageView];
    }
    
    // MSTD-6201 检测是否有新版本
    [self checkUpgradeHasNewVersion];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[JFDEntryObject getInstance] removeDebutTools];
    [super viewWillDisappear:animated];
}

- (void)showFunctionIntroduction
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(functionIntroductionEnd)
                                                 name:@"saasenter"
                                               object:nil];
    
    self.saasEnterViewController = [[SaasEnterViewController alloc] init];
    self.saasEnterViewController.view.frame = [[UIScreen mainScreen] applicationFrame];//CGRectMake(0, 0, 320, 480);
    
    self.saasEnterViewController.view.alpha = 0.0;
    [self.view.window addSubview:self.saasEnterViewController.view];
    [UIView animateWithDuration:0.5 animations:^{
        self.saasEnterViewController.view.alpha = 1.0;
    }];
    
}

- (void)functionIntroductionEnd
{
    self.saasEnterViewController = nil;
}

- (void)logOut:(id)sender{
    
    UIViewController *viewController = [self checkNotUploadData];
    if (viewController && [viewController isKindOfClass:[WSManuallyUploadViewController class]]) {
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
        NSString *NODataString = NSLocalizedString(@"homepage_unupload_recommendation",nil);
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NODataString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }else{
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"exit_app_prompt", nil)];
        
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
        
        
        @weakify_self;
        [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
            
            [weakSelf loginOutApp];
           
        }];
        
        [alert show];
    }
}

- (UIViewController *)checkNotUploadData{
    WSOffLineUploadTable* l_leaveStore = [WSOffLineUploadTable sharedTable];
    NSInteger pending = [l_leaveStore queryCountWithUploadFlagType:Failed];
    WSFuncsBeanArray * fba = [WSAppData getObjectbyKey:FUNCS];
    
    
    if (pending > 0) {
        
        WSFuncsBean *funcsBean;
        for (WSFuncsBean *fb in fba.funcsArray) {
            if ([fb.fv isEqualToString:@"TB_V180"]) {
                funcsBean = fb;
                break;
            }
        }
        WSManuallyUploadViewController *manullyUploadController;
        if (funcsBean) {
            manullyUploadController = [[WSManuallyUploadViewController alloc] initWithFuncs:funcsBean];
        }
        else{
            manullyUploadController = [[WSManuallyUploadViewController alloc] init];
        }
        manullyUploadController.isInCheckUploadedDataFlow = YES;
        
        return manullyUploadController;
    }
    return nil;
    
}

-(void)refreshHeadImageView{
    UIImageView *sysNameLogo = self.headImageView;
    
    NSString *imageKey = [WCUserDefaultHelper getUserImageKey];
    if (imageKey && imageKey.length > 0) {
        UIImage * image = [[SDImageCache sharedImageCache] imageFromKey:imageKey];
        if (image) {
            sysNameLogo.image = image;
            return;
        }
    }
    
    NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:WS_CHARTMODULE_USERHEADIMAGE];
    if (url && url.length > 0) {
        [[WSRequestHelper shareInstance] downloadImageWithUrl:url imageView:sysNameLogo placeholderImage:[UIImage imageNamed:@"mrtx"]];
    }
    else
    {
        WSUserInfo * loginUser=[[WSEMSDKManager sharedInstance] getUserInfo];
        if(loginUser.wsheadImageURL && loginUser.wsheadImageURL.length > 0){
            NSString * headImageUrlString = [WSHttpURLHelper getImageCompleteURL:loginUser.wsheadImageURL];
            [[WSRequestHelper shareInstance] downloadImageWithUrl:headImageUrlString imageView:sysNameLogo placeholderImage:[UIImage imageNamed:@"mrtx"]];
            
            [[NSUserDefaults standardUserDefaults] setObject:headImageUrlString forKey:WS_CHARTMODULE_USERHEADIMAGE];
        }else{
            [sysNameLogo setImage:[UIImage imageNamed:@"mrtx"]];
            
        }
    }
}

#pragma mark - UIAlterViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == alterLoginTag) {
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else if (alertView.tag == k_ClearCacheAlertViewTag) {
        if (buttonIndex == 0) {
            
        } else if (buttonIndex == 1) {
            [self clearCache];
        }
    }
    
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)[self.dataArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"appsettingcell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell.contentView removeAllSubviews];
    
    
    WSAppSettingModel *model = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell.imageView setImage:[UIImage imageNamed:model.leftIconName]];
   
    
    // cell左侧内容
    cell.textLabel.textColor = APP_SETTING_COLOR;
    //    cell.textLabel.backgroundColor = [UIColor blueColor];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.font = APP_SETTING_FONT;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.textLabel.text =  model.leftText;
    
    
    CGFloat cellHeight = [self getCellHeightWithTableView:tableView heightForRowAtIndexPath:indexPath];
    if ([model.rightCellMethodName length] > 0) {
        SEL sel = NSSelectorFromString(model.rightCellMethodName);
        if ([self respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:sel withObject:cell withObject:[NSNumber numberWithFloat:cellHeight]];
#pragma clang diagnostic pop
        }
    }
    else if ([model.rightText length] > 0)
    {
        UILabel *rightLabel = [self addRightViewForLabel:cell contentText:model.rightText];
        
        //2018-01-16-YIHAIKERRY-1169
        if(model.drawStylepe == WSAppSettingDrawStylePhone)
        {
            NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:rightLabel.text];
            NSRange contentRange = {0, [rightLabel.text length]};
            [content addAttribute:NSForegroundColorAttributeName value:rightLabel.textColor range:contentRange];
            [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
            rightLabel.attributedText = content;
        }
    }
    else
    {
        [self addRightViewForArrow:cell cellHeight:[NSNumber numberWithFloat:cellHeight]];
    }
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    WSAppSettingModel *model = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    NSString *methodName = model.selectMethodName;
    if ([methodName length] > 0) {
        if ([methodName isEqualToString:@"gotoBrotherFuncs"]) {
            [self gotoBrotherFuncs:indexPath.row - 1];
        } else {
            SEL sel = NSSelectorFromString(methodName);
            if ([self respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self performSelector:sel];
#pragma clang diagnostic pop
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self getCellHeightWithTableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)getCellHeightWithTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont *font = nil ;
    
    CGFloat x = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? tableView.frame.size.width *2/7 + 5 + 64  :tableView.frame.size.width*2/3 + 120);
    
    if ([[UIDevice getPreferredLanguage] isEqualToString:@"ja_JP"]) {
        x = tableView.frame.size.width *3/7;
    }
    //    CGFloat y = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  5 : 13);
    CGFloat width = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  tableView.frame.size.width - x -20 :tableView.frame.size.width + 345);
    CGFloat height = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  k_TableViewRowHeight -  5*2 :k_TableViewRowHeight - 5*2);
    if  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        font = [UIFont systemFontOfSize:UI_Font];
    } else {
        font = [UIFont systemFontOfSize:UI_Font - 2];
        
    }
    
    WSAppSettingModel *model = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    CGSize size = [model.leftText ws_sizeWithFont:font constrainedToWidth:width lineBreakMode:NSLineBreakByCharWrapping];
    // 如果有标题的高度大于左标题的话  哪边高用哪边的高度
    if (model.rightText.length > 0) {
        CGSize rightSize = [model.rightText ws_sizeWithFont:font constrainedToWidth:width lineBreakMode:NSLineBreakByCharWrapping];
        if (rightSize.height > size.height) {
            size.height = rightSize.height;
        }
    }

    if (size.height + 20 > height) {
        height = size.height + 20;
    }
    
    return k_TableViewRowHeight > height ? k_TableViewRowHeight : height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return MAIN_PADDING;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
//backBtnClicked addBy wangdongyan
-(void)backClicked{
    
    [self.navigationController popViewControllerAnimated:YES];
    
    /*
     [UIView beginAnimations:nil context:nil];
     [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view.superview cache:YES];
     [self.view removeFromSuperview];
     [UIView setAnimationDuration:0.5];
     [UIView commitAnimations];
     */
}

-(void)reloadTableview{
    [self.mTableView reloadData];
}

- (UILabel *)createCellRightLabelWithFrame:(UITableViewCell *)cell withTextStr:(NSString *)text{
    
    UIFont *font = nil ;
    CGFloat viewWidth = self.mTableView.frame.size.width;
    
    CGFloat y = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  5 : 13);
    CGFloat width = viewWidth * 3 / 7;
    CGFloat height = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  cell.frame.size.height -  y*2 :cell.frame.size.height - y*2);
    CGFloat x = viewWidth - width - 15.0;
    if  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        font = [UIFont systemFontOfSize:UI_Font];
    } else {
        font = [UIFont systemFontOfSize:UI_Font - 2];
        
    }
    
    CGSize size = [text ws_sizeWithFont:font constrainedToWidth:width lineBreakMode:NSLineBreakByCharWrapping];
    
    if (size.height + 10 > height) {
        height = size.height + 10;
    }
    
    if (size.width < 26.0) {
        width = size.width + 8 > kManualUploadCountTipWidth ? size.width + 8 : kManualUploadCountTipWidth;
        x = viewWidth - width - MAIN_BUTTON_WH ;
        y = (cell.contentView.height - kManualUploadCountTipWidth)/2;
        height = kManualUploadCountTipWidth;
    }

    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
    //countLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin  | UIViewAutoresizingFlexibleWidth;
    countLabel.lineBreakMode = NSLineBreakByCharWrapping;
    countLabel.numberOfLines = 0;
    countLabel.textColor = [UIColor whiteColor];
    countLabel.font = font;
    countLabel.text = text;
    countLabel.textAlignment = NSTextAlignmentRight;
    countLabel.contentMode = UIViewContentModeCenter;
    return countLabel;
    
}

#pragma mark - Add Right View To Cell
- (void)addRightViewForManuallyUpload:(UITableViewCell *)cell cellHeight:(NSNumber *)cellHeight {
    NSInteger pending = [[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed];
    
    if (pending > 0 ) {
        NSString *countStr = [[NSNumber numberWithInteger:pending] stringValue];
        UILabel *rightLabel = [self createCellRightLabelWithFrame:cell withTextStr:countStr];
        rightLabel.textAlignment = NSTextAlignmentCenter;
        rightLabel.backgroundColor = WARNING_BTN_COLOR;
        rightLabel.layer.cornerRadius = kManualUploadCountTipWidth / 2;
        rightLabel.layer.masksToBounds = YES;
        [cell.contentView addSubview:rightLabel];
    }
    [self addRightViewForArrow:cell cellHeight:cellHeight];
}

- (void)addRightViewForCheckUpgrade:(UITableViewCell *)cell cellHeight:(NSNumber *)cellHeight {
    CGRect arrowFrame = [self getArrowRect:cell cellHeight:cellHeight];
    CGFloat dotWH = 12;
    CGRect dotFrame = CGRectMake(arrowFrame.origin.x - dotWH, (cell.contentView.height - dotWH) / 2, dotWH, dotWH);
    UIView *dotView = [[UIView alloc] initWithFrame:dotFrame];
    [dotView setBackgroundColor:[UIColor redColor]];
    dotView.layer.cornerRadius = dotWH / 2;
    dotView.layer.masksToBounds = YES;
    [cell.contentView addSubview:dotView];
    [dotView setHidden:!self.hasNewVersion];
    
    [self addRightViewForArrow:cell cellHeight:cellHeight];
}

- (void)addRightViewForConsult:(UITableViewCell *)cell cellHeight:(NSNumber *)cellHeight {
    CGFloat fCellHeight = [cellHeight floatValue];
    [_onlineConsultationSwitch setFrame:CGRectMake(SCREEN_WIDTH - 15.0 - 51.0, (fCellHeight - 31.0)/2, 51.0, 31.0)];
    
    [cell.contentView addSubview:_onlineConsultationSwitch];
}


- (CGRect)getArrowRect:(UITableViewCell *)cell cellHeight:(NSNumber *)cellHeight {
    CGFloat fCellHeight = [cellHeight floatValue];
    return CGRectMake(SCREEN_WIDTH - 30.0, (fCellHeight - 20.0)/2, 20.0, 20.0);
}

- (void)addRightViewForArrow:(UITableViewCell *)cell cellHeight:(NSNumber *)cellHeight {
    CGRect arrowFrame = [self getArrowRect:cell cellHeight:cellHeight];
    UIImageView *indicatorImageView = [[UIImageView alloc] initWithFrame:arrowFrame];
    [indicatorImageView setImage:[UIImage imageNamed:@"arrow_right"]];
    [cell.contentView addSubview:indicatorImageView];
}

- (UILabel *)addRightViewForLabel:(UITableViewCell *)cell contentText:(NSString *)contentText {
    UILabel *rightLabel = [self createCellRightLabelWithFrame:cell withTextStr:contentText];
    rightLabel.textColor = MAIN_TEXT_COLOR;
    [cell.contentView addSubview:rightLabel];
    return rightLabel;
}
#pragma mark - Actions

// 我的信息
- (void)gotoMyInfo {
    WSFuncsBean *fb = [self getMyInfoFuncsBean];
    /*Jira - SFA-14426 有我的信息要是YES create by sunhongfu 2017-11-28*/
    if (fb)
    {
        _isChartVisible = YES;
    }
    NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
    LogInfo(@"Going to init class name: %@, fb.fv:%@", className, fb.fv);
    UIViewController *vc = [[NSClassFromString(className) alloc] initWithFuncs:fb];
    vc.title = NSLocalizedString(@"my_info", nil);
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

// 手动上传
- (void)gotoManuallyUpload {
    WSManuallyUploadViewController *manuallyUploadController = [[WSManuallyUploadViewController alloc]init];
    manuallyUploadController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:manuallyUploadController animated:YES];
}


// 跳转软件二维码
-(void)gotoSoftwareCode{
    // YIHAIKERRY-3059
//    NSString *updateUrl =  [[NSUserDefaults standardUserDefaults] objectForKey:APPDATA_QR_URL];
//
//    if (!updateUrl || [updateUrl isKindOfClass:[NSNull class]] || [updateUrl isEqualToString:@"null"]) {
//        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"please_log", nil) message:nil];
//        [alert setCancelButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
//            [self.navigationController popViewControllerAnimated:YES];
//        }];
//
//        [alert show];
//    }else{
    
        WSQRCodeViewController *qrCodeViewController = [[WSQRCodeViewController alloc]init];
        qrCodeViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:qrCodeViewController animated:YES];
        
//    }
    
}

// Todo : not test, server is closed
- (void)gotoBrotherFuncs:(NSInteger)index {
    WSFuncsBean *funcsBean = [self.brotherFuncs objectAtIndex:index];
    NSString *className = [WSPlistHelper valueForKey:funcsBean.fv withPlistName:kControllerMappingFileName];
    LogInfo(@"Going to init class name: %@, fb.fv:%@", className, funcsBean.fv);
    UIViewController *vc = [[NSClassFromString(className) alloc] initWithFuncs:funcsBean];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

// 跳转沟通备份数据页面
- (void)gotoChat {
    WSChatMessageUploadController * controller = [[WSChatMessageUploadController alloc]init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

// 修改密码
- (void)gotoModifyPassword {
    UIViewController *con = nil;
    
    NSString *getPasswordMjet = [WSPlistHelper valueForKey:kMODIFY_PASSWORD_URL withPlistName:kConfilgFileName];
    
    if ([getPasswordMjet length] > 0) {
        getPasswordMjet = [NSString stringWithFormat:@"%@&nls=%@", getPasswordMjet,[UIDevice getPreferredLanguage]];
        con = [[WSReportFormController alloc]initWithURL:[NSURL URLWithString:getPasswordMjet]];
        con.title = NSLocalizedString(@"modify_password_label", nil);
        
    }else {
        //修改密码
        con = [[WSModifyPasswdViewController alloc]init];
        ((WSModifyPasswdViewController *)con).modifyUserName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_LAST_LOGIN];
    }
    
    con.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:con animated:YES];
}

// 诊断日志 "btn_diagnosis"
- (void)gotoDiagnostic {
    WSDiagnosticTestViewController *controller = [[WSDiagnosticTestViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
    
}

// 关于我们
- (void)gotoAboutUs {
    WSDeveloperViewController *guidanceViewController = [[WSDeveloperViewController alloc]init];
    guidanceViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:guidanceViewController animated:YES];
}

// 在线咨询
- (void)gotoOnlineConsult {
    NSString *online_Consultation = [[NSUserDefaults standardUserDefaults] objectForKey:ONLINE_CONSULTATION];
    
    WSReportFormController *rfvc = [[WSReportFormController alloc] initWithURL:[NSURL URLWithString:[online_Consultation stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    rfvc.title = NSLocalizedString(@"online_consult", nil);
    rfvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rfvc animated:YES];
}

// 拨打热线
- (void)gotoHotline {
    WSHotLineViewController *hotLineVC = [[WSHotLineViewController alloc] init];
    self.definesPresentationContext = YES;
    hotLineVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
    hotLineVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:hotLineVC animated:NO completion:nil];

}


// 检查更新关于中添加是否是最新版本的标志
- (void)checkUpgradeHasNewVersion {
    NSString *url = [WSEnvrionment getSaasUrl];
    if ([url length] > 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNewVersionFinish:) name:CHECK_UPGRADE_NOTIFY object:nil];

        [self requestUpgradeWithUrl:url];
    }
}

- (void)requestUpgradeWithUrl:(NSString *)url {
    NSString *completeUrl = [WSHttpURLHelper getCompleteURLByServerUrl:url partOfURL:LOGIN_SAAS_CHECK_VERSION];
    [[WSRequestHelper shareInstance] checkUpgradeWithUrl:completeUrl notifyName:CHECK_UPGRADE_NOTIFY];
}

- (void)checkNewVersionFinish:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHECK_UPGRADE_NOTIFY object:nil];
    
    NSDictionary *data = [sender userInfo];
    NSString *info = [data objectForKey:DATAS];
    NSDictionary *dic = [info objectFromJSONString];
    
    NSString *flag = [NSString stringWithValue:[dic objectForKey:@"flag"]];
    if ([flag isEqualToString:@"1"]) {
        NSString *version = [NSString stringWithValue:[dic objectForKey:@"version"]];
        
        // 应用版本号 打包时动态配置
        NSString *versionCode = [WSEnvrionment getAppSystemVersion];
        NSComparisonResult  result = [version compare:versionCode];
        if (result == NSOrderedDescending) {
            self.hasNewVersion = YES;
        } else {
           self.hasNewVersion = NO;
        }
    } else {
        self.hasNewVersion = NO;
        LogError(@"CheckUpgrade Info Error:%@", info);
    }
}

// 检查更新
- (void)gotoCheckUpgrade {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUpgradeFinish:) name:CHECK_UPGRADE_NOTIFY object:nil];
    
    NSString *url = [WSEnvrionment getSaasUrl];
    [self requestUpgradeWithUrl:url];
}


- (void)checkUpgradeFinish:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHECK_UPGRADE_NOTIFY object:nil];
    
    NSDictionary *data = [sender userInfo];
    NSString *info = [data objectForKey:DATAS];
    NSDictionary *dic = [info objectFromJSONString];
    
    NSString *flag = [NSString stringWithValue:[dic objectForKey:@"flag"]];
    if ([flag isEqualToString:@"1"]) {
        NSString *version = [NSString stringWithValue:[dic objectForKey:@"version"]];
        
        // 应用版本号 打包时动态配置
        NSString *versionCode = [WSEnvrionment getAppSystemVersion];
        NSComparisonResult  result = [version compare:versionCode];
        if (result == NSOrderedDescending) {
            NSString *msg = [NSString stringWithValue:[dic objectForKey:@"msg"]];
            
            NSString *upgradeUrl =  [NSString stringWithValue:[dic objectForKey:@"url"]];
            upgradeUrl = [upgradeUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            [self showUpgradeAlertWithMsg:msg url:upgradeUrl];
        } else {
            NSString *message = NSLocalizedString(@"latest_version", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            
            LogInfo(@"server version is: %@", version);
        }
    } else {
        LogError(@"CheckUpgrade Info Error:%@", info);
    }
}



- (void)showUpgradeAlertWithMsg:(NSString *)message url:(NSString *)url {
    NSString *OKString = NSLocalizedString(@"confirm",nil);
    
    if (!message || [message length] == 0) {
        NSString *upgradeMsg = [WSEnvrionment getUpgradeMessage];
        if ([upgradeMsg length] > 0) {
            message  = upgradeMsg;
        } else {
            message = NSLocalizedString(@"update_tip",nil);
        }
    }
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"version_upgrate", nil) message:message];
    [alert setCancelButtonWithTitle:NSLocalizedString(@"disable_lable", nil) block:nil];
    [alert addButtonWithTitle:OKString block:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }];
    [alert show];
}










#pragma mark - 去清除缓存操作方法
- (void)gotoClearCache {
    
    NSInteger pending = [[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed];
    if (pending > 0) {
        
        NSString *NODataString = NSLocalizedString(@"homepage_unupload_recommendation",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NODataString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    @weakify_self;
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"del_cache_notify", nil)];
    [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
    [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
        
        [weakSelf clearAppDataSuccess:^{
            [weakSelf clearCache];
        }];
    }];
    
    [alert show];
}

#pragma mark - 清除缓存方法
- (void)clearCache {
    
    LogTrace();
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"数据清理中", nil) tips:nil tapTarget:nil action:nil];
    
    [self performSelector:@selector(doClearCache) withObject:nil afterDelay:0.1f];
}

#pragma mark - 延迟执行清除缓存方法
- (void)doClearCache {
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_LAST_LOGIN];
    [FileManager removeDefaultsByKey:CACHE_DATA_VERSION_KEY_BYUSER(userName)];
 
    NSString *loginDataFilePath = [[FileManager Documents] stringByAppendingPathComponent:LOGIN_DATA_FILENAME_BYUSER(userName)];
    [FileManager deleFileWithName:loginDataFilePath];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SSOLOGINSTATE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:REMEMBER_ME_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:REMEMBER_PASSWORD];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERNAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSWORD];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERNAME_LAST_LOGIN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSWORD_LAST_LOGIN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SWIPE_PASSWORD_IS_RIGHT];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SELECTED_CITY_NAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLevel2Password];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_SAAS_WEB_ADDRESS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SAAS_WEB_ADDRESS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_SAAS_SEND_VERSION];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:APPDATA_QR_URL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MAIN_TIPS];
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:[NSString stringWithFormat:@"%@_%@", VISITPRIVACYFLAG, ISNULL(empId)]];
    [[NSUserDefaults standardUserDefaults] synchronize];
 
    [WCUserDefaultHelper saveUserImageKey:@""];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
    NSArray *temp = [[WSRichMediaTable sharedTable] queryTableItems];
    NSString *cachesPaths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    if (temp && temp.count > 0) {

        [[SLDownLoadQueue downLoadQueue] pauseAll];
        [[SLDownLoadQueue downLoadQueue].downLoadQueueArr removeAllObjects];
    
        [[SLDownLoadQueue downLoadQueue2] pauseAll];
        [[SLDownLoadQueue downLoadQueue2].downLoadQueueArr removeAllObjects];
        
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(globalQueue, ^{
            
            NSString *arrPath = [cachesPaths stringByAppendingString:@"/richMedia.plist"];
            [NSKeyedArchiver archiveRootObject:temp toFile:arrPath];
            LogInfo(@"spemedia cache oldArrays count:%ld", (unsigned long)[temp count]);
        });
    }
    
    NSString *downloadfilePath = [cachesPaths stringByAppendingPathComponent:[NSString stringWithFormat:@"downloadfile/"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadfilePath]) {
        
        NSError *error;
        if ([[NSFileManager defaultManager] removeItemAtPath:downloadfilePath error:&error]) {
            LogInfo(@"%@",@"清除以前附件或者培训文档下载的文件成功");
        } else {
            LogError(@"清除以前附件或者培训文档下载的文件失败 %@",error.description);
        }
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataBaseFilePath = [documentsDirectory stringByAppendingPathComponent:@"wch_DataBase.db"];
    NSString *message = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataBaseFilePath]) {
        
        NSError *error;
        if ([[NSFileManager defaultManager] removeItemAtPath:dataBaseFilePath error:&error]) {
            
            [[WSFMDatebase getInstance] closeDB];
            message = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"清除缓存数据成功:", nil), documentsDirectory];

            [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT object:nil];
        }
        else {
            message = error.debugDescription;
        }
    }
    else {
        message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"数据库不存在:",nil), documentsDirectory];
    }
    LogInfo(@"%@", message);
    
    //清除全部强制离店数据
    [[WSInoutStoreTable sharedTable] clearAllForceLeaveStore];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"LastReplyCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LAST_UPDATE_LOCATION_MESSAGE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [WSAcvtModel claerAllEnterBackgroundMark];
    
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
}

@end
