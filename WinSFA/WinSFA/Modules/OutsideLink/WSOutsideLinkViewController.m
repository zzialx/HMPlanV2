//
//  WSOutsideLinkViewController.m
//  WinSFA
//
//  Created by huzepei on 16/7/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSOutsideLinkViewController.h"
#import "PureLayout.h"
#import "WSOutlinkCell.h"
#import "YYModel.h"
#import "WSOutlinkModel.h"

#import "WSBaseFunsTable.h"

#define TITLEBTNCOLOR  [UIColor colorWithRed:112.0/255.0 green:112.0/255.0 blue:112.0/255.0 alpha:1]
#define CELLHEIGHT 95

@interface WSOutsideLinkViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSArray *linkArr;

@end

@implementation WSOutsideLinkViewController


#pragma mark - view cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initViews];
    
    [_tableView registerClass:[WSOutlinkCell class] forCellReuseIdentifier:NSStringFromClass([WSOutlinkCell class])];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.currentFuncs.funcsArray.count];
    for (WSFuncsBean *funcBean in self.currentFuncs.funcsArray) {
        WSOutlinkModel *om = [[WSOutlinkModel alloc] init];
        om.imageStr = [WSHttpURLHelper getImageCompleteURL:funcBean.icon];
        om.titleName = funcBean.name;
        om.outlink = funcBean.filter;
        [array addObject:om];
    }
    
    self.linkArr = array;
    
    self.tableView.tableFooterView=[[UIView alloc]init];
    
}
-(void)initViews
{
    UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    titleBtn.backgroundColor = TITLEBTNCOLOR;
    [titleBtn setTitle:@"友情链接" forState:UIControlStateNormal];
    [titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:titleBtn];
    
    ALEdgeInsets defInsets = ALEdgeInsetsMake(0.0,0.0,0.0,0.0);
    [titleBtn autoSetDimension:ALDimensionHeight toSize:58];
    [titleBtn autoPinEdgesToSuperviewEdgesWithInsets:defInsets excludingEdge:ALEdgeBottom];
    
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [_tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleBtn];
    [_tableView autoPinEdgesToSuperviewEdgesWithInsets:defInsets excludingEdge:ALEdgeTop];
    
}
#pragma mark - tableView delegate dataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSOutlinkCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WSOutlinkCell class]) forIndexPath:indexPath];
    
    cell.om = self.linkArr[indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELLHEIGHT;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.linkArr.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSOutlinkModel *om = self.linkArr[indexPath.row];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:om.outlink]];
}
@end
