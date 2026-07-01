//
//  WSReportFormController.m
//  WinSFA
//
//  Created by Nemo on 14-4-11.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSReportFormController.h"
#import "WSRequestHelper.h"
#import "WSAppData.h"
#import "WSServerIPController.h"
#import "WSServerIPList.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+TapAction.h"
#import "WSRequestBase.h"
#import "WSQRModule.h"
#import "WSInterAction.h"
#import "WSFuncsBeanArray.h"
#import "WSWebViewNativeBridgeManager.h"
#import "MJRefresh.h"
#import "WSLoginViewController.h"
#import "WSMjetLoginManager.h"
#import "WSCookieHelper.h"
#import "WSLeftMenuViewController.h"
#import "WSChartConst.h"
#import "WSChartViewController.h"
#import "WSEMSDKManager.h"
#import "WSStatisticsManager.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSIMagePickerModule.h"
#import "WSDownloadUtil.h"
#import "WSSignatureModule.h"
#import "WSPhotoBrowserViewController.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "UIDevice+IdentifierAddition.h"
#import "WSJSONBuilder.h"
#import "NSString+Util.h"
#import "WSMJProgressHeader.h"
#import "WSBottomPopView.h"
#import <MessageUI/MessageUI.h>
#import "WSFuncsBeanContainerViewController.h"
#import "DateUtil.h"
#import "WSAllStoresMapViewController.h"
#import "WSDevieceUtil.h"
#import "SEPrinterManager.h"
#import "WSBlueToothListActionSheet.h"
#import "WSEnvrionment.h"
#import "WWKApi.h"
#import "WSAcvtQstWidgetRelationTools.h"
#import "WSNewAddAcvtViewController.h"
#import "WSBaseAcvtDBService.h"
#import "UIImage+Eemporary.h"
#import "WSOnlineConsultationService.h"
#import "WSNewStoreListTool.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "WSBaseStoreDBService.h"
#import "WSBaseStoreTable.h"
#import "WSVisitStoreStatusTable.h"
#import <WebKit/WebKit.h>

#define kSpaceWidth             50
#define kViewHeight             120
#define AUTH_BY_HW_UNIPORTAL    @"AUTH_BY_HW_UNIPORTAL"
#define kIOSLocalIdentifer      @"kIOSLocalIdentifer"
#define PULL_REFRESH_FORBIDDEN  @"iosfresh=false"
#define WINDOW_RESIZE           @"wd_on_resize=1"
#define WEB_QUERY_KEY           @"&queryKey"
#define UPDATA_NOTIFY_STORE     @"store_notify"
//======================================================================================================================================================================================================

#pragma mark - 弱网页脚本消息委托
@interface WinWeakWebViewScriptMessageDelegate : NSObject <WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;      //脚本代理

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;//自定义初始化方法

@end
//======================================================================================================================================================================================================

#pragma mark - 弱网页脚本消息委托
@implementation WinWeakWebViewScriptMessageDelegate

#pragma mark - 自定义初始化方法
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    
    self = [super init];
    if (self) {
        
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

#pragma mark - 实现WKScriptMessageHandler userContentController:didReceiveScriptMessage:协议
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([self.scriptDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        
        [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end
//======================================================================================================================================================================================================

@interface WSReportFormController () <WSMjetLoginManagerDelegate, SEPrinterManagerDelegate,
UIDocumentInteractionControllerDelegate, MFMessageComposeViewControllerDelegate, WKNavigationDelegate, WKUIDelegate, UINavigationControllerDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *reportFormWKWebView;       //网页视图
@property (nonatomic, assign) BOOL isNewPage;
@property (nonatomic, assign) BOOL authenticated;
@property (nonatomic, assign) BOOL isLogging;
@property (nonatomic, assign) BOOL isShowHud;
@property (nonatomic, assign) BOOL isShowNativePage;
@property (nonatomic, assign) BOOL isManualRefresh;
@property (nonatomic, assign) NSInteger loginCount;
@property (nonatomic, assign) WSReportFormControllerWorkMode workMode;
@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, assign) BOOL isNeedClearCookie;
@property (nonatomic, assign) BOOL isIgnoreNewRequest;
@property (nonatomic, weak) SEPrinterManager *printerManager;
@property (nonatomic, strong) WSWebViewNativeBridgeManager *manager;
@property (nonatomic, strong) NSURLRequest *loadrequest;
@property (nonatomic, strong) NSString *finishLoadGenId;
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, strong) UIBarButtonItem *shareBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *barButtonItem;
@property (nonatomic, strong) NSDictionary *shareDataDict;
@property (nonatomic, strong) UIButton *webViewKeyboardDoneBtn;
@property (nonatomic, strong) NSData *postBody;
@property (nonatomic, strong) NSMutableArray *backFuncNameArray;
@property (nonatomic, strong) WSBlueToothListActionSheet *actionSheet;
@property (nonatomic, strong) NSArray *cookieArr;
@property (nonatomic, strong) NSURL *curentURL;
@property (nonatomic, copy) NSString *keyboardCallBackName;
@property (nonatomic, copy) NSString *downloadProgressName;
@property (nonatomic, copy) NSString *downloadCallBackName;
@property (nonatomic, copy) NSString *backCallBackName;
@property (nonatomic, copy) NSString *firstLoadRequestUrlStr;
@property (nonatomic, copy) NSString *isAdd;
@property (nonatomic, copy) NSString *lastUrl;
@property (nonatomic, copy) NSString *jumpStoreID;
@property (nonatomic, copy) NSString *viewDidLoadData;                          //视图预加载时间
@property (nonatomic, assign) BOOL isLoadURL;                                   //是否加载url


@property (nonatomic, strong) NSMutableDictionary * cookieDic;

@end
//======================================================================================================================================================================================================

@implementation WSReportFormController

#pragma mark - 初始化方法1
- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean*)store {
    
    if (funcs == nil || store == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        self.title = funcs.name;
        self.currentFuncs = funcs;
        self.currentStore = store;
        _workMode = WSReportFormControllerWorkModeReportForm;
    }
    return self;
}

#pragma mark - 初始化方法1
- (id)initWithFuncs:(WSFuncsBean *)funcs {
    
    if (funcs == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        self.title = funcs.name;
        self.currentFuncs = funcs;
        _workMode = WSReportFormControllerWorkModeReportForm;
    }
    return self;
}

#pragma mark - 初始化方法3
- (id)initWithURL:(NSURL *)url {
    
    self = [super init];
    if (self) {
        
        _loadURL = url;
        _workMode = WSReportFormControllerWorkModeURL;
    }
    return self;
}

#pragma mark - 初始化方法4
- (id)initWithURL:(NSURL *)url WithIsNeedCookie:(BOOL)isNeedCookie {
    
    if (!isNeedCookie) {
        
        [WSCookieHelper removeCookieForName:kSSO_JSESSIONID];
    }
    return [self initWithURL:url];
}

#pragma mark - 初始化方法5
- (instancetype)initWithPostURL:(NSURL *)url postBody:(NSData *)body {
    
    self = [self initWithURL:url];
    if (self) {
        
        self.postBody = body;
    }
    return self;
}

#pragma mark - 获取reportFormWKWebView方法
- (WKWebView *)reportFormWKWebView {
    
    if (!_reportFormWKWebView) {
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKPreferences *preference = [[WKPreferences alloc] init];
        preference.minimumFontSize = 0;
        preference.javaScriptEnabled = YES;
        preference.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preference;
        config.allowsInlineMediaPlayback = YES;
        config.mediaTypesRequiringUserActionForPlayback = YES;
        config.allowsPictureInPictureMediaPlayback = YES;
        config.applicationNameForUserAgent = @"winchannel";
        
        WinWeakWebViewScriptMessageDelegate *weakScriptMessageDelegate = [[WinWeakWebViewScriptMessageDelegate alloc] initWithDelegate:self];
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"clickOnAndroid"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"scanBarcode"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"toLoginPage"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"finish"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"setScrollY"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"printData"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"closeWindow"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"getChatInfoMsg"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"takePhoto"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"selectPhoto"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"elecSignature"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"downFile"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"softkeyboardChange"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"registBackListen"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"getCurrentPosition"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"onResize"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"openGallery"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"shareParams"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"shareTextToWeChat"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"jumpRouteMap"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"requestServerDataByJs"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"removeFuncMarker"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"functip"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"addAcvt"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"updateStoreInfoDatas"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"needUpdateStoreList"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"addNewStore"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"goHome"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"setFuncMarker"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"openNewWebView"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate name:@"jumpStoreTask"];
        config.userContentController = wkUController;
        
        NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [config.userContentController addUserScript:wkUScript];
        
        jSString = @"var script = document.createElement('meta');"
        "script.name = 'viewport';"
        "script.content=\"width=device-width, user-scalable=no\";"
        "document.getElementsByTagName('head')[0].appendChild(script);";
        wkUScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [config.userContentController addUserScript:wkUScript];
        
        _reportFormWKWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _reportFormWKWebView.backgroundColor = UIColor.whiteColor;
        _reportFormWKWebView.UIDelegate = self;
        _reportFormWKWebView.navigationDelegate = self;
        _reportFormWKWebView.allowsBackForwardNavigationGestures = NO;
        _reportFormWKWebView.scrollView.bounces = NO;
        // 设置cookie代理
//        _reportFormWKWebView.cookieDelegate = self;

#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            _reportFormWKWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
#endif
    }
    
    return _reportFormWKWebView;
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor whiteColor]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endFullScreen) name:UIWindowDidBecomeHiddenNotification object:nil];
    
    [[WSStatisticsManager sharedInstance] insertWebPageSenceEventWithID:EVENT_WEB_PAGE_START parentFuncBean:self.currentFuncs.iParentFuncsBean currentFuncBean:self.currentFuncs store:self.currentStore
                                                              startTime:[WSCurrentTime getTimeMillisStringForDevice] endTime:nil genId:[WSStatisticsManager getGenId]];
    
    _firstLoadRequestUrlStr = nil;
    _isNewPage = NO;
    _loginCount = 0;
    _isManualRefresh = NO;
    _isLogging = NO;
    _viewHeight = kViewHeight;
    _viewDidLoadData = [WSCurrentTime getTimeMillisString];

    NSURL *url = [self getURL];
    //默认刷新，不刷新导致部分新增失效
    _shouldReloadWhenAppear = ([url.absoluteString rangeOfString:PULL_REFRESH_FORBIDDEN].location == NSNotFound && ![self.currentFuncs.opt.isRefresh isEqualToString:@"0"]) ? YES : NO;
    
    if ([self.executeParam.execute_class_param isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dic = (NSDictionary *)self.executeParam.execute_class_param;
        self.loadURL = [dic objectForKey:@"url"];
        self.title = [dic objectForKey:@"title"];
        self.workMode = WSReportFormControllerWorkModeURL;
    }
    
    [super uploadVisitAction];
    [self setupWebView];

    if (self.currentFuncs.opt.loginUrl.length > 0) {
        [self optLoginUrlNormalLogin];
    }
    else {
        [self requestCookie];
//        [self loadWebViewRequest];
    }
}

#pragma mark - 重写viewWillAppear:方法
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.lastUrl = nil;
    [self clearAllNavBBI];
    [self addBackBarButtonItem];
    [self checkRightBarButtonItem];
    
    if ([[self getURL].absoluteString containsString:@"isHideTitle=1"]) {
        self.navigationController.navigationBarHidden = YES;
    }

    self.isIgnoreNewRequest = NO;
        
    if (self.isNewPage) {
        [self webViewReload];
        self.isNewPage = NO;
        self.isLoadURL = YES;
    }
    else if (self.shouldReloadWhenAppear) {

        BOOL parentIsTabBarController = NO;
        if ([self.parentViewController.parentViewController isKindOfClass:[UITabBarController class]]) {
            
            if ([self.parentViewController isKindOfClass:[UINavigationController class]]) {
                if ([(UINavigationController *)self.parentViewController viewControllers].count == 1) {
                    parentIsTabBarController = YES;
                }
            }
        }
            
        BOOL isWebChat = NO;
        NSURL *requsetUrl = [self getURL];
        if (requsetUrl.absoluteString && [requsetUrl.absoluteString rangeOfString:@"webchat.7moor.com"].location != NSNotFound) {
            isWebChat = YES;
        }
        if (!isWebChat && (!parentIsTabBarController || self.isShowNativePage)) {
            
            self.isLogging = NO;
            self.loginCount = 0;
            [self performSelector:@selector(webViewReload) withObject:nil afterDelay:0.5];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWebView) name:ACVT_UPLOAD_SUCEESS_REFRESH_WEBVIEW_NOTIFY object:nil];
}

#pragma mark - 重写viewDidAppear:方法
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (INTERFACE_IS_PAD) {
        if (self.navigationController.view.width != 1024 && self.navigationController.view.height != 1024) {
            [self addFullScreenButton];
        }
    }
}

#pragma mark - 重写viewWillDisappear:方法
- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (self.isNeedClearCookie) {
        [WSCookieHelper removeCookieForName:kSSO_JSESSIONID];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACVT_UPLOAD_SUCEESS_REFRESH_WEBVIEW_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeHiddenNotification object:nil];
}

#pragma mark - 重写viewDidDisappear:方法
- (void)viewDidDisappear:(BOOL)animated {
    
//    [self cleanCacheAndCookie];
    [self writeSystemInfoToLog];
}


#pragma mark - 重写didReceiveMemoryWarning方法
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    [[SDImageCache sharedImageCache] clearMemory];
//    [self cleanCacheAndCookie];
}

