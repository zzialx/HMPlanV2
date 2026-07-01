//
//  WSLeftMenuViewController.m
//  WinSFA
//
//  Created by winchannel on 16/8/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSLeftMenuViewController.h"
#import "WSLeftMenuView.h"
#import "WSNewAddListViewController.h"
#import "WSAcvtViewController.h"
#import "WSEnvrionment.h"
#import "WSSpecialAcvtViewController.h"
#import "WSNewStoreListViewController.h"
#import "WSBaseAcvtDBService.h"

#define k_LeftMenuXOffSet ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  :10)
//#define k_LeftMenuYOffSet ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  :((self.view.bounds.size.height - 64 - k_LeftMenuHeight)/2.0 ))


#define k_LeftMenuWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  :100)
#define k_LeftMenuCellHeight 90
//#define k_LeftMenuHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  :574)

#define k_LeftMenuRightSpace  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  : 10)//(IOS8_OR_LATER ? 40:0))


#define k_MainViewXOffSet ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  :k_LeftMenuXOffSet + k_LeftMenuWidth + k_LeftMenuRightSpace)
#define k_MainViewYOffSet ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  :0)
#define k_MainViewWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  :self.view.bounds.size.width - k_MainViewXOffSet)
#define k_MainViewHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  :self.view.bounds.size.height)

@interface WSLeftMenuViewController ()<WSLeftMenuViewDelegate>

@property (nonatomic, strong) NSMutableArray *leftMenuItems;
@property (nonatomic, strong) NSArray *disPlayFuncs;
@property (nonatomic, strong)UIViewController *selectViewController;
@property (nonatomic, strong) WSLeftMenuView *leftMenuView;
@property (nonatomic, strong) UIView *mainView;

@end

@implementation WSLeftMenuViewController

- (id)initWithFuncs:(WSFuncsBean *)funcs{
    self = [super initWithFuncs:funcs];
    if (self) {
        _leftMenuItems = [[NSMutableArray alloc]init];
        
        _disPlayFuncs = [NSArray arrayWithArray:funcs.funcsArray];
        for (WSFuncsBean *funcsBean  in funcs.funcsArray) {
            [_leftMenuItems addObject:funcsBean.name];
        }
    }
    return self;
    
}

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store{
    
    self = [super initWithFuncs:funcs Store:store];
    if (self) {
        _leftMenuItems = [[NSMutableArray alloc]init];
        
        _disPlayFuncs = [NSArray arrayWithArray:funcs.funcsArray];
        for (WSFuncsBean *funcsBean  in funcs.funcsArray) {
            [_leftMenuItems addObject:funcsBean.name];
        }
    }
    return self;
}

- (void)loadView{
    
    [super loadView];

    [self addFuncsLeftMenu];
    [self addMainSelfMainView];
    
    
    [_leftMenuView setSelectedIndex:0];
}

- (void)viewDidLoad {
 
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBCOLOR(246, 246, 246);
    
    [self leftItemImage:@"icon_back" target:self action:@selector(backAction)];

}

- (void)backAction {
    
    BOOL isPromptUpload = NO;
    
    
    WSAcvtViewController *acvtCon = nil;
    
    if ([self.selectViewController isKindOfClass:[WSAcvtViewController class]]) {
        acvtCon = (WSAcvtViewController *)self.selectViewController;
    }else if ([self.selectViewController isKindOfClass:[WSSpecialAcvtViewController class]]) {
        acvtCon = [((WSSpecialAcvtViewController *)self.selectViewController) m_AcvtViewController];
    }
    
    if ([acvtCon performSelector:@selector(isValueChange)]) {
        isPromptUpload = YES;
    }
    
    if (isPromptUpload) {
        
        
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"back_confirm2", nil)];
        
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
        [alert addButtonWithTitle:NSLocalizedString(@"upload_label", nil) block:^{
            if ([acvtCon isKindOfClass:[WSAcvtViewController class]]) {
                [acvtCon executeUpload];
            }
        }];
        [alert addButtonWithTitle:NSLocalizedString(@"give_up", nil) block:^{
            [self backToParent];
        }];
        [alert show];

        return;
        
    }
    [self backToParent];
}


- (void)addMainSelfMainView{
    
    UIView *view = [[UIView alloc
                     ]init];
    view.frame = CGRectMake(k_MainViewXOffSet, k_MainViewYOffSet, self.view.bounds.size.width - k_MainViewXOffSet, k_MainViewHeight);
//    if (self.m_ParentViewController) {
//         view.frame = CGRectMake(k_MainViewXOffSet +(IOS8_OR_LATER ? 50:50), k_MainViewYOffSet, k_MainViewWidth, k_MainViewHeight);
//    }
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    view.backgroundColor = [UIColor clearColor];
    self.mainView = view;
    [self.view addSubview:view];
    
}

