//
//  OTCSubempLISTViewController.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-7-2.
//
//

#define Notification_Query @"OTCSubempLISTViewController_query"

#import "OTCSubempLISTViewController.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+TapAction.h"
#import "OTCFollowUpVisitStoreListViewController.h"
#import "WSFuncsBean.h"
#import "WSOutPlanStoreBean.h"
#import "WSAppDelegate.h"
#import "WSVisitStoreActionTable.h"

@interface OTCSubempLISTViewController ()


/*  Zheng Jiepeng - 2013/07/02
 *  辉瑞零售（OTC）项目
 *  filter 中解释出来的配置项
 *  range:          为数据源节点
 *  followupvisit:  为请求时的objId
 */
@property (nonatomic, copy) NSString *range;
@property (nonatomic, copy) NSString *query;
@property (nonatomic, strong) NSArray *searchResultArray;

@property (nonatomic, strong) WSSubempstoreBean *currentSubempBean;

@end

@implementation OTCSubempLISTViewController

@synthesize searchBar = _searchBar;
@synthesize range = _range;
@synthesize query = _query;


- (void)initDataArray {
    /*  Zheng Jiepeng - 2013/07/02
     *  辉瑞零售（OTC）项目
     *  重写父类的 initDataArray
     *  数据源为 filter 中可配
     */
    /*
     NSString *filter = self.currentFuncs.filter;
     */
    /*  Zheng Jiepeng - 2013/07/02
     *  辉瑞零售（OTC）项目 
     *  此处 filter 中传回来的字符串包含了多个配置项
     *  格式为 NSDictionary 的描述
     *  需要对 filter 进行解析
     */
    /*

    NSDictionary *filterDic = [filter propertyListFromStringsFileFormat];
    
    self.range = [filterDic objectForKey:@"range"];
    self.query = [filterDic objectForKey:@"query"];
    
    WSSubempstoreBeanArray *subBeanArr = [WSAppData getObjectbyKey:_range];
    [self.dataArray addObjectsFromArray:subBeanArr.subempstoreArray];
     */
    /*
     最新主管协防取数据逻辑,优先取funcs节点的数据
     结果清单数据 用下一级funcs的ds值 （作为请求参数）
     */
//    WSFuncsBean *resultListFuncsBean = [self.currentFuncs.funcsArray objectAtIndex:0];
//    self.query = resultListFuncsBean.filter;
    //    SFA-16299
    //    【辉瑞医院】经理随访模块点击人进去请求的节点不对，跟配置的节点不一致
    NSString *filter = self.currentFuncs.filter;
    NSDictionary *filterDic = [filter objectFromJSONString];
    self.query = [filterDic objectForKey:@"query"];
    if (!self.query) {
        self.query = @"allplanstoreontime";
    }
    
    NSString *keyStr = self.currentFuncs.ds;
    if (!keyStr) {
        keyStr = @"subempstore";
        WSSubempstoreBeanArray *subBeanArr = [WSAppData getObjectbyKey:keyStr];
        if (subBeanArr && subBeanArr.subempstoreArray) {
            [self.dataArray addObjectsFromArray:subBeanArr.subempstoreArray];
        }
        
        keyStr = @"subempstore1";
        subBeanArr = [WSAppData getObjectbyKey:keyStr];
        if (subBeanArr && subBeanArr.subempstoreArray) {
            [self.dataArray addObjectsFromArray:subBeanArr.subempstoreArray];
        }
        
    }else {
        WSSubempstoreBeanArray *subBeanArr = [WSAppData getObjectbyKey:self.currentFuncs.ds];
        [self.dataArray addObjectsFromArray:subBeanArr.subempstoreArray];
    }
    
    
    self.filterArray = [NSMutableArray arrayWithArray:self.dataArray];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.myTableView) {
        return [self.filterArray count];
    }
    WSSubempstoreBeanArray *subBeanArr = [WSAppData getObjectbyKey:_range];
    NSArray *all = [NSArray arrayWithArray:subBeanArr.subempstoreArray];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[cd] %@",self.searchBar.searchBar.text];
    NSArray *fiterArray = [all filteredArrayUsingPredicate:predicate];
    self.searchResultArray = [NSMutableArray arrayWithArray:fiterArray];
    return [self.searchResultArray count];
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
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    WSSubempstoreBean *subBean = nil;
    if (tableView == self.myTableView) {
        subBean =[self.filterArray objectAtIndex:indexPath.row];
    }else {
        subBean =[self.searchResultArray objectAtIndex:indexPath.row];
    }
    
    if (subBean.name) {
        cell.textLabel.text = subBean.name;
    }
    else if(subBean.orgCode)
    {
        cell.textLabel.text = subBean.orgCode;
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:UI_Font];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*  Zheng Jiepeng - 2013/07/02
     *  辉瑞零售（OTC）项目
     *  重写父类的 tableView:didSelectRowAtIndexPath:
     *  点击时，发送实时请求数据
     */
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*  Zheng Jiepeng - 2013/07/02
     *  辉瑞零售（OTC）项目
     *  构造一个请求的 NSDictionary
     *  参数包含: empId, objId
     */
    WSSubempstoreBean *subempBean = nil;
    if (tableView == self.myTableView) {
        subempBean = [self.filterArray objectAtIndex:[indexPath row]];
    }
    else
    {
        subempBean = [self.searchResultArray objectAtIndex:[indexPath row]];
    }
    
    _currentSubempBean = subempBean;
    // SFA-16398  辉瑞医院节点查询方式更换，其他项目用的时候 增加storeId 参数。 storeid  当前登录人id 节点名称