#pragma mark - 重写dealloc方法
- (void)dealloc {

    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"clickOnAndroid"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"scanBarcode"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"toLoginPage"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"finish"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"setScrollY"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"printData"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"closeWindow"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"getChatInfoMsg"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"takePhoto"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"selectPhoto"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"elecSignature"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"downFile"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"softkeyboardChange"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"registBackListen"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"getCurrentPosition"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"onResize"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"openGallery"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"shareParams"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"shareTextToWeChat"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"jumpRouteMap"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"requestServerDataByJs"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"removeFuncMarker"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"functip"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"addAcvt"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"updateStoreInfoDatas"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"needUpdateStoreList"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"addNewStore"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"goHome"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"setFuncMarker"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"openNewWebView"];
    [[_reportFormWKWebView configuration].userContentController removeScriptMessageHandlerForName:@"jumpStoreTask"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:login_web_notify object:nil];
    
    if (self.keyboardCallBackName) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
}

#pragma mark - 实现webView:didFailProvisionalNavigation:协议 失败回调
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {

    LogInfo(@"WSReportFormController webView:didFailProvisionalNavigation: URL=%@", webView.URL);
    
    [self webViewHideHUDWithAnimated:NO];
}

#pragma mark - 实现webView:didStartProvisionalNavigation:协议 启动时回调
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    LogInfo(@"WSReportFormController webView:didStartProvisionalNavigation: URL=%@", webView.URL);
    
    [self webViewHideHUDWithAnimated:NO];
    [self webViewShowHUDWithText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil) tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
}

#pragma mark - 实现webView:didFinishNavigation:协议 完成时回调
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

    LogInfo(@"WSReportFormController webView:didFinishNavigation: URL=%@", webView.URL);
    
    [self closeWebViewMJHeader];
    [self webViewHideHUDWithAnimated:NO];
    [self resetViewHeight:0];

    if (!self.title || [self.title isEqualToString:@""]) {
        [webView evaluateJavaScript:@"document.title" completionHandler:^(NSString *result, NSError * _Nullable error) {
            self.title = result;
        }];
    }

    if (!webView.isLoading && !self.isManualRefresh) {

        if (webView.URL.absoluteString && [webView.URL.absoluteString rangeOfString:@"nativeSkip=1"].location != NSNotFound) {
            WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
            delegate.welcomeReportVC = nil;
        }

        if (!self.finishLoadGenId) {

            self.finishLoadGenId = [WSStatisticsManager getGenId];
            [[WSStatisticsManager sharedInstance] insertWebPageSenceEventWithID:EVENT_WEB_PAGE_END parentFuncBean:self.currentFuncs.iParentFuncsBean currentFuncBean:self.currentFuncs
                                                                          store:self.currentStore startTime:[WSCurrentTime getTimeMillisStringForDevice] endTime:nil genId:self.finishLoadGenId];
        }
        else {

            [[WSStatisticsManager sharedInstance] updateStartTime:[WSCurrentTime getTimeMillisStringForDevice] withGenID:self.finishLoadGenId];
        }
    }
}

