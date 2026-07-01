//
//  WSPlanFollowUpListViewController.m
//  WinSFA
//
//  Created by 董宏 on 2020/5/7.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSPlanFollowUpListViewController.h"
#import "WSCalendarFollowUpDataModel.h"
#import "WSRequestHelper.h"
#import "YYModel.h"
#import "WSPlanFollowUpListTableViewCell.h"
#import "WSPlanCalendarManageDataModel.h"


static CGFloat const kPlanFollowUpListCellHeight    = 40;

static NSString * const kPlanFollowUpListCellId     = @"PlanFollowUpListCellId";
static NSString * const kPlanFollowUpListHeaderId    = @"PlanFollowUpListHeaderId";

@interface WSPlanFollowUpListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *selectDS;
@property (nonatomic ,strong) NSMutableArray *arrList;
@property (nonatomic ,strong) WSCalendarFollowUpDataInfoModel *selectModel;



@end


@implementation WSPlanFollowUpListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addControls];
    
}
- (void)loadData
{
    self.arrList = [NSMutableArray arrayWithCapacity:0];
    if(self.followUpDataListModel.getLeaderList)
    {
        self.title = @"随访主管";
        for (WSCalendarFollowUpDataInfoModel *model in self.followUpDataListModel.getLeaderList) {
            NSInteger number = 0;
            for (WSPlanCalendarRouteManageDataInfoModel *infoModel in self.followList) {
                if ([model.Id isEqualToString:infoModel.leaderId]) {
                    number++;
                }
            }
            model.number = number;
            [self.arrList addObject:model];
        }
        self.selectDS = @"getSrList";
    }else if (self.followUpDataListModel.getSrList){
        self.title = @"随访代表";
        for (WSCalendarFollowUpDataInfoModel *model in self.followUpDataListModel.getSrList) {
            NSInteger number = 0;
            for (WSPlanCalendarRouteManageDataInfoModel *infoModel in self.followList) {
                if ([model.Id isEqualToString:infoModel.salesId]) {
                    number++;
                }
            }
            model.number = number;
            [self.arrList addObject:model];
        }
        self.selectDS = @"getSrStoreList";
        
    }else{
        self.title = @"随访";
        for (WSCalendarFollowUpDataInfoModel *model in self.followUpDataListModel.getSrStoreList) {
            NSInteger number = 0;
            for (WSPlanCalendarRouteManageDataInfoModel *infoModel in self.followList) {
                if ([model.Id isEqualToString:infoModel.storeId]) {
                    number++;
                    break;
                }
            }
            model.number = number;
            [self.arrList addObject:model];
        }
    }
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self layoutControls];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
    if (self.tableView) {
        [self.tableView reloadData];
    }
    if(self.followUpDataListModel.getSrStoreList)
    {

        NSMutableArray *barButtonItems = [[NSMutableArray alloc]init];
        UIBarButtonItem *buttonItem = nil;
        buttonItem = [self barButtonItemImage:@"icon_upload" target:self action:@selector(savePlanList)];

        [barButtonItems addObject:buttonItem];
        if (self.ownParentViewController){
            self.ownParentViewController.navigationItem.rightBarButtonItems = barButtonItems;
        }
        else{
            self.navigationItem.rightBarButtonItems = barButtonItems;
        }
    }
    
}
- (void)addControls {
    UITableView *tableView = [[UITableView alloc] init];
    tableView.rowHeight = kPlanFollowUpListCellHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[WSPlanFollowUpListTableViewCell class] forCellReuseIdentifier:kPlanFollowUpListCellId];
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
    return  self.arrList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WSPlanFollowUpListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlanFollowUpListCellId forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    WSCalendarFollowUpDataInfoModel * followUpDataModel = self.arrList[indexPath.row];
    cell.title =followUpDataModel.name;
    cell.numer = [NSString stringWithFormat:@"%ld",followUpDataModel.number];
    if(self.followUpDataListModel.getSrStoreList)
    {
        [cell.setImg setImage:[UIImage imageNamed:@"visit_action_done"]];
        cell.setImg.hidden = YES;
        if([cell.numer integerValue] > 0)
        {
            cell.setImg.hidden = NO;
        }
        cell.numer = @"";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.followUpDataListModel) {
        if(self.followUpDataListModel.getSrStoreList){
            WSCalendarFollowUpDataInfoModel * followUpDataModel = self.arrList[indexPath.row];
            if(followUpDataModel.number > 0)
            {
                followUpDataModel.number = 0;
            }else{
                followUpDataModel.number = 1;
            }
            [self.tableView reloadData];
//            WSPlanFollowUpListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlanFollowUpListCellId forIndexPath:indexPath];
//            cell.setImg.hidden =  !cell.setImg.hidden;
        }else{
            WSCalendarFollowUpDataInfoModel * followUpDataModel = self.arrList[indexPath.row];
            self.selectModel = followUpDataModel;
            [self loadSrList:followUpDataModel];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return kPlanFollowUpListCellHeight;
}



- (void)loadSrList:(WSCalendarFollowUpDataInfoModel*)model{
    [self querying_messageTips];
    NSMutableDictionary*paramDic=[[NSMutableDictionary alloc] init];
    [paramDic setObject:[NSString stringNotNilWithValue:self.selectDS] forKey:@"objId"];
    [paramDic setObject:model.Id forKey:@"pId"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    NSString *notifyID = @"loadFollowUpEmpList";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadSrListFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}

-(void)uploadSrListFinish:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    if(![notification.object isKindOfClass:[NSError class]]){
        NSDictionary *dic = [[notification object] objectFromJSONString];
        if([dic objectForKey:[NSString stringNotNilWithValue:@"getLeaderList"]] || [dic objectForKey:[NSString stringNotNilWithValue:@"getSrList"]] || [dic objectForKey:[NSString stringNotNilWithValue:@"getSrStoreList"]]){
            WSPlanFollowUpListViewController *follow = [[WSPlanFollowUpListViewController alloc] init];
            follow.followUpDataListModel = [WSCalendarFollowUpDataModel yy_modelWithDictionary:dic];
            follow.followList = self.followList;
            if(self.followUpDataListModel.getLeaderList){
                follow.leaderId = self.selectModel.Id;
            }
            if(self.followUpDataListModel.getSrList){
                follow.leaderId = self.leaderId;
                follow.salesId = self.selectModel.Id;
            }
            follow.selecDate = self.selecDate;
            [self.navigationController pushViewController:follow animated:YES];
        }
    }else{
        NSString * title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}
- (void)savePlanList
{
    
    NSMutableArray *arrData = [NSMutableArray arrayWithCapacity:self.arrList.count];
    for (WSCalendarFollowUpDataInfoModel *model in self.arrList) {
        if (model.number > 0) {
            [arrData addObject:model.Id];
        }
    }
    if (arrData.count < 1) {
        [MBProgressHUD showHUDAddedTo:self.view withText:@"请选择随访门店！" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    [self querying_messageTips];
    NSMutableDictionary*paramDic=[[NSMutableDictionary alloc] init];
    [paramDic setObject:[NSString stringNotNilWithValue:@"savePlanList"] forKey:@"objId"];
    [paramDic setObject:[NSString stringNotNilWithValue:self.leaderId] forKey:@"leaderId"];
    [paramDic setObject:[NSString stringNotNilWithValue:self.salesId] forKey:@"salesId"];
    [paramDic setObject:[NSString stringNotNilWithValue:self.selecDate] forKey:@"selectDate"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [paramDic setObject:arrData forKey:@"storeIds"];
    NSString *notifyID = @"savePlanList";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savePlanListFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}
-(void)savePlanListFinish:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    if(![notification.object isKindOfClass:[NSError class]]){
        NSDictionary *dic = [[notification object] objectFromJSONString];
        if(dic && [dic objectForKey:@"savePlanList"] && [[dic objectForKey:@"savePlanList"] isEqualToString:@"1"])
        {
            
//            for (NSUInteger i = 0; i < self.followList.count; i++) {
//                WSPlanCalendarRouteManageDataInfoModel *dataInfoModel  = self.followList[i];
//                if ([dataInfoModel.salesId isEqualToString:self.salesId]) {
//                    [self.followList removeObjectAtIndex:i];
//                    i--;
//                    //                    break;
//                }
//            }
            
            // 逆序遍历
            for (WSPlanCalendarRouteManageDataInfoModel *dataInfoModel in [self.followList reverseObjectEnumerator]) {
                if ([dataInfoModel.salesId isEqualToString:self.salesId]) {
                    [self.followList removeObject:dataInfoModel];

                }
            }
//            for (WSPlanCalendarRouteManageDataInfoModel *dataInfoModel in self.followList) {
//                if ([dataInfoModel.salesId isEqualToString:self.salesId]) {
//                    [self.followList removeObject:dataInfoModel];
////                    break;
//                }
//            }
            for (WSCalendarFollowUpDataInfoModel *model in self.arrList) {
                if(model.number > 0)
                {
                    WSPlanCalendarRouteManageDataInfoModel *dataInfoModel = [[WSPlanCalendarRouteManageDataInfoModel alloc] init];
                    dataInfoModel.salesId = self.salesId;
                    dataInfoModel.leaderId = self.leaderId;
                    dataInfoModel.storeId = model.Id;
                    [self.followList addObject:dataInfoModel];
                }
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            NSString * title = NSLocalizedString(@"refresh_failure", nil);
            [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }
    }else{
        NSString * title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}
@end
