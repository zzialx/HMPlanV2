//
//  SpecialAcvtListViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSpecialAcvtListViewController.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSRequestHelper.h"
#import "WSFuncTipDBService.h"
#import "WSFuncsBeanArray.h"

@implementation WSSpecialAcvtListViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (self.currentFuncs.pageTag && self.currentFuncs.pageTag .length > 0) {
//        [self loadTip];
//    }
}
#pragma mark - View lifecycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([WSAppData sharedManager].showHomePage) {
        return;
    }
//    [WSAppData sharedManager].showHomePage = YES;
//    WSFuncsBeanArray* fba= [WSAppData getObjectbyKey:FUNCS];
//    NSDictionary *showFuncsDict = [fba getShowFuncsBean];
//    if ([[showFuncsDict objectForKey:IS_SHOW] isEqualToString:@"1"]) {
//        [self pushViewWithFuncsBean:[showFuncsDict objectForKey:FROM_FUNCS_BEAN] realSubFuncsBean:[showFuncsDict objectForKey:SHOW_FUNCS_BEAN]];
//    }
}
- (void)pushViewWithFuncsBean:(WSFuncsBean *)fb realSubFuncsBean:(WSFuncsBean *)realSubFuncsBean{
    WCBaseViewController* vc = [WCBaseViewController getControllerWithFuncsBean:fb realSubFuncsBean:realSubFuncsBean];
    
    if (vc) {
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)loadTip
{
//    [self querying_messageTips];
    NSMutableDictionary*paramDic=[[NSMutableDictionary alloc] init];
    [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.pageTag] forKey:@"objId"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    NSString *notifyID = @"loadTipOne";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}
-(void)uploadFinish:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
//    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    if(![notification.object isKindOfClass:[NSError class]]){
        NSDictionary *dic = [[notification object] objectFromJSONString];
        if([dic objectForKey:@"fcCountTipOnTime"] && [[dic objectForKey:@"fcCountTipOnTime"] isKindOfClass:[NSArray class]])
        {
            WSFuncTipDBService *DB = [WSFuncTipDBService alloc];
            [DB replaceToTableWithDicts:[dic objectForKey:@"fcCountTipOnTime"] FromNode:nil hasNewData:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loadCountTip" object:nil userInfo:nil];
            });
        }
    }else{
        NSString * title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}
@end

