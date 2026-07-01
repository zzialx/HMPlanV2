//
//  InfoCustomerViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-2.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSInfoCustomerViewController.h"
#import "WSFuncsBean.h"
#import "WSInPlanStoreBean.h"
#import "WSOutPlanStoreBean.h"
#import "WSAppData.h"
#import "WSStoreBean.h"
#import "WSStoreInfoViewController.h"
#import "WSDistStore.h"
#import "WSAppData.h"
#import "WSRequestHelper.h"
#import "WinSFA.h"
//#import "ConfigFileController.h"

#define DEALER_UPDATA_NOTIFY       @"dealterstore_notify"

@interface WSInfoCustomerViewController ()

@property (nonatomic, strong) NSArray *tempDataArray;

@end

@implementation WSInfoCustomerViewController
//@synthesize ownDataArray = _ownDataArray;

-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    
    self = [super initWithFuncs:funcs];
    if(self != nil)
    {
//        NSMutableArray* array = [[NSMutableArray alloc]init];
//        self.ownDataArray = array;
//        [array release];
        return self;
    }
    return nil;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self startUpdataManager];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
}
-(void)resetDataSource:(NSDictionary*)aDic
{
    if(aDic)
    {
        NSString * objId = self.currentFuncs.ds ? self.currentFuncs.ds : STORES;
        NSArray* l_stores = [aDic objectForKey:objId];
        for(NSDictionary* aStore in l_stores)
        {
            //排重
            NSString *storeId = [NSString stringWithValue:[aStore objectForKey:Store_id]];
            BOOL isExist = NO;
            
            for (WSStoreBean *storeBean in self.storeArray) {
                if ([storeBean.Id isEqualToString:storeId]) {
                    isExist = YES;
                    break;
                }
            }
            if (!isExist) {
                WSStoreBean* l_sb = [[WSStoreBean alloc]initStoreWithObject:aStore IsPlan:NO];
                [self.filterArray addObject:l_sb];
            }
        }
    }
    
    if (!self.tempDataArray) {
        self.tempDataArray = [self.filterArray copy];
    }
    [self resetTitle];
    [self.tableView reloadData];
}
-(void)startUpdataManager
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:DEALER_UPDATA_NOTIFY
                                               object:nil];    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    // SFA 项目 SFA-8257
    NSString * objId = self.currentFuncs.ds ? self.currentFuncs.ds : STORES;
    [uploadMgr appUpdataDealterInfo:DEALER_UPDATA_NOTIFY andObjId:objId];
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.hidesWhenStopped = YES;
    [aiv startAnimating];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    
    [self querying_messageTips];

}
-(void)finishRequest:(id)sender
{
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    if ([info rangeOfString:@"flag"].location != NSNotFound) {
        NSDictionary *infoDic = [info objectFromJSONString];
        NSString *flag = [NSString stringWithValue: infoDic[@"flag"]];
        if ([flag isEqualToString:@"1"]) {
            [self.storeArray removeAllObjects];
        }
    }
    [self initAllDataFromDb];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DEALER_UPDATA_NOTIFY 
                                                  object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    
    
    [self resetDataSource:[info objectFromJSONString]];
    //NSLog(@"info is = %@",info);
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }else{
        
        NSDictionary *uploadState = [info objectFromJSONString];
        if(self.currentStore != nil)
            [self.currentStore reSetStore:uploadState Key: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME];
//        NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
    }
    
    
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

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

////指定每个分区中有多少行，默认为1
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    int count = [self.dataArray count];
//    return count;
//}

//
////绘制Cell
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
//                             SimpleTableIdentifier];
//    if (cell == nil) {  
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                       reuseIdentifier: SimpleTableIdentifier] autorelease];
//    }
//    
//    StoreBean* store = [self.ownDataArray objectAtIndex:indexPath.row];
//    cell.textLabel.text = store.name;
//    return cell;
//    
//}
//
//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
//    StoreInfoViewController* sivc = [[StoreInfoViewController alloc]initWithStoreInfo:[self.dataArray objectAtIndex:indexPath.row]];
    WSStoreInfoViewController* sivc = [[WSStoreInfoViewController alloc]initWithStoreInfo:[self.filterArray objectAtIndex:indexPath.row]];
    LogInfo(@"Going to class WSStoreInfoViewController");
    NSString *StoreInforString = NSLocalizedString(@"store_info",nil);
    sivc.title = StoreInforString;
    self.ownParentViewController.hidesBottomBarWhenPushed = YES;
    [self.ownParentViewController.navigationController pushViewController:sivc animated:YES];
    
}
//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {  
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier: SimpleTableIdentifier];
    }
    
    WSStoreBean* store = [self.filterArray objectAtIndex:indexPath.row];
//    [self setAccessFlag:cell Store:store];
    cell.textLabel.text = store.name;
    cell.detailTextLabel.text = store.code;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
    
}
- (NSMutableArray *)searchUnitbyString:(NSString *)search{
    //NSLog(@"serch is %@",search);
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSRange range;
    memset(&range, 0, sizeof(NSRange));
    
    NSRange codeRange;
    memset(&codeRange, 0, sizeof(NSRange));
    
    for (id obj in self.storeArray) {
        memset(&range, 0, sizeof(NSRange));
        if ([obj isKindOfClass:[WSStoreBean class]]){
            WSStoreBean *store = (WSStoreBean *)obj;
            range = [store.name rangeOfString:search];
            codeRange = [store.code rangeOfString:search];
            if (range.length > 0 || codeRange.length > 0) 
            {
                [ret addObject:store];
            }
        }
    }
    ret = [ret valueForKeyPath:@"@distinctUnionOfObjects.self"];

    return ret;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
//    self.dataArray=[self searchUnitbyString:searchBar.text];
//    [self.tableView reloadData];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchBar.text==nil||[searchBar.text length]<=0)
    {
//        [self startUpdataManager];
        self.filterArray = [self.tempDataArray mutableCopy];
        [self resetTitle];
        [self.tableView reloadData];
        return;
    }
    
    self.filterArray = [[NSMutableArray alloc] initWithArray:[self searchUnitbyString:searchBar.text]];
    [self resetTitle];
    [self.tableView reloadData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder]; 
}

- (void)resetTitle
{
    NSString *title = [NSString stringWithFormat:@"%@(%lu)", self.currentFuncs.name, (unsigned long)[self.filterArray count]];
    
    if ([self.delegate respondsToSelector:@selector(superWorkSpaceVC:refreshControllerTitle:)]) {
        [self.delegate superWorkSpaceVC:self refreshControllerTitle:title];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [self addAllNavBBI];
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
}
@end
