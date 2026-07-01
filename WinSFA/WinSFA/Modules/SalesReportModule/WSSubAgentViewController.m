//
//  SubAgentViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-1-13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//
#define UPDATA_NOTIFY       @"outPlan_notify"

#import "WSSubAgentViewController.h"
#import "WSStoreBean.h"
#import "WSAppData.h"
#import "WSFuncsBeanArray.h"
#import "WSOutPlanStoreBean.h"
#import "WSMV_LISTViewController.h"

#import "WSRequestHelper.h"
//modity by yanguoshuai at 2012-02-29
#import "WSDistStore.h"

@implementation WSSubAgentViewController

//-(void)finishRequest:(id)sender
//{
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self 
//                                                    name:UPDATA_NOTIFY 
//                                                  object:nil];
//    
//    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
//    self.alert = nil;
//    
//    NSString *info = [[sender userInfo] objectForKey:DATAS];
//    //NSLog(@"info is = %@",info);
//    NSError *error = [[sender userInfo] objectForKey:ERROR];
//    if (error.code != 0) {
//        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
//        iToast *toast = [iToast makeText:tmpString] ;
//        [toast setDuration:iToastDurationNormal];
//        [toast setGravity:iToastGravityBottom];
//        [toast show];
//        return;
//    }else{
//        
//        NSDictionary *uploadState = [info objectFromJSONString];
//        if(self.currentStore != nil)
//            [self.currentStore reSetStore:uploadState Key:@"diststoreinfo"];
//        NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
//        iToast *toast = [iToast makeText:tmpString] ;
//        [toast setDuration:iToastDurationNormal];
//        [toast setGravity:iToastGravityBottom];
//        [toast show];
//        
//    }
//    
//}


-(void)startUpdata:(WSStoreBean*)store
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:UPDATA_NOTIFY 
                                               object:nil];
    
    
    [[WSRequestHelper shareInstance]  appUpdataAgentInfo:store notifyName:UPDATA_NOTIFY];
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.hidesWhenStopped = YES;
    [aiv startAnimating];
    NSString *tmpString = NSLocalizedString(@"update_data_tip",nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString  tips:nil tapTarget:self action:nil];
}
//重写父类
-(void)initDataArray
{
    [self.storeArray removeAllObjects];
    //modity by yanguoshuai at 2012-02-29  加节点DISTSTORE
    WSDistStore *distStoreArray = [WSAppData getObjectbyKey:DISTSTORE];
    [self.storeArray addObjectsFromArray:distStoreArray.distStoreArray];
    self.filterArray = [NSMutableArray arrayWithArray:self.storeArray];
}


-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;

    self = [super init];
    if(self != nil)
    {
        self.currentFuncs = funcs;
        self.title = funcs.name;
        NSMutableArray* array = [[NSMutableArray alloc]init];
        self.storeArray = array;
        [self initDataArray];
        return self;
    }
    return nil;
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

//选中Cell响应事件
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
//    
//    WSStoreBean* store = [self.dataArray objectAtIndex:indexPath.row];
//    self.currentStore = store;
//    [self startUpdata:store];
//    
//    //结果清单
//    WSFuncsBean* fb;
//    if([self.currentFuncs.funcsArray count]>0)
//        fb = [self.currentFuncs.funcsArray objectAtIndex:0];
//    else
//        return;
//    
//    WSMV_LISTViewController* ml = [[WSMV_LISTViewController alloc]initWithFuncs:fb Store:self.currentStore];
//    self.ownParentViewController.hidesBottomBarWhenPushed = YES;
//    [self.ownParentViewController.navigationController pushViewController:ml animated:YES];
//}

@end