#pragma mark - 实现webView:decidePolicyForNavigationAction:decisionHandler:协议 预启动回调
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    LogInfo(@"WSReportFormController webView:decidePolicyForNavigationAction:decisionHandler: URL=%@ request=%@", webView.URL, navigationAction.request);

    AFNetworkReachabilityStatus networkReachabilityStatus = [[WinAFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
    if (networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {

        [self closeWebViewMJHeader];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"似乎已断开与互联网的连接", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:1.5f];

        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    self.isShowNativePage = NO;

    if (self.currentFuncs.opt.loginUrl.length == 0 && [self isNeedLogin:navigationAction.request.URL]) {

        if (self.isLogging) {
            decisionHandler(WKNavigationActionPolicyAllow);
            return;
        }

        [self performSelector:@selector(loginWeb) withObject:nil afterDelay:0.1];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if (navigationAction.request.URL.absoluteString && [navigationAction.request.URL.absoluteString rangeOfString:@"nativeSkip=1"].location != NSNotFound) {
        [self addSkipButton];
    }
    
    if ([navigationAction.request.URL.scheme isEqualToString:[[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"]] ||
        [navigationAction.request.URL.scheme isEqualToString:[[[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"] lowercaseString]] ||
        [navigationAction.request.URL.scheme isEqualToString:@"winsfawebview"]) {

        if ([navigationAction.request.URL.host isEqualToString:@"returnData"]) {
            
            NSArray *queryArray = [navigationAction.request.URL.query componentsSeparatedByString:@"&"];
            NSString *queryStr = [queryArray firstObject];
            NSArray *dataArray = [queryStr componentsSeparatedByString:@"="];
            if ([[dataArray firstObject] isEqualToString:@"param"]) {
                
                NSString *dataStr = [dataArray lastObject];
                NSString *encodingStr = [dataStr stringByRemovingPercentEncoding];
                if ([self.delegate respondsToSelector:@selector(didGetDataFromReportForm:)]) {
                    [self.delegate didGetDataFromReportForm:encodingStr];
                }
            }
            
            if ([_loadURL.absoluteString rangeOfString:@"method=registIndex"].location!=NSNotFound ) {
                [self backAction];
            }
            else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else {
            
            __weak typeof(self) wself = self;
            self.cookieArr = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
            self.manager = [[WSWebViewNativeBridgeManager alloc] init];
            [self.manager getViewControllerAndDataWithURL:navigationAction.request.URL completionBlock:^(WCBaseViewController *controller, NSError *error) {
                
                if (error) {
                    
                    NSString *msg = [error.userInfo objectForKey:@"msg"];
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                }
                else if (controller) {
                    
                    wself.isShowNativePage = YES;
                    controller.hidesBottomBarWhenPushed = YES;
                    [[wself getNavigationController] pushViewController:controller animated:YES];
                    [self resetCookie];
                }
                
                if (self.isFullScreenMode) {
                    [wself exitFullScreen];
                }
            }];
        }
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([navigationAction.request.URL.scheme isEqualToString:@"jumpapp"]) {
        
        self.manager = [[WSWebViewNativeBridgeManager alloc] init];
        [self.manager getJumpAPPAndDataWithURL:navigationAction.request.URL completionBlock:^(NSString *selectJump, NSError *error) {
            
            if (selectJump.length > 0) {
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:selectJump tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            }
        }];

        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    BOOL ret = [self shouldPushNewControllerWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    LogInfo(@"WSReportFormController webView:decidePolicyForNavigationAction:decisionHandler: ret %d %@ %ld", ret, navigationAction.request, (long)navigationAction.navigationType);
    
    if (ret) {
        
        WSReportFormController *link;
        if (navigationAction.navigationType != WKNavigationTypeFormSubmitted) {
            link = [[self.class alloc] initWithURL:navigationAction.request.URL];
        }
        else {
            link = [[self.class alloc] initWithPostURL:navigationAction.request.URL postBody:navigationAction.request.HTTPBody];
        }

        NSString *reUrlString = navigationAction.request.URL.absoluteString;
        if ([reUrlString containsString:@"?"]) {
            reUrlString = [[reUrlString componentsSeparatedByString:@"?"] lastObject];
        }
        
        if ([reUrlString rangeOfString:@"backrefresh=false"].location == NSNotFound) {
            self.isNewPage = YES;
        }
        else {
            self.shouldReloadWhenAppear = NO;
        }
        
        if ([navigationAction.request.URL.absoluteString rangeOfString:@"addUploadBtn=1"].location != NSNotFound) {
            link.buttonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageForName:@"icon_upload"] style:UIBarButtonItemStylePlain
                                                              target:link action:@selector(executeUpload)];
        }
        
        link.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:link animated:YES];
        self.isIgnoreNewRequest = YES;
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if (self.isIgnoreNewRequest) {
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    NSString *reUrlString = navigationAction.request.URL.absoluteString;
    if ([reUrlString containsString:@"?"]) {
        reUrlString = [[reUrlString componentsSeparatedByString:@"?"] lastObject];
    }
    if ([reUrlString rangeOfString:@"backrefresh=false"].location != NSNotFound) {
        self.shouldReloadWhenAppear = NO;
    }
            
    if (self.isLogging && [navigationAction.request.URL.absoluteString rangeOfString:kIOSLocalIdentifer].location != NSNotFound) {
                
        self.isLogging = NO;
        [self webViewHideHUDWithAnimated:NO];
        [self performSelector:@selector(loadWebViewUrl) withObject:nil afterDelay:0.1];
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}
/** 接收到服务器跳转请求即服务重定向时之后调用 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    LogInfo(@"WSReportFormController webView:didReceiveServerRedirectForProvisionalNavigation: %@ %@", webView.title, navigation);
}
/** 收到服务器响应后，决定是否跳转 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
//    LogInfo(@"WSReportFormController webView:decidePolicyForNavigationResponse:decisionHandler: %@ %@", webView.title, navigationResponse);
//    NSArray *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;

//    if (@available(iOS 11.0, *)) {
//        WKHTTPCookieStore *cookieStroe = webView.configuration.websiteDataStore.httpCookieStore;
//        for(NSHTTPCookie*cookie in cookies) {
//          [cookieStroe setCookie:cookie completionHandler:nil];
//         }
//    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        decisionHandler(WKNavigationResponsePolicyAllow);
    });
}
/** 创建一个新的webView,可以解决点击内部链接没有反应问题 */
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    if (!navigationAction.targetFrame.isMainFrame) {
           [webView loadRequest:navigationAction.request];
       }
       return nil;
}

#pragma mark - 实现webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:协议 警示框回调
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    LogInfo(@"WSReportFormController webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler: %@ %@", webView.title, message);
    
    if (!message || message.length == 0) {
        
        completionHandler();
        return;
    }
    
    __weak __typeof__(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong __typeof__(weakself) strongself = weakself;
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:webView.title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completionHandler();
        }];
        [controller addAction:okAction];
        [strongself presentViewController:controller animated:YES completion:nil];
    });
}

#pragma mark - 实现webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:completionHandler:协议 确认框回调
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
    LogInfo(@"WSReportFormController webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:completionHandler: %@ %@", webView.title, message);
    
    if (!message || message.length == 0) {
        
        completionHandler(NO);
        return;
    }
    
    __weak __typeof__(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong __typeof__(weakself) strongself = weakself;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:webView.title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel_label", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completionHandler(NO);
        }];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completionHandler(YES);
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:confirmAction];
        [strongself presentViewController:alertController animated:YES completion:nil];
    });
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
    [webView evaluateJavaScript:@"document.cookie" completionHandler:^(NSString *result, NSError * _Nullable error) {
        NSLog(@"网页中的cookie为：\n%@",[result componentsSeparatedByString:@"; "]);
    }];
}
#pragma mark - 实现WKScriptMessageHandler userContentController:didReceiveScriptMessage:协议 js交互回调
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([message.name isEqualToString:@"clickOnAndroid"]) {
        [self handleJSMessageClickOnAndroidWithBody:message.body];
        return;
    }
    
    if ([message.name isEqualToString:@"scanBarcode"]) {
        [self handleJSMessageScanBarcodeWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"toLoginPage"]) {
        [self handleJSMessageToLoginPageWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"finish"]) {
        [self handleJSMessageFinishWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"setScrollY"]) {
        [self handleJSMessageSetScrollYWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"printData"]) {
        [self handleJSMessagePrintDataWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"closeWindow"]) {
        [self handleJSMessageCloseWindowWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"getChatInfoMsg"]) {
        [self handleJSMessageGetChatInfoMsgWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"takePhoto"]) {
        [self handleJSMessageTakePhotoWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"selectPhoto"]) {
        [self handleJSMessageSelectPhotoWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"elecSignature"]) {
        [self handleJSMessageElecSignatureWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"downFile"]) {
        [self handleJSMessageDownFileWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"softkeyboardChange"]) {
        [self handleJSMessageSoftkeyboardChangeWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"registBackListen"]) {
        [self handleJSMessageRegistBackListenWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"getCurrentPosition"]) {
        [self handleJSMessageGetCurrentPositionWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"onResize"]) {
        [self handleJSMessageOnResizeWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"openGallery"]) {
        [self handleJSMessageOpenGalleryWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"shareParams"]) {
        [self handleJSMessageShareParamsWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"shareTextToWeChat"]) {
        [self handleJSMessageShareTextToWeChatWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"jumpRouteMap"]) {
        [self handleJSMessageJumpRouteMapWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"requestServerDataByJs"]) {
        [self handleJSMessageRequestServerDataByJsWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"removeFuncMarker"]) {
        [self handleJSMessageRemoveFuncMarkerWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"functip"]) {
        [self handleJSMessageFunctipWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"addAcvt"]) {
        [self handleJSMessageAddAcvtWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"updateStoreInfoDatas"]) {
        [self handleJSMessageUpdateStoreInfoDatasWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"needUpdateStoreList"]) {
        [self handleJSMessageNeedUpdateStoreListWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"addNewStore"]) {
        [self handleJSMessageAddNewStoreWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"goHome"]) {
        [self handleJSMessageGoHomeWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"setFuncMarker"]) {
        [self handleJSMessageSetFuncMarkerWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"openNewWebView"]) {
        [self handleJSMessageOpenNewWebViewWithBody:message.body];
        return;
    }

    if ([message.name isEqualToString:@"jumpStoreTask"]) {
        [self handleJSMessageJumpStoreTaskWithBody:message.body];
        return;
    }
}

#pragma mark - 处理js消息-ClickOnAndroid方法
- (void)handleJSMessageClickOnAndroidWithBody:(id)body {
    
    if ([body isKindOfClass:[NSString class]]) {
        [self.backFuncNameArray addObject:((NSString *)body)];
    }
}

#pragma mark - 处理js消息-ScanBarcode方法
- (void)handleJSMessageScanBarcodeWithBody:(id)body {
    
    NSString *callbackName = [self getCallbackFromData:body];
    if (callbackName) {
        
        WSQRModule *wsScanModule = [WSQRModule getInstance];
        __weak __typeof__(self) weakself = self;
        [wsScanModule showQRViewControllerToViewController:weakself WithScanTxtBlock:^(NSString *textStr) {
            
            __strong __typeof__(weakself) strongself = weakself;
            if (textStr && [textStr length] > 0) {
                
                NSArray *barcodeArray = [NSArray arrayWithObject:textStr];
                NSMutableDictionary * resultDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [resultDic setObject:@"complete" forKey:@"type"];
                [resultDic setObject:barcodeArray forKey:@"upc"];
                
                [strongself webViewExecuteJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", callbackName, [resultDic JSONString]] completionHandler:nil];
            }
        }
                                          withScanImgBlock:nil];
    }
}

#pragma mark - 处理js消息-ToLoginPage方法
- (void)handleJSMessageToLoginPageWithBody:(id)body {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT object:nil];
    
    if ([WSAppData sharedManager].showHomePage) {
         [WSAppData sharedManager].showHomePage = NO;
    }
}

#pragma mark - 处理js消息-Finish方法
- (void)handleJSMessageFinishWithBody:(id)body {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 处理js消息-SetScrollY方法
- (void)handleJSMessageSetScrollYWithBody:(id)body {
}

#pragma mark - 处理js消息-PrintData方法
- (void)handleJSMessagePrintDataWithBody:(id)body {
    
    [self showBlueToothListViewWithParam:body];
}

#pragma mark - 处理js消息-CloseWindow方法
- (void)handleJSMessageCloseWindowWithBody:(id)body {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 处理js消息-GetChatInfo方法
- (void)handleJSMessageGetChatInfoMsgWithBody:(id)body {
    
    [self jumpChatViewControllerWith:body];
}

#pragma mark - 处理js消息-TakePhoto方法
- (void)handleJSMessageTakePhotoWithBody:(id)body {
    
    NSString *callbackName = [self getCallbackFromData:body];
    if (callbackName) {
          
        WSIMagePickerModule *imagePickerModule = [WSIMagePickerModule getInstance];
        __weak __typeof__(self) weakself = self;
        [imagePickerModule showImagePickerViewControllerWithParentVC:weakself andSourceType:UIImagePickerControllerSourceTypeCamera andImageBlock:^(UIImage *image) {
            
            __strong __typeof__(weakself) strongself = weakself;
            UIImage *newImae = [image fixOrientation];
            if (newImae) {
                
                NSData *imageData = UIImageJPEGRepresentation(newImae, .35);
                imageData = [imageData base64EncodedDataWithOptions:0];
                NSString *base64Str = [[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding];
                
                NSArray *imageArray = [NSArray arrayWithObject:base64Str];
                NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [resultDic setObject:@"complete" forKey:@"type"];
                [resultDic setObject:imageArray forKey:@"image"];
                
                [strongself webViewExecuteJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", callbackName, [resultDic JSONString]] completionHandler:nil];
            }
            
            strongself.shouldReloadWhenAppear = NO;
        }];
    }
}

#pragma mark - 处理js消息-SelectPhoto方法
- (void)handleJSMessageSelectPhotoWithBody:(id)body {
    
    NSString *callbackName = [self getCallbackFromData:body];
    if (callbackName) {
                
        WSIMagePickerModule *imagePickerModule = [WSIMagePickerModule getInstance];
        __weak __typeof__(self) weakself = self;
        [imagePickerModule showImagePickerViewControllerWithParentVC:weakself andSourceType:UIImagePickerControllerSourceTypePhotoLibrary andImageBlock:^(UIImage *image) {
            
            __strong __typeof__(weakself) strongself = weakself;
            UIImage *newImae = [image fixOrientation];
            if (newImae) {
            
                NSData *imageData  = UIImageJPEGRepresentation(newImae,.35);
                imageData = [imageData base64EncodedDataWithOptions:0];
                NSString *base64Str = [[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding];
                        
                NSArray *imageArray = [NSArray arrayWithObject:base64Str];
                NSMutableDictionary * resultDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [resultDic setObject:@"complete" forKey:@"type"];
                [resultDic setObject:imageArray forKey:@"image"];
                
                [strongself webViewExecuteJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", callbackName, [resultDic JSONString]] completionHandler:nil];
            }
        }];
    }
}

#pragma mark - 处理js消息-ElecSignature方法
- (void)handleJSMessageElecSignatureWithBody:(id)body {
    
    NSString *callbackName = [self getCallbackFromData:body];
    if (callbackName) {
        
        NSDictionary *dataDict = [self convertToDict:body];
        WSSignatureModule *signatureModule = [WSSignatureModule getInstance];
        NSString *aPath = [dataDict objectForKey:@"path"];
        UIImage *signImg = nil;
        
        if (aPath && aPath.length > 0) {
            NSData *signImgData = [NSData dataWithContentsOfFile:aPath];
            signImg = [UIImage imageWithData:signImgData];
        }
        
        __weak __typeof__(self) weakself = self;
        [signatureModule showSignatureVCWithParentVC:weakself andSignImage:signImg withBlock:^(UIImage *image, BOOL isCancel) {
            
            __strong __typeof__(weakself) strongself = weakself;
            NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithCapacity:2];
            
            if (isCancel) {
                [resultDic setObject:@"cancel" forKey:@"type"];
            }
            else {
                
                if (image) {
                    
                    NSString *aPath = [NSString stringWithFormat:@"%@/Documents/%@.jpg",NSHomeDirectory(),@"lastElecSignatureImage"];
                    NSData *imgData = UIImageJPEGRepresentation(image,0);
                    [imgData writeToFile:aPath atomically:YES];
                    
                    NSData *imageData  = UIImageJPEGRepresentation(image,.35);
                    imageData = [imageData base64EncodedDataWithOptions:0];
                    NSString *base64Str = [[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding];
                    
                    NSArray *imageArray = [NSArray arrayWithObject:base64Str];
                    [resultDic setObject:@"complete" forKey:@"type"];
                    [resultDic setObject:imageArray forKey:@"image"];
                    [resultDic setObject:aPath forKey:@"path"];
                }
                else {
                    
                    NSString *imageDir = [NSString stringWithFormat:@"%@/Documents/%@.jpg",NSHomeDirectory(),@"lastElecSignatureImage"];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    [fileManager removeItemAtPath:imageDir error:nil];
                    [resultDic setObject:@"complete" forKey:@"type"];
                    [resultDic setObject:@"" forKey:@"image"];
                }
            }
            
            [strongself webViewExecuteJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", callbackName, [resultDic JSONString]] completionHandler:nil];
            strongself.shouldReloadWhenAppear = NO;
        }];
    }
}

#pragma mark - 处理js消息-DownFile方法
- (void)handleJSMessageDownFileWithBody:(id)body {
    
    NSDictionary *dict = [self convertToDict:body];
    if (!dict) {
        return;
    }
    
    self.downloadCallBackName = [dict objectForKey:@"callback"];
    self.downloadProgressName = [dict objectForKey:@"progress"];
    
    NSString *url = [dict objectForKey:@"url"];
    NSString *fileName  = [WSBaseStoreOtherDataDBService queryStoreSearchObjCodeWithFlag:WSRF_DOWNLOAD_SEARCH_OBJ_STR_FLAG empId:[WSAppData getObjectbyKey:APPDATA_EMPID] funcode:url];
    if (!fileName) {
        [self downLoadFile:url];
    }
    else {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", [WSDownloadUtil getDownloadDirectory], fileName];
        
        if(![fileManager fileExistsAtPath:filePath]) {
            [self downLoadFile:url];
        }
        else {
            
            NSMutableDictionary * resultDic = [NSMutableDictionary dictionaryWithCapacity:1];
            [resultDic setObject:@"complete" forKey:@"type"];
            [self webViewExecuteJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", self.downloadCallBackName, [resultDic JSONString]] completionHandler:nil];
            
            NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:filePath];
            self.documentInteractionController = [UIDocumentInteractionController  interactionControllerWithURL:fileUrl];
            self.documentInteractionController.delegate = self;
            [self.documentInteractionController presentPreviewAnimated:YES];
        }
    }
}

#pragma mark - 处理js消息-SoftkeyboardChange方法
- (void)handleJSMessageSoftkeyboardChangeWithBody:(id)body {
    
    NSString *callBackName = [self getCallbackFromData:body];
    if (callBackName) {
        
        self.keyboardCallBackName = callBackName;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
}

#pragma mark - 处理js消息-RegistBackListen方法
- (void)handleJSMessageRegistBackListenWithBody:(id)body {
    
    NSString *callbackName = [self getCallbackFromData:body];
    if (callbackName) {
        self.backCallBackName = callbackName;
    }
}

#pragma mark - 处理js消息-GetCurrentPosition方法
- (void)handleJSMessageGetCurrentPositionWithBody:(id)body {
    
    NSString *callbackJson = [NSString stringWithFormat:@"%@", ((NSString *)body)];
    id dic = [callbackJson mutableObjectFromJSONString];
    NSString *callbackName = nil;
    if ([dic isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary * messageDic = (NSDictionary*)dic;
        callbackName = [messageDic objectForKey:@"callback"];
    }
    
    if (callbackName) {
       
        __weak __typeof__(self) weakself = self;
        [[WSLocationManager getInstance] startUpdatesCityInfoWithBlock:^(WSLocationDescribe *aLocationDescribe, NSError *error) {
            
            __strong __typeof__(weakself) strongself = weakself;
            NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
            if (error) {
                
                [resultDic setObject:@"timeout" forKey:@"type"];
            }
            else {
                
                [resultDic setObject:@"complete" forKey:@"type"];
                [resultDic setObject:[NSString stringWithFormat:@"%f",aLocationDescribe.location.coordinate.latitude] forKey:@"lat"];
                [resultDic setObject:[NSString stringWithFormat:@"%f",aLocationDescribe.location.coordinate.longitude] forKey:@"lon"];
                [resultDic setObject:[NSString stringWithFormat:@"%f",aLocationDescribe.location.horizontalAccuracy] forKey:@"accury"];
            }
            
            [strongself webViewExecuteJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", callbackName, [resultDic JSONString]] completionHandler:nil];
        }];
    }
}

#pragma mark - 处理js消息-OnResize方法
- (void)handleJSMessageOnResizeWithBody:(id)body {
    
    CGFloat height = 0;
    NSString *callbackJson = [NSString stringWithFormat:@"%@", ((NSString *)body)];
    id dic = [callbackJson mutableObjectFromJSONString];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        
        height = [[dic objectForKey:@"height"] doubleValue];
    }
    [self resetViewHeight:height];
}

#pragma mark - 处理js消息-OpenGallery方法
- (void)handleJSMessageOpenGalleryWithBody:(id)body {
    
    NSString *callbackJson = [NSString stringWithFormat:@"%@", ((NSString *)body)];
    id dic = [callbackJson mutableObjectFromJSONString];
    NSArray *photos = nil;
    if ([dic isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary * messageDic = (NSDictionary*)dic;
        photos = [messageDic objectForKey:@"photos"];
    }
    
    WSPhotoBrowserViewController *photobrowseVC = [[WSPhotoBrowserViewController alloc] initWithImageIDs:(NSMutableArray *)photos];
    [photobrowseVC gotoPage:0];
    photobrowseVC.enableEdit = NO;
    photobrowseVC.isAllowDeletePhoto = NO;
    photobrowseVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:photobrowseVC animated:YES completion:nil];
}

#pragma mark - 处理js消息-ShareParams方法
- (void)handleJSMessageShareParamsWithBody:(id)body {
    
    [self loadShareButtonItem];
}

#pragma mark - 处理js消息-ShareTextToWeChat方法
- (void)handleJSMessageShareTextToWeChatWithBody:(id)body {
    
    [self shareImgToWXItem];
}

#pragma mark - 处理js消息-JumpRouteMap方法
- (void)handleJSMessageJumpRouteMapWithBody:(id)body {
    
    NSString *jsonString = (NSString *)body;
    self.shareDataDict = [jsonString objectFromJSONString];
    [self loadMapButtonItem];
}

#pragma mark - 处理js消息-RequestServerDataByJs方法
- (void)handleJSMessageRequestServerDataByJsWithBody:(id)body {
    
    NSString *callbackJson = [NSString stringWithFormat:@"%@", ((NSString *)body)];
    if ([self.delegate respondsToSelector:@selector(didGetDataFromReportForm:)]) {
        [self.delegate realTimeRefreshAcvtDatasWithGetDataFromReportForm:callbackJson];
    }
    [self backAction];
}

#pragma mark - 处理js消息-RemoveFuncMarker方法
- (void)handleJSMessageRemoveFuncMarkerWithBody:(id)body {
    
    NSString *callbackJson = (NSString *)body;
    id funcDataArray = [callbackJson mutableObjectFromJSONString];
    if ([funcDataArray isKindOfClass:[NSArray class]]) {
        [WSBaseStoreOtherDataDBService saveFuncTipData:funcDataArray];
    }
}

#pragma mark - 处理js消息-Functip方法
- (void)handleJSMessageFunctipWithBody:(id)body {
    
    NSString *callbackJson = (NSString *)body;
    id funcDataArray = [callbackJson mutableObjectFromJSONString];
    if ([funcDataArray isKindOfClass:[NSArray class]]) {
        [WSBaseStoreOtherDataDBService saveFuncTipData:funcDataArray];
    }
}

#pragma mark - 处理js消息-AddAcvt方法
- (void)handleJSMessageAddAcvtWithBody:(id)body {
    
    [self buttonClick];
}

#pragma mark - 处理js消息-UpdateStoreInfoDatas方法
- (void)handleJSMessageUpdateStoreInfoDatasWithBody:(id)body {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ModifyStoreRefreshNotification object:nil];
}

#pragma mark - 处理js消息-NeedUpdateStoreList方法
- (void)handleJSMessageNeedUpdateStoreListWithBody:(id)body {

    [[NSNotificationCenter defaultCenter] postNotificationName:CustomerQueryRefreshNotification object:nil];
}

#pragma mark - 处理js消息-AddNewStore方法
- (void)handleJSMessageAddNewStoreWithBody:(id)body {
    
    NSString *jsonString = (NSString *)body;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:kAddNewStoreApply object:nil userInfo:userInfo];
}

#pragma mark - 处理js消息-GoHome方法
- (void)handleJSMessageGoHomeWithBody:(id)body {
    
    if (self.tabBarController) {
        
        self.tabBarController.selectedIndex = 0;
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

#pragma mark - 处理js消息-SetFuncMarker方法
- (void)handleJSMessageSetFuncMarkerWithBody:(id)body {
    
    NSString *jsonString = (NSString *)body;
    NSDictionary *tmpDic = [jsonString objectFromJSONString];
    [self setFuncMarkerParams:tmpDic];
}

#pragma mark - 处理js消息-OpenNewWebView方法
- (void)handleJSMessageOpenNewWebViewWithBody:(id)body {
    
    NSString *urlString = (NSString *)body;
    NSArray *paramArray = [urlString componentsSeparatedByString:@"#"];
    if (paramArray.count > 1) {
        
        NSArray *urlArray = [urlString componentsSeparatedByString:@"&imei"];
        if (urlArray.count > 1) {
            urlString = [NSString stringWithFormat:@"%@#%@", [urlArray firstObject], [paramArray lastObject]];
        }
    }
    
    WSReportFormController *link;
    link = [[WSReportFormController alloc] initWithURL:[NSURL URLWithString:urlString]];
    link.title = self.title;
    link.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:link animated:YES];
}

#pragma mark - 处理js消息-JumpStoreTask方法
- (void)handleJSMessageJumpStoreTaskWithBody:(id)body {
    
    NSString *jsonString = (NSString *)body;
    NSDictionary *tmpDic = [jsonString objectFromJSONString];
    NSString *storeId = @"";
    if (tmpDic && [tmpDic objectForKey:@"storeId"]) {
        storeId = [tmpDic objectForKey:@"storeId"];
    }
    
    if (storeId.length == 0) {
        return;
    }
    
    self.jumpStoreID = storeId;
    [self requestStoreInfoWithStoreId:storeId];
}

#pragma mark - 设置网页视图方法
- (void)setupWebView {

    NSURL *url = [self getURL];
    if ([url.absoluteString rangeOfString:PULL_REFRESH_FORBIDDEN].location == NSNotFound && ![self.currentFuncs.opt.isRefresh isEqualToString:@"0"]) {

        __weak __typeof__(self) weakSelf = self;
        WSMJProgressHeader *header = [WSMJProgressHeader headerWithRefreshingBlock:^{

            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            strongSelf.isManualRefresh = YES;

            AFNetworkReachabilityStatus networkReachabilityStatus = [[WinAFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
            if (networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable) {

                strongSelf.curentURL = nil;
                [strongSelf webViewReload];
            }
            else {

                [strongSelf closeWebViewMJHeader];
                NSString *text = NSLocalizedString(@"似乎已断开与互联网的连接", nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:text tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:1.5f];
            }
        }];

        header.automaticallyChangeAlpha = YES;
        self.reportFormWKWebView.scrollView.mj_header = header;
    }

    [self.view addSubview:self.reportFormWKWebView];

    [self.reportFormWKWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f));
    }];
}

#pragma mark - 网页重载方法
- (void)webViewReload {
    
    if (!self.reportFormWKWebView) {
        return;
    }
    
    NSString *signKey = [WSAppData getObjectbyKey:APPDATA_SIGNKEY];
    if (!signKey || [signKey length] == 0) {
        
        [self setupWebViewReload];
        return;
    }
    
    NSString *urlString = [self.reportFormWKWebView.URL absoluteString];
    NSString *newUrlString = [self getToResignUrl:urlString];
    if (!newUrlString) {
        
        [self setupWebViewReload];
        return;
    }
    
    NSString *toSignUrlString = [self getToSignUrl:newUrlString];
    NSURL *toSignUrl = [NSURL URLWithString:toSignUrlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:toSignUrl];
    [self setRequestPostBody:request];
    
    [self setupWebViewLoadRequest:request];
}

#pragma mark - 加载网页请求方法
- (void)loadWebViewRequest {
    
    NSURL *requestUrl = [self getURL];
    if ([WSMjetLoginManager isNeedMejtLogin]) {
        
        if ([WSMjetLoginManager isNeedGetSSOSession]) {
            
            if ([WSHttpURLHelper getLoginDataServerUrl] && [requestUrl.absoluteString rangeOfString:[WSHttpURLHelper getLoginDataServerUrl]].location != NSNotFound) {
                
                NSString *sessionid = [WSCookieHelper getCookieValueForName:kSSO_JSESSIONID url:[NSURL URLWithString:[WSHttpURLHelper getLoginDataServerUrl]]];
                if (!([sessionid length] > 0)) {
                    
                    [self webViewShowHUDWithText:NSLocalizedString(@"logining_prompt", nil) tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
                    [WSMjetLoginManager sharedInstance].delegate = self;
                    [[WSMjetLoginManager sharedInstance] getSSOSessionForUrl:[WSHttpURLHelper getLoginDataServerUrl]];
                    return;
                }
            }
            else if ([WSHttpURLHelper getConfigFileServerIP] && [requestUrl.absoluteString rangeOfString:[WSHttpURLHelper getConfigFileServerIP]].location != NSNotFound) {
                
                NSString *sessionid = [WSCookieHelper getCookieValueForName:kSSO_JSESSIONID url:[NSURL URLWithString:[WSHttpURLHelper getConfigFileServerIP]]];
                if (!([sessionid length] > 0)) {
                    
                    [self webViewShowHUDWithText:NSLocalizedString(@"logining_prompt", nil) tips:NSLocalizedString(@"pleaseplease_wait_wait", nil) tapTarget:self action:nil];
                    [WSMjetLoginManager sharedInstance].delegate = self;
                    [[WSMjetLoginManager sharedInstance] getSSOSessionForUrl:[WSHttpURLHelper getConfigFileServerIP]];
                    return;
                }
            }
        }
        else {
            
            if ([WSHttpURLHelper getLoginDataServerUrl] && [requestUrl.absoluteString rangeOfString:[WSHttpURLHelper getLoginDataServerUrl]].location != NSNotFound) {
                
                NSString *serverUrl = [WSHttpURLHelper getLoginDataServerUrl];
                NSArray *urlCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:serverUrl]];
                if (!urlCookies || [urlCookies count] == 0) {
                    
                    NSArray *allCookies = [WSMjetLoginManager sharedInstance].allMjetCookies;
                    [WSCookieHelper setCookies:allCookies forURLString:serverUrl];
                }
            }
            else if ([WSHttpURLHelper getConfigFileServerIP] && [requestUrl.absoluteString rangeOfString:[WSHttpURLHelper getConfigFileServerIP]].location != NSNotFound){
                
                NSString *serverUrl = [WSHttpURLHelper getConfigFileServerIP];
                NSArray *urlCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:serverUrl]];
                if (!urlCookies || [urlCookies count] == 0) {
                    
                    NSArray *allCookies = [WSMjetLoginManager sharedInstance].allMjetCookies;
                    [WSCookieHelper setCookies:allCookies forURLString:serverUrl];
                }
            }
        }
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:requestUrl];
    NSString *requestUrlStr = [[requestUrl absoluteString] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    if (requestUrlStr == nil || requestUrlStr.length < 1) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, PHONE_STATUSBAR_HEIGHT, self.view.width, 40)];
        label.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        label.backgroundColor=[UIColor clearColor];
        label.textAlignment=NSTextAlignmentCenter;
        NSString *nodata = NSLocalizedString(@"acvt_type_empty_label", nil);
        label.text = nodata;
        [self.view addSubview:label];

        if (self.currentFuncs.opt && self.currentFuncs.opt.isHideTitle) {
            [self addSkipButton];
        }
        
        [self setupWebViewHidden:YES];
    }
    else {
        [self setupWebViewHidden:NO];
    }
    
    [request setValue:[WCBaseRequest getUserAgent] forHTTPHeaderField:@"User-Agent"];
    [self setRequestPostBody:request];
    [self setupWebViewLoadRequest:request];
}

#pragma mark - 清除缓存与Cookie方法
- (void)cleanCacheAndCookie {
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{}];
}

#pragma mark - 设置网页重载方法
- (void)setupWebViewReload {

    [self.reportFormWKWebView reload];
}

#pragma mark - 设置网页加载请求方法
- (void)setupWebViewLoadRequest:(NSMutableURLRequest *)request {
    
    NSString *serverUrl = [WSHttpURLHelper getLoginDataServerUrl];
    if ([serverUrl hasSuffix:@"/"]) {
        serverUrl = [serverUrl substringToIndex:[serverUrl length] - 1];
    }
    serverUrl = [NSString stringWithFormat:@"%@/login.do?noresponsebody=1", serverUrl];
    
    NSArray *urlCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:serverUrl]];
    if (@available(iOS 11.0, *)) {
    
        WKHTTPCookieStore *cookieStore = self.reportFormWKWebView.configuration.websiteDataStore.httpCookieStore;
        for (NSHTTPCookie *cookie in urlCookies) {
            [cookieStore setCookie:cookie completionHandler:^{}];
        }
    }
    else {
    
        NSHTTPCookieStorage *shareCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in urlCookies) {
            [shareCookie setCookie:cookie];
        }
    }
    
    if (urlCookies.count > 0) {
        
        NSDictionary *reqHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:urlCookies];
        [request setValue:[reqHeader objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
        self.cookieDic = reqHeader.mutableCopy;
        NSLog(@"cookie------>%@",reqHeader);
        for (NSHTTPCookie *cookie in urlCookies) {
            
            if ([cookie.name isEqualToString:@"JSESSIONID"]) {
                
                [request setValue:cookie.value forHTTPHeaderField:@"JSESSIONID"];
                
                NSString *cookieValue = [NSString stringWithFormat:@"'JSESSIONID = %@'", cookie.value];
                NSString *source = [NSString stringWithFormat: @"document.cookie = %@", cookieValue];
                WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
                [self.reportFormWKWebView.configuration.userContentController addUserScript:cookieScript];
            }
        }
    }
    [self.reportFormWKWebView loadRequest:request];
}

#pragma mark - 关闭网页mj头视图方法
- (void)closeWebViewMJHeader {

    [self.reportFormWKWebView.scrollView.mj_header endRefreshing];
}

#pragma mark - 网页执行js命令方法
- (void)webViewExecuteJavaScriptFromString:(NSString *)script completionHandler:(void (^)(NSString *result, NSError *error))completionHandler {

    [self.reportFormWKWebView evaluateJavaScript:script completionHandler:^(NSString *result, NSError * _Nullable error) {
        
        if (completionHandler) {
            completionHandler(result, error);
        }
    }];
}

#pragma mark - 设置网页隐藏展示方法
- (void)setupWebViewHidden:(BOOL)hidden {

    [self.reportFormWKWebView setHidden:hidden];
}

#pragma mark - 设置网页隐藏hud方法
- (void)webViewHideHUDWithAnimated:(BOOL)animated {

    [MBProgressHUD hideHUDForView:self.reportFormWKWebView animated:animated];
}

#pragma mark - 设置网页显示hud方法
- (void)webViewShowHUDWithText:(NSString *)text tips:(NSString *)tips tapTarget:(id)target action:(SEL)action {

    [MBProgressHUD showHUDAddedTo:self.reportFormWKWebView withText:text  tips:tips tapTarget:target action:action];
}

#pragma mark - 获取网页是否可以返回方法
- (BOOL)getWebViewCanGoBack {

    return [self.reportFormWKWebView canGoBack];
}

#pragma mark - 重置视图高度方法
- (void)resetViewHeight:(CGFloat)webViewHeight {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(resetFrame)]) {
        
        if (webViewHeight == 0) {
            
            __weak __typeof__(self) weakself = self;
            [self webViewExecuteJavaScriptFromString:@"document.body.clientHeight" completionHandler:^(NSString *result, NSError *error) {

                __strong __typeof__(weakself) strongself = weakself;
                CGFloat webViewHeight = [result floatValue];
                if (webViewHeight > kViewHeight && !FLOAT_IS_EQUAL(webViewHeight, self.viewHeight)) {

                    strongself.viewHeight = webViewHeight;
                    [strongself.delegate resetFrame];
                }
            }];
            
            return;
        }
        
        if (webViewHeight > kViewHeight && !FLOAT_IS_EQUAL(webViewHeight, self.viewHeight)) {
            self.viewHeight = webViewHeight;
            [self.delegate resetFrame];
        }
    }
}

