//
//  WSMyPJPViewController.m
//  WinSFA
//
//  Created by zhiqing on 16/8/15.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSMyPJPViewController.h"
#import "WSMyJPJCollectionViewCell.h"
#import "WSMyJPJCollectionModel.h"
#import "WSSelectTimeView.h"
#import "WSRequestHelper.h"
#import "WSFuncsBeanArray.h"
#import "WSShipView.h"

#import "WSMyJPJMapViewController.h"
#define k_TitleView_Hight 60
#define kLeftVieWidth 200.0f

@interface WSMyPJPViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,WSSelectTimeViewDelegate>

{
    UIView * dateView;
    UICollectionView * _collectionView;
    UIButton * leftBtn;
    UIButton * rightBtn;
    UIButton * jumpToMap;
    NSInteger index;
    UIButton * _leftRefresh;
    UIButton * _rightRefresh;
}
@property(nonatomic,strong) NSCalendar * calendar;
@property(nonatomic,strong) NSArray *weekArray;
@property(nonatomic,strong) NSArray *weekDataArray; // 每次装的5个数据模型
@property(nonatomic,strong) NSDate *currentDate;
@property(nonatomic,strong) WSSelectTimeView *mounthBtn; // 选择月份的
@property(nonatomic,copy) NSString *lastMounth;
@property (nonatomic,strong) MBProgressHUD* m_HUD;

@end

@implementation WSMyPJPViewController

-(id)initWithFuncs:(WSFuncsBean *)funcs{
    
    if(funcs == nil)
        return nil;
    
    self = [super init];
    if(self)
    {
        self.currentFuncs = funcs;
        self.title = funcs.name;
        WSFuncsBeanArray* fbArray = [WSAppData getObjectbyKey:FUNCS];
        WSFuncsBean* subMenuFB = [fbArray getFuncsBeanWithFC:funcs.submenu];
        
        self.prepareFuncBean = subMenuFB;
        
        return self;
        
    }
    return nil;


}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = nil;
    dateView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, k_TitleView_Hight)];
    [self.view addSubview:dateView];
    
    leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 12, 40,37)];
    [leftBtn addTarget:self action:@selector(refreshCollectionViewData:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *leftImage = [UIImage imageNamed:@"icon_rili_black"];
    leftImage = [leftImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    leftBtn.tintColor = MAIN_TINT_COLOR;
    
    [leftBtn setBackgroundImage:leftImage forState:UIControlStateNormal];
    _mounthBtn = [[WSSelectTimeView alloc]init];
    _mounthBtn.frame = CGRectMake(leftBtn.right - 1, 10, 150, 45);
    _mounthBtn.style = WSSelectTimeViewStyleYM;
//    _mounthBtn.selectTime = [NSDate dateWithTimeIntervalSinceNow:0];
    _mounthBtn.delegate = self;
    
    rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(_mounthBtn.right -1, 12, 40,37)];
    [rightBtn addTarget:self action:@selector(refreshCollectionViewData:) forControlEvents:UIControlEventTouchUpInside];

    UIImage *rightImage = [UIImage imageNamed:@"icon_rili_next"];
    rightImage = [rightImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    rightBtn.tintColor = MAIN_TINT_COLOR;
    
    [rightBtn setBackgroundImage:rightImage forState:UIControlStateNormal];
    
    WSShipView * shipview = [[WSShipView alloc]initWithFrame:CGRectMake(rightBtn.right +100,18 , 300, 40)];
    
    jumpToMap = [[UIButton alloc]initWithFrame:CGRectMake(shipview.right, 12, 100, 30)];
    [jumpToMap addTarget:self action:@selector(junmToMapView) forControlEvents:UIControlEventTouchUpInside];
    [jumpToMap setTitle:@"地图模式" forState:UIControlStateNormal];
    [jumpToMap setTitleColor:MAIN_TINT_COLOT forState:UIControlStateNormal];
    jumpToMap.titleLabel.font = [UIFont systemFontOfSize:15];
    jumpToMap.layer.cornerRadius = 8;
    jumpToMap.layer.borderColor = MAIN_TINT_COLOT.CGColor;
    jumpToMap.layer.borderWidth = 1;
    
    [dateView addSubview:leftBtn];
    [dateView addSubview:_mounthBtn];
    [dateView addSubview:rightBtn];
    [dateView addSubview:shipview];
    [dateView addSubview:jumpToMap];
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, k_TitleView_Hight, self.view.width , SCREEN_HEIGHT - k_TitleView_Hight) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[WSMyJPJCollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;

    self.m_HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.m_HUD];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"dismiss" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.weekArray = @[@"周一",@"周二",@"周三",@"周四",@"周五"];

    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [self.calendar setLocale:[NSLocale currentLocale]];
    [self.calendar setFirstWeekday:2];
    
    self.ownParentViewController.navigationItem.rightBarButtonItem = nil;
    self.ownParentViewController.navigationItem.rightBarButtonItems = nil;
    
    _leftRefresh = [[UIButton alloc]initWithFrame:CGRectMake(_collectionView.left, self.view.centerY - 100, 25, 50)];
    [_leftRefresh addTarget:self action:@selector(refreshCollectionViewData:) forControlEvents:UIControlEventTouchUpInside];
    [_leftRefresh setBackgroundImage:[UIImage imageNamed:@"zuo"] forState:UIControlStateNormal];
    _rightRefresh = [[UIButton alloc]initWithFrame:CGRectMake(self.view.right - 255, self.view.centerY - 100, 25, 50)];
    [_rightRefresh addTarget:self action:@selector(refreshCollectionViewData:) forControlEvents:UIControlEventTouchUpInside];
    [_rightRefresh setBackgroundImage:[UIImage imageNamed:@"you"] forState:UIControlStateNormal];
    [self.view addSubview:_leftRefresh];
    [self.view addSubview:_rightRefresh];

    
}

-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
    
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter * formatter = [NSDateFormatter standardDateFormatter];
    
    [formatter setDateFormat:@"yyyy-MM"];
    _lastMounth = [formatter stringFromDate:date];
    _mounthBtn.selectTime = date;
    [self getDataWith:date];

}

