//
//  WSEnterOrLeaveStoreBaseAcvtViewController.m
//  WinSFA
//
//  Created by HZH on 2017/12/1.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSEnterOrLeaveStoreBaseAcvtViewController.h"
#import "WSAcvtScrollView.h"
// YIHAIKERRY-3168
#define KButtonTitleColor ([UIColor colorForKey:@"LuaButtonTitleColor"] ? [UIColor colorForKey:@"LuaButtonTitleColor"] :[UIColor blackColor])

@interface WSEnterOrLeaveStoreBaseAcvtViewController ()
{
    UIButton *_funcButton;
    UIView *_funcBtnsBgView;
    BOOL _isFirstLoad;
}
@end

@implementation WSEnterOrLeaveStoreBaseAcvtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isFirstLoad = YES;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.currentFuncs.buttonName && self.currentFuncs.buttonName.length > 0 && _isFirstLoad) {
        // MN-2241 父类已经实现右上角按钮清理
        //        self.navigationItem.rightBarButtonItems = nil;
        [self setupFunctionBtnWithBtnName:self.currentFuncs.buttonName];
        _isFirstLoad = NO;
    }
}

- (void)addToolBar
{
    if (self.currentFuncs.buttonName && self.currentFuncs.buttonName.length > 0) {
        
    }else{
        [super addToolBar];
    }
}

// YIHAIKERRY-977 上传按钮放在问卷中显示，按钮标题为funcs里面配置的bottonName
- (void)setupFunctionBtnWithBtnName:(NSString *)btnName
{
    
    _funcBtnsBgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - kEnterOrLeaveStoreFuncBtnTopPadding * 2 - kEnterOrLeaveStoreFuncBtnHeight, self.view.bounds.size.width, kEnterOrLeaveStoreFuncBtnTopPadding * 2 + kEnterOrLeaveStoreFuncBtnHeight)];
    _funcBtnsBgView.backgroundColor = [UIColor whiteColor];
    
    _funcButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _funcButton.frame = CGRectMake(kEnterOrLeaveStoreFuncBtnLeftPadding, kEnterOrLeaveStoreFuncBtnTopPadding, _funcBtnsBgView.frame.size.width - kEnterOrLeaveStoreFuncBtnLeftPadding * 2, kEnterOrLeaveStoreFuncBtnHeight);
    // YIHAIKERRY-3168
//    [_funcButton setBackgroundColor:MAIN_TINT_COLOR];
    [_funcButton setBackgroundColor:[UIColor clearColor]];
    [_funcButton setBackgroundImage:[UIImage imageNamed:@"sign_button_icon"] forState:UIControlStateNormal];
    _funcButton.layer.cornerRadius = 3.0;
    _funcButton.layer.masksToBounds = YES;
    
    [_funcButton setAdjustsImageWhenHighlighted:NO];
    
    // YIHAIKERRY-3168
    [_funcButton setTitleColor:KButtonTitleColor forState:UIControlStateNormal];
//    [_funcButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_funcButton setTitleColor:MAIN_TEXT_DISABLE_COLOR forState:UIControlStateDisabled];
    _funcButton.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
    [_funcButton addTarget:self action:@selector(funcButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_funcButton setTitle:btnName forState:UIControlStateNormal];
    
    [_funcBtnsBgView addSubview:_funcButton];
    
    [self.view addSubview:_funcBtnsBgView];
    
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[WSAcvtScrollView class]]) {
            WSAcvtScrollView *acvtScrollView = (WSAcvtScrollView *)subview;

            CGRect frame = acvtScrollView.frame;
            frame.size.height = frame.size.height - kEnterOrLeaveStoreFuncBtnTopPadding * 2 - kEnterOrLeaveStoreFuncBtnHeight;
            acvtScrollView.frame = frame;
            break;
        }
    }
    
}

- (void)funcButtonClicked:(id)sender
{
    
    [self executeUpload];
}

- (NSString *)getEnterOrLeaveStoreModuleFc {
    
    NSString *moduleFc = self.currentVisitAction.module_fc;
    return (moduleFc.length > 0) ? moduleFc : @"";
}
- (void)setStoreExitTime:(NSString*)exitTime{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