#pragma mark - 判断是否展示新视图管理器请求方法
- (BOOL)shouldPushNewControllerWithRequest:(NSURLRequest *)request navigationType:(WKNavigationType)navigationType {
    
    if (navigationType == WKNavigationTypeOther) {
        
        if (!self.curentURL) {
            self.curentURL = request.URL;
        }
        else {
        
            if (![self.curentURL isEqual:request.URL] && ![[self getToResignUrl:self.curentURL.absoluteString] isEqualToString:[self getToResignUrl:request.URL.absoluteString]]) {
                
                if ([request.URL.absoluteString rangeOfString:@"http"].location != 0) {
                    return NO;
                }

                if ([self isNewWindowWhenClickLink:request.URL]) {
                    self.lastUrl = request.URL.absoluteString;
                    return YES;
                }
            }
        }
    }
    else if (navigationType == WKNavigationTypeLinkActivated || navigationType == WKNavigationTypeFormSubmitted ){
        
        if (!self.curentURL) {
            self.curentURL = request.URL;
        }
        else {
            
            if (![self.curentURL isEqual:request.URL]) {
                
                if ([request.URL.absoluteString rangeOfString:@"My97DatePicker"].location != NSNotFound) {
                    self.lastUrl = request.URL.absoluteString;
                    return NO;
                }

                if (navigationType == WKNavigationTypeFormSubmitted) {
                    
                    if ([self isNewWindowWhenClickLink:request.URL]) {
                        self.lastUrl = request.URL.absoluteString;
                        return YES;
                    }
                    else {
                        return NO;
                    }
                }
                else {
                    
                    if ([self isNewWindowWhenClickLink:request.URL]) {
                        return YES;
                    }

                    if (navigationType == WKNavigationTypeLinkActivated) {
                        return NO;
                    }
                    
                    return YES;
                }
            }
        }
    }

    return NO;
}

