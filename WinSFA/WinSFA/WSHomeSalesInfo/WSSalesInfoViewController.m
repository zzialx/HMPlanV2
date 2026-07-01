//
//  WSSalesInfoViewController.m
//  WinSFA
//
//  Created by yuanji on 2018/4/12.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSSalesInfoViewController.h"
#import "WSSalesInfoView.h"
#import "WSBaseAcvtDBService.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSFuncTipDBService.h"
#import "WSBaseMsgTable.h"
#import "WSFuncsBeanArray.h"
//===================================================================================================================================================================

#pragma mark - 销售信息视图管理器 延展(内部)
@interface WSSalesInfoViewController ()

@property (nonatomic, strong) WSSalesInfoView *salesInfoView; //销售信息视图

@end
//===================================================================================================================================================================

#pragma mark - 销售信息视图管理器 延展(工具)
@interface WSSalesInfoViewController (Tools)

#pragma mark - 布局销售信息视图方法
- (void)layoutSalesInfoView;

#pragma mark - 处理销售信息数据方法
- (void)handleSalesInfoData;

#pragma mark - 点击通知方法
- (void)clickNotify;

#pragma mark - 刷新通知数量方法
- (void)updateNoticeCount;

@end
//===================================================================================================================================================================

#pragma mark - 销售信息视图管理器
@implementation WSSalesInfoViewController

#pragma mark - 获取salesInfoView方法
- (WSSalesInfoView *)salesInfoView
{
    if(_salesInfoView == nil)
    {
        _salesInfoView = [[WSSalesInfoView alloc] initWithFrame:CGRectZero];
        _salesInfoView.backgroundColor = [UIColor clearColor];
        
        __weak typeof(self) weakSelf = self;
        [_salesInfoView setNotifyClickBlock:^(void){
            [weakSelf clickNotify];
        }];
    }
    return _salesInfoView;
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.salesInfoView];
    [self handleSalesInfoData];
}

#pragma mark - 重写viewWillLayoutSubviews方法
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self layoutSalesInfoView];
}

#pragma mark - 重写viewWillAppear:方法
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateNoticeCount];
}

#pragma mark - 重写contentHeight方法
- (CGFloat)contentHeight
{
    return [self.salesInfoView calculationSalesInfoViewHeightWithWidth:CGRectGetWidth(self.view.frame)];
}

@end
//===================================================================================================================================================================

#pragma mark - 销售信息视图管理器 延展(工具)
@implementation WSSalesInfoViewController (Tools)

#pragma mark - 布局销售信息视图方法
- (void)layoutSalesInfoView
{
    self.salesInfoView.frame = self.view.bounds;
}

#pragma mark - 处理销售信息数据方法
- (void)handleSalesInfoData
{
    WSSalesInfoViewShowData *showData = [[WSSalesInfoViewShowData alloc] init];
    showData.slogan = [WSFuncTipDBService queryTipWithFuncCode:self.currentFuncs.fc andEmpId:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    
    NSArray *unReadMessage = [[WSBaseMsgTable sharedTable] queryAllUnreadBaseMsgs];
    showData.noticeCount = (unReadMessage.count > 99) ? @"99+" : ((unReadMessage.count > 0) ? [NSString stringWithFormat:@"%ld", unReadMessage.count] : @"");
    
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    NSString *tempStr = [NSString stringNotNilWithValue:[service queryQstValueWithQstCode:@"new_homepage_1"]];
    showData.tilte1 = ((tempStr.length > 0) ? tempStr : @" ");
    tempStr = [NSString stringNotNilWithValue:[service queryQstValueWithQstCode:@"new_homepage_2"]];
    showData.content1 = ((tempStr.length > 0) ? tempStr : @" ");
    tempStr = [NSString stringNotNilWithValue:[service queryQstValueWithQstCode:@"new_homepage_3"]];
    showData.tilte2 = ((tempStr.length > 0) ? tempStr : @" ");
    tempStr = [NSString stringNotNilWithValue:[service queryQstValueWithQstCode:@"new_homepage_4"]];
    showData.content2 = ((tempStr.length > 0) ? tempStr : @" ");
    tempStr = [NSString stringNotNilWithValue:[service queryQstValueWithQstCode:@"new_homepage_5"]];
    showData.tilte3 = ((tempStr.length > 0) ? tempStr : @" ");
    tempStr = [NSString stringNotNilWithValue:[service queryQstValueWithQstCode:@"new_homepage_6"]];
    showData.content3 = ((tempStr.length > 0) ? tempStr : @" ");
    tempStr = [NSString stringNotNilWithValue:[service queryQstValueWithQstCode:@"new_homepage_7"]];
    showData.tilte4 = ((tempStr.length > 0) ? tempStr : @" ");
    tempStr = [NSString stringNotNilWithValue:[service queryQstValueWithQstCode:@"new_homepage_8"]];
    showData.content4 = ((tempStr.length > 0) ? tempStr : @" ");
    tempStr = [NSString stringNotNilWithValue:[service queryQstValueWithQstCode:@"new_homepage_9"]];
    showData.tilte5 = ((tempStr.length > 0) ? tempStr : @" ");
    tempStr = [NSString stringNotNilWithValue:[service queryQstValueWithQstCode:@"new_homepage_10"]];
    showData.content5 = ((tempStr.length > 0) ? tempStr : @" ");
    tempStr = [NSString stringNotNilWithValue:[service queryQstValueWithQstCode:@"new_homepage_11"]];
    showData.tilte6 = ((tempStr.length > 0) ? tempStr : @" ");
    tempStr = [NSString stringNotNilWithValue:[service queryQstValueWithQstCode:@"new_homepage_12"]];
    showData.content6 = ((tempStr.length > 0) ? tempStr : @" ");
    tempStr = [NSString stringNotNilWithValue:[service queryQstValueWithQstCode:@"new_homepage_13"]];
    showData.tilte7 = ((tempStr.length > 0) ? tempStr : @" ");
    tempStr = [NSString stringNotNilWithValue:[service queryQstValueWithQstCode:@"new_homepage_14"]];
    showData.content7 = ((tempStr.length > 0) ? tempStr : @" ");
    [self.salesInfoView updateSalesInfoViewWithShowData:showData];
}

#pragma mark - 点击通知方法
- (void)clickNotify
{
    WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean *fb = [funcsArray getFuncsBeanWithFV:@"TAB_V1002"];
    if (fb == nil)
        fb = [funcsArray getHideFuncsBeanWithFV:@"TAB_V1002"];
    
    NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
    UIViewController *vc = [[NSClassFromString(className) alloc] initWithFuncs:fb];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 刷新通知数量方法
- (void)updateNoticeCount
{
    NSArray *unReadMessage = [[WSBaseMsgTable sharedTable] queryAllUnreadBaseMsgs];
    NSString *count = (unReadMessage.count > 99) ? @"99+" : ((unReadMessage.count > 0) ? [NSString stringWithFormat:@"%ld", unReadMessage.count] : @"");
    if([count isEqualToString:self.salesInfoView.noticeCount] == NO)
        [self.salesInfoView updateNoticeCountWithCountData:count];
}

@end
//===================================================================================================================================================================
