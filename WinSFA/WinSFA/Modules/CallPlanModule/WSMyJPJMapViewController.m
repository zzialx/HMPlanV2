//
//  WSMyJPJMapViewController.m
//  WinSFA
//
//  Created by zhiqing on 16/8/18.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSMyJPJMapViewController.h"
//#import "PureLayout.h"
//#import "WSMapView.h"
//#import "WSMyJPJTableViewCell.h"
//#import "WSMyJPJCollectionModel.h"
//#import "WSSelectTimeView.h"
//#import "WSRequestHelper.h"
//#import "WSMapShipView.h"
//#define k_TitleView_Hight 60
//#define WSMyJPJTableView_TEXT_SIZE [UIFont systemFontOfSize:15]

//@interface WSMyJPJMapViewController ()<UITableViewDelegate,UITableViewDataSource,WSSelectTimeViewDelegate>
//{
//    UITableView * _leftTableView;
//    UILabel * weekLable ;
//    UILabel * dayLable ;
//    UILabel * lable ;
//    UIView  * view;
//    WSMapView * mapview;
//    UIView * bgView;
//}
//@property(nonatomic,strong) NSArray *weekArray;
//@property (nonatomic,strong) MBProgressHUD* m_HUD;
//
//@end

@implementation WSMyJPJMapViewController

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    UIView  * dateView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, k_TitleView_Hight)];
//    [self.view addSubview:dateView];
//
//    self.weekArray = @[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"];
//
//    WSSelectTimeView * selectTime  = [[WSSelectTimeView alloc]init];
//    selectTime.frame = CGRectMake(20, 10, 150, 40);
//    selectTime.style = WSSelectTimeViewStyleYMD;
//    selectTime.delegate = self;
//     selectTime.selectTime = [NSDate dateWithTimeIntervalSinceNow:0];
//    [dateView addSubview:selectTime];
//
////    UILabel * shipLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.width *0.3 + 10, 20, 300, 40)];
////    shipLabel.text = @"提示: 橙色虚线为实际路线,蓝色为计划路线。";
////    shipLabel.textColor = [UIColor grayColor];
////    shipLabel.font = [UIFont systemFontOfSize:13];
////    [dateView addSubview:shipLabel];
//
//    WSMapShipView * shipView = [[WSMapShipView alloc]initWithFrame:CGRectMake(200, 10, 600, 40)];
//    [dateView addSubview:shipView];
//
//    self.m_HUD = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:self.m_HUD];
//    mapview = [[WSMapView alloc] initWithFrame:CGRectMake(10, k_TitleView_Hight, self.view.width - 20 - 200, self.view.height - 2*k_TitleView_Hight ) routePlanStores:nil isOrder:YES];
//    [self.view addSubview:mapview];
//    _model = [[WSMyJPJCollectionModel alloc]init];
//    [self getCallPlanDateFromWebWith:[NSDate dateWithTimeIntervalSinceNow:0]];
//
//    _leftTableView = [[UITableView alloc]initWithFrame:CGRectMake(10, k_TitleView_Hight, self.view.width *0.3  - 20, self.view.height - 2*k_TitleView_Hight)];
//    _leftTableView.sectionHeaderHeight = k_TitleView_Hight;
//    _leftTableView.delegate = self;
//    _leftTableView.dataSource = self;
//    _leftTableView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
//    [self.view addSubview:_leftTableView];
//
//    UIBarButtonItem * allScreen = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"fullscreen_btn@2x"] style:UIBarButtonItemStylePlain target:self action:@selector(allScreen)];
//    self.navigationItem.rightBarButtonItem = allScreen;
//}
//-(void)allScreen{
//    [mapview removeFromSuperview];
//    UIWindow * window = [UIApplication sharedApplication].keyWindow;
//
//   __block UIButton * exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    exitButton.frame = CGRectMake(mapview.bounds.size.width - 100, 20, 100, 60);
//    [UIView animateWithDuration:0.5 animations:^{
//
//        bgView = [[UIView alloc]initWithFrame:window.bounds];
//        bgView.backgroundColor = [UIColor whiteColor];
//        [window addSubview:bgView];
//
//        mapview.frame = CGRectMake(0, 20, window.bounds.size.width, window.bounds.size.height - 20 );
//        [window addSubview:mapview];
//
//    } completion:^(BOOL finished) {
//        exitButton.frame = CGRectMake(mapview.bounds.size.width - 100, 20, 100, 60);
//        exitButton.backgroundColor = [UIColor blackColor];
//        exitButton.alpha = 0.6;
//        [exitButton setTitle:NSLocalizedString(@"exit_full_screen", nil) forState:UIControlStateNormal];
//        [exitButton addTarget:self action:@selector(exitAllScreen:) forControlEvents:UIControlEventTouchUpInside];
//        [window addSubview:exitButton];
//    }];
//}
//
//-(void)exitAllScreen:(UIButton *)sender{
//    [UIView animateWithDuration:0.5 animations:^{
//        mapview.frame = CGRectMake(10, k_TitleView_Hight, self.view.width - 20, self.view.height - k_TitleView_Hight );
//        [mapview removeFromSuperview];
//        [sender removeFromSuperview];
//        [bgView removeFromSuperview];
//        [self.view addSubview:mapview];
//        [self.view bringSubviewToFront:_leftTableView];
//    } completion:^(BOOL finished) {
//        //
//    }];
//
//}
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static  NSString * reuserID = @"tableViewReuserID";
//    WSMyJPJTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuserID];
//    if (cell == nil) {
//        cell = [[WSMyJPJTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserID withStyle:@"planOrder"];
//    }
////    cell.storeDict = _model.visitPlanStoreArray[indexPath.row];
//     cell.storeBean = _model.visitPlanStoreArray[indexPath.row];
//
////    cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
//    cell.backgroundColor = [UIColor clearColor];
//    return cell;
//}
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return _model.visitPlanStoreArray.count;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 60;
//
//}

//
//
//-(void)selectTimeViewValueChanged:(NSDate *)date{
//    // 更新数据
//    [self getCallPlanDateFromWebWith:date];
//}


//
//-(NSMutableArray *)DuplicateRemoval:(NSArray *)array{ // 数组去重
//
//    NSMutableDictionary  *dict = [NSMutableDictionary dictionary];
//    for (NSDictionary * object in array) {
//        [dict setObject:object forKey:object[@"id"]];
//    }
//    NSMutableArray * planArray = [NSMutableArray arrayWithCapacity:0];
//    NSArray * allkeys = [dict allKeys];
//    for (NSString  *str in allkeys) {
//        [planArray addObject:[dict objectForKey:str]];
//    }
//
//    return planArray;
//}
@end
