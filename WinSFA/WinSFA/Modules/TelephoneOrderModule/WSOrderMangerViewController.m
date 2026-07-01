//
//  OrderMangerViewController.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-4-25.
//
//

#import "WSOrderMangerViewController.h"
#import "WSRequestHelper.h"
#import "WSAppData.h"
#import "WSOrderManagerGrideViewController.h"
#import "WSFuncsBean.h"

#define UPDATA_ORDER_NOTIFY @"updata_order_notify"

@interface WSOrderMangerViewController ()

@property (nonatomic, strong) UITableView *tbView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UIAlertView *alert;

@end

@implementation WSOrderMangerViewController

@synthesize tbView = _tbView;
@synthesize dataArray = _dataArray;
@synthesize alert = _alert;


- (void)loadView {
    [super loadView];
    self.tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tbView.delegate = self;
    self.tbView.dataSource = self;
    self.tbView.backgroundColor = [UIColor clearColor];
    self.tbView.backgroundView = nil;
    [self.view addSubview:self.tbView];
    
    [self startUpdata];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"订单数: %lu", (unsigned long)[self.dataArray count]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identify = @"ordermanagercell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSDictionary *ordBean = [self.dataArray objectAtIndex:[indexPath row]];
    NSString *title = [ordBean objectForKey:@"storename"];
    if ([title isKindOfClass:[NSString class]]) {
        cell.textLabel.text = title;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *infoDic = [self.dataArray objectAtIndex:[indexPath row]];
    WSFuncsBean *fb = [self.currentFuncs.funcsArray objectAtIndex:0];
    UIViewController *vc = nil;
    if ([fb.fv isEqualToString:@"V20T01"]) {
        vc = [[WSOrderManagerGrideViewController alloc] initWithFuncs:fb orderInfoDic:infoDic];
    }
    [self.ownParentViewController.navigationController pushViewController:vc animated:YES];
}

- (void)startUpdata {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:UPDATA_ORDER_NOTIFY
                                               object:nil];
    
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    
    [uploadMgr appUpdataOrderInfoEmpId:[WSAppData getObjectbyKey:APPDATA_EMPID] notifyName:UPDATA_ORDER_NOTIFY];
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.hidesWhenStopped = YES;
    [aiv startAnimating];
    NSString *tmpString = NSLocalizedString(@"update_data_tip",nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString  tips:nil tapTarget:self action:nil];
}

- (void)finishRequest:(id)sender
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UPDATA_ORDER_NOTIFY
                                                  object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    } else {
        NSDictionary *uploadState = [info objectFromJSONString];
        self.dataArray = [uploadState objectForKey:@"ordLst"];
        if(self.currentStore != nil)
            [self.currentStore reSetStore:uploadState Key:@"diststoreinfo"];
//        NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        
        [self.tbView reloadData];
    }
    
}




@end
