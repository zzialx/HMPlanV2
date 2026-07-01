//
//  WSPlanRouteListViewController.m
//  WinSFA
//
//  Created by 董宏 on 2020/4/28.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSPlanRouteListViewController.h"
#import "WSRequestHelper.h"
#import "YYModel.h"
#import "WSPlanRouteListTableViewHeaderView.h"
#import "WSPlanRouteListTableViewCell.h"
#import "WSPlanRouteListDataModel.h"
#import "WSPlanCalendarDataModel.h"

static CGFloat const kPlanRouteListCellHeight    = 40;
static CGFloat const kPlanRouteListHeaderHeight    = 50;

static NSString * const kPlanRouteListCellId     = @"PlanRouteListCellId";
static NSString * const kPlanRouteListHeaderId    = @"PlanRouteListHeaderId";

@interface WSPlanRouteListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *selectRouteId;


@end

@implementation WSPlanRouteListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择拜访路线";
    self.selectRouteId = self.selectDataInfoModel.routeId;
    [self addControls];

}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self layoutControls];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableArray *barButtonItems = [[NSMutableArray alloc]init];
    UIBarButtonItem *buttonItem = nil;
    buttonItem = [self barButtonItemImage:@"icon_upload" target:self action:@selector(upLoadRoute)];
        
    [barButtonItems addObject:buttonItem];    
    if (self.ownParentViewController)
    {
        self.ownParentViewController.navigationItem.rightBarButtonItems = barButtonItems;
    }
    else
    {
        self.navigationItem.rightBarButtonItems = barButtonItems;
    }
    
}
- (void)addControls {
    UITableView *tableView = [[UITableView alloc] init];
    tableView.rowHeight = kPlanRouteListCellHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[WSPlanRouteListTableViewCell class] forCellReuseIdentifier:kPlanRouteListCellId];
    [tableView registerClass:[WSPlanRouteListTableViewHeaderView class] forHeaderFooterViewReuseIdentifier:kPlanRouteListHeaderId];
    [tableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}
- (void)layoutControls {
    
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    
    self.tableView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.routeListData.getRouteInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WSPlanRouteListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlanRouteListCellId forIndexPath:indexPath];
    WSPlanRouteListDataInfoModel *dataInfoModel = self.routeListData.getRouteInfo[indexPath.row];
    cell.model = dataInfoModel;
    if (dataInfoModel.routeId == [self.selectRouteId integerValue]) {
        cell.setImg.hidden = NO;
    }else{
        cell.setImg.hidden = YES;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    WSPlanRouteListTableViewHeaderView *headerView = (WSPlanRouteListTableViewHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:kPlanRouteListHeaderId];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kPlanRouteListHeaderHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WSPlanRouteListDataInfoModel *dataInfoModel = self.routeListData.getRouteInfo[indexPath.row];
    self.selectRouteId =[NSString stringWithFormat:@"%ld",dataInfoModel.routeId];
    [self.tableView reloadData];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return kPlanRouteListCellHeight;
}

- (void)upLoadRoute
{
    if (!self.selectRouteId || self.selectRouteId.length < 1) {
        
        [MBProgressHUD showHUDAddedTo:self.view withText:@"请选择路线！" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    [self querying_messageTips];
    NSMutableDictionary*paramDic=[[NSMutableDictionary alloc] init];
    [paramDic setObject:@"saveRouteInfo" forKey:@"objId"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [paramDic setObject:self.selectRouteId forKey:@"routeId"];
    [paramDic setObject:self.routeListData.selectToday forKey:@"selectDate"];
    NSString *notifyID = @"upLoadRoute";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}

-(void)uploadFinish:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    if(![notification.object isKindOfClass:[NSError class]]){
        [MBProgressHUD showHUDAddedTo:self.view withText:@"计划路线设置成功" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        if (self.planRouteListViewCellDelegate && [self.planRouteListViewCellDelegate respondsToSelector:@selector(upLoadRouteCalendar)]){
            [self.planRouteListViewCellDelegate upLoadRouteCalendar];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        NSString * title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}


@end