#pragma mark - 右按键上传方法
- (void)executeUpload {
    
    [self webViewExecuteJavaScriptFromString:@"javascript:upload()" completionHandler:nil];
}
- (NSURL *)getURL {
    
    NSURL *requestUrl;
    if (self.workMode == WSReportFormControllerWorkModeReportForm) {
        NSString *serverUrl = [WSOnlineConsultationService rebuildOnlineConsultationUrlStringWithUrl:self.currentFuncs.filter];
        requestUrl = [self processUrl:serverUrl];
    }
    else {
        requestUrl = self.loadURL;
    }
    return requestUrl;
}

- (NSURL *)processUrl:(NSString *)originUrlString {
    
    NSString *url = [originUrlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL isHaveStoreIDFormat = [url rangeOfString:StoreIDFormat].location != NSNotFound;
    BOOL isHaveEmpIDFormat = [url rangeOfString:EmpIDFormat].location != NSNotFound;
    BOOL isHaveSrIDFormat = [url rangeOfString:SrIDFormat].location != NSNotFound;
    
    BOOL isNeedAutoAddParam = YES;
    if (isHaveStoreIDFormat || isHaveEmpIDFormat || isHaveSrIDFormat) {
        isNeedAutoAddParam = NO;
    }
    
    if (isHaveStoreIDFormat) {
        
        if (self.currentStore.Id) {
            url = [url stringByReplacingOccurrencesOfString:StoreIDFormat withString:self.currentStore.Id];
        }
    }
    else {
        
        if (self.currentStore.Id && isNeedAutoAddParam) {
            url = [NSString stringWithFormat:@"%@%@", url, self.currentStore.Id];
        }
    }

    if (isHaveEmpIDFormat) {
        
        if ([WSAppData getObjectbyKey:APPDATA_EMPID]) {
            url = [url stringByReplacingOccurrencesOfString:EmpIDFormat withString:[WSAppData getObjectbyKey:APPDATA_EMPID]];
        }
    }
    
    if (isHaveSrIDFormat) {
        
        if (self.currentStore.srid) {
            url = [url stringByReplacingOccurrencesOfString:SrIDFormat withString:self.currentStore.srid];
        }
        else if (self.currentSubEmpStore.Id) {
            url = [url stringByReplacingOccurrencesOfString:SrIDFormat withString:self.currentSubEmpStore.Id];
        }
        else {
            url = [url stringByReplacingOccurrencesOfString:SrIDFormat withString:@""];
        }
    }
    else {
        
        if (self.currentStore.srid && isNeedAutoAddParam) {
            url = [NSString stringWithFormat:@"%@%@", url, self.currentStore.srid];
        }
    }
    
    if ([url rangeOfString:AcvtIDFormat].location != NSNotFound) {
        
        if (self.currentAcvtBean.acvtId) {
            url = [url stringByReplacingOccurrencesOfString:AcvtIDFormat withString:self.currentAcvtBean.acvtId];
        }
    }
    
    if ([url rangeOfString:BizDateFormat].location != NSNotFound) {
        
        NSString *bizDate;
        if ([self.bizDate length] > 0) {
            bizDate = self.bizDate;
        }
        else {
            bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        }
        url = [url stringByReplacingOccurrencesOfString:BizDateFormat withString:bizDate];
    }
    
    url = [self resetUrl:url];
    url = [self getToSignUrl:url];
    NSURL *finalUrl = [NSURL URLWithString:url];
    if (finalUrl == nil) {
        finalUrl = [NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    }
    return finalUrl;
}

- (NSString *)resetUrl:(NSString *)urlString {
    
    if (!urlString || [urlString length] == 0) {
        return urlString;
    }
    
    NSString *language = [UIDevice getPreferredLanguage];
    if ([urlString rangeOfString:@"?"].location != NSNotFound) {
        urlString = [NSString stringWithFormat:@"%@&i18n_locale=%@", urlString, language];
    }
    else {
        urlString = [NSString stringWithFormat:@"%@?i18n_locale=%@", urlString, language];
    }
    
    urlString = [self getScreenSizeUrl:urlString];
    urlString = [self checkAndReplaceQueryKeyWithUrl:urlString];
    return urlString;
}

- (NSString *)getToSignUrl:(NSString *)urlString {
    
    if (self.workMode != WSReportFormControllerWorkModeReportForm) {
        return urlString;
    }
    
    if (!urlString || [urlString length] == 0) {
        return urlString;
    }
    
    return [WSHttpURLHelper getNeedsSignUrl:urlString];
}

- (NSString *)checkAndReplaceQueryKeyWithUrl:(NSString *)urlStr {
    
    NSString *requestUrlStr = urlStr;
    if ([requestUrlStr rangeOfString:QueryKeyFormat].location != NSNotFound) {
        
        requestUrlStr = [requestUrlStr stringByReplacingOccurrencesOfString:QueryKeyFormat withString:[DateUtil getCurrentTimeIntervalDoubleString]];
    }
    else {
        
        if (requestUrlStr && [requestUrlStr rangeOfString:WEB_QUERY_KEY].location != NSNotFound) {
            
            NSInteger indexOfQueryKeyStr = 0;
            NSString *tempQueryKeyStr = @"";
            NSArray *tempStrComArray = [requestUrlStr componentsSeparatedByString:@"&"];
            for (NSString *str in tempStrComArray) {
                
                if (str && [str rangeOfString:@"queryKey"].location != NSNotFound) {
                    
                    NSArray *strComArray = [str componentsSeparatedByString:@"="];
                    tempQueryKeyStr = [NSString stringWithFormat:@"%@=%@", [strComArray firstObject], [DateUtil getCurrentTimeIntervalDoubleString]];
                    break;
                }
                indexOfQueryKeyStr++;
            }
            
            requestUrlStr = @"";
            for (int i = 0; i < [tempStrComArray count]; i ++) {
                
                if (i == 0) {
                    requestUrlStr = [tempStrComArray objectAtIndex:i];
                }
                else {
                    
                    if (i == indexOfQueryKeyStr) {
                        requestUrlStr = [NSString stringWithFormat:@"%@&%@", requestUrlStr,tempQueryKeyStr];
                    }
                    else {
                        requestUrlStr = [NSString stringWithFormat:@"%@&%@", requestUrlStr,[tempStrComArray objectAtIndex:i]];
                    }
                }
            }
        }
    }
    
    return requestUrlStr;
}

- (NSString *)getToResignUrl:(NSString *)urlString {
    
    NSRange range = [urlString rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        
        NSString *paramString = [urlString substringFromIndex:range.location + 1];
        NSArray *paramArray = [paramString componentsSeparatedByString:@"&"];
        if ([paramArray count] >= 6) {
            
            NSMutableArray *paramTempArray = [NSMutableArray arrayWithCapacity:paramArray.count];
            for (NSString *param in paramArray) {
                
                if ([param rangeOfString:@"imei="].location == NSNotFound &&
                    [param rangeOfString:@"appid="].location == NSNotFound &&
                    [param rangeOfString:@"uid="].location == NSNotFound &&
                    [param rangeOfString:@"timestamp="].location == NSNotFound &&
                    [param rangeOfString:@"nonce="].location == NSNotFound &&
                    [param rangeOfString:@"winc_sign="].location == NSNotFound ) {
                    [paramTempArray addObject:param];
                }
            }
            
            if ([paramTempArray count] == 0) {
                return [urlString substringToIndex:range.location];
            }
            else {
            
                NSString *newParamString = [paramTempArray componentsJoinedByString:@"&"];
                NSString *newUrlString = [NSString stringWithFormat:@"%@%@", [urlString substringToIndex:range.location + 1], newParamString];
                return newUrlString;
            }
        }
    }
    
    return nil;
}

- (void)setRequestPostBody:(NSMutableURLRequest *)request {
    
    if (self.workMode == WSReportFormControllerWorkModeURL && [self.postBody length] > 0) {
        
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: self.postBody];
    }
}

- (void)addSkipButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor whiteColor];
    NSString *title = NSLocalizedString(@"skip", nil);
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font=[UIFont systemFontOfSize:15.0f];
    button.layer.backgroundColor=[UIColor colorWithRed:(231.0f/255) green:(239.0f/255) blue:(243.0f/255) alpha:(1.0f)].CGColor;
    button.layer.borderColor=[UIColor colorWithRed:(79.0f/255) green:(107.0f/255) blue:(127.0f/255) alpha:(1.0f)].CGColor;
    button.layer.cornerRadius = 15;
    button.layer.borderWidth = 2.5;
    [button addTarget:self action:@selector(closeImage) forControlEvents:UIControlEventTouchUpInside];
    button.frame=CGRectMake(self.view.width-70, 25, 58, 30);
    [self.view addSubview:button];
}

- (void)clearAllNavBBI {
    
    [self getNavigationItem].leftBarButtonItems = nil;
    [self getNavigationItem].rightBarButtonItems = nil;
    [self getNavigationItem].titleView = nil;
}

- (void)addBackBarButtonItem {
    
    NSMutableArray *barButtonItems = [NSMutableArray arrayWithArray:[self getNavigationItem].leftBarButtonItems] ;
    if ([self getNavigationController].viewControllers.count <= 1) {
    }
    else {
        
        UIBarButtonItem *backBBI = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
        [barButtonItems addObject:backBBI];
        [self getNavigationItem].leftBarButtonItems = barButtonItems;
    }
}

