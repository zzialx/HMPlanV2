//
//  WSMyVisitViewController.m
//  WinSFA
//
//  Created by zhiqing on 16/7/28.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSMyVisitViewController.h"
#import "PureLayout.h"
#import "WSCalendarView.h"
#import "WSSelectListNewTableviewCell.h"
#import "WSStoreBean.h"
#import "WSAddVisitPlanPopView.h"
@interface WSMyVisitViewController ()<WSCalendarViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UITableView * _tableView;
    WSCalendarView * _calendarView;
    UILabel * _label;
    UILabel * _operationLabel;
    
    UIView * _addNewVisitPlan;
    
}
@end

@implementation WSMyVisitViewController

-(NSMutableArray *)visitPlanArray{
    if (_visitPlanArray == nil) {
        _visitPlanArray  = [[NSMutableArray alloc]init];
    }
    return _visitPlanArray;
}

-(void)loadView{
    [super loadView];
    _calendarView = [[WSCalendarView alloc]init];
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setEditing:YES animated:YES];
    _label = [[UILabel alloc]init];
    _label.text = @"提示: 只能设置当天之后的工作计划";
    _operationLabel = [[UILabel alloc]init];
    _operationLabel.text = @"提示: 拖动右侧按钮可以设置计划顺序";
    _operationLabel.textColor = [UIColor redColor];
    
    _addNewVisitPlan = [[UIView alloc]init];
    UIView *subview = [[UIView alloc]init];
    
    UITapGestureRecognizer  *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addNewVisitPlan)];
    
     UIImageView * addImageView = [[UIImageView alloc]init];
     addImageView.image = [UIImage imageNamed:@"iocn_add"];
     addImageView.userInteractionEnabled = YES;
     addImageView.contentMode = UIViewContentModeScaleAspectFit;
     UILabel * addLabel = [[UILabel alloc]init];
     addLabel.text = @"new_add";
     addLabel.userInteractionEnabled = YES;
     [subview addSubview:addLabel];
     [subview addSubview:addImageView];
     
     [addImageView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
     [addImageView autoPinEdgeToSuperviewEdge:ALEdgeTop ];
     [addImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom ];
     [addImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:subview withMultiplier:0.4];
     
     [addLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:addImageView withOffset:10];
     [addLabel autoPinEdgeToSuperviewEdge:ALEdgeTop ];
     [addLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom ];
     [addLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:subview withMultiplier:0.4];
    [subview addGestureRecognizer:recognizer];
    [_addNewVisitPlan addSubview:subview];
    
    [subview autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [subview autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [subview autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
    [subview autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10];
    [subview autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:_addNewVisitPlan withMultiplier:0.1];
    
    [self.view addSubview:_calendarView];
    [self.view addSubview:_tableView];
    [self.view addSubview:_label];
    [self.view addSubview:_operationLabel];
    [self.view addSubview:_addNewVisitPlan];
    
    [_calendarView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 0, 0, 0) excludingEdge:ALEdgeBottom];
    [_calendarView autoSetDimension:ALDimensionHeight toSize:60];
    
    [_label autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:30];
    [_label autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [_label autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_calendarView withOffset:20];
    [_label autoSetDimension:ALDimensionHeight toSize:10];
    
    [_operationLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:30];
    [_operationLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [_operationLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_label withOffset:10];
    [_operationLabel autoSetDimension:ALDimensionHeight toSize:10];
    
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:60];
    [_tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_label withOffset:20];
    
    [_addNewVisitPlan autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [_addNewVisitPlan autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [_addNewVisitPlan autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [_addNewVisitPlan autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑拜访计划";
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_up"] style:UIBarButtonItemStylePlain target:self action:@selector(uploadVisitPlan)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    UIBarButtonItem * leftJPJItem = [[UIBarButtonItem alloc]initWithTitle:@"我的JPJ" style:UIBarButtonItemStylePlain target:self action:@selector(jumpToMyJPJ)];
    self.navigationItem.leftBarButtonItems = @[leftItem,leftJPJItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)uploadVisitPlan{
     NSLog(@"uploadVisitPlan");
}

-(void)back{
    NSLog(@"back");
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)jumpToMyJPJ{
    NSLog(@"jumpToMyJPJ");

}

-(void)addNewVisitPlan{
    NSLog(@"addNewVisitPlan");
    UIWindow *wc = [[[UIApplication sharedApplication] windows] firstObject];
    UIView* rootView= wc.rootViewController.view;
    WSAddVisitPlanPopView * visitPlanView = [[WSAddVisitPlanPopView alloc]init];
    visitPlanView.layer.cornerRadius = 8;
    visitPlanView.clipsToBounds = YES;
    visitPlanView.dataSource = self.visitPlanArray;
    [rootView addSubview:visitPlanView];
    [visitPlanView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(80, 266, 100, 80)];
    
}
#define mark - UITableViewDelegate,UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _visitPlanArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * reuserId = @"WSSelectListNewTableviewCell";
    WSSelectListNewTableviewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    if (cell == nil) {
        cell = [[WSSelectListNewTableviewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId withFuncStyle:WSSelectListNewTableviewCellStyleStoreVisitList isStoreInfo:self.currentFuncs.isStoreInfo cellWidth:tableView.width];
    }
    cell.store = _visitPlanArray[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 100;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{

    return UITableViewCellEditingStyleDelete;
}

- (void)tableView :(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [_visitPlanArray removeObject:_visitPlanArray[indexPath.row]];  //删除之前行的数据
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
    
     NSLog(@"删除这一行");
}


-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    // 取出要拖动的模型数据
    WSStoreBean *store = _visitPlanArray[sourceIndexPath.row];    //删除之前行的数据
    [_visitPlanArray removeObject:store];
    // 插入数据到新的位置
    [_visitPlanArray insertObject:store atIndex:destinationIndexPath.row];
}

#pragma mark - WSCalendarViewDelegate
-(void)queryDataFromDBByDate:(NSDate *)date {
    
}

@end
