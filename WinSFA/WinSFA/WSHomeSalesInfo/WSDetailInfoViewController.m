//
//  WSDetailInfoViewController.m
//  WinSFA
//
//  Created by mac on 2018/11/9.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSDetailInfoViewController.h"
#import "WSDetailInfoView.h"
#import "WSBaseAcvtDBService.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSFuncTipDBService.h"
#import "WSBaseMsgTable.h"

#pragma mark - 销售信息视图管理器 延展(工具)
@interface WSDetailInfoViewController (Tools)

#pragma mark - 布局销售信息视图方法
//- (void)layoutCircleInfoView;

#pragma mark - 处理销售信息数据方法
- (void)handleDetailInfoData;

@end

@interface WSDetailInfoViewController ()

@property (nonatomic,strong) WSDetailInfoView *detailInfoView;


@end

@implementation WSDetailInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.detailInfoView];
    [self handleDetailInfoData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (WSDetailInfoView *)detailInfoView
{
    if(_detailInfoView == nil)
    {
        _detailInfoView = [[WSDetailInfoView alloc] initWithFrame:CGRectZero];
        _detailInfoView.backgroundColor = [UIColor clearColor];
    }
    return _detailInfoView;
}
#pragma mark - 重写viewWillLayoutSubviews方法
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self layoutDetailInfoView];
}

- (void) layoutDetailInfoView{
    self.detailInfoView.frame = self.view.bounds;
}

- (CGFloat)contentHeight
{
    return [self.detailInfoView calculationCircleInfoViewHeightWithWidth:CGRectGetWidth(self.view.frame)];
}


@end

#pragma mark - 销售信息视图管理器 延展(工具)
@implementation WSDetailInfoViewController (Tools)


#pragma mark - 处理销售信息数据方法
- (void)handleDetailInfoData
{
    WSCircleDetailInfoViewShowData *showData = [[WSCircleDetailInfoViewShowData alloc] init];
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
    [self.detailInfoView updateDetailInfoViewWithShowData:showData];
}

@end


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