-(void)getDataWith:(NSDate *)date{
    
    self.currentDate = date;
    self.weekDataArray =  [self getWeekOfFirstDayWithDate:date];
    [self getCallPlanDateFromWebWith:0 toIndex:4];
    
}
// 获取传入日期当前周的数组
-(NSArray *)getWeekOfFirstDayWithDate:(NSDate *)date{
    
    NSInteger dateWeekNum = [self.calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:date];
    NSTimeInterval nowTime = [date timeIntervalSince1970]; // date的时间戳
    NSDate *needTimeDate = [NSDate dateWithTimeIntervalSince1970:nowTime - (dateWeekNum - 1)* 24*60*60]; // 根据传入的时间 该周 计算周日的时间
    
    
    NSMutableArray * tempArray = [NSMutableArray arrayWithCapacity:5];
    for (NSInteger i = 0; i < 5; i++) {
        WSMyJPJCollectionModel * model = [[WSMyJPJCollectionModel alloc]init];
        NSDate * tempDate = [needTimeDate dateByAddingTimeInterval:i * 24 * 60 * 60];
        if ([self.currentDate.description isEqualToString:tempDate.description]) {
//            model.isSelected = YES;
        }
        model.week = self.weekArray[i];
        model.day = tempDate;
        [tempArray addObject:model];
    }
    return tempArray;
}

