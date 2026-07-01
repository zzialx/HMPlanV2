//
//  InitSwipePasswordViewController.m
//  Family_ios
//
//  Created by Tmc on 15/5/20.
//  Copyright (c) 2015年 hohistar. All rights reserved.
//

#import "InitSwipePasswordViewController.h"
#import "YLSwipeLockView.h"
#import "WSCurrentTime.h"
//#import "RootManager.h"
//#import "FunctionModel.h"
//#import "ProductLineModel.h"

static NSInteger defaultChangePassWordNumber = 5;
@interface InitSwipePasswordViewController ()<YLSwipeLockViewDelegate>

@property (nonatomic, weak) YLSwipeLockView *lockView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, strong) NSString *passwordString;
@property (nonatomic, weak) UIButton *resetButton;
@property (nonatomic, weak) UIButton *reloginButton;
@property (nonatomic, assign) NSInteger unmatchCounter;

@property (nonatomic, strong) UIImageView *imageV;


@end

@implementation InitSwipePasswordViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,self.view.bounds.size.width, 0)];
    if (SCREEN_WIDTH == 320) {
        imageV.height = 217;
    } else {
        imageV.height = 242;
    }
    //    imageV.image = [UIImage imageNamed:@"login_bg"];
    imageV.image = [UIImage imageNamed:@"appname_about"];
    
    [self.view addSubview:imageV];
    
    self.imageV = imageV;
    
    
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, imageV.height/2-24, self.view.bounds.size.width, 48)];
    if (INTERFACE_IS_PAD) {
        logoView.top = imageV.height/2-24 - 12;
    }
    logoView.backgroundColor = [UIColor clearColor];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    logoView.image = [UIImage imageNamed:@"appname_about"];
    //    [imageV addSubview:logoView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    
    titleLabel.textColor = [UIColor redColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.frame = CGRectMake(0,imageV.bottom, self.view.bounds.size.width, 20);
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.view addSubview:titleLabel];
    
    self.titleLabel = titleLabel;
    
    CGFloat viewWidth = self.view.bounds.size.width -100;
    CGFloat viewHeight = viewWidth;
    
    YLSwipeLockView *lockView = [[YLSwipeLockView alloc] initWithFrame:CGRectMake((CGRectGetMaxX(self.view.frame)-viewWidth)/2, imageV.bottom + 40, viewWidth, viewHeight)];
    [self.view addSubview:lockView];
    
    self.lockView = lockView;
    self.lockView.delegate = self;
    
    UIButton *resetButton = [[UIButton alloc] initWithFrame:CGRectMake(self.lockView.left, CGRectGetMaxY(self.view.frame) - 60, 75, 20)];
    [resetButton setTitle:@"重置密码" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
    self.resetButton = resetButton;
    self.resetButton.hidden = YES;
    
    UIButton *reloginButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 120, CGRectGetMaxY(self.view.frame) - 60, 75, 20)];
    reloginButton.right = self.lockView.right + 5;
    [reloginButton setTitle:@"重新登录" forState:UIControlStateNormal];
    [reloginButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [reloginButton addTarget:self action:@selector(reloginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    [reloginButton handleWithBlock:^(id sender) {
    //        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserModel];
    //        [[NSUserDefaults standardUserDefaults]synchronize];
    //        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLevel2Password];
    //        [[NSUserDefaults standardUserDefaults] synchronize];
    //        AppDelegate *app = kAppDelegate;
    //        [app.rootManager exit];
    //    } controlEvent:UIControlEventTouchUpInside];
    
    [self.view addSubview:reloginButton];
    self.reloginButton = reloginButton;
    
    if (INTERFACE_IS_PAD) {
        self.lockView.left = (1024 - 320)/2;
        self.lockView.width = 320;
        self.lockView.height = 320;
        self.lockView.top = imageV.bottom + 60;
        
        self.resetButton.left = 40;
        self.reloginButton.right = self.view.width - 40;
    }
    
    [self initTitleLabel];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.imageV.frame = CGRectMake(0, 0,self.view.bounds.size.width, 0);
    if (SCREEN_WIDTH == 320) {
        self.imageV.height = 217;
    } else {
        self.imageV.height = 242;
    }
    self.titleLabel.frame = CGRectMake(0,self.imageV.bottom, self.view.bounds.size.width, 20);
    
    CGFloat viewWidth = self.view.bounds.size.width -100;
    CGFloat viewHeight = viewWidth;
    
    self.lockView.frame = CGRectMake((CGRectGetMaxX(self.view.frame)-viewWidth)/2, self.imageV.bottom + 40, viewWidth, viewHeight);
    
    self.resetButton.frame = CGRectMake(self.lockView.left, CGRectGetMaxY(self.view.frame) - 60, 75, 20);
    
    self.reloginButton.frame = CGRectMake(self.view.bounds.size.width - 120, CGRectGetMaxY(self.view.frame) - 60, 75, 20);
    
    self.reloginButton.right = self.lockView.right + 5;
    
    if (INTERFACE_IS_PAD) {
        self.lockView.left = (1024 - 320)/2;
        self.lockView.width = 320;
        self.lockView.height = 320;
        self.lockView.top = self.imageV.bottom + 60;
        
        self.resetButton.left = 40;
        self.reloginButton.right = self.view.width - 40;
    }
    
    
}
- (void)reloginButtonClicked:(id)sender
{
    [self cleanGestureAndRelogin];
}

- (void)cleanGestureAndRelogin
{
    // 清除本地缓存的手势密码
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLevel2Password];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_GESTURE_PASSWORD_LAST_USED_DATE];
    //   YIHAIKERRY-1869 董宏  清楚本地缓存的密码 不清没法换账号
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSWORD];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSWORD_LAST_LOGIN];
    //YIHAIKERRY-3047
    //益海嘉里-深圳：【ios】：输入用户名和密码勾选“记住用户名”，登录后点击重新登录时，没有记住用户名
    
    //    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERNAME];
    //    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERNAME_LAST_LOGIN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SWIPE_PASSWORD_IS_RIGHT];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    WSAppDelegate *appDelegate = (WSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoginAndClearAppDatasByIsLogout:NO];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)initTitleLabel
{
    if (self.swipeType == 0) {
        _titleLabel.text = @"请设置你的手势锁";
    }else{
        _titleLabel.text = @"手势密码校验";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(YLSwipeLockViewState)swipeView:(YLSwipeLockView *)swipeView didEndSwipeWithPassword:(NSString *)password
{
    if ([self checkIfGesturePasswordIsExpired]) {
        return YLSwipeLockViewStateWarning;
    }
    
    if (_swipeType == SwipeTypeInit) {
        
        if (self.passwordString == nil && password.length < 4) {
            self.titleLabel.text = @"手势密码要四位以上";
            return YLSwipeLockViewStateNormal;
        }else if (self.passwordString == nil && password.length >= 4) {
            self.passwordString = password;
            self.titleLabel.text = @"再次确认您的手势锁";
            self.resetButton.hidden = NO;
            return YLSwipeLockViewStateNormal;
        }else if ([self.passwordString isEqualToString:password]){
            self.titleLabel.text = @"设置成功";
            self.passwordString = nil;
            
            //            UserModel *userModel = [CommonUtil getUserModel];
            //            userModel.level2Password = password;
            //            [[NSUserDefaults standardUserDefaults] setObject:userModel.keyValues forKey:kUserModel];
            //            [[NSUserDefaults standardUserDefaults]synchronize];
            //
            [[NSUserDefaults standardUserDefaults] setObject:password forKey:kLevel2Password];
            
            [[NSUserDefaults standardUserDefaults] setObject:[WSCurrentTime formatDataToString:[NSDate date]] forKey:USER_GESTURE_PASSWORD_LAST_USED_DATE];
            //            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (_finishSwipeBlock) {
                _finishSwipeBlock();
            }
            return YLSwipeLockViewStateSelected;
        }else{
            
            self.titleLabel.text = @"与上一次不同";
            return YLSwipeLockViewStateWarning;
        }
    }else{
        NSString *savedPassword = [[NSUserDefaults standardUserDefaults] objectForKey:kLevel2Password];
        
        if ([savedPassword isEqualToString:password]) {
            //只在之后二级密码进去再次请求权限
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //                [self requestFunctionData];
                //                [self requestProductLineData];
            });
            
            if (_finishSwipeBlock) {
                _finishSwipeBlock();
            }
            return YLSwipeLockViewStateNormal;
        }else{
            defaultChangePassWordNumber -- ;
            
            if (defaultChangePassWordNumber == 0) {
                BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"手势密码输入错误5次，请重新登录", nil) message:nil];
                [alert setCancelButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
                    [self cleanGestureAndRelogin];
                }];
                [alert show];
                
            }
            _titleLabel.text = [NSString stringWithFormat:@"手势密码错误"];
            [self performSelector:@selector(initTitleLabel) withObject:nil afterDelay:1.0f];
            
            return YLSwipeLockViewStateWarning;
        }
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)reset
{
    self.passwordString = nil;
    _swipeType = SwipeTypeInit;
    self.titleLabel.text = @"请设置您的手势锁";
    self.resetButton.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([self checkIfGesturePasswordIsExpired]) {
        self.titleLabel.text = @"手势锁已经超期，请重新登陆";
    }
    
}

