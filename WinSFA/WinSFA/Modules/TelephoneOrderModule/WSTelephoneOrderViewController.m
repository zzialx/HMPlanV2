//
//  TelephoneOrderViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-4-11.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSTelephoneOrderViewController.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSRequestHelper.h"
#import "WSFuncTipDBService.h"


@implementation WSTelephoneOrderViewController
- (id)initWithFuncs:(WSFuncsBean *)funcs  {

    self = [super initWithFuncs:funcs];
    if(self) {
        return self;
    }
    return nil;
}
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
    [self handleTabBarItemBadgeValue];
}
- (void)handleTabBarItemBadgeValue {
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *funCode = (self.currentFuncs.iParentFuncsBean) ? self.currentFuncs.iParentFuncsBean.fc : self.currentFuncs.fc;
    NSString *item2 = [WSBaseStoreOtherDataDBService queryStoreSearchObjCodeWithFlag:FUNC_TIP empId:empId funcode:funCode];
    
    UIViewController *vc = (self.ownParentViewController) ? self.ownParentViewController : self;
    NSInteger count = [item2 integerValue];
    if (count <= 0) {
        vc.tabBarItem.badgeValue = nil;
    } else {
        NSString *badgeValue = (count > 99) ? @"..." : [NSString stringWithFormat:@"%ld", count];
        vc.tabBarItem.badgeValue = badgeValue;
    }
}
- (void)loadTip
{
    [self querying_messageTips];
    NSMutableDictionary*paramDic=[[NSMutableDictionary alloc] init];
    [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.pageTag] forKey:@"objId"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    NSString *notifyID = @"loadTip";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}
-(void)uploadFinish:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    if(![notification.object isKindOfClass:[NSError class]]){
        NSDictionary *dic = [[notification object] objectFromJSONString];
        if([dic objectForKey:@"fcCountTipOnTime"] && [[dic objectForKey:@"fcCountTipOnTime"] isKindOfClass:[NSArray class]])
        {
            WSFuncTipDBService *DB = [WSFuncTipDBService alloc];
            [DB replaceToTableWithDicts:[dic objectForKey:@"fcCountTipOnTime"] FromNode:nil hasNewData:YES];
            [self handleTabBarItemBadgeValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:FRIEND_COMMUNITY_NEW_MESSAGE_NOTIFICATION object:nil];
        }
    }else{
        NSString * title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}
@end