- (void)checkRightBarButtonItem
{
    self.isAdd = [NSString stringWithValue: self.currentFuncs.opt.isAdd];
    if ([self.currentFuncs.opt.showStyle isEqualToString:@"addBtnHide"]) {
        return;
    }
    
    if (self.curentURL && [self.curentURL.absoluteString containsString:@"addUploadBtn=1"]) {
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageForName:@"icon_upload"] style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(executeUpload)];
        [self addRightBarButtonItem:buttonItem];
        return;
    }
    
    self.isAdd = [NSString stringWithValue: self.currentFuncs.opt.isAdd];
    if ([self.isAdd length] > 0 && !([self.isAdd isEqualToString:@"Y"] && [self.isAdd isEqualToString:@"N"])) {
        
        UIBarButtonItem *buttonItem = self.buttonItem;
        if (!buttonItem) {
            
            NSString *buttonName = self.currentFuncs.buttonName;
            if (buttonName && [buttonName length] > 0) {
                buttonName = [buttonName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
            else {
                buttonName = NSLocalizedString(@"new_add",nil);
            }
            buttonItem = [[UIBarButtonItem alloc]initWithTitle:buttonName style:UIBarButtonItemStylePlain target:self action:@selector(buttonClick)];
        }
        
        [self addRightBarButtonItem:buttonItem];
        return;
    }
    
    [self addRightBarButtonItem:self.buttonItem];
}

- (void)addRightBarButtonItem:(UIBarButtonItem *)buttonItem {
    
    if (!buttonItem) {
        return;
    }
    
    if (self.ownParentViewController) {
        self.ownParentViewController.navigationItem.rightBarButtonItem = buttonItem;
    }
    else {
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
}

-  (void)writeSystemInfoToLog {
    
    LogInfo(@"系统版本：%@ %@", [[UIDevice currentDevice] systemName] , [[UIDevice currentDevice] systemVersion]);
    LogInfo(@"设备版本：%@", [[UIDevice currentDevice] platform]);
    LogInfo(@"是否越狱：%@", [[UIDevice currentDevice] isJailBroken] ? @"post_quit_yes" : @"post_quit_no");
    LogInfo(@"svn版本号：%@", [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName]);
    LogInfo(@"可用内存：%f MB", [UIDevice freeMemory]/1024.0/1024.0);
    LogInfo(@"已用内存：%f MB", [UIDevice usedMemory]/1024.0/1024.0);
    
    CGFloat freeMB = [[UIDevice freeDiskSpaceInBytes] floatValue]/1024.0/1024.0;
    NSString *unit = @"MB";
    if (freeMB / 1024.0 > 1.0) {
        freeMB = freeMB / 1024.0;
        unit = @"GB";
    }
    LogInfo(@"可用存储空间: %f %@", freeMB, unit);
}


- (BOOL)isNeedLogin:(NSURL *)url {
    
    if ([WSMjetLoginManager isNeedMejtLogin]) {
        
        NSArray *queryArray = [url.query componentsSeparatedByString:@"&"];
        for (NSString *queryStr in queryArray) {
            
            NSArray *parasArray = [queryStr componentsSeparatedByString:@"="];
            NSString *paraName = [parasArray firstObject];
            NSString *paraValue = nil;
            if ([parasArray count] > 1) {
                
                paraValue = [parasArray objectAtIndex:1];
                if ([paraName isEqualToString:@"msg"]) {
                    
                    if ([paraValue isEqualToString:AUTH_BY_HW_UNIPORTAL]) {
                        return YES;
                    }
                    break;
                }
            }
        }
    }
    else {
        
        NSString *urlStr = [url absoluteString];
        if (urlStr && [urlStr rangeOfString:@"login"].location != NSNotFound) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isNewWindowWhenClickLink:(NSURL *)url {

    NSString * requestUrl = url.absoluteString;
    if ([requestUrl containsString:@"?"]) {
        requestUrl = [[requestUrl componentsSeparatedByString:@"?"] lastObject];
    }
    
    if ([requestUrl rangeOfString:kNewWindowWhenClickLink].length && [requestUrl rangeOfString:@"#"].location == NSNotFound && (![url.absoluteString isEqualToString:self.lastUrl])) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)loadShareButtonItem {
    
    UIBarButtonItem *shareBarButtonItem = nil;
    NSString *shareFunction = self.shareDataDict[@"shareFunction"];
    if (![shareFunction isEqualToString:@"N"]) {
       shareBarButtonItem= self.shareBarButtonItem;
    }
    if (self.ownParentViewController) {
        self.ownParentViewController.navigationItem.rightBarButtonItem = shareBarButtonItem;
    }
    else {
        self.navigationItem.rightBarButtonItem = shareBarButtonItem;
    }
}

- (void)loadShareView {

    NSMutableArray *items = [NSMutableArray array];
    NSDictionary * infoDic = [[NSBundle mainBundle]infoDictionary];
    NSArray *CFBundleURLTypes = [infoDic objectForKey:@"CFBundleURLTypes"];
    for (NSDictionary *obj in CFBundleURLTypes) {
        
        NSString *bundleURLName = obj[@"CFBundleURLName"];
        if ([bundleURLName isEqualToString:@"weixin"]) {
            
            NSArray *urlSchemes = obj[@"CFBundleURLSchemes"];
            NSString *appId = [urlSchemes firstObject];
            if (appId && appId.length > 0) {
                
                WSShareItem *item = [[WSShareItem alloc]initWithTitle:NSLocalizedString(@"wechat", nil)  Icon:@"icon_wechat"];
                [items addObject:item];
                
                WSShareItem *item2 = [[WSShareItem alloc]initWithTitle:NSLocalizedString(@"朋友圈", nil)  Icon:@"icon_moments"];
                [items addObject:item2];
            }
        }
        
        if ([bundleURLName isEqualToString:@"mqq"]) {
            
            NSString *appId = (NSString *)[obj[@"CFBundleURLSchemes"] firstObject];
            if (appId && appId.length > 0) {
                
                WSShareItem *item = [[WSShareItem alloc]initWithTitle:NSLocalizedString(@"QQ好友", nil) Icon:@"icon_qq"];
                [items addObject:item];
                
                WSShareItem *item2 = [[WSShareItem alloc]initWithTitle:NSLocalizedString(@"QQ空间", nil)  Icon:@"icon_qzone"];
                [items addObject:item2];
            }
        }
        
        NSArray *shareIDs = [WSEnvrionment getWWCHAT_SHARE_ID];
        if (shareIDs.count > 1) {
            
            if ([bundleURLName isEqualToString:@"qyweixin"]) {
                WSShareItem * itemSms = [[WSShareItem alloc]initWithTitle:NSLocalizedString(@"wxworkwechat", nil) Icon:@"WechatIMG"];
                [items addObject:itemSms];
            }
        }
    }
    
    NSString *type = self.shareDataDict[@"type"];
    BOOL isTypeImg = YES;
    if (![type isEqualToString:@"img"]) {
        
        isTypeImg = NO;
        WSShareItem * itemSms = [[WSShareItem alloc]initWithTitle:NSLocalizedString(@"sms_lable", nil) Icon:@"icon_sms"];
        [items addObject:itemSms];
    }
    
    __weak typeof(self) weakSelf = self;
    [WSBottomPopView showToView:self.view.window withItems:(NSArray *)items andSelectBlock:^(WSShareItem *item) {

        NSString * title = weakSelf.shareDataDict[@"title"];
        NSString * imageUrl = weakSelf.shareDataDict[@"imgurl"];
        NSString * content = weakSelf.shareDataDict[@"content"];
        NSString * weburl = weakSelf.shareDataDict[@"weburl"];
        NSString *linkURL = weburl;
        if (isTypeImg) {
            linkURL = imageUrl;
        }
        [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        }
                                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            
            CGSize imgSize = image.size;
            imgSize.height = 99.0f;
            imgSize.width = 99.0f;
            UIImage * img = [self imageWithImage:image scaledToSize:imgSize];
            NSData *imageData = UIImageJPEGRepresentation(img,0.00001);
            img = [UIImage imageWithData:imageData];
            
            if (item && [item.title isEqualToString:NSLocalizedString(@"sms_lable", nil)]) {
                [self sendMessage];
            }
            
            if (item && ([item.title isEqualToString:NSLocalizedString(@"wxworkwechat", nil)])) {
                
                NSString *titleAlt = NSLocalizedString(@"not_wxworkwechat", nil);
                NSString *messageAlt = NSLocalizedString(@"please_install_wxworkwechat", nil) ;
                if ([linkURL hasSuffix:@".html"]) {
                    
                    if ([WWKApi isAppInstalled]) {
                        
                        WWKSendMessageReq *req = [[WWKSendMessageReq alloc] init];
                        WWKMessageLinkAttachment *attachment = [[WWKMessageLinkAttachment alloc] init];
                        attachment.title = title;
                        attachment.url = linkURL;
                        attachment.icon = UIImagePNGRepresentation([UIImage imageNamed:@"Icon"]);
                        req.attachment = attachment;
                        [WWKApi sendReq:req];
                    }
                    else {
                        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:titleAlt tips:messageAlt tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                    }
                }
                else {
                    
                    [[WSRequestHelper shareInstance] downloadImageWithUrl:linkURL progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"加载中请稍后...", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
                    }
                                                                completed:^(UIImage *image, NSError *error, BOOL finished, NSURL *imageURL) {
                    
                        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
                        if (error) {
                            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:nil tips:error.localizedDescription tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                        }
                        else {
                        
                            if ([WWKApi isAppInstalled]) {
                                
                                [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
                                WWKSendMessageReq *req = [[WWKSendMessageReq alloc] init];
                                WWKMessageImageAttachment *attachment = [[WWKMessageImageAttachment alloc] init];
                                attachment.filename = @"ocr.jpg";
                                attachment.path = [self getSharePhotoPathWithImage:image];
                                req.attachment = attachment;
                                [WWKApi sendReq:req];
                            }
                            else {
                                
                                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:titleAlt tips:messageAlt tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                            }
                        }
                    }];
                }
            }
        }];
    }];
}

- (void)sendMessage {
    
    MFMessageComposeViewController *mcvc = [[MFMessageComposeViewController alloc]init];
    mcvc.messageComposeDelegate = self ;
    
    if ([MFMessageComposeViewController canSendAttachments]) {
        
        mcvc.body = self.shareDataDict[@"weburl"] ;
        [self presentViewController:mcvc animated:YES completion:nil];
    }
}

- (void)loadMapButtonItem {
    
    UIButton *mapButton = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, 24, 24)];
    [mapButton setBackgroundColor:[UIColor clearColor]];
    [mapButton setImage:[UIImage imageNamed:@"storeMapMode"] forState:UIControlStateNormal];
    [mapButton addTarget:self action:@selector(jumpMapConntroller) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *mapBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:mapButton];
    
    self.shareBarButtonItem = mapBarButtonItem;
    if (self.ownParentViewController) {
        self.ownParentViewController.navigationItem.rightBarButtonItem = mapBarButtonItem;
    }
    else {
        self.navigationItem.rightBarButtonItem = mapBarButtonItem;
    }
    
    if (INTERFACE_IS_PAD) {
        
        UIBarButtonItem *backBBI = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
        self.barButtonItem = backBBI;
        [self getNavigationItem].leftBarButtonItem = backBBI;
    }
}

- (void)jumpMapConntroller {
    
    WSAllStoresMapViewController * mapContrl = [[WSAllStoresMapViewController alloc]initWithFuncs:self.currentFuncs];
    mapContrl.routeMapId = self.shareDataDict[@"routId"];
    mapContrl.rightButtonName = self.shareDataDict[@"backName"];

    [self.navigationController pushViewController:mapContrl animated:YES];
}

- (void)buttonClick {

    WSFuncsBeanArray *funcsBeanArray = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean *nextFuncBean = [funcsBeanArray getAllFuncsBeanWithFC:self.isAdd];
    
    if (nextFuncBean) {

        UIViewController *nextVc = nil;
        if ([nextFuncBean.ds isEqualToString:@"acvt"]) {
            
            WSBaseAcvtDBService *dbService = [[WSBaseAcvtDBService alloc] init];
            WSAcvtBean *newAddAcvtBean = [dbService queryAcvtByFilter:nextFuncBean.filter acvtCode:nil];
            WSNewAddAcvtViewController *newAcvt = [[WSNewAddAcvtViewController alloc] initWithAcvt:newAddAcvtBean Funcs:nextFuncBean Store:self.currentStore md5:nil];
            newAcvt.moduleFC = self.moduleFC;
            newAcvt.currentVisitAction = self.currentVisitAction;
            nextVc = newAcvt;
        }
        else {
                
            NSString *className = [WSPlistHelper valueForKey:nextFuncBean.fv withPlistName:kControllerMappingFileName];
            SuperWorkSpaceViewController *vc = [[NSClassFromString(className) alloc] initWithFuncs:nextFuncBean Store:self.currentStore subEmpStore:self.currentSubEmpStore];
            nextVc = vc;
        }

        if ([nextVc respondsToSelector:@selector(setSubempid:)]) {
            [nextVc performSelector:@selector(setSubempid:) withObject:self.currentSubEmpStore.Id];
        }
        nextVc.hidesBottomBarWhenPushed = YES;
            
        if (self.ownParentViewController) {
            [self.ownParentViewController.navigationController pushViewController:nextVc animated:YES];
        }
        else {
            [self.navigationController pushViewController:nextVc animated:YES];
        }
    }
}

- (void)loginWeb {
    
    self.isLogging = YES;
    
    [self webViewHideHUDWithAnimated:NO];
    [self webViewShowHUDWithText:NSLocalizedString(@"logining_prompt", nil) tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
    
    if ([WSMjetLoginManager isNeedMejtLogin]) {
        [self mjetLogin];
    }
    else {
        [self normalLogin];
    }
}

- (void)normalLogin {
    
    NSString *serverIPStr = [WSHttpURLHelper getLoginDataServerUrl];
    if (!serverIPStr || [serverIPStr length] == 0) {
        LogError(@"登录web后台，没有serverURL");
        return;
    }
    
    NSString *username = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_CALL_APP];
    NSString *passwd = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_CALL_APP];
    username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    passwd = [passwd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (!serverIPStr || !username || !passwd || username.length == 0 || passwd.length == 0) {
        
        LogError(@"登录web后台前的异常，serverURL:%@  username:%@   passwd:%@",serverIPStr,username,passwd);
        [self webViewHideHUDWithAnimated:NO];
        return;
    }
    
    if ([serverIPStr hasSuffix:@"/"]) {
        serverIPStr = [serverIPStr substringToIndex:[serverIPStr length] - 1];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginWebResponse:) name:login_web_notify object:nil];

    NSString *mobileUrlString = [WSHttpURLHelper getCompleteURL:@""];
    NSString *webUrlString = [WSHttpURLHelper getLoginDataServerUrl];
    if (![mobileUrlString isEqualToString:webUrlString]) {
        self.isNeedClearCookie = YES;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/login.do?noresponsebody=1",serverIPStr];
    [[WSRequestBase shareInstance] startReportLoginbyPost:url notifyName:login_web_notify userAccount:username userPassword:passwd];
}

- (void)loginWebResponse:(NSNotification *)sender {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:login_web_notify object:nil];
    
    [self webViewHideHUDWithAnimated:NO];
    
    self.isLogging = NO;
    
    if ((!self.currentFuncs.filter || [self.currentFuncs.filter length] < 1) && !self.loadURL) {
        
        [self webViewHideHUDWithAnimated:NO];
        return;
    }
    
    [self loadWebViewRequest];
}

- (NSString *)getScreenSizeUrl:(NSString *)urlString {
    
    if ([urlString rangeOfString:WINDOW_RESIZE].location != NSNotFound) {
        
        CGFloat scale = [UIScreen mainScreen].scale;
        urlString = [NSString stringWithFormat:@"%@&screenWD=%.0f&screenHT=%.0f", urlString, SCREEN_WIDTH * scale, SCREEN_HEIGHT * scale];
    }
    return urlString;
}


- (void)mjetLogin {
    
    [WSMjetLoginManager sharedInstance].delegate = self;
    [[WSMjetLoginManager sharedInstance] mjetLogin];
}

- (CGFloat)contentHeight {
    
    return self.viewHeight;
}

- (NSString *)getBadgeValue {
    
    if (_workMode == WSReportFormControllerWorkModeReportForm) {
        
        WSBaseStoreOtherDataDBService *dataService = [[WSBaseStoreOtherDataDBService alloc] init];
        NSInteger badgeCount = [dataService getFuncTipCountWithFC:self.currentFuncs.fc storeId:self.currentStore.Id];
        if (badgeCount > 0) {
            return [NSString stringWithFormat:@"%ld", badgeCount];
        }
    }
    return nil;
}

- (void)removeButtonItem {
    
    if (self.shareBarButtonItem) {
        
        self.shareBarButtonItem = nil;
        if (self.ownParentViewController) {
            self.ownParentViewController.navigationItem.rightBarButtonItem = nil;
        }
        else {
            self.navigationItem.rightBarButtonItem = nil;
        }
        
        if (INTERFACE_IS_PAD) {
            
            if (self.navigationController.view.width != 1024 && self.navigationController.view.height != 1024) {
                [self addFullScreenButton];
            }
        }
    }
    
    if (self.barButtonItem) {
        
        self.barButtonItem = nil;
        if (self.ownParentViewController) {
            self.ownParentViewController.navigationItem.leftBarButtonItem = nil;
        }
        else {
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
}

- (void)refreshWebView {
    
    self.isManualRefresh = YES;
    [self webViewReload];
}

- (void)closeImage {
    
    NSString *realUrlStr = [[self getURL] absoluteString];
    if (realUrlStr && [realUrlStr rangeOfString:@"nativeSkip=1"].location != NSNotFound) {
        
        WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
        delegate.welcomeReportVC = self;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backAction {
    
    [self removeButtonItem];
    
    if ([self.backFuncNameArray count] > 0) {
        
        [self webViewExecuteJavaScriptFromString:[NSString stringWithFormat:@"javascript:%@()", [self.backFuncNameArray lastObject]] completionHandler:nil];
        [self.backFuncNameArray removeLastObject];
        return;
    }
    
    if (self.backCallBackName) {
        
        NSNumber *canGoBack = [NSNumber numberWithBool:[self getWebViewCanGoBack]];
        __weak __typeof__(self) weakself = self;
        [self webViewExecuteJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)",self.backCallBackName, canGoBack] completionHandler:^(NSString *result, NSError *error) {

            __strong __typeof__(weakself) strongself = weakself;
            if (result && result.length > 0) {
                
                if ([result isEqualToString:@"false"]) {
                    
                    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"页面有内容未上传，请确认是否返回", nil)];
                    [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
                    [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
                        self.backCallBackName = nil;
                        [self backAction];
                    }];
                    [alert show];
                    return;
                }
                else if ([result isEqualToString:@"true"]) {
                    [strongself dismissOrPop];
                }
                else {
                    return;
                }
            }
        }];
    }
    
    [self dismissOrPop];
}

