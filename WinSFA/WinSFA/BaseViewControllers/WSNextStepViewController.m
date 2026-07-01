//
//  WSNextStepViewController.m
//  WinSFA
//
//  Created by winchannel on 16/8/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSNextStepViewController.h"
#import "WSNextStepBottomView.h"
#import "WSLeftMenuViewController.h"
#import "WSInterAction.h"
#import "WSNewAddListViewController.h"
#import "WSAcvtViewController.h"
#import "WSWorkFlowViewController.h"
#import "I_NextStepContentView.h"
#import "WSRichMediaMainController.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "WSBaseAcvtDBService.h"
#import "WSRichMediaMainController.h"
#import "WSSuggestedTableShowController.h"

#define k_BottomMainViewHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  : self.view.bounds.size.height - k_BottomBarHeight )

#define k_BottomBarYOffSet ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  : self.view.bounds.size.height - k_BottomBarHeight)

#define k_BottomBarWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  : self.view.bounds.size.width - k_BottomBarLeftSpace *2 )
#define k_BottomBarHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  :48)
#define k_BottomBarLeftSpace ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  :0)
#define k_BottomBarTopSpace ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  :20)



@interface WSNextStepViewController ()

@property (nonatomic, strong) NSArray *contentFuncsArray;
@property (nonatomic, strong) UIViewController *centerViewController;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) WSNextStepBottomView *nextStepBottomView;

@end

@implementation WSNextStepViewController

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store
{
    return [self initWithFuncs:funcs Store:store currentIndex:0];
}

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store currentIndex:(NSInteger)currentIndex
{
    
    if (store) {
        self = [super initWithFuncs:funcs Store:store];
    }else {
        self = [super initWithFuncs:funcs];
    }
    
    if (self) {
        _currentIndex = currentIndex;
        _contentFuncsArray = [WSFuncsBeanFilterLogicService filterFuncsBean:funcs.funcsArray withStore:store bizDate:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    }
    
    return self;
}

- (void)loadView{
    
    [super loadView];
    
    CGFloat titleBarHeight = 0;

    if ([self.prepareVisitDate length] > 0 && self.currentIndex < 2) {
        titleBarHeight = 45;
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, titleBarHeight)];
        titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleView.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.bounds.size.width - 20, titleBarHeight)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:UI_Font];
        label.backgroundColor = [UIColor clearColor];
        [titleView addSubview:label];
        
        NSMutableString *string = [NSMutableString stringWithFormat:@"拜访日期：%@",self.prepareVisitDate];
        if (self.currentStore.name) {
            [string appendFormat:@"    拜访门店：%@",self.currentStore.name];
        }
        label.text = string;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, titleBarHeight - 1, self.view.bounds.size.width, 1)];
        line.backgroundColor = [UIColor colorWithHexString:@"#d2d2d2"];
        [titleView addSubview:line];
        
        [self.view addSubview:titleView];
    }
    
    UIView *mainView = [[UIView alloc]initWithFrame:CGRectMake(0, titleBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - k_BottomBarHeight - titleBarHeight)];
    mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    mainView.tag = 1001;
    self.mainView = mainView;
    
    [self.view addSubview:mainView];
    
    UIViewController *vc =  [self generateMainView];
    if ([vc isKindOfClass:[BaseViewController class]]) {
        
        ((BaseViewController *)vc).m_ParentViewController = self;
    }
 
    
    if ([vc isKindOfClass:[WSRichMediaMainController class]]) {
        WSRichMediaMainController * richMediaMain = (WSRichMediaMainController *)vc;
        richMediaMain.visitData = self.prepareVisitDate;
    }
    
    if ([vc isKindOfClass:[WSSuggestedTableShowController class]]) {
        WSSuggestedTableShowController * suggest = (WSSuggestedTableShowController *)vc;
        suggest.prepareDate = self.prepareVisitDate;
    }
    
    if (vc) {
        vc.view.frame = self.mainView.bounds;
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addChildViewController:vc];
        
        [self.mainView addSubview:vc.view];
    }
    
    WSNextStepBottomView *bottomView = [[WSNextStepBottomView alloc] initWithFrame:CGRectMake(k_BottomBarLeftSpace, k_BottomBarYOffSet, k_BottomBarWidth, k_BottomBarHeight) funcsArray:self.contentFuncsArray currentIndex:self.currentIndex];
    bottomView.autoresizingMask= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.nextStepBottomView = bottomView;
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
  
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *rightBarItemTitle ;
    SEL  rightSelector ;
    if (self.currentIndex < [self.contentFuncsArray count] - 1) {
        rightBarItemTitle = NSLocalizedString(@"下一步", nil);
        rightSelector = @selector(nextStep);
    }else{
        rightBarItemTitle = NSLocalizedString(@"complete", nil);;
         rightSelector = @selector(confirmCompletion);
    }
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithTitle:rightBarItemTitle style:UIBarButtonItemStyleDone target:self action:rightSelector];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    if (self.currentIndex > 0) {
        UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"上一步" style:UIBarButtonItemStyleDone target:self action:@selector(backAction)];
        self.navigationItem.leftBarButtonItem = homeButtonItem;
    }
    
    // Do any additional setup after loading the view.
    
    NSArray *namesArray = [self.contentFuncsArray valueForKey:@"name"];
    
    LogInfo(@"当前index:%ld,所有菜单：%@", (long)self.currentIndex, namesArray);
}

