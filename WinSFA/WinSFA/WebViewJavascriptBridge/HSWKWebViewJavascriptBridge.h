//
//  HSWKWebViewJavascriptBridge.h
//  WebBridgePlugin
//
//  Created by zhangjikuan on 2019/10/17.
//
#if (__MAC_OS_X_VERSION_MAX_ALLOWED > __MAC_10_9 || __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_1)
#define supportsWKWebView 1
#endif

#if defined supportsWKWebView
#import <Foundation/Foundation.h>
#import "HSWebViewJavascriptBridgeBase.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSWKWebViewJavascriptBridge : NSObject<WKNavigationDelegate, HSWebViewJavascriptBridgeBaseDelegate>

+ (instancetype)bridgeForWebView:(WKWebView*)webView;
+ (void)enableLogging;

- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler;
- (void)removeHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
- (void)reset;
- (void)setWebViewDelegate:(id)webViewDelegate;
- (void)disableJavscriptAlertBoxSafetyTimeout;


@end

NS_ASSUME_NONNULL_END
#endif
