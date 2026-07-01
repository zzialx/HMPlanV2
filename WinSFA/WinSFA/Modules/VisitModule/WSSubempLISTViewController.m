//
//  SubempLISTViewController.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSubempLISTViewController.h"
#import "WSSubempstoreBeanArray.h"
#import "WSFuncsBean.h"
#import "WSVisitStoreActionTable.h"
#import "GlobalUtil.h"

#define HELPVIST_FUNCS_FC @"TAB_V5003"

@implementation WSSubempLISTViewController
@synthesize myTableView,dataArray;


-(id)initWithFuncs:(WSFuncsBean*)funcs{
    if (funcs==nil) {
        
        return nil;
        
    }
    
    self = [super init];
    if(self != nil)
    {
        NSMutableArray *array=[[NSMutableArray alloc]init];
        self.dataArray=array;
        self.currentFuncs=funcs;
        
        [self initDataArray];
        
        return self;
    }
    return nil;
}
- (void)viewWillAppear:(BOOL)animated
{
    [self clearAllNavBBI];
}
- (void)clearAllNavBBI
{
    [self navBarClearRightBarButtonItems];
    [self navBarClearLeftBarButtonItems];
    [self removeSearchBarFromNavigationTitleView];
}

// SFA-5115 清除右侧按钮，否则会反复出现或者反复添加
- (void)navBarClearRightBarButtonItems
{
    [self getNavigationItem].rightBarButtonItems = nil;
    
}

- (void)navBarClearLeftBarButtonItems
{
    [self getNavigationItem].leftBarButtonItems = nil;
}
- (void)removeSearchBarFromNavigationTitleView
{
    [self getNavigationItem].titleView = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    myTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    myTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    myTableView.backgroundColor = [UIColor whiteColor];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:myTableView];
    //SFA-16776 SFA辉瑞医院--手机端主管协访模块搜索框显示问题 ipad修改
    self.searchBar = [[WSSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-(INTERFACE_IS_PAD ? k_MainkLeftVieWidth : 0), 44) isResetTextField:NO isResetBackgroundColor:YES isTop:NO isNotAutoresizingFlexible:YES];
    self.searchBar.searchBar.delegate = self;
    //self.searchBar.showsCancelButton = YES;

    // MN-328 2018-01-31
    if (self.filterArray.count > [self.currentFuncs.opt.acvtSearch integerValue])
        self.myTableView.tableHeaderView = self.searchBar;
    
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.searchBar.searchBar.placeholder = NSLocalizedString(@"query_label", nil);

    // 如果是主管协防模块 且无人员可协防提示
    if ([self.currentFuncs.fv isEqualToString:HELPVIST_FUNCS_FC] && ([self.dataArray count] == 0 || !self.dataArray)) {
        
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"no_sub_emp", nil) message:nil];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"back_to_main_page", nil) block:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alert show];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:myTableView
                                             selector:@selector(reloadData)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

-(void)initDataArray{
    
    [MultipeerManager sharedManager].delegate=self;
    
    [self reloadArray];
    [myTableView reloadData];
    
}

-(void)reloadArray
{
    [self.dataArray removeAllObjects];
    
    WSSubempstoreBeanArray *subBeanArr;
    NSString *filterKey = self.currentFuncs.ds;
    if (!filterKey) {
        filterKey = SUBEMPSTORES;
    }
    subBeanArr = [WSAppData getObjectbyKey:filterKey];
    
    NSString *enableMultipeer = [[NSUserDefaults standardUserDefaults] objectForKey:ENABLE_MULTIPEER];
    BOOL isEanbleMutipeer = NO;
    if ([enableMultipeer isEqualToString:@"1"]) {
        isEanbleMutipeer = YES;
    }
    
    if (isEanbleMutipeer) {
        NSMutableArray* array=[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"peerArray"]];
        
        NSSortDescriptor* sort=[[NSSortDescriptor alloc] initWithKey:@"online" ascending:NO];
        NSArray* sortArray=[NSArray arrayWithObject:sort];
        [array sortUsingDescriptors:sortArray];
        
        sort=[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        sortArray=[NSArray arrayWithObject:sort];
        [array sortUsingDescriptors:sortArray];
        
        if(array.count>3){
            NSPredicate* pre=[NSPredicate predicateWithFormat:@"online==1"];
            NSArray* onlineArray=[array filteredArrayUsingPredicate:pre];
            if(onlineArray.count>3){
                NSRange range={onlineArray.count,array.count-onlineArray.count};
                [array removeObjectsInRange:range];
            }else{
                NSRange range={3,array.count-3};
                [array removeObjectsInRange:range];
            }
        }
        
        //辉瑞Etrip:去掉空岗的下属，
        for (WSSubempstoreBean *subEmpStoreBean in subBeanArr.subempstoreArray) {
            if (subEmpStoreBean.Id) {
                NSMutableDictionary* dic=[NSMutableDictionary dictionary];
                [dic setObject:subEmpStoreBean forKey:@"subEmpStoreBean"];
                
                for(NSDictionary* peerDic in array){
                    NSString* peerid=[peerDic objectForKey:PEERID];
                    if([subEmpStoreBean.Id isEqualToString:peerid]){
                        [dic setObject:[peerDic objectForKey:@"date"] forKey:@"date"];
                        [dic setObject:[peerDic objectForKey:@"online"] forKey:@"online"];
                    }
                }
                
                [self.dataArray addObject:dic];
            }
        }
    }else {
        //辉瑞Etrip:去掉空岗的下属，
        for (WSSubempstoreBean *subEmpStoreBean in subBeanArr.subempstoreArray) {
            if (subEmpStoreBean.Id) {
                [self.dataArray addObject:subEmpStoreBean];
            }
        }
    }
    
    self.filterArray = [NSMutableArray arrayWithArray:self.dataArray];
    
    if ([self.filterArray count] == 0)
    {
        if (!self.empty)
            [self addEmptyView];
    }
    else
    {
        [self.empty removeFromSuperview];
        self.empty = nil;
    }
}

