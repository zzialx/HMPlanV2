//
//  PfizerHospitalQueryOutplanViewController.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 6/15/13.
//
//

#import "PfizerHospitalQueryOutplanViewController.h"
#import "WSRequestHelper.h"
#import "WSOutPlanStoreBean.h"
#import "WSStoreAcvtDisBean.h"
#import "WSStoreInfoBeanArray.h"
#import "WSPlistHelper.h"
#import "WSStoredDictDisArray.h"
#import "WSStoredDictDisBean.h"
#import "WSStoreDataProcessService.h"

@interface PfizerHospitalQueryOutplanViewController ()

@property (nonatomic, copy) NSString *iSearchText;

@end

@implementation PfizerHospitalQueryOutplanViewController

@synthesize iSearchText = _iSearchText;


- (void)initAllDataFromDb {
    
}

#pragma mark - fetch information
- (void)fetchHospitalInformation
{
    if (self.iSearchText == nil ) return;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchFinished:)
                                                 name:@"PFIZERHOSFETCH"
                                               object:nil];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:8];

    (self.currentFuncs.sqlw != nil) ? [dic setObject:self.currentFuncs.sqlw forKey:@"sqlw"] : [dic setObject:@"" forKey:@"sqlw"] ;
    [dic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    (self.currentFuncs.filter != nil) ? [dic setObject:self.currentFuncs.filter forKey:@"objId"] : [dic setObject:@"" forKey:@"objId"];
    [dic setObject:@"no cellid" forKey: @"cellId"];
    [dic setObject:self.iSearchText forKey:@"name"];
    [dic setObject:@"PFIZERHOSFETCH" forKey:NT_NAME];
    
    [[WSRequestHelper shareInstance] QueryHospitalInfoWith:dic];
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.hidesWhenStopped = YES;
    [aiv startAnimating];
    NSString *AccessInfortmpString = NSLocalizedString(@"正在获取信息，请稍候...",nil);
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:AccessInfortmpString  tips:nil tapTarget:self action:nil];
    
}

- (void)fetchFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PFIZERHOSFETCH" object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0)
    {
        NSString *tmpString = NSLocalizedString(@"网络无法连接，请检查网络",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;        
    }
    
    if (self.storeArray != nil) {
        [self.storeArray removeAllObjects];
    }
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *infoDic = [info objectFromJSONString];
    WSOutPlanStoreBean *outempolan = [[WSOutPlanStoreBean alloc] initWithObject:infoDic noteName:@"spestore"];
    
    self.storeArray = outempolan.storesArray;
    self.filterArray = outempolan.storesArray;
    [self.tableView reloadData];
    
    BOOL isRealCount = YES;
    if ([self.storeArray count] > 0) {
        WSStoreBean *storeBean = [self.storeArray objectAtIndex:0];
        if ([storeBean.inArray count] > 0) {
            NSDictionary *dic = [storeBean.inArray objectAtIndex:0];
            NSString *numberString = [NSString stringWithValue:[dic objectForKey:@"num"]];
            NSInteger number = [numberString integerValue];
            if (number > 0 && [self.storeArray count] < number) {
                isRealCount = NO;
            }
        }
    }
    
    NSString *tmpString = nil;
    if (isRealCount) {
        tmpString = NSLocalizedString(@"更新完成",nil);
    }
    else
    {
        tmpString = [NSString stringWithFormat:NSLocalizedString(@"搜索结果过多，为节约您的流量只返回了前%d项。", nil),[outempolan.storesArray count]] ;
    }
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
}

-(void)startUpdataManager:(WSStoreBean*)store
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:@"PFIZERGETDOCTOR"
                                               object:nil];
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr fetchHospitalInfo:store notifyName:@"PFIZERGETDOCTOR"];
    
    NSString *AccessInforString = NSLocalizedString(@"正在获取信息，请稍候...",nil);
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:AccessInforString  tips:nil tapTarget:self action:nil];
}

