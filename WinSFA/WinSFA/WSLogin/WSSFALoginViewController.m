//
//  WSSFALoginViewController.m
//  WinSFA
//
//  Created by yuanji on 2017/12/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSFALoginViewController.h"
#import "WSSFALoginTool.h"
#import "WSEnvrionment.h"
#import "WSSFALoginView.h"
#import "WSReportFormController.h"
#import "WSHotLineViewController.h"
//===================================================================================================================================================================

#pragma mark - SFA登陆视图管理器 延展(内部)
@interface WSSFALoginViewController ()

@property (nonatomic, strong) WSSFALoginView *loginView;//登陆视图
@property (nonatomic, assign) BOOL isRequestingLogIn;   //是否请求登陆标示

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图管理器 延展(工具)
@interface WSSFALoginViewController (Tool)

#pragma mark - 设置交互连接方法
- (void)setupInteractiveConnect;

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图管理器
@implementation WSSFALoginViewController

#pragma mark - 获取loginView方法
- (WSSFALoginView *)loginView
{
    if(_loginView == nil)
    {
        _loginView = [[WSSFALoginView alloc] initWithFrame:CGRectZero];
        _loginView.backgroundColor = [UIColor clearColor];
        
        NSString *orgCode = [WSSFALoginTool getSaasOrgCode];
        _loginView.isShowOrgCode = (([orgCode length] > 0) ? YES : YES);
        
        NSString *warning = NSLocalizedString(@"login_warning", nil);
        _loginView.isShowWarning = (([warning length] > 0) ? YES : NO);
        
        _loginView.isShowRetrieve = [WSEnvrionment getHideRetrievePassword];
        
        NSString *hotline = [WSEnvrionment getHotline];
        _loginView.isShowHotline = (([hotline length] > 0) ? YES : NO);
    }
    
    return _loginView;
}

#pragma mark - 重写init方法
- (id)init
{
    self = [super init];
    if (self)
    {
        _isRequestingLogIn = NO;
    }
    
    return self;
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.loginView];
    [self setupInteractiveConnect];
}

#pragma mark - 重写viewWillLayoutSubviews方法
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.loginView.frame = self.view.bounds;
}

#pragma mark - 重写viewWillAppear:方法
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - 重写shouldAutorotateToInterfaceOrientation:方法
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图管理器 延展(工具)
@implementation WSSFALoginViewController (Tool)

#pragma mark - 设置交互连接方法
- (void)setupInteractiveConnect
{
    __weak typeof(self) weakSelf = self;
    
    [self.loginView setHotlineClickBlock:^(NSString *hotline){
        
        if ([[WSEnvrionment getOnlineConsultation] length] > 0)
        {
            NSString *online_Consultation = [[NSUserDefaults standardUserDefaults] objectForKey:ONLINE_CONSULTATION];
            NSURL *url = [NSURL URLWithString:[online_Consultation stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            WSReportFormController *rfvc = [[WSReportFormController alloc] initWithURL:url];
            rfvc.title = NSLocalizedString(@"online_consult", nil);
            rfvc.hidesBottomBarWhenPushed = YES;
            [weakSelf.navigationController pushViewController:rfvc animated:YES];
        }
        else
        {
            weakSelf.definesPresentationContext = YES;
            
            WSHotLineViewController *hotLineVC = [[WSHotLineViewController alloc] init];
            hotLineVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
            hotLineVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            
            [weakSelf presentViewController:hotLineVC animated:NO completion:nil];
            hotLineVC.checkChangePwd = ^(){
                //[weakSelf modifyPasswd:nil];
            };
            hotLineVC.findBackPwd = ^(){
                //[weakSelf retrievePassword:nil];
            };
        }
    }];
}

@end
//===================================================================================================================================================================
