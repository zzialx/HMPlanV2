//
//  OTCManagerSubempLISTViewController.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-7-3.
//
//

#import "OTCManagerSubempLISTViewController.h"
#import "WSSubempstoreBean.h"
#import "WSAppData.h"
#import "WSVisitStoreActionTable.h"
#import "WSAcvtListViewController.h"
//#import "PropertyManager.h"
#import "WSAcvtViewController.h"
#import "WSPlistHelper.h"
#import "WSAppDelegate.h"
#import "WSNewAddListViewController.h"
#import "WSSpecialAcvtViewController.h"
#import "WSNewStoreListViewController.h"
#import "WSSearchBar.h"
#import "WSBaseAcvtDBService.h"

@interface OTCManagerSubempLISTViewController ()

/*  UITableView 搜索框
 */
//@property (nonatomic, strong) WSSearchBar *searchBar;

@end

@implementation OTCManagerSubempLISTViewController

-(void)reloadArray
{
    [self.dataArray removeAllObjects];
    
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
    
    
    WSSubempstoreBeanArray *subBeanArr;
    NSString *filterKey = self.currentFuncs.filter;
    if (!filterKey) {
        filterKey = SUBEMPSTORES;
    }
    subBeanArr = [WSAppData getObjectbyKey:filterKey];
    
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
    
    self.filterArray = [NSMutableArray arrayWithArray:self.dataArray];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDataArray];
    
    WSSearchBar *searchBar = [[WSSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0) isResetTextField:NO isResetBackgroundColor:NO isTop:NO isNotAutoresizingFlexible:YES];
    self.searchBar = searchBar;
    self.searchBar.searchBar.delegate = self;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    if(INTERFACE_IS_PHONE){
        headerView.backgroundColor = MAIN_SEARCH_BG_COLOR;
    }
    [headerView  addSubview:self.searchBar];
    
    // SFA-7056 与安卓统一逻辑当大于20条的时候显示搜索框，否则不显示。
    if (self.filterArray.count > 20) {
        self.myTableView.tableHeaderView = headerView;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.myTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filterArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *pushVC = nil;
    
    WSFuncsBean *fb = [self.currentFuncs.funcsArray objectAtIndex:0];
    WSSubempstoreBean *subempStore = [self.filterArray objectAtIndex:indexPath.row];
    Class aClass=NSClassFromString([WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName]);
    BaseViewController *vc = nil;
    if([aClass instancesRespondToSelector:@selector(initWithFuncs:subempStore:)]){
        vc=[[aClass alloc] initWithFuncs:fb subempStore:subempStore];
    }else{
        vc=[[aClass alloc] initWithFuncs:fb];
        
    }
    if([vc isKindOfClass:[WSSpecialAcvtViewController class]]){
        id object =[self.filterArray objectAtIndex:indexPath.row];
        WSSubempstoreBean *subBean =nil;
        if([object isKindOfClass:[WSSubempstoreBean class]]){
            subBean=object;
        }else{
            subBean =[object objectForKey:@"subEmpStoreBean"];
        }

        [(WSSpecialAcvtViewController*)vc setSubempid:subBean.Id];
    }else if([vc isKindOfClass:[WSNewStoreListViewController class]]){
        
        id object =[self.filterArray objectAtIndex:indexPath.row];
        WSSubempstoreBean *subBean =nil;
        if([object isKindOfClass:[WSSubempstoreBean class]]){
            subBean=object;
        }else{
            subBean =[object objectForKey:@"subEmpStoreBean"];
        }
        
        [(WSNewStoreListViewController*)vc setSubempid:subBean.Id];
        
    }if([vc isKindOfClass:[WSCustomerQueryViewController class]]){
        
        id object =[self.filterArray objectAtIndex:indexPath.row];
        WSSubempstoreBean *subBean =nil;
        if([object isKindOfClass:[WSSubempstoreBean class]]){
            subBean=object;
        }else{
            subBean =[object objectForKey:@"subEmpStoreBean"];
        }
        
        [(WSCustomerQueryViewController*)vc setSubempid:subBean.Id];
        
    }
    
    NSDictionary *dic =[self.filterArray objectAtIndex:indexPath.row];

    if (vc == nil) {
        if([fb.isAcvtList isEqualToString:@"1"]) {
            WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
            NSArray *filtersArray = [baseAcvtDBService queryAcvtsWithStoreId:self.currentStore.Id filter:self.currentFuncs.filter];
            
            WSAcvtBean *l_acvtBean = nil;
            if([filtersArray count] > 0)
                l_acvtBean = [filtersArray objectAtIndex:0];
            vc = [[WSAcvtViewController alloc] initWithAcvt:l_acvtBean Funcs:fb Store:self.currentStore];
        } else {
            vc = [[NSClassFromString([WSPlistHelper valueForKey:fb.ds withPlistName:kControllerMappingFileName]) alloc] initWithFuncs:fb];
            if ([vc isKindOfClass:[WSAcvtListViewController class]]) {
                WSSubempstoreBean *subBean = nil;
                subBean = [dic objectForKey:@"subEmpStoreBean"];
                
                WSAcvtListViewController *listvc = (WSAcvtListViewController *)vc;
                listvc.m_SubempstoreBean = subBean;
            }
        }
    }
    pushVC = vc;
    
    WSSubempstoreBean *subBean =[dic objectForKey:@"subEmpStoreBean"];
    
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    action.store_id = subBean.Id;
    action.func_code = fb.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        
        action.module_fc = self.currentVisitAction.module_fc;
    }else{
    
        action.module_fc = action.func_code;
    }
    action.title = subBean.name;
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    pushVC.currentVisitAction = action;
    pushVC.showActionTip = YES;

    [self.navigationController pushViewController:pushVC animated:YES];
}


- (NSMutableArray *)resultArrayBySearchWord:(NSString *)searchWord
{
    if (searchWord == nil || [searchWord isEqualToString:@""]) {
        if (self.dataArray) {
            return [NSMutableArray arrayWithArray:self.dataArray];
        }
        else
        {
            return nil;
        }
    }
    
    NSMutableArray* array=[NSMutableArray array];
    for(NSDictionary* dic in self.dataArray){
        WSSubempstoreBean *subBean =[dic objectForKey:@"subEmpStoreBean"];
        if([subBean.name rangeOfString:self.searchBar.searchBar.text].location!=NSNotFound){
            [array addObject:dic];
        }
    }
    
    return array;
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    
    for(id cc in [searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
            [btn setTitle:CancelString  forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text=@"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.filterArray = [NSMutableArray arrayWithArray:self.dataArray];
    [self.myTableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.filterArray = [self resultArrayBySearchWord:searchBar.text];
    [self.myTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    self.filterArray = [self resultArrayBySearchWord:searchBar.text];
    [self.myTableView reloadData];
    
}

@end