-(void)reloadMultipeerData
{
    [self reloadArray];
    
    [myTableView reloadData];
    
}




#pragma mark tableViewDelegate

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.filterArray count];
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {  
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier: SimpleTableIdentifier];
    }
    
    WSSubempstoreBean *subBean;
    
    id object =[self.filterArray objectAtIndex:indexPath.row];
    if([object isKindOfClass:[WSSubempstoreBean class]]){
        subBean=object;
        [cell.contentView removeAllSubviews];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (subBean.name) {
            cell.textLabel.text = subBean.name;
        }
        else if(subBean.orgCode)
        {
            cell.textLabel.text = subBean.orgCode;
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:UI_Font];
        cell.detailTextLabel.text = subBean.Id;

    }else{
        subBean =[object objectForKey:@"subEmpStoreBean"];
        
        [cell.contentView removeAllSubviews];
        
        NSString* onlineString=[object objectForKey:@"online"];
        if(onlineString){
            UIView* onlineView=[[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.width- (INTERFACE_IS_PHONE ? 60:120), 15, 14, 14)];
            onlineView.layer.masksToBounds=YES;
            onlineView.layer.cornerRadius=7;
            onlineView.tag=101;
            [cell.contentView addSubview:onlineView];
            
            BOOL online=[onlineString integerValue]>0;
            onlineView.backgroundColor= online?[UIColor greenColor] : [UIColor grayColor];
            
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (subBean.name) {
            cell.textLabel.text = subBean.name;
        }
        else if(subBean.orgCode)
        {
            cell.textLabel.text = subBean.orgCode;
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:UI_Font];
        cell.detailTextLabel.text = subBean.Id;
    }
    
    // TODO 需要重构，着急上线按照以前的方式实现
    if([subBean.imgUrl length] > 0) {
        CGSize textSize = [cell.textLabel.text ws_sizeWithFont:cell.textLabel.font constrainedToHeight:MAIN_CELL_HEIGHT];
        CGSize imgSize = CGSizeMake(20, 20);
        UIImageView *planImageView = [[UIImageView alloc] initWithFrame:CGRectMake(MAIN_CELL_PADDING + textSize.width + MAIN_TEXT_IMG_PADDING, (MAIN_CELL_HEIGHT -  imgSize.height) / 2, imgSize.width, imgSize.height)];
        [cell.contentView addSubview:planImageView];
        
        [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:subBean.imgUrl] imageView:planImageView];
    }
    
    UIView *viewSep = [[UIView alloc] initWithFrame:CGRectMake(0, cell.size.height-1, self.view.bounds.size.width-5, 1)];
    viewSep.backgroundColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0f];
    [cell.contentView addSubview:viewSep];
    
    return cell;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
    WSSubempstoreBean *subBean =nil;
    id object =[self.filterArray objectAtIndex:indexPath.row];
    if([object isKindOfClass:[WSSubempstoreBean class]]){
        subBean=object;
    }else{
        NSDictionary* dic=[self.filterArray objectAtIndex:indexPath.row];
        subBean=[dic objectForKey:@"subEmpStoreBean"];
    }
    
    UIViewController *vc = nil;
