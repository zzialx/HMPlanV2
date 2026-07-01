//
//  WSStoreBaseViewController.m
//  WinSFA
//
//  Created by yuanji on 2018/9/3.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSStoreBaseViewController.h"
#import "WSAcvtViewController.h"
#import "WSNewAddListViewController.h"
#import "WSBaseAcvtDBService.h"
#import "WSAcvtListViewController.h"
#import "WSMV_LISTViewController.h"

#pragma mark - 门店视图管理器基地
@implementation WSStoreBaseViewController

#pragma mark - 获取当前empid方法
- (NSString *)getCurrentEmpId {
    
    NSString *currenteEmpId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *subEmpId = self.subempStore.Id;
    NSString *empId = (subEmpId ? : currenteEmpId);
    return empId;
}
- (UIViewController *)nextPageWithFunsBean:(WSFuncsBean *)fb withINdexStore:(WSStoreBean *)store{
    
    if (!fb) {
        return nil ;
    }
    
    NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
    UIViewController *vc = nil;
    
    // SFA-17353 添加 fb.fv 是否是报表的逻辑判断
    if (fb.opt.isAdd != nil && [fb.opt.isAdd isEqualToString:@"N"] == NO && ![fb.fv isEqualToString:REPOPRT_FV]) {
        vc = [[WSNewAddListViewController alloc] initWithFuncs:fb Store:store];
    }
    else{
        
        vc = [[NSClassFromString(className) alloc]initWithFuncs:fb Store:store];
        
        if (vc == nil) {
            
            LogInfo(@"className no support :%@",fb.fv);
            
            if ([fb.isAcvtList isEqualToString:@"1"]) {
                
                WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
                NSArray *filterArray = [baseAcvtDBService queryAcvtsWithStoreId:self.currentStore.Id filter:fb.filter];
                if ([filterArray count] > 1) {
                    vc = [[WSAcvtListViewController alloc]initWithFuncs:fb Store:store];
                    
                }
                else if ([filterArray count] == 1){
                    vc = [[WSAcvtViewController alloc]initWithAcvt:[filterArray firstObject] Funcs:fb Store:store];
                    
                }
                else{
                    vc = [[WSAcvtViewController alloc]initWithAcvt:nil Funcs:fb Store:store];
                }
            }
            else{
                
                LogInfo(@"Go into class 2 fb.ds: %@ == %@\n",fb.ds,[WSPlistHelper valueForKey:fb.ds withPlistName:kControllerMappingFileName]);
                vc = [[NSClassFromString([WSPlistHelper valueForKey:fb.ds withPlistName:kControllerMappingFileName]) alloc]initWithFuncs:fb Store:store];
                [vc setShowActionTip:YES];
            }
        }
        
    }
    
    if ([vc isKindOfClass:[WSMV_LISTViewController class]]) {
        WSMV_LISTViewController *mvListCon = (WSMV_LISTViewController *)vc;
        [mvListCon initData];
        if ([mvListCon itemCount] == 1) {
            UIViewController *nextViewController  = [mvListCon generateNextPageWithRow:0];
            vc = nextViewController ;
        }
    }
    
    return vc ;
}
- (BOOL)gotoNextPageWithViewController:(UIViewController *)tmpVc withFuncsBean:(WSFuncsBean *)fb withStoreBean:(WSStoreBean *)store withAutoJump:(BOOL)isAuto{
    
    if (tmpVc == nil ) {
        return NO;
    }
    
    BaseViewController *controller = (BaseViewController *)tmpVc;
    controller.currentStore = store ;
    LogInfo(@" Go into class %@\n", [tmpVc className]);
    
    if (![fb.name isEqualToString:@"离开门店"]) {
        controller.title = fb.name ;
    }
    //    MMSH-3296
    //    SFA玛氏中国MWC：IOS,门店拜访，点击一个门店进入主管门店报表界面时，底部还显示tab。
    controller.hidesBottomBarWhenPushed = YES;
    
    if (isAuto) {
        if (self.navigationController.viewControllers.count >1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.navigationController pushViewController:controller animated:YES];
            });
        }
        else{
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    
    return YES;
}

@end
