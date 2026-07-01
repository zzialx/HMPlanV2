//
//  WSAcvtVCManager.m
//  WinSFA
//
//  Created by HZH on 2018/4/7.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSAcvtVCManager.h"

NSString *const WSAcvtVCManagerSaveAcvtViewControllerMark = @"acvtVCManagerSaveAcvtViewControllerMark";
NSString *const WSAcvtVCManagerSaveAcvtDataGridViewPanelMark = @"acvtVCManagerSaveAcvtDataGridViewPanelMark";
//===============================================================================================================================================================

@interface WSAcvtVCManager ()

@property (nonatomic, strong) NSMutableDictionary *managerDic;

@end
//===============================================================================================================================================================

@implementation WSAcvtVCManager

- (NSMutableDictionary *)managerDic {
    
    if (!_managerDic) {
        _managerDic = [[NSMutableDictionary alloc] init];
    }
    return _managerDic;
}

+ (WSAcvtVCManager *)sharedInstance {
    
    static WSAcvtVCManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WSAcvtVCManager alloc] init];
    });
    
    return instance;
}

- (void)saveAcvtViewController:(WSAcvtViewController *)acvtViewController {
    
    if (acvtViewController) {
        [self.managerDic setObject:acvtViewController forKey:WSAcvtVCManagerSaveAcvtViewControllerMark];
    } else {
        [self.managerDic removeObjectForKey:WSAcvtVCManagerSaveAcvtViewControllerMark];
    }
}

- (void)saveAcvtDataGridViewPanel:(WSAcvtDataGridViewPanel *)acvtDataGridViewPanel {
    
    if (acvtDataGridViewPanel) {
        [self.managerDic setObject:acvtDataGridViewPanel forKey:WSAcvtVCManagerSaveAcvtDataGridViewPanelMark];
    } else {
        [self.managerDic removeObjectForKey:WSAcvtVCManagerSaveAcvtDataGridViewPanelMark];
    }
}

- (WSAcvtViewController *)getAcvtViewController {
    
    return [self.managerDic objectForKey:WSAcvtVCManagerSaveAcvtViewControllerMark];
}

- (WSAcvtDataGridViewPanel *)getAcvtDataGridViewPanel {
    
    return [self.managerDic objectForKey:WSAcvtVCManagerSaveAcvtDataGridViewPanelMark];
}

- (void)deleteAcvtViewController {
    
    [self.managerDic removeObjectForKey:WSAcvtVCManagerSaveAcvtViewControllerMark];
}

- (void)deleteAcvtDataGridViewPanel {
    
    [self.managerDic removeObjectForKey:WSAcvtVCManagerSaveAcvtDataGridViewPanelMark];
}

- (void)deleteAll {
    
    [self.managerDic removeAllObjects];
}

@end
//===============================================================================================================================================================