-(void)refreshCollectionViewData:(id)sender{
    if (sender == _leftRefresh || sender == _rightRefresh)
    {

        if (sender == _leftRefresh) {
            [self getlastWeekData];
        }
        
        if (sender == _rightRefresh) {
            [self getNextWeekData];
        }
        // 滑动换月份时更新月份选择器时间
        WSMyJPJCollectionModel * model =  self.weekDataArray[0];
        NSDate * lastDate = model.day;
        NSDateFormatter * formatter = [NSDateFormatter standardDateFormatter];
        [formatter setDateFormat:@"yyyy-MM"];
        NSString * currentMounth = [formatter stringFromDate:lastDate];
        if (![_lastMounth isEqualToString:currentMounth]) {
            _lastMounth = currentMounth;
            _mounthBtn.selectTime = lastDate;
        }
        
        
    }else if ([sender isKindOfClass:[UIButton class]]){
       
        [self getlastMounthData:sender];
  
    }
}

// 获取下周的数据
-(void)getNextWeekData{
    WSMyJPJCollectionModel * model =  self.weekDataArray[4];
    NSDate * lastDate = model.day;
    self.weekDataArray = [self getWeekOfFirstDayWithDate:[lastDate dateByAddingTimeInterval:3 *24 *60*60]];
//    [_collectionView reloadData];
    [self getCallPlanDateFromWebWith:0 toIndex:4];
}
// 获取上周的数据
-(void)getlastWeekData{
    WSMyJPJCollectionModel * model =  self.weekDataArray[0];
    NSDate * lastDate = model.day;
    self.weekDataArray = [self getWeekOfFirstDayWithDate:[lastDate dateByAddingTimeInterval:-3 *24 *60*60]];
//    [_collectionView reloadData];
    [self getCallPlanDateFromWebWith:0 toIndex:4];
}

// 上个月 或下个月第一周的数据
-(void)getlastMounthData:(id)sender{
    // 获取月初的第一个星期一  去刷新数据
    WSMyJPJCollectionModel * model =  self.weekDataArray[0];
    NSDate * lastDate = model.day;
    double interval = 0;
    NSDate *beginDate = nil; // 当前页面该月的开始时间
    NSDate *endDate = nil;   // 当前页面该月的结束时间
    
    BOOL ok = [self.calendar rangeOfUnit:NSMonthCalendarUnit startDate:&beginDate interval:&interval forDate:lastDate];
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }
    
    // 获取上个月的开始时间
    NSDate * lastOrNextMounthDate ;
    NSDate *lastOrNextBeginDate = nil;
     double lastInterval = 0;
    
    if (sender == leftBtn) {
        lastOrNextMounthDate  = [NSDate dateWithTimeIntervalSince1970:[beginDate timeIntervalSince1970] - 24*60*60];
        
    }else if (sender == rightBtn){
        lastOrNextMounthDate  = [NSDate dateWithTimeIntervalSince1970:[endDate timeIntervalSince1970] + 24*60*60];
    }
    [self.calendar rangeOfUnit:NSMonthCalendarUnit startDate:&lastOrNextBeginDate interval:&lastInterval forDate:lastOrNextMounthDate];
 
    NSInteger beginWeekNum = [self.calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:lastOrNextBeginDate];
    
    for (int i = 0; i< 7; i++) {
        if (beginWeekNum == 1) {
            // 上个月的第一周是周一的date
           self.weekDataArray = [self getWeekOfFirstDayWithDate:lastOrNextBeginDate];
            WSMyJPJCollectionModel * model =  self.weekDataArray[0];
            _mounthBtn.selectTime = model.day;
            [self getCallPlanDateFromWebWith:0 toIndex:4];
            return;
        }else{
            NSTimeInterval  time = [lastOrNextBeginDate timeIntervalSince1970];
            lastOrNextBeginDate = [NSDate dateWithTimeIntervalSince1970:time  +24*60*60];
            beginWeekNum = [self.calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:lastOrNextBeginDate];
        }
    }
}