- (void)dismissOrPop {

    NSInteger l_count = self.ownParentViewController != nil ? [self.ownParentViewController.navigationController.viewControllers count]:[self.navigationController.viewControllers count];
    if (l_count <= 1) {
        
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else {
        
        if (_loadURL.absoluteString && [_loadURL.absoluteString rangeOfString:@"method=registIndex"].location!=NSNotFound ) {
            
            [[self getNavigationController] popToRootViewControllerAnimated:YES];
        }
        else {

            [[self getNavigationController] popViewControllerAnimated:YES];
            if (self.showTips) {
                self.showTips();
            }
        }
    }
}

- (void)mjetLoginSuccess:(NSDictionary *)dictionary {
    
    self.isLogging = NO;
    [self loadWebViewRequest];
}

- (void)mjetLoginFailed:(NSDictionary *)dictionary {
    
    self.isLogging = NO;
    
    [self webViewHideHUDWithAnimated:NO];
    
    NSString *msg = dictionary[@"errorDescription"];
    if (!msg) {
        msg = dictionary[@"string"];
    }
    if (!msg) {
        msg = NSLocalizedString(@"login_fail", nil);
    }
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}

- (void)getSSOSessionSuccess:(NSDictionary *)dictionary {
    
    [self webViewHideHUDWithAnimated:NO];
    [self loadWebViewRequest];
}

- (void)getSSOSessionFailed:(NSDictionary *)dictionary {
    
    [self webViewHideHUDWithAnimated:NO];
    NSString *title = NSLocalizedString(@"login_fail", nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}

- (void)jumpChatViewControllerWith:(id)data {
    
    NSDictionary *dict = [data objectFromJSONString];
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithCapacity:2];
    NSString *storeName=[NSString stringNotNilWithValue:dict[@"storeName"]];
    NSString *storeID=[NSString stringNotNilWithValue:dict[@"storeId"]];
    NSString *toChartName = [NSString stringNotNilWithValue:dict[@"empName"]];
    
    NSString *nickname=[[WSEMSDKManager sharedInstance]getChatNickName];
    if(nickname==nil || nickname.length<=0){
        nickname=@"";
    }
    
    NSString *headImageUrl=[[WSEMSDKManager sharedInstance]getChatHeadImageLRL];
    if(headImageUrl==nil || headImageUrl.length<=0){
        headImageUrl=@"";
    }
    
    NSMutableDictionary *extDic=[[NSMutableDictionary alloc] init];
    NSString *sourceFrom = WS_MSG_SOURCENEEDNOTIFICATION;
    [extDic setObject:sourceFrom forKey:WS_MSG_sourceFrom];
    [extDic setObject:storeID forKey:WS_MSG_toStoreId];
    [extDic setObject:storeName forKey:WS_MSG_toStoreName];
    [extDic setObject:nickname forKey:WS_MSG_fromChatrealName];
    [extDic setObject:headImageUrl forKey:WS_MSG_fromChatHeadImgUrl];

    NSString *storeImageUrl = [dict objectForKey:WS_MSG_toStoreUrl];
    if (storeImageUrl.length == 0) {
        
        storeImageUrl = [[[WSBaseAcvtdisDBService alloc]init] queryStoreImageUrlWithStoreId:storeID imgType:WSStoreImgTypeSmall];
        if (storeImageUrl) {
            
            storeImageUrl = [WSHttpURLHelper getImageCompleteURL:storeImageUrl];
            [extDic setObject:storeImageUrl forKey:WS_MSG_toStoreUrl];
        }
    }

    WSUserInfo *storeUserInfo=[[WSEMSDKManager sharedInstance]getUserInfoWithStoreID:storeID andEmpId:nil];
    NSString *conversation= [NSString stringNotNilWithValue:dict[@"userChatAccount"]];
    
    NSString *toChartHeadURL=@"";
    if(storeUserInfo.wsheadImageURL && storeUserInfo.wsheadImageURL.length>0){
        toChartHeadURL=[WSHttpURLHelper getImageCompleteURL:storeUserInfo.wsheadImageURL];
    }

    [extDic setObject:toChartHeadURL forKey:WS_MSG_toChatHeadImgUrl];
    [extDic setObject:toChartName forKey:WS_MSG_toChatrealName];
    NSString *jsonStr=[extDic JSONString];
    [jsonDict setObject:jsonStr forKey:WS_MSG_protyKey];
    
    WSChartViewController *chartViewController=[[WSChartViewController alloc]initWithConversationChatter:conversation conversationType:EMConversationTypeChat extertDic:jsonDict];
    WSStoreBean *store = [[WSStoreBean alloc]init];
    store.Id = storeID;
    store.name = storeName;
    chartViewController.store = store;
    chartViewController.imageUrlArray= dict[@"images"];
    chartViewController.navigationItem.title = storeName;
    chartViewController.hidesBottomBarWhenPushed = YES;

    if (self.ownParentViewController==nil) {
        [self.navigationController pushViewController:chartViewController animated:YES];
    }
    else {
        [self.ownParentViewController.navigationController pushViewController:chartViewController animated:YES];
    }
}

- (NSString *)getCallbackFromData:(id)data {
    
    NSDictionary *dict = [self convertToDict:data];
    if (dict) {
        return [dict objectForKey:@"callback"];
    }
    else {
        return nil;
    }
}

- (NSDictionary *)convertToDict:(id)data {
    
    if (!data) {
        return nil;
    }
    
    NSString *jsonString = [NSString stringWithFormat:@"%@",data];
    id dict = [jsonString mutableObjectFromJSONString];

    if ([dict isKindOfClass:[NSDictionary class]]) {
        return dict;
    }
    return nil;
}

- (void)showBlueToothListViewWithParam:(NSString *)str {
    
    if (!self.printerManager) {
        
        self.printerManager = [SEPrinterManager sharedInstance];
        self.printerManager.delegate = self;
    }
    
    if (!self.actionSheet) {
        self.actionSheet = [[WSBlueToothListActionSheet alloc] initWithFrame:self.view.bounds WithBaseController:self withSEPrinterManager:self.printerManager withPrintParam:str];
    }
    else {
        [self.actionSheet reloadPrintParam:str];
    }
    
    BOOL isFirst = [SEPrinterManager getSharedInstancePrinterManager] ? NO : YES;
    if (!isFirst) {
        [self showBlueToothListView];
    }
}

- (void)showBlueToothListView {
    
    if (self.printerManager.isStatePoweredOn) {
        
        [self.actionSheet show];
        return;
    }
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请打开蓝牙" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        
        NSURL *url = [NSURL URLWithString:@"App-Prefs:root=Bluetooth"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action){}];
    [alertVC addAction:setAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:^{}];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    
    return self;
}

- (void)downLoadFile:(NSString *)urlString {
    
    if (!self.downloadCallBackName || !self.downloadProgressName) {
        return;
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    WinAFURLSessionManager *manager = [[WinAFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        NSString *fileName = [self getFileNameByResponse:response];
        NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@", [WSDownloadUtil getDownloadDirectory], fileName];
        return [[NSURL alloc] initFileURLWithPath:fileFullPath];
    }
                                                    completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        if (!error) {

            [WSBaseStoreOtherDataDBService saveStoreSearchObjCode:[self getFileNameByResponse:response] flagWith:WSRF_DOWNLOAD_SEARCH_OBJ_STR_FLAG empId:[WSAppData getObjectbyKey:APPDATA_EMPID]  funcCode:urlString
                                                          bizDate:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
            
            NSMutableDictionary * resultDic = [NSMutableDictionary dictionaryWithCapacity:1];
            [resultDic setObject:@"complete" forKey:@"type"];
            
            [self webViewExecuteJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)",self.downloadCallBackName, [resultDic JSONString]] completionHandler:nil];
        }
        else {
            
            NSMutableDictionary * resultDic = [NSMutableDictionary dictionaryWithCapacity:2];
            [resultDic setObject:[error ws_localizedDescription] forKey:@"reason"];
            [resultDic setObject:@"error" forKey:@"type"];
            
            [self webViewExecuteJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)",self.downloadCallBackName, [resultDic JSONString]] completionHandler:nil];
        }
    }];

    [manager setDownloadTaskDidWriteDataBlock:^ (NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *downState = [NSString stringWithFormat:@"%lld/%lld", totalBytesWritten, totalBytesExpectedToWrite];
            NSInteger percent = (NSInteger)((CGFloat)totalBytesWritten / totalBytesExpectedToWrite * 100);
            NSString *percentString = [NSString stringWithFormat:@"%ld", (long)percent];
            
            NSMutableDictionary * resultDic = [NSMutableDictionary dictionaryWithCapacity:3];
            [resultDic setObject:downState forKey:@"downState"];
            [resultDic setObject:percentString forKey:@"percent"];
            [resultDic setObject:@"progress" forKey:@"type"];
            
            [self webViewExecuteJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)",self.downloadProgressName, [resultDic JSONString]] completionHandler:nil];
        });
    }];
    
    [task resume];
}

- (NSString *)getFileNameByResponse:(NSURLResponse *)response {
    
    NSString *fileName;
    if ([response.suggestedFilename length] > 0) {
        fileName = response.suggestedFilename;
    }
    else {
        fileName = [response.URL lastPathComponent];
    }
    
    return fileName;
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    
    if (!self.keyboardCallBackName) {
        return;
    }
    
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithCapacity:2];
    [resultDic setObject:@YES forKey:@"show"];
    [resultDic setObject:@"0" forKey:@"height"];
    [self webViewExecuteJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)",self.keyboardCallBackName, [resultDic JSONString]] completionHandler:nil];

    if ([WSDevieceUtil getOsVersionNumber] > 11.0) {
        [self performSelector:@selector(updateKeyboardSubviews:) withObject:nil afterDelay:0.01];
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    
    if (!self.keyboardCallBackName) {
        return;
    }
    
    NSMutableDictionary * resultDic = [NSMutableDictionary dictionaryWithCapacity:2];
    [resultDic setObject:@NO forKey:@"show"];
    [resultDic setObject:@"0" forKey:@"height"];
    
    [self webViewExecuteJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)",self.keyboardCallBackName, [resultDic JSONString]] completionHandler:nil];
}

- (void)updateKeyboardSubviews:(id)sender {
    
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        
        if (![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    for (UIView *formView in [keyboardWindow subviews]) {
        for (UIView *tempview in formView.subviews) {
            if ([[tempview description] rangeOfString:@"UIInputSetHostView"].location != NSNotFound) {
                for (UIView *subView in [tempview subviews]) {
                    if ([[subView description] rangeOfString:@"UIWebFormAccessory"].location != NSNotFound) {
                        for (UIView *sView in [subView subviews]) {
                            if ([[sView description] rangeOfString:@"UIInputViewContent"].location != NSNotFound) {
                                for (UIView *ssView in [sView subviews]) {
                                    if ([[ssView description] rangeOfString:@"UIToolbar"].location != NSNotFound) {
                                        UIToolbar *toolbarView = (UIToolbar *)ssView;
                                        for (UIBarButtonItem *bbi in toolbarView.items) {
                                            
                                            if (bbi.action == @selector(done:)) {
                                                
                                                [bbi setTintColor:[UIColor redColor]];
                                                
                                                if (!_webViewKeyboardDoneBtn) {
                                                    
                                                    _webViewKeyboardDoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                                                    [_webViewKeyboardDoneBtn setFrame:CGRectMake(0.0, 0.0, 50.0, 44.0)];
                                                    [_webViewKeyboardDoneBtn addTarget:subView action:bbi.action forControlEvents:UIControlEventTouchUpInside];
                                                    
                                                    [_webViewKeyboardDoneBtn setTitle:NSLocalizedString(@"complete", nil) forState:UIControlStateNormal];
                                                    [_webViewKeyboardDoneBtn setTitleColor:[UIColor colorWithHexString:@"#4488F1"] forState:UIControlStateNormal];
                                                    [_webViewKeyboardDoneBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
                                                }
                                                
                                                bbi.customView = _webViewKeyboardDoneBtn;
                                                break;
                                            }
                                        }
                                        break;
                                    }
                                }
                                break;
                            }
                        }
                        break;
                    }
                }
                break;
            }
        }
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    switch (result) {
            
        case MessageComposeResultCancelled:
            LogInfo(@"Message was cancelled url :%@",self.shareDataDict[@"weburl"]);
            break;
        case MessageComposeResultFailed:
            LogInfo(@"Message failed url :%@",self.shareDataDict[@"weburl"]);
            break;
        case MessageComposeResultSent:
            LogInfo(@"Message was sent url :%@",self.shareDataDict[@"weburl"]);
            break;
        default:
            break;
    }
}

- (UIBarButtonItem *)shareBarButtonItem {
    
    if (!_shareBarButtonItem) {
       
        UIButton *shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, 24, 24)];
        [shareBtn setBackgroundColor:[UIColor clearColor]];
        [shareBtn setImage:[UIImage scaledImageForName:@"btn_share_white" ofType:@"png"] forState:UIControlStateNormal];
        [shareBtn addTarget:self action:@selector(loadShareView) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *shareBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:shareBtn];
        _shareBarButtonItem = shareBarButtonItem;
    }
    
    return _shareBarButtonItem;
}

- (void)shareImgToWXItem {
    
   
}

- (NSData *)zipImageWithImage:(UIImage *)originalImage {
    
    NSData *imageData = UIImagePNGRepresentation(originalImage);
    CGFloat maxFileSize = 32*1024;
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    UIImage *image = [UIImage imageWithData:imageData];
    NSData *compressedData = UIImageJPEGRepresentation(image, compression);
    if ([compressedData length] > maxFileSize && compression > maxCompression) {
        compression = maxFileSize / [compressedData length];
    }
    compressedData = UIImageJPEGRepresentation(image, compression);
    
    return compressedData;
}

- (NSString *)getSharePhotoPathWithImage:(UIImage *)image {
    
    UIImage *thumbImage = [self imageWithImage:image scaledToSize:image.size];
    NSData *imageData = UIImageJPEGRepresentation(thumbImage,0.5);
    thumbImage = [UIImage imageWithData:imageData];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"ocr.jpg"];
    [imageData writeToFile:filePath atomically:NO];
    
    return filePath;
}

- (void)setFuncMarkerParams:(NSDictionary *)markDic{
    
    NSArray *markArray = [NSArray arrayWithObject:markDic];
    [WSBaseStoreOtherDataDBService saveFuncTipData:markArray];
}

- (UIImage*)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)endFullScreen {

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)resetCookie {

    for (NSHTTPCookie *cookie in self.cookieArr) {
        
        if ([cookie.name isEqualToString:kSSO_JSESSIONID]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            break;
        }
    }
}