//    NSArray *keysArray = [NSArray arrayWithObjects:@"empId", @"objId", nil];
//    NSArray *objectsArray = [NSArray arrayWithObjects:subempBean.Id, self.query, nil];
    NSArray *keysArray = [NSArray arrayWithObjects:@"storeId", @"objId",@"empId",nil];
    NSArray *objectsArray = [NSArray arrayWithObjects:subempBean.Id, self.query, [WSAppData getObjectbyKey:APPDATA_EMPID],nil];
    NSDictionary *aDic = [NSDictionary dictionaryWithObjects:objectsArray forKeys:keysArray];
    
    /*  Zheng Jiepeng - 2013/07/02
     *  辉瑞零售（OTC）项目
     *  添加 Notification
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishRequest:) name:Notification_Query object:nil];
    /*  Zheng Jiepeng - 2013/07/02
     *  辉瑞零售（OTC）项目
     *  发送请求
     */
    [[WSRequestHelper shareInstance] postRequestData:aDic notifyName:Notification_Query];
    
    NSString *text = NSLocalizedString(@"数据请求中...", nil);
    NSString *tips = NSLocalizedString(@"please_wait", nil);
    [MBProgressHUD showHUDAddedTo:self.view withText:text tips:tips tapTarget:self action:nil];
}

- (void)finishRequest:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notification_Query object:nil];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    

    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *dic = [info objectFromJSONString];
    NSArray *stores = [dic objectForKey:self.query]; //@"followupvisit"
    /*  Zheng Jiepeng - 2013/07/02
     *  辉瑞零售（OTC）项目
     *  如果返回 json 串中没有 followupvisit 节点
     *  显示 无匹配结果 (与 Android v2 一致)
     */
    if (!stores) {
        // SFA-18097 默认提示语修改为"该人员目前未进店"，如果有下发该人员的jobTitle则用jobTitle值替换关键词
//        NSString *tip = NSLocalizedString(@"该代表目前未进院", nil);
        NSString *tip = NSLocalizedString(@"该人员目前未进院", nil);
        
        if (_currentSubempBean.jobTitle.length > 0) {
            tip = [NSString stringWithFormat:@"该%@目前未进院", _currentSubempBean.jobTitle];
        }
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    /*  Zheng Jiepeng - 2013/07/02
     *  辉瑞零售（OTC）项目
     *  返回 json 串没有 followupvisit 节点
     *  跳转到 门店列表 OTCFollowUpVisitStoreListViewController
     */
    WSOutPlanStoreBean *storesBean = [[WSOutPlanStoreBean alloc] initWithObject:dic noteName:self.query];
    for (WSStoreBean *bean in storesBean.storesArray) {
        bean.srid = _currentSubempBean.Id;
    }
    WSFuncsBean *fb = [self.currentFuncs.funcsArray firstObject];
    
    NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];

    UIViewController* vc = [[NSClassFromString(className) alloc] initWithFuncs:fb Stores:storesBean.storesArray];
    if (vc == nil)
    {   fb = self.currentFuncs;
        LogInfo(@"className no support :%@", fb.fv);
        vc = [[OTCFollowUpVisitStoreListViewController alloc] initWithFuncs:fb Stores:storesBean.storesArray];
    }
    if ([vc respondsToSelector:@selector(setSubempid:)]) {
        [vc performSelector:@selector(setSubempid:) withObject:_currentSubempBean.Id];
    }
    
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    action.store_id = _currentSubempBean.Id;
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
    action.ID = (int)[[WSVisitStoreActionTable sharedTable] queryActionId:action];
    vc.currentVisitAction = action;
    
    LogInfo(@"Going to class name: %@", [vc className]);
    if (self.ownParentViewController) {
        [self.ownParentViewController.navigationController pushViewController:vc animated:YES];
    } else {
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