// 检查是否在过期天数之内未使用手势锁
- (BOOL)checkIfGesturePasswordIsExpired
{
    NSString *userGesturePasswordExpiredDays = [[NSUserDefaults standardUserDefaults] objectForKey:USER_GESTURE_PASSWORD_EXPIRED_DAYS];
    NSString *userGesturePasswordLastUsedDateStr = [[NSUserDefaults standardUserDefaults] objectForKey:USER_GESTURE_PASSWORD_LAST_USED_DATE];
    BOOL isOverExpiredDays = NO;
    
    if (userGesturePasswordExpiredDays && userGesturePasswordExpiredDays.length > 0 && userGesturePasswordLastUsedDateStr && userGesturePasswordLastUsedDateStr.length > 0) {
        NSString *currentDateStr = [WSCurrentTime formatDataToString:[NSDate date]];
        
        NSDictionary *timeInfoDict = [WSCurrentTime getTotalTimeInfoDictWithStartTime:userGesturePasswordLastUsedDateStr endTime:currentDateStr];
        NSNumber *totalDays = [timeInfoDict objectForKey:@"day"];
        
        if ([totalDays intValue] >= [userGesturePasswordExpiredDays intValue]) {
            isOverExpiredDays = YES;
        }
        
    }
    
    return isOverExpiredDays;
}