//  donghong  SFA-20229 与 安卓逻辑对应 TAB_V5003_LIST 不单独映射 WSPersonnelListTreeController 类  此类是树形结构
    if([self.currentFuncs.fv isEqualToString:@"TAB_V5003_LIST"] )
    {
        WSWorkFlowViewController *workFlow = [[WSWorkFlowViewController alloc] initWithFuncs:self.currentFuncs Store:nil subEmpStore:subBean];
        vc =(BaseViewController *)workFlow;
    }else if ([self.currentFuncs.fv isEqualToString:@"TAB_V5003"] || [self.currentFuncs.funcsArray count] > 1) {
        vc = [[WSManagV_LISTViewController alloc]initWithSubBeans:subBean Funcs:self.currentFuncs];
    }else {
        WSFuncsBean *fb = [self.currentFuncs.funcsArray firstObject];
        NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
        
        vc = [[NSClassFromString(className) alloc] initWithFuncs:fb];
        if (subBean) {
            if ([vc respondsToSelector:@selector(initWithFuncs:subEmpStore:)]) {
                vc = [[NSClassFromString(className) alloc] initWithFuncs:fb subEmpStore:subBean];
            }else if ([vc respondsToSelector:@selector(initWithFuncs:subempStore:)]) {
                vc = [[NSClassFromString(className) alloc] initWithFuncs:fb subempStore:subBean];
            }
        }
        
        if ([vc respondsToSelector:@selector(setSubempid:)]) {
            [vc performSelector:@selector(setSubempid:) withObject:subBean.Id];
        }
    }


     WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
     action.parent_action_id = self.currentVisitAction.ID;
     action.store_id = subBean.Id ? subBean.Id : subBean.orgId;
     action.func_code = self.currentFuncs.fc;
     action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
     action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
     action.title = self.currentFuncs.name;
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        
        action.module_fc = self.currentVisitAction.module_fc;
    }else{
        
        action.module_fc = action.func_code;
    }
     action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
     vc.currentVisitAction = action;
    vc.hidesBottomBarWhenPushed = YES;
    LogInfo(@"Going to class %@", NSStringFromClass([vc class]));
     if (self.ownParentViewController) {
         [self.ownParentViewController.navigationController pushViewController:vc animated:YES];
     } else {
         [self.navigationController pushViewController:vc animated:YES];
     }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0.0f)];
    return headView;
}


#pragma mark UIAlterViewDelegate Methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark  UISearchDisplayDelegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    NSString *searchString = [searchText stringByTrimmingWhitespace];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[cd] %@",searchString];
    //    WSSubempstoreBeanArray *subBeanArr = [WSAppData getObjectbyKey:self.currentFuncs.ds];
    NSArray *fiterArray;
    
    if ([searchString length] == 0) {
        fiterArray = self.dataArray;
    }else {
        fiterArray = [self.dataArray filteredArrayUsingPredicate:predicate];
    }
    
    [self.filterArray removeAllObjects];
    [self.filterArray addObjectsFromArray:fiterArray];
    [self.myTableView reloadData];
}

// 点击cancel Button
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    //    WSSubempstoreBeanArray *subBeanArr = [WSAppData getObjectbyKey:self.currentFuncs.ds];
    //    self.dataArray = subBeanArr.subempstoreArray;
    [self.filterArray removeAllObjects];
    [self.filterArray addObjectsFromArray:self.dataArray];
    [self.myTableView reloadData];
    [searchBar resignFirstResponder];
}

// 点击searchButton
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    for(UIView *cc in [searchBar subviews])
    {
        for (UIView *views in [cc subviews]) {
            if([views isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)views;
                NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
                [btn setTitle:CancelString  forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
                break;
            }
        }
        
    }
    
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    //    searchBar.layer.anchorPoint = CGPointMake(320, searchBar.layer.anchorPoint.y);
//   SFA-16912 SFA辉瑞医院--ipad端主管协访模块搜索框数据显示问题
//    searchBar.text = @" ";
    for(UIView *cc in [searchBar subviews])
    {
        for (UIView *views in [cc subviews]) {
            if([views isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)views;
                NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
                [btn setTitle:CancelString  forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
                break;
            }
        }
        
    }
}
//SFA-16776 SFA辉瑞医院--手机端主管协访模块搜索框显示问题
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if (INTERFACE_IS_PAD && ([GlobalUtil isEmpty:self.searchBar.searchBar.text] || [self.searchBar.searchBar.text isEqualToString:@" "]) )
    {
        self.searchBar.searchBar.text = @"";
        [searchBar setShowsCancelButton:NO animated:YES];
        [searchBar resignFirstResponder];
    }
}
@end