- (void)finishRequest:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PFIZERGETDOCTOR" object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0)
    {
        NSString *tmpString = NSLocalizedString(@"网络无法连接，请检查网络",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *uploadState = [info objectFromJSONString];
    if (self.currentStore) {
        [self.currentStore reSetStore:uploadState Key:@"spestoreinfo"];
    }
//    [self dealWithStoreDictdis:uploadState withNodeName:@"spestoreinfo"];
//    [self dealWithStoreInfo:uploadState withNodeName:@"spestoreinfo" withFilter:self.currentFuncs.filter];
    
//    [WSStoreDataProcessService processStoreDisDataWithDic:uploadState objID:@"spestoreinfo" storeID:self.currentStore.Id];
//    [WSStoreDataProcessService processStoreInfoDataWithDic:uploadState objID:@"spestoreinfo" filter:self.currentFuncs.filter];
    
//    [self addUpdateStoreInfoToAppdata:uploadState noteName:@"spestoreinfo"];
    
    NSObject *tmpObject = uploadState[@"spestoreinfo"];
    NSDictionary *storeDicInfo = nil;
    if ([tmpObject isKindOfClass:[NSDictionary class]]) {
        storeDicInfo = (NSDictionary *)tmpObject;
    }else if ([tmpObject isKindOfClass:[NSArray class]]) {
        storeDicInfo = [(NSArray *)tmpObject firstObject];
    }
    [WSStoreDataProcessService processStoreInfoDataToDbWith:self.currentStore info:storeDicInfo];
    
    [self goNextWorkView];
}

- (void)addUpdateStoreInfoToAppdata:(NSDictionary *)aDic noteName:(NSString *)aNoteName {
    LogTrace();
    NSArray *array = [aDic objectForKey:aNoteName];
    if (!array) {
        LogError(@"\n\n[LogError array----%@]\n\n",[array description]);
        return;
    }
    NSDictionary *dicInfo = [array objectAtIndex:0];
    if (!dicInfo && !aNoteName) {
        LogError(@"\n\n[LogError dicInfo---%@,aNoteName----%@]\n\n",[dicInfo description],[aNoteName description]);
        return;
    }
    [[WSAppData sharedManager].datas setObject:dicInfo forKey:aNoteName];
    
    NSLog(@"%@", [WSAppData sharedManager].datas);
}

//- (void)dealWithStoreDictdis:(NSDictionary *)uploadState withNodeName:(NSString *)aNodeName
//{
//    NSArray *arr = [uploadState objectForKey:aNodeName];
//    NSDictionary *dic = [arr objectAtIndex:0];
//    
//    NSArray *acvtdisArray = [dic objectForKey:STOREACVTDIS];
//    for (NSDictionary *item in acvtdisArray)
//    {
//        WSStoreAcvtDisBean *sb = [[WSStoreAcvtDisBean alloc]initWithObject:item];
//        [self.currentStore.acvtDisArray addObject:sb];
//    }
//    
//   
//    WSStoredDictDisArray *storeDictDisArray = [WSAppData getObjectbyKey:STOREDICTDIS];
//    if (storeDictDisArray == nil
//        || storeDictDisArray.storedDictDisArray == nil
//        || [storeDictDisArray.storedDictDisArray count] < 1 )
//    {
//        storeDictDisArray = [[WSStoredDictDisArray alloc] initWithObject:dic];
//        [WSAppData putObject:storeDictDisArray forKey:STOREDICTDIS];
//   
//    }
//    else
//    {
//        NSArray *sdaArray= [storeDictDisArray.storedDictDisArray copy];
//        
//        for (WSStoredDictDisBean *item in sdaArray)
//        {
//            if ([[item.m_p firstObject] isEqualToString:self.currentStore.Id])
//            {
//                [storeDictDisArray.storedDictDisArray removeObject:item];
//            }
//        }
//        WSStoredDictDisArray *newStoreDictDisArray = [[WSStoredDictDisArray alloc] initWithObject:dic];
//        [storeDictDisArray.storedDictDisArray addObjectsFromArray:newStoreDictDisArray.storedDictDisArray];
//    }
//    
//}

//- (void)dealWithStoreInfo:(NSDictionary *)uploadState withNodeName:(NSString *)aNodeName
//{
//    NSArray *tempArray = [uploadState objectForKey:aNodeName];
//    NSDictionary *object = [tempArray objectAtIndex:0];
//    
//    WSStoreInfoBeanArray *loginStoreInfoBeans = [WSAppData getObjectbyKey:STOREINFOS];
//    NSMutableArray* l_dataArray = [[NSMutableArray alloc] init];
//    for(WSStoreInfoBean* f_storeInfo in loginStoreInfoBeans.storeinfoArray)
//    {
//        if(![f_storeInfo.storeId isEqualToString:self.currentStore.Id] && ![f_storeInfo.typ isEqualToString:self.currentFuncs.filter])
//        {
//            [l_dataArray addObject:f_storeInfo];
//        }
//    }
//    
//    WSStoreInfoBeanArray *storeinfoBeans = [[WSStoreInfoBeanArray alloc] initWithObject:object];
//    [storeinfoBeans.storeinfoArray addObjectsFromArray:l_dataArray];
//    
//    //    NSMutableArray *newBeanArray = [object objectForKey:STOREINFOS];
//    //    [newBeanArray addObjectsFromArray:l_dataArray];
//    
//    
//    
//    [WSAppData putObject:storeinfoBeans forKey:STOREINFOS];
//}

#pragma mark - UISearchBar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    self.iSearchText = [NSString stringWithString:searchText];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self fetchHospitalInformation];
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
    WSStoreBean* store = [self.filterArray objectAtIndex:indexPath.row];
    
    BOOL haveStoreNotLeave = NO;
    
    NSString *moduleFC = nil;
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        moduleFC = self.currentVisitAction.module_fc;
    }else if(self.subMenuFuncsCode && [self.subMenuFuncsCode length] > 0){
        moduleFC = self.subMenuFuncsCode;
    }else {
        if (store.plan) {
            moduleFC = self.inPlanFuncsBean.fc;
        }else {
            moduleFC = self.currentFuncs.fc;
        }
        
    }
    /*如果当前列表是随访人员的列表 则modelFc取当前fc*/
    if (self.subempStore) {
        moduleFC = self.currentFuncs.fc;
    }
    
    haveStoreNotLeave = ![self anyStoreHasNotLeave:store andModuleFC:moduleFC];
    
    
    if(haveStoreNotLeave)
        return;
    self.currentStore = store;
    
    [self startUpdataManager:store];
    //以下code因submenu而改
//    if ([self.currentFuncs.funcsArray count]<1) {
//        return;
//    }
//    
//    FuncsBean* nextfb = [self.currentFuncs.funcsArray objectAtIndex:0];
//    
//    WorkFlowViewController* wfvc = [[WorkFlowViewController alloc]initWithFuncs:nextfb Store:store];
//    self.ownParentViewController.hidesBottomBarWhenPushed = YES;
//    [self.ownParentViewController.navigationController pushViewController:wfvc animated:YES];
//    [wfvc release];
}


@end