/*
 - (void)requestFunctionData
 {
 NSDictionary *header = @{@"AUTH_TOKEN":[CommonUtil getUserModel].token};
 
 [APPHTTPManager syncLoadWithURLString:Url_GetReportListData headDict:header block:^(id info, NSError *error) {
 if (error) {
 } else{
 if ([info isKindOfClass:[NSDictionary class]]) {
 dispatch_async(dispatch_get_main_queue(), ^{
 ResponseModel *response = [ResponseModel modelWithDictionary:info error:nil];
 if (response.status == 1 && [response.data isKindOfClass:[NSDictionary class]]) {
 NSArray *items = [response.data objectForKey:@"items"];
 [FunctionModel deleteWithWhere:nil];
 for (NSDictionary *dic in items) {
 FunctionModel *model = [FunctionModel objectWithKeyValues:dic];
 [model saveToDB];
 }
 }
 });
 }
 }
 }];
 }
 
 - (void)requestProductLineData
 {
 NSDictionary *header = @{@"AUTH_TOKEN":[CommonUtil getUserModel].token};
 [APPHTTPManager syncLoadWithURLString:Url_GetBWProduectLineData headDict:header block:^(id info, NSError *error) {
 if (error) {
 } else{
 NSLog(@"%@",info);
 if ([info isKindOfClass:[NSDictionary class]]) {
 dispatch_async(dispatch_get_main_queue(), ^{
 ResponseModel *response = [ResponseModel modelWithDictionary:info error:nil];
 if (response.status==1 && [response.data isKindOfClass:[NSDictionary class]]) {
 NSArray *items = [response.data objectForKey:@"items"];
 [ProductLineModel deleteWithWhere:nil];
 for (NSDictionary *dic in items) {
 ProductLineModel *model = [ProductLineModel objectWithKeyValues:dic];
 [model saveToDB];
 }
 }
 });
 }
 }
 }];
 }
 */

@end