- (UIViewController *)generateMainView{
    
    for (UIView *view in self.mainView.subviews) {
        [view removeFromSuperview];
    }
    if (self.centerViewController != nil) {
        [self.centerViewController.view removeFromSuperview];
        [self.centerViewController removeFromParentViewController];
        self.centerViewController = nil;
    }
    
    WSFuncsBean *funcBean = [self.contentFuncsArray objectAtIndex:self.currentIndex];
    
    LogInfo(@"当前页面：%@,fc:%@", funcBean.name, funcBean.fc);
    
    NSString *className = [WSPlistHelper valueForKey:funcBean.fv withPlistName:kControllerMappingFileName];
    UIViewController *vc =nil;
    
    if (self.currentStore) {
        vc = [[NSClassFromString(className) alloc] initWithFuncs:funcBean Store:self.currentStore];
    } else {
        vc = [[NSClassFromString(className) alloc] initWithFuncs:funcBean];
    }
    if ([funcBean.menuLayout isEqualToString:MENU_LAYOUT_LEFT]) {
        vc = [[WSLeftMenuViewController alloc] initWithFuncs:funcBean Store:self.currentStore];
    }
    
    if (vc == nil) {
        
        // 和从门店拜访项进入下一个页面的逻辑一样和安卓保持一致
        if (funcBean.opt.isAdd && [funcBean.opt.isAdd isEqualToString:@"Y"]) {
            vc = [[WSNewAddListViewController alloc]  initWithFuncs:funcBean Store:self.currentStore];
        } else {
            if ([funcBean.isAcvtList isEqualToString:@"1"])
            {
                WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
                NSArray *filtersArray = [baseAcvtDBService queryAcvtsWithStoreId:self.currentStore.Id filter:funcBean.filter];
                
                WSAcvtBean *acvtBean = [filtersArray lastObject];
                if (self.currentSubEmpStore) {
                    vc = [[WSAcvtViewController alloc]initWithAcvt:acvtBean Funcs:funcBean subEmpStore:self.currentSubEmpStore];
                }else{
                    vc = [[WSAcvtViewController alloc]initWithAcvt:acvtBean Funcs:funcBean Store:self.currentStore];
                }
                
            }
            else
            {
                NSString *className = [WSPlistHelper valueForKey:funcBean.ds withPlistName:kControllerMappingFileName];
                if (self.currentStore) {
                    vc =[[NSClassFromString(className) alloc] initWithFuncs:funcBean Store:self.currentStore];
                } else {
                    vc =[[NSClassFromString(className) alloc] initWithFuncs:funcBean];
                }

            }
        }
        
    }
    
    vc.prepareVisitDate = self.prepareVisitDate;
    
    self.centerViewController = vc;
    
    return vc;
}

- (BOOL)validateAndUploadDatasForContenViewController
{
    id<I_NextStepContentView> nextStepContent;
    if ([self.centerViewController conformsToProtocol:@protocol(I_NextStepContentView)]) {
        nextStepContent = (id<I_NextStepContentView>)self.centerViewController;
    }else if ([[[self.centerViewController childViewControllers] firstObject] conformsToProtocol:@protocol(I_NextStepContentView)]){
        nextStepContent = (id<I_NextStepContentView>)[[self.centerViewController childViewControllers] firstObject];
    }
    
    if ([nextStepContent respondsToSelector:@selector(nextStepContentViewValidateData)]) {
        BOOL result = [nextStepContent nextStepContentViewValidateData];
        if (!result) {
            return NO;
        }
    }
    
    if ([nextStepContent respondsToSelector:@selector(nextStepContentViewUploadData)]) {
        [nextStepContent nextStepContentViewUploadData];
    }
    
    return YES;
}

- (void)backAction
{
    [super backAction];
    
    LogTrace();
    
    id<I_NextStepContentView> nextStepContent;
    if ([self.centerViewController conformsToProtocol:@protocol(I_NextStepContentView)]) {
        nextStepContent = (id<I_NextStepContentView>)self.centerViewController;
    }else if ([[[self.centerViewController childViewControllers] firstObject] conformsToProtocol:@protocol(I_NextStepContentView)]){
        nextStepContent = (id<I_NextStepContentView>)[[self.centerViewController childViewControllers] firstObject];
    }
    
    if ([nextStepContent respondsToSelector:@selector(nextStepContentViewClearData)]) {
        [nextStepContent nextStepContentViewClearData];
    }
}
    
- (void)nextStep{
    
    LogTrace();
    
    if (![self validateAndUploadDatasForContenViewController]) {
        return;
    }

    WSNextStepViewController *nextStepViewController = [[[self class] alloc] initWithFuncs:self.currentFuncs Store:self.currentStore currentIndex:self.currentIndex + 1];
    nextStepViewController.prepareVisitDate = self.prepareVisitDate;
    nextStepViewController.currentVisitAction = self.currentVisitAction;
        
    [self.navigationController pushViewController:nextStepViewController animated:YES];
    
}

- (void)confirmCompletion{
    
    LogTrace();
    
    //上传演示列表
    NSString *centerVC = NSStringFromClass([self.centerViewController class]);
    NSString *RichMedia = NSStringFromClass([WSRichMediaMainController class]);
    if ([centerVC isEqualToString:RichMedia]) {
        
       WSRichMediaMainController *richMedia = (WSRichMediaMainController *) self.centerViewController;
        
        richMedia.uploadDemolist();
        
    }
    
    if (![self validateAndUploadDatasForContenViewController]) {
        return;
    }
    
    [self uploadVisitAction];
    
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if (self.navigationController){
        NSArray *array = self.navigationController.viewControllers;
        NSInteger index = array.count - 1 - _contentFuncsArray.count;
        if (array.count > index) {
            UIViewController *con = array[index];
            [self.navigationController popToViewController:con animated:YES];
        }
        
    }
    
}



@end
