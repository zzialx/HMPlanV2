//
//  WSAcvtVCManager.h
//  WinSFA
//
//  Created by HZH on 2018/4/7.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WSAcvtViewController, WSAcvtDataGridViewPanel;
//===============================================================================================================================================================

@interface WSAcvtVCManager : NSObject

+ (WSAcvtVCManager *)sharedInstance;
- (void)saveAcvtViewController:(WSAcvtViewController *)acvtViewController;
- (void)saveAcvtDataGridViewPanel:(WSAcvtDataGridViewPanel *)acvtDataGridViewPanel;
- (WSAcvtViewController *)getAcvtViewController;
- (WSAcvtDataGridViewPanel *)getAcvtDataGridViewPanel;
- (void)deleteAcvtViewController;
- (void)deleteAcvtDataGridViewPanel;
- (void)deleteAll;

@end
//===============================================================================================================================================================