- (void)addFuncsLeftMenu{
    
    CGFloat height = _leftMenuItems.count * k_LeftMenuCellHeight;
    
    _leftMenuView = [[WSLeftMenuView alloc]initWithFrame:CGRectMake(k_LeftMenuXOffSet,(self.view.height - height)/2,k_LeftMenuWidth,height) withFuncs:_leftMenuItems];
    _leftMenuView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    _leftMenuView.delegate = self;
    [self.view addSubview:_leftMenuView];

}




- (UIViewController *)generateMainViewWithIndex:(NSInteger)index{
    
    for (UIView *view in self.mainView.subviews) {
        [view removeFromSuperview];
    }
    if (self.selectViewController != nil) {
        [self.selectViewController.view removeFromSuperview];
        [self.selectViewController removeFromParentViewController];
        self.selectViewController = nil;
    }
    
    
    
    WSFuncsBean *fb = [self.disPlayFuncs objectAtIndex:index];
    NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
    UIViewController *vc =nil;
    
    
    BOOL isAddAcvt = NO;
    if ([fb.opt.isAdd isEqualToString:@"Y"]) {
        isAddAcvt = YES;
    }
    
    if (!isAddAcvt) {
        if (self.currentStore) {
            vc = [[NSClassFromString(className) alloc] initWithFuncs:fb Store:self.currentStore];
        } else {
            vc = [[NSClassFromString(className) alloc] initWithFuncs:fb];
        }
    }
    
    if (vc == nil) {
        
        // 和从门店拜访项进入下一个页面的逻辑一样和安卓保持一致
        if (isAddAcvt) {
            if (self.currentStore) {
                vc = [[WSNewAddListViewController alloc]  initWithFuncs:fb Store:self.currentStore];
            }else {
                vc = [[WSNewStoreListViewController alloc] initWithFuncs:fb];
            }
        } else {
            if ([fb.isAcvtList isEqualToString:@"1"])
            {
                
                WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
                NSArray *filtersArray = [baseAcvtDBService queryAcvtsWithStoreId:self.currentStore.Id filter:fb.filter];
                WSAcvtBean *acvtBean = [filtersArray lastObject];
                
                if (self.currentSubEmpStore) {
                    vc = [[WSAcvtViewController alloc]initWithAcvt:acvtBean Funcs:fb subEmpStore:self.currentSubEmpStore];
                }else{
                    vc = [[WSAcvtViewController alloc]initWithAcvt:acvtBean Funcs:fb Store:self.currentStore];
                }
                
            }
            else
            {
                NSString *className = [WSPlistHelper valueForKey:fb.ds withPlistName:kControllerMappingFileName];
                if (self.currentStore) {
                    vc =[[NSClassFromString(className) alloc] initWithFuncs:fb Store:self.currentStore];
                } else {
                    vc =[[NSClassFromString(className) alloc] initWithFuncs:fb];
                }
                
            }
        }
        
    }
    self.selectViewController = vc;
    return vc;
}

- (void)showViewControllerAtIndex:(NSInteger)index
{
    self.navigationItem.rightBarButtonItems = nil;
    
    UIViewController *controller =  [self generateMainViewWithIndex:index];
    
    if ([controller isKindOfClass:[WCBaseViewController class]]) {
        ((WCBaseViewController *)controller).ownParentViewController = self;
    }
    
    if ([controller isKindOfClass:[BaseViewController class]]) {
        ((BaseViewController *)controller).m_ParentViewController = self;
    }
    
    controller.view.frame = self.mainView.bounds;
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addChildViewController:controller];
    
    [self.mainView addSubview:controller.view];
}

#pragma mark - WSLeftMenuViewDelegate


static BOOL didEnd = NO;
static BOOL result = YES;
- (BOOL)leftMenusViewShouldSelectItemAtIndex:(NSInteger)index
{
    BOOL isNeedConfirm = NO;
    
            
    if ([self.selectViewController respondsToSelector:@selector(isValueChange)]) {
        //                BOOL changed = [(BaseViewController*)realContentTopViewController isValueChange];
        if ([(BaseViewController*)self.selectViewController isValueChange]) {
            isNeedConfirm = YES;
        }
    }
    
    result = YES;
    
    if (isNeedConfirm) {
        
        didEnd = NO;
        
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"back_confirm2", nil)];
        
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:^{
            didEnd = YES;
            result = NO;
        }];
        [alert addButtonWithTitle:NSLocalizedString(@"upload_label", nil) block:^{
            didEnd = YES;
            result = NO;
            if ([self.selectViewController isKindOfClass:[WSAcvtViewController class]]) {
                [(WSAcvtViewController *)self.selectViewController executeUpload];
            }
        }];
        [alert addButtonWithTitle:NSLocalizedString(@"give_up", nil) block:^{
            didEnd = YES;
            result = YES;
            
        }];
        [alert show];
        
        
        while (!didEnd) {
            [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
        }
        
        return result;
    }
    
    return result;
}

- (void)leftMenusViewDidSelectItemAtIndex:(NSInteger)index
{
    [self showViewControllerAtIndex:index];
}

@end
