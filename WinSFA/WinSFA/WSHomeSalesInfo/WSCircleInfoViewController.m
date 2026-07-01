//
//  WSCircleInfoViewController.m
//  WinSFA
//
//  Created by mac on 2018/11/7.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSCircleInfoViewController.h"
#import "WSCircleInfoView.h"
#import "WSBaseAcvtDBService.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSFuncTipDBService.h"
#import "WSBaseMsgTable.h"
#import "WSFuncsBeanArray.h"

#pragma mark - 销售信息视图管理器 延展(工具)
@interface WSCircleInfoViewController (Tools)

#pragma mark - 布局销售信息视图方法
- (void)layoutCircleInfoView;

#pragma mark - 处理销售信息数据方法
- (void)handleCircleInfoData;

#pragma mark - 点击通知方法
- (void)clickNotify;

#pragma mark - 刷新通知数量方法
- (void)updateNoticeCount;

@end
@interface WSCircleInfoViewController ()

@property (nonatomic,strong) WSCircleInfoView *circleInfoView;

@end

@implementation WSCircleInfoViewController

#pragma mark - 获取salesInfoView方法
- (WSCircleInfoView *)circleInfoView
{
    if(_circleInfoView == nil)
    {
        _circleInfoView = [[WSCircleInfoView alloc]initWithFrame:CGRectZero];
        _circleInfoView.backgroundColor = [UIColor clearColor];
        __weak typeof(self) weakSelf = self;
        [_circleInfoView setNotifyClickBlock:^(void){
            [weakSelf clickNotify];
        }];
    }
    return _circleInfoView;
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.circleInfoView];
    [self handleCircleInfoData];
    
}

#pragma mark - 重写viewWillLayoutSubviews方法
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self layoutCircleInfoView];
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
    return [self.circleInfoView calculationCircleInfoViewHeightWithWidth:CGRectGetWidth(self.view.frame)];
}


@end

#pragma mark - 销售信息视图管理器 延展(工具)
@implementation WSCircleInfoViewController (Tools)

#pragma mark - 布局销售信息视图方法
- (void)layoutCircleInfoView
{
    self.circleInfoView.frame = self.view.bounds;
}

#pragma mark - 处理销售信息数据方法
- (void)handleCircleInfoData
{
    WSCircleInfoViewShowData *showData = [[WSCircleInfoViewShowData alloc] init];
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
    [self.circleInfoView updateCircleInfoViewWithShowData:showData];
}

#pragma mark - 点击通知方法
- (void)clickNotify
{
    WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
    
    // SFA-25472  SFA-立白-IOS-首页点铃铛图标没有显示出配置的过滤项信息 立白新增了一个菜单TAB_F1003_AT02显示公告信息，如果有，则用这个，没有就走老逻辑
    WSFuncsBean *fb =  [funcsArray getAllFuncsBeanWithFC:@"TAB_F1003_AT02"];
    if (!fb) { //老逻辑
        fb = [funcsArray getFuncsBeanWithFV:@"TAB_V1002"];
        if (!fb){
            fb = [funcsArray getHideFuncsBeanWithFV:@"TAB_V1002"];
        }
    }
    
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
    if([count isEqualToString:self.circleInfoView.noticeCount] == NO)
        [self.circleInfoView updateNoticeCountWithCountData:count];
}

@end