- (void)requestStoreInfoWithStoreId:(NSString *)storeId {
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:nil  tips:nil tapTarget:self action:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishRequest:) name:UPDATA_NOTIFY_STORE object:nil];
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    WSStoreBean *storeBean = [[WSStoreBean alloc] init];
    storeBean.Id = storeId;
    [uploadMgr appUpdataManagerInfo:storeBean StoreIds:nil subempId:nil withObjId:ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME notifyName:UPDATA_NOTIFY_STORE styp:nil timeout:0];
}

- (void)finishRequest:(id)sender {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATA_NOTIFY_STORE object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error) {

        NSString *tmpString = [error ws_localizedDescription];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    NSDictionary *uploadState = [info objectFromJSONString];
    NSString *objId = ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
    NSObject *tmpObject = uploadState[objId];
    NSDictionary *storeDicInfo = nil;
    if ([tmpObject isKindOfClass:[NSDictionary class]]) {
        storeDicInfo = (NSDictionary *)tmpObject;
    }
    else if ([tmpObject isKindOfClass:[NSArray class]]) {
        storeDicInfo = [(NSArray *)tmpObject firstObject];
    }
    
    if ([storeDicInfo objectForKey:@"storeDis"]) {
        
        id storeBeanInfo = [storeDicInfo objectForKey:@"storeDis"];
        if ([storeBeanInfo isKindOfClass:[NSArray class]]) {
            
            NSArray *array = (NSArray *)storeBeanInfo;
            [[WSBaseStoreTable sharedTable] insertAllStoresWith:array searchObjId:objId searchObjCode:nil isPlan:@"0"];
        }
    }
    
    WSBaseStoreDBService *storeService = [[WSBaseStoreDBService alloc] init];
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSArray *storesArray = [storeService queryStoreWithId:self.jumpStoreID andEmpId:empId];
    if (storesArray && storesArray.count > 0) {
        self.currentStore = [storesArray firstObject];
    }
    else {
        return;
    }
    
    BOOL isForceLeaveStore = [[WSInoutStoreTable sharedTable] isForceLeaveStoreWithStore:self.currentStore];
    if (isForceLeaveStore) {
        
        NSString *str = NSLocalizedString(@"forceLeaveStore_tip", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:str tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    if (![WSNewStoreListTool anyStoreHasNotLeave:self.currentStore andModuleFC:self.currentFuncs.fc withCurrentFuncs:self.currentFuncs]) {
        return;
    }

    [self.currentStore reSetStore:uploadState Key:objId];
    [WSStoreDataProcessService processStoreInfoDataToDbWith:self.currentStore info:storeDicInfo];
    [WSBaseStoreOtherDataDBService saveStoreRequestFlagWith:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:self.currentStore.Id];

    [self jumpStore];
}

- (void)jumpStore {
    
    WSFuncsBean *realFuncBean = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:self.currentFuncs];
    WSWorkFlowViewController* wfvc = nil;
    WSVisitStoreActionObject * visitAction = [self findActionIDAndCreateNextAction:self.currentFuncs andCurrentVisitAction:nil andStoreId:self.currentStore.Id subMenuFuncsCode:self.currentFuncs.fc];
    if (self.currentStore.actionState == nil) {
        self.currentStore.actionState = visitAction.status == nil?@"0":visitAction.status;
    }
    wfvc = [[WSWorkFlowViewController alloc] initWithFuncs:realFuncBean Store:self.currentStore unredo:self.currentFuncs.unredo];
    wfvc.input_reflect_code = self.currentFuncs.fc;
    wfvc.currentVisitAction = self.currentVisitAction ? self.currentVisitAction : visitAction;
    wfvc.moduleFC = visitAction.func_code;
    wfvc.realParentFuncsCode = self.currentFuncs.fc;
    wfvc.moduleFC = self.currentFuncs.fc;
    if (self.currentStore.mappingStoreListFV && [self.currentStore.mappingStoreListFV isEqualToString:@"TAB_V8003"]) {
        wfvc.moduleFC = self.currentStore.mappingStoreListFC;
    }
    
    if ([self.currentStore.name isKindOfClass:[NSString class]] && ![self.currentStore.name isEqualToString:@""]) {
       
        NSString *title = nil;
        if ([self.currentStore.code isKindOfClass:[NSString class]] && [self.currentStore.code length] > 0) {
            title = [NSString stringWithFormat:@"%@-%@", self.currentStore.code, self.currentStore.name];
        }
        else {
            title = self.currentStore.name;
        }
        wfvc.title = title;
    }
    
    wfvc.hidesBottomBarWhenPushed = YES;
    
    if (self.ownParentViewController) {
        [self.ownParentViewController.navigationController pushViewController:wfvc animated:YES];
    }
    else {
        [self.navigationController pushViewController:wfvc animated:YES];
    }
}

- (WSVisitStoreActionObject*) findActionIDAndCreateNextAction:(WSFuncsBean *)funcsBean
                                        andCurrentVisitAction:(WSVisitStoreActionObject *)currentAction
                                                   andStoreId:(NSString *)store_id
                                             subMenuFuncsCode:(NSString *)subMenuFuncsCode {
    
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = currentAction.ID;
    action.store_id = store_id;
    action.func_code = funcsBean.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.title = funcsBean.name;
    
    NSString *moduleFC;
    if ([currentAction.module_fc length] > 0) {
        moduleFC = currentAction.module_fc;
    }
    else if([subMenuFuncsCode length] > 0){
        moduleFC = subMenuFuncsCode;
    }
    else {
        moduleFC = funcsBean.fc;
    }
    
    action.module_fc = moduleFC;
    
    if (self.currentStore.mappingStoreListFV && [self.currentStore.mappingStoreListFV isEqualToString:@"TAB_V8003"]) {
        action.module_fc = self.currentStore.mappingStoreListFC;
    }
    
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    
    return action;
}

- (NSMutableArray *)backFuncNameArray {
    
    if (!_backFuncNameArray) {
        _backFuncNameArray = [NSMutableArray array];
    }
    return _backFuncNameArray;
}

- (void)optLoginUrlNormalLogin {
    
    [self webViewShowHUDWithText:NSLocalizedString(@"logining_prompt", nil) tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];

    NSString *loginUrl = [self.currentFuncs.opt.loginUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *userName = [self.currentFuncs.opt.username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passWord = [self.currentFuncs.opt.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (loginUrl.length <= 0 || userName.length <= 0 || passWord.length <= 0) {
        
        [self webViewHideHUDWithAnimated:NO];
        LogError(@"登录web异常，loginUrl:%@ username:%@ password:%@", loginUrl, userName, passWord);
        return;
    }
    
    NSString *loginUserName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_BEGIN_LOGIN];
    NSString *loginPassWord = [[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD];
    NSString *url = [NSString stringWithFormat:@"%@&%@=%@&%@=%@", loginUrl, userName, loginUserName, passWord, loginPassWord];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(optLoginWebResponse:) name:opt_login_web_notify object:nil];
    [[WSRequestBase shareInstance] startReportLoginbyPost:url notifyName:opt_login_web_notify userAccount:loginUserName userPassword:loginPassWord];
}

#pragma mark - opt登陆后台响应方法 sender:响应数据
- (void)optLoginWebResponse:(NSNotification *)sender {
    
    LogTrace();
    [[NSNotificationCenter defaultCenter] removeObserver:self name:opt_login_web_notify object:nil];
    [self webViewHideHUDWithAnimated:NO];
    [self loadWebViewRequest];
}

#pragma mark - 请求Cookie方法
- (void)requestCookie {
        
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil)  tips:nil tapTarget:self action:nil];
        
    NSString *username = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_CALL_APP];
    username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passwd = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_CALL_APP];
    passwd = [passwd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSString *serverUrl = [self getLoginServerUrl];
    NSString *url = [NSString stringWithFormat:@"%@", serverUrl];
    LogInfo(@"WinJSBridgeViewController requestCookie url %@", url);
    
    NSString *notifyName = [NSString stringWithFormat:@"%@%@", login_web_notify, self.viewDidLoadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestCookieNotice:) name:notifyName object:nil];
    [[WSRequestBase shareInstance] startReportLoginbyPost:url notifyName:notifyName userAccount:username userPassword:passwd];
}

#pragma mark - 请求Cookie通知回调方法
- (void)requestCookieNotice:(NSNotification *)sender {
    
    NSString *notifyName = [NSString stringWithFormat:@"%@%@", login_web_notify, self.viewDidLoadData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notifyName object:nil];
    
    NSString *serverUrl = [self getLoginServerUrl];
    NSArray *urlCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:serverUrl]];
    LogInfo(@"WinJSBridgeViewController requestCookie callback urlCookies %@", urlCookies);
    
    if (@available(iOS 11.0, *)) {
        
        WKHTTPCookieStore *cookieStore = self.reportFormWKWebView.configuration.websiteDataStore.httpCookieStore;
        for (NSHTTPCookie *cookie in urlCookies) {
            [cookieStore setCookie:cookie completionHandler:^{}];
        }
        LogInfo(@"WinJSBridgeViewController requestCookie callback WKHTTPCookieStore");
    }
    else {
        
        NSHTTPCookieStorage *shareCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in urlCookies) {
            [shareCookie setCookie:cookie];
        }
        LogInfo(@"WinJSBridgeViewController requestCookie callback NSHTTPCookieStorage");
    }

    ;
    self.loadURL = [self getURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.loadURL];
    LogInfo(@"WinJSBridgeViewController loadRequest %@", request.URL.absoluteString);
    NSString *requestUrlStr = [[self.loadURL absoluteString] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    if (requestUrlStr == nil || requestUrlStr.length < 1) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, PHONE_STATUSBAR_HEIGHT, self.view.width, 40)];
        label.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        label.backgroundColor=[UIColor clearColor];
        label.textAlignment=NSTextAlignmentCenter;
        NSString *nodata = NSLocalizedString(@"acvt_type_empty_label", nil);
        label.text = nodata;
        [self.view addSubview:label];

        if (self.currentFuncs.opt && self.currentFuncs.opt.isHideTitle) {
            [self addSkipButton];
        }
        
        [self setupWebViewHidden:YES];
    }
    else {
        [self setupWebViewHidden:NO];
    }
    
    [request setValue:[WCBaseRequest getUserAgent] forHTTPHeaderField:@"User-Agent"];
    [self setRequestPostBody:request];
    
    if (urlCookies.count > 0) {

        NSDictionary *reqHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:urlCookies];
        [request setValue:[reqHeader objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
        self.cookieDic = reqHeader.mutableCopy;
        NSLog(@"------->%@",self.cookieDic);
        for (NSHTTPCookie *cookie in urlCookies) {
            
            if ([cookie.name isEqualToString:@"JSESSIONID"]) {
                
                [request setValue:cookie.value forHTTPHeaderField:@"JSESSIONID"];
 
                NSString *cookieValue = [NSString stringWithFormat:@"'JSESSIONID =%@'", cookie.value];
                NSString *source = [NSString stringWithFormat: @"document.cookie = %@", cookieValue];
                WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
                [self.reportFormWKWebView.configuration.userContentController addUserScript:cookieScript];
                
                LogInfo(@"WinJSBridgeViewController requestCookie callback source %@", source);
                break;
            }
        }
    }
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        // 开启自定义cookie（在loadRequest前开启）
//        [strongSelf.reportFormWKWebView startCustomCookie];
        
        [strongSelf.reportFormWKWebView loadRequest:request];
    });
}
#pragma mark - 获取登陆url方法
- (NSString *)getLoginServerUrl {
    
    NSString *serverUrl = [WSHttpURLHelper getLoginDataServerUrl];
    if ([serverUrl hasSuffix:@"/"]) {
        serverUrl = [serverUrl substringToIndex:[serverUrl length] - 1];
    }
    serverUrl = [NSString stringWithFormat:@"%@/login.do?noresponsebody=1", serverUrl];
    return serverUrl;
}

@end
//========================================================================================================================================================================