-(void)getCallPlanDateFromWebWith:(NSInteger)indexs toIndex:(NSInteger)toIndex{
    if (self.m_HUD) {
        [self.m_HUD removeFromSuperview];
        self.m_HUD = nil;
        self.m_HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.m_HUD];
    }
    self.m_HUD.labelText = NSLocalizedString(@"please_wait",nil);
    [self.m_HUD show:YES];
    index = indexs;
        WSMyJPJCollectionModel * model =  self.weekDataArray[index];
        WSMyJPJCollectionModel * tomodel =  self.weekDataArray[toIndex];

        NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSMutableDictionary*willPostDic=[[NSMutableDictionary alloc]init];
    
//        [willPostDic setObject:[dateFormat stringFromDate:model.day] forKey:@"docDate"];
        [willPostDic setObject:[dateFormat stringFromDate:model.day] forKey:@"from"];
        [willPostDic setObject:[dateFormat stringFromDate:tomodel.day] forKey:@"to"];

        [willPostDic setObject:@"callPlan" forKey:@"objId"];
//    NSLog(@"######%@",[willPostDic JSONString]);
        //点击搜索按钮开始发送请求
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(requestHaveBeenDone:) name:@"roadManagerRequest" object:nil];
        [[WSRequestHelper shareInstance] postRequestOnRoadsManager:willPostDic notifyName:@"roadManagerRequest"];

}
//请求完数据后 该方法将被调用
-(void)requestHaveBeenDone:(NSNotification*)notification{
    
    
     [[NSNotificationCenter defaultCenter]removeObserver:self name:@"roadManagerRequest" object:nil];
     [self.m_HUD hide:YES];
     
     NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
     [dateFormat setDateFormat:@"yyyy-MM-dd"];
     if(![notification.object isKindOfClass:[NSError class]])
     {
         NSDictionary* requestData=[[notification object] objectFromJSONString];
         
         NSArray* array=[requestData objectForKey:@"callPlan"];
         WSMyJPJCollectionModel * day0Model =  self.weekDataArray[0];
         WSMyJPJCollectionModel * day1Model =  self.weekDataArray[1];
         WSMyJPJCollectionModel * day2Model =  self.weekDataArray[2];
         WSMyJPJCollectionModel * day3Model =  self.weekDataArray[3];
         WSMyJPJCollectionModel * day4Model =  self.weekDataArray[4];
         
         for (NSDictionary * dict in array) {
         
             if ([dict[@"docDate"] isEqualToString:[dateFormat stringFromDate:day0Model.day]]) {
             [day0Model.visitPlanStoreArray addObject:dict];
             }
             if ([dict[@"docDate"] isEqualToString:[dateFormat stringFromDate:day1Model.day]]) {
             [day1Model.visitPlanStoreArray addObject:dict];
             }
             if ([dict[@"docDate"] isEqualToString:[dateFormat stringFromDate:day2Model.day]]) {
             [day2Model.visitPlanStoreArray addObject:dict];
             }
             if ([dict[@"docDate"] isEqualToString:[dateFormat stringFromDate:day3Model.day]]) {
             [day3Model.visitPlanStoreArray addObject:dict];
             }
             if ([dict[@"docDate"] isEqualToString:[dateFormat stringFromDate:day4Model.day]]) {
             [day4Model.visitPlanStoreArray addObject:dict];
             }
         }
         [_collectionView reloadData];
     
     }else{
         NSString *title = NSLocalizedString(@"connect_timeout", nil);
         [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
     }
 
    
}
-(void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * reuserId = @"UICollectionViewCell";
    WSMyJPJCollectionViewCell * cell  =[collectionView dequeueReusableCellWithReuseIdentifier:reuserId forIndexPath:indexPath];
    cell.model = self.weekDataArray[indexPath.row];
    return cell;

}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.weekDataArray.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return  CGSizeMake(self.view.width / 5, SCREEN_HEIGHT - k_TitleView_Hight);
}


-(void)junmToMapView{
    
    WSMyJPJMapViewController * controller = [[WSMyJPJMapViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];

}

#pragma mark - WSSelectTimeViewDelegate

- (void)selectTimeViewValueChanged:(NSDate *)date
{
    [self getDataWith:date];
}
@end
