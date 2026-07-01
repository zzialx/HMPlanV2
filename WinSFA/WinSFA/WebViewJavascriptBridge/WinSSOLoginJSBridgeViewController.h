//
//  WinSSOLoginJSBridgeViewController.h
//  WinSFA
//
//  Created by yuanji on 2022/12/5.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCBaseViewController.h"
//===================================================================================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

typedef void (^SSOLoginRegisterSuccessBlock)(NSString *successCode);

#pragma mark - 注册协议
@protocol SSOLoginRegisterHandlerProtocol <NSObject>

- (void)registerHandler_close;          //关闭协议
- (void)registerHandler_ssoLoginSuccess;//SSO登陆成功协议

@end
//===================================================================================================================================================================================================

@interface WinSSOLoginJSBridgeViewController : WCBaseViewController

@property (nonatomic, copy) NSString *externalOpenUrl;                  //外部打开URL标识
@property (nonatomic, copy) SSOLoginRegisterSuccessBlock successBlock;  //成功闭包

@end

NS_ASSUME_NONNULL_END
//===================================================================================================================================================================================================
