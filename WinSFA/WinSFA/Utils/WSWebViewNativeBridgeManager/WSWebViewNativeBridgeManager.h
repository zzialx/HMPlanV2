//
//  WSWebViewNativeBridgeManager.h
//  WinSFA
//
//  Created by yang on 15/12/22.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCBaseViewController;

@interface WSWebViewNativeBridgeManager : NSObject

- (void)getViewControllerAndDataWithURL:(NSURL *)url completionBlock:(void (^)(WCBaseViewController *controller, NSError *error))completionBlock;

- (void)getJumpAPPAndDataWithURL:(NSURL *)url completionBlock:(void (^)(NSString *selectJump, NSError *error))completionBlock;


@end
