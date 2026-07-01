//
//  ManagV_OutPlanViewController.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSManagV_OutPlanViewController.h"
#import "WSStoreInfoViewController.h"
#import "WSFuncsBean_opt.h"
#import "WSSelectListTableViewCell.h"

#import "WSBaseStoreTable.h"

#import "WSBaseStoreOtherDataDBService.h"
#import "WSBaseStoreDBService.h"
#import "WSFuncsBeanFilterLogicService.h"

#define k_TableViewContentWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 210 : (210 * UI_XFactor))

@interface WSManagV_OutPlanViewController ()

@property (nonatomic, strong) NSArray *subempStoreArray;

@end

@implementation WSManagV_OutPlanViewController

@synthesize subempStore;
@synthesize searchResult = _searchResult;
@synthesize filterArray = _filterArray;





-(id)initWithSubBeans:(WSSubempstoreBean*)subBeans Funcs:(WSFuncsBean*)funcs
{
    
    if (subBeans==nil) {
        return nil;
    }
    self = [super init];
    if(self != nil)
    {
        _filterArray = [[NSMutableArray alloc]init];
        
        self.subempStore=subBeans;
        
        self.title=subBeans.name;
        
        self.currentFuncs = funcs;
        
        self.subMenuFuncsBean = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:self.currentFuncs];
        
        self.subMenuFuncsCode = self.subMenuFuncsBean.fc;
    }        
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}



// 搜索框的响应事件
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if( self.m_searchResult == nil) {
        self.m_searchResult = [[NSMutableString alloc]init];
    }
    [self.m_searchResult setString:[searchText stringByTrimmingWhitespace]];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    //    [self startUpdata:nil];
    [self startUpdata:nil];
}

-(void)startUpdata:(WSStoreBean*)store
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchFinished:)
                                                 name:CQ_OUT_NOTIFY
                                               object:nil];
    [self requestMethed:store];
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.hidesWhenStopped = YES;
    [aiv startAnimating];
    [self querying_messageTips];

}

-(void)addNetFinishObserver
{
    
}

-(void)requestMethed:(WSStoreBean*)aStore
{
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    NSMutableDictionary* l_dic = [[NSMutableDictionary alloc]init];
    /*
     [l_dic setObject:self.m_searchResult forKey:CQ_KEYWORD];
     [l_dic setObject:CQ_NOTIFY forKey:NT_NAME];
     [l_dic setObject:self.subempStore.empId forKey:@"empId"];
     */
    
    if (self.subempStore.Id)
    {
        [l_dic setObject:self.subempStore.Id forKey:@"empId"];
    }
    else if (self.subempStore.orgId)
    {
        [l_dic setObject:self.subempStore.orgId forKey:@"orgId"];
    }
    [l_dic setObject:[NSString stringNotNilWithValue:self.m_searchResult] forKey:@"name"];
    [l_dic setObject:@"1" forKey:@"compress"];
    
    NSString *objId = [self getObjIDToStoreList];
    if (self.currentFuncs.filter && [self.currentFuncs.filter length] > 0) {
        objId = self.currentFuncs.filter;
    }
    
    [l_dic setObject:objId forKey:@"objId"];
    [l_dic setObject:CQ_OUT_NOTIFY forKey:NT_NAME];
    if ([self isUploadGeoLocationInfo]) {
        [l_dic setObject:[[NSNumber numberWithDouble:self.locationDescribe.location.coordinate.latitude] stringValue] forKey:GPS_LAT];
        [l_dic setObject:[[NSNumber numberWithDouble:self.locationDescribe.location.coordinate.longitude] stringValue] forKey:GPS_LON];
        [l_dic setObject:self.currentCity.length > 0 ? self.currentCity : @"" forKey:GEONAME];
    }
    
    
    [uploadMgr postVistHelpOutPlanQuery:l_dic];
}

-(void)searchFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CQ_OUT_NOTIFY
                                                  object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    if([self respondsToSelector:@selector(resetOutEmpStoreDataSources:)])
    {
        [self performSelector:@selector(resetOutEmpStoreDataSources:) withObject:[info objectFromJSONString]];
    }
    
    
    BOOL isRealCount = YES;
    if ([self.subempStoreArray count] > 0) {
        WSSubempstoreBean *storeBean = [self.subempStoreArray objectAtIndex:0];
        if ([storeBean.InArr count] > 0) {
            NSDictionary *dic = [storeBean.InArr objectAtIndex:0];
            NSString *numberString = [NSString stringWithValue:[dic objectForKey:@"num"]];
            NSInteger number = [numberString integerValue];
            if (number > 0 && [self.filterArray count] < number) {
                isRealCount = NO;
            }
        }
    }
    
    NSString *tmpString = nil;
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        
        tmpString = NSLocalizedString(@"network_failure",nil);;
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
    else
    {
        NSString *objId = [self getObjIDToStoreList];
        if (self.currentFuncs.filter && [self.currentFuncs.filter length] > 0) {
            objId = self.currentFuncs.filter;
        }
        NSArray *l_stores = [[info objectFromJSONString] objectForKey:objId];
        if (l_stores != nil) {
            if (isRealCount) {
//                tmpString = NSLocalizedString(@"update_done_label",nil);
//                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
            }
            else
            {
                tmpString = [NSString stringWithFormat:NSLocalizedString(@"search_too_much", nil),[self.storeArray count]] ;
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
            }
        } else {
            tmpString = NSLocalizedString(@"no_result", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }
        
    }
}

-(void)startUpdataManager:(WSStoreBean*)store
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:UPDATA_NOTIFY
                                               object:nil];    
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *outPlan = [NSMutableDictionary dictionary];
    [outPlan setObject:[NSString stringNotNilWithValue:store.Id] forKey:@"storeId"];
    [outPlan setObject:[NSString stringNotNilWithValue:[self getObjIDToStoreInfo]] forKey:@"objId"];
    if(self.subempStore.Id){
        [outPlan setObject:self.subempStore.Id forKey:@"empId"]; //下属id
    }
    [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"loginEmpId"]; //当前登录人id
    [[WSRequestHelper shareInstance] uploadDatasDictionary:outPlan urlString:URL_UPDATE notifyName:UPDATA_NOTIFY md5:nil isUpload:NO];
    
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.hidesWhenStopped = YES;
    [aiv startAnimating];
    [self querying_messageTips];

}



-(void)resetOutEmpStoreDataSources:(NSDictionary*)aDic
{
    if(aDic == nil) {
        return;
    }
    if (self.filterArray!=nil) {
        [self.filterArray removeAllObjects];
    }
    NSString *objId = [self getObjIDToStoreList];
    if (self.currentFuncs.filter && [self.currentFuncs.filter length] > 0) {
        objId = self.currentFuncs.filter  ;
    }
    
    NSString * search_ObjCode_Code = @"";
    
    if (self.m_searchResult && self.m_searchResult.length > 0) {
        search_ObjCode_Code = [search_ObjCode_Code stringByAppendingString:self.m_searchResult];
    }
    NSString *subEmpId = self.subempStore.Id;
    NSString *empId = subEmpId?:[WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *funCode = self.currentFuncs.fc;
    if (self.subMenuFuncsCode) {
        funCode = self.subMenuFuncsCode;
    }

    
    [WSBaseStoreOtherDataDBService saveStoreSearchObjCode:search_ObjCode_Code flagWith:WSCQVC_QUERY_STORE_SEARCH_OBJ_STR_FLAG empId:empId funcCode:funCode];
    NSArray* l_stores = [aDic objectForKey:objId];
    
    /**
     搜索内容插入数据库
     objId: 搜索节点
     objCode:搜索内容
     */
    [self insertToDbWithEmpstores:l_stores objId:objId objCode:self.m_searchResult];
    
    
    BOOL isSearchable  = [self.currentFuncs.opt.isSearchable isEqualToString:@"remote"];
    NSArray *searchedStore =[[WSBaseStoreDBService shareInstance] queryAllStoreWithFuncCode:funCode empId:empId styp:self.currentFuncs.styp searchStr:search_ObjCode_Code search_objId:objId isSearchable:isSearchable storeAccessMode:[subEmpId length] > 0 ? WSStoreAccessModeSubEmp : WSStoreAccessModeNormal parentStoreFc:self.currentFuncs.opt.parentStoreFc];

    self.filterArray =  [NSMutableArray arrayWithArray:searchedStore];
        
    self.subempStoreArray = nil;
    NSMutableArray *subEmpStoreArray = [NSMutableArray arrayWithCapacity:l_stores.count];
    for(NSDictionary* aStore in l_stores)
    {
        WSSubempstoreBean* l_sb = [[WSSubempstoreBean alloc] initWithObject:aStore];
        [subEmpStoreArray addObject:l_sb];
    }
    self.subempStoreArray = subEmpStoreArray;

    [self isShowEmptyView];
    
    [self.tableView reloadData];
    
    NSString *title = [NSString stringWithFormat:@"%@(%ld)", self.currentFuncs.name, (unsigned long)self.filterArray.count];
    [self refreshControllerTitle:title];
}



- (void)insertToDbWithEmpstores:(NSArray *)stores   objId:(NSString *)objId objCode:(NSString *)objCode {
    [[WSBaseStoreTable sharedTable] insertAllStoresWith:stores searchObjId:objId searchObjCode:objCode isPlan:@"0"];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    WSStoreBean *rowStore = [self.filterArray objectAtIndex:indexPath.row];
    if ([rowStore isKindOfClass:[WSSubempstoreBean class]]) {
        rowStore = [self transformationWith:(WSSubempstoreBean *)rowStore];
    }
    return [WSSelectListNewTableviewCell  heightForRowWithStore:rowStore cellWidth:self.tableView.width isHavePrepareButton:self.prepareFuncBean?YES:NO withOpt:self.currentFuncs.opt];
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *NewTableviewCellIdentifier = @"NewTableviewCellIdentifier";
    WSSelectListNewTableviewCell * cell = [tableView dequeueReusableCellWithIdentifier:NewTableviewCellIdentifier];
    if (cell == nil) {
        cell = [[WSSelectListNewTableviewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NewTableviewCellIdentifier withFuncStyle:WSSelectListNewTableviewCellStyleStoreVisitList isStoreInfo:self.currentFuncs.isStoreInfo cellWidth:tableView.width];
    }
    
    cell.delegate = self;
    
    
    NSArray *array = [self isUseFilterArray] ? self.filterArray : self.storeArray;
    

    WSStoreBean *storeBean = array[indexPath.row];
    if ([storeBean isKindOfClass:[WSSubempstoreBean class]]) {
        storeBean = [self transformationWith:(WSSubempstoreBean *)storeBean];
    }

    if (self.visitTypeAcvtBean && !storeBean.hasGetStateData) {
        [self getVisitTypeByStore:storeBean];
    }

    [cell setStore:storeBean withOpt:self.currentFuncs.opt];
    
    if (self.prepareFuncBean) {
        [cell setPrepareState:[self getPrepareStateByStore:storeBean] prepareFuncsBean:self.prepareFuncBean prepareAcvtBean:self.prepareStateAcvtBean];
    }
    
    storeBean.hasGetStateData = YES;
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WSStoreBean *currentStore = [self.filterArray objectAtIndex:indexPath.row];
    if ([currentStore isKindOfClass:[WSSubempstoreBean class]]) {
        currentStore = [self transformationWith:(WSSubempstoreBean *)currentStore];
    }

    self.currentStore = currentStore;
    BOOL haveStoreNotLeave = NO;
    if (currentStore.plan) {
        haveStoreNotLeave = ![self anyStoreHasNotLeave:currentStore andModuleFC:self.inPlanFuncsBean.fc];
    }else{
        NSString *moduleFC = nil;
        if ([self.currentVisitAction.module_fc length] > 0) {
            moduleFC = self.currentVisitAction.module_fc;
        }else if(self.subMenuFuncsCode && [self.subMenuFuncsCode length] > 0){
            moduleFC = self.subMenuFuncsCode;
        }else {
            moduleFC = self.currentFuncs.fc;
        }
        haveStoreNotLeave = ![self anyStoreHasNotLeave:currentStore andModuleFC:moduleFC];
    }
    if(haveStoreNotLeave)
        return;
    /**
     WSWorkFlowViewController *workflow = [[WSWorkFlowViewController alloc] initWithFuncs:self.currentFuncs Store:currentStore];
     
     [self.navigationController pushViewController:workflow animated:YES];
     */
    /**
     上面为原来的代码，直接跳到WorkFlow，Etrip的随访中的计划外门店需要请求数据然后跟正常的计划外门店走一样的逻辑，暂时如此修改，不确定是否有其他影响。
     */
    [self startUpdataManager:currentStore];
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    WSSubempstoreBean *selectStoreBean = [self.filterArray objectAtIndex:indexPath.row];

    WSStoreBean *l_store = [self transformationWith:selectStoreBean];
    UIViewController *storeInfo = nil;
    NSArray* arrays = self.currentFuncs.funcsArray;
    if (arrays && [arrays count] > 0 )
    {
        WSFuncsBean* fb = [arrays objectAtIndex:0];
        // Only isStoreInfo == "1", show the
        if ([fb.isStoreInfo isEqualToString:@"1"]) {
            storeInfo = [[WSStoreInfoViewController alloc]
                         initWithStoreInfo:l_store];
        }
    }else {
        
        storeInfo = [[WSStoreInfoViewController alloc]initWithStoreInfo:l_store];
        
    }
    
    NSString *StoreInforString = NSLocalizedString(@"store_info",nil);
    storeInfo.title = StoreInforString;
    
    self.ownParentViewController.hidesBottomBarWhenPushed = YES;
    [self.ownParentViewController.navigationController pushViewController:storeInfo animated:YES];

}

- (WSStoreBean *)transformationWith:(WSSubempstoreBean *)subempStoreBean {
    WSStoreBean *currentStore= [[WSStoreBean alloc]init];
    currentStore.Id  = subempStoreBean.Id;
    currentStore.styp  = subempStoreBean.styp;
    currentStore.acvtsArray =subempStoreBean.acvtArray;
    currentStore.code = subempStoreBean.cod;
    currentStore.name = subempStoreBean.name;
    currentStore.srid=self.subempStore.Id;
    currentStore.orgId=self.subempStore.orgId;
    currentStore.actionState = subempStoreBean.actionState;
    currentStore.storeAccessMode =  WSStoreAccessModeSubEmp;
    return currentStore;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
