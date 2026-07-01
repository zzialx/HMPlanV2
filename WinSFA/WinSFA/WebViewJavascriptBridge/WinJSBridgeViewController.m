//
//  WinJSBridgeViewController.m
//  NIVEA
//
//  Created by yuanji on 2022/10/9.
//

#import "WinJSBridgeViewController.h"
#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import "HSWKWebViewJavascriptBridge.h"
#import "Masonry.h"
#import "WSRequestBase.h"
#import "WinNewLocationManager.h"
#import <AMapLocationKit/AMapLocationCommonObj.h>
#import "WinStoreInfoTools.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "WSWorkFlowViewController.h"
#import "WSPaiPaiManager.h"
#import "WSLeaveStoreAcvtViewController.h"
#import "WSReportFormController.h"
#import "WinQueueUploadImageTool.h"
#import "WSBaseStoreAcvtDisTable.h"
#import "WSEnvrionment.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <TZImagePickerController/TZImagePickerController.h>
#import "WSFuncTipDBService.h"

//打开Trax相机类型枚举
typedef NS_ENUM(NSUInteger, WJBVCOpenCameraType) {
    WJBVCOpenCameraTypeSpeOrange = 0,
    WJBVCOpenCameraTypeSpeManagerFollowUp = 1,
    WJBVCOpenCameraTypeLocalPicture = 2
};
//====================================================================================================================================

#pragma mark - js桥接视图管理器 延展(内部)
@interface WinJSBridgeViewController () <WKNavigationDelegate, WKUIDelegate, WSPaiPaiManagerDelegate, TZImagePickerControllerDelegate>

@property (nonatomic, strong) WKWebView *webView;                               //网页视图
@property (nonatomic, strong) UIProgressView *progressView;                     //进度条视图
@property (nonatomic, strong) WinNewLocationManager *locationManager;           //定位管理器
@property (nonatomic, strong) HSWKWebViewJavascriptBridge *bridge;              //js桥接
@property (nonatomic, strong) WVJBResponseCallback callbackObj;                 //回调对象
@property (nonatomic, strong) WVJBResponseCallback cameraCallbackObj;           //相机回调对象
@property (nonatomic, strong) NSURL *loadURL;                                   //加载url
@property (nonatomic, strong) WinStoreInfoTools *storeInfoTools;                //门店信息工具
@property (nonatomic, strong) WinNewLocationDescribe *currentLocationDescribe;  //当前定位信息
@property (nonatomic, assign) BOOL isLoadURL;                                   //是否加载url
@property (nonatomic, assign) BOOL isUploadImageHUD;                            //是否上传图片状态弹框
@property (nonatomic, copy) NSString *jumpStoreID;                              //跳转门店id
@property (nonatomic, copy) NSString *viewDidLoadData;                          //视图预加载时间

@end
//====================================================================================================================================

#pragma mark - js桥接视图管理器 延展(注册处理器协议)
@interface WinJSBridgeViewController (RegisterHandler) <RegisterHandlerProtocol>

- (void)registerHandler;                        //注册处理器方法
- (NSArray *)getRegisterHandlerProtocolMethods; //获取注册处理器协议模型方法

@end
//====================================================================================================================================

#pragma mark - js桥接视图管理器
@implementation WinJSBridgeViewController

#pragma mark - 获取progressView方法
- (UIProgressView *)progressView {
    
    if (!_progressView) {
        
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
        _progressView.tintColor = [UIColor blueColor];
        _progressView.trackTintColor = [UIColor clearColor];
    }
    return _progressView;
}

#pragma mark - 获取webView方法
- (WKWebView *)webView {
    
    if (!_webView) {
        
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
        
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        config.userContentController = wkUController;
        
        NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                      forMainFrameOnly:YES];
        [config.userContentController addUserScript:wkUScript];
        
        jSString = @"var script = document.createElement('meta');"
        "script.name = 'viewport';"
        "script.content=\"width=device-width, user-scalable=no\";"
        "document.getElementsByTagName('head')[0].appendChild(script);";
        wkUScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [config.userContentController addUserScript:wkUScript];
    
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.allowsBackForwardNavigationGestures = NO;
        _webView.scrollView.bounces = NO;
        if (@available(iOS 16.4, *)) {
            _webView.inspectable = YES;
        }
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
#endif
    }
    
    return _webView;
}

#pragma mark - 获取locationManager方法
- (WinNewLocationManager *)locationManager {
    
    if (!_locationManager) {
        _locationManager = [[WinNewLocationManager alloc] init];
    }
    return _locationManager;
}

#pragma mark - 获取storeInfoTools方法
- (WinStoreInfoTools *)storeInfoTools {
    
    if (!_storeInfoTools) {
        _storeInfoTools = [[WinStoreInfoTools alloc] init];
    }
    return _storeInfoTools;
}

#pragma mark - 实现自定义初始化方法
- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store {
    
    self = [self initWithFuncs:funcs];
    if (self != nil) {
        
        _currentStore = store;
    }
    return self;
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (self.isNotAllowSideslipBack) {
        [self addNotAllowSlidBack];
    }
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    [self subWidgetLayout];
    
    [self.webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
    [HSWKWebViewJavascriptBridge enableLogging];
    _bridge = [HSWKWebViewJavascriptBridge bridgeForWebView:self.webView];
    [_bridge setWebViewDelegate:self];
    
    _viewDidLoadData = [WSCurrentTime getTimeMillisString];
    [self registerHandler];
}

#pragma mark - 重写viewWillAppear:方法
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (self.currentFuncs.opt.isExhibitionNavTitle) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
    [self requestLocationWithIsHUD:NO isCallBack:NO];
    
    if (!self.isLoadURL) {
        
        self.isLoadURL = YES;
        [self requestCookie];
    }
    else {
        
        NSString *webBackUpdateJS = [NSString stringNotNilWithValue:self.currentFuncs.opt.webBackUpdateJS];
        if (webBackUpdateJS.length > 0) {
            NSString *js = [NSString stringWithFormat:@"%@()", webBackUpdateJS];
            [self.webView evaluateJavaScript:js completionHandler:^(NSString *result, NSError * _Nullable error) {
                LogInfo(@"WinJSBridgeViewController viewWillAppear webBackUpdateJS = %@", webBackUpdateJS);
            }];
        }
        
        self.isUploadImageHUD = [[WinQueueUploadImageTool sharedInstance] currentIsUpload];
        if (self.isUploadImageHUD) {
            [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
            NSString *text = NSLocalizedString(@"uploading_prompt", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:text tips:nil tapTarget:nil action:nil];
        }
    }
}

#pragma mark - 重写shouldCustomInteractivePopGestureRecognizerDelegate方法
- (BOOL)shouldCustomInteractivePopGestureRecognizerDelegate {
    
    return YES; //授权左滑返回启动
}

#pragma mark - 实现observeValueForKeyPath:ofObject:change:context:kvo监听协议
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == _webView) {
        
        self.progressView.progress = _webView.estimatedProgress;
        if (_webView.estimatedProgress >= 1.0f) {
            
            __weak __typeof__(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                __strong typeof(weakSelf) strongSelf = weakSelf;
                strongSelf.progressView.progress = 0;
            });
        }
    }
    else if ([keyPath isEqualToString:@"title"] && object == _webView) {
        self.navigationItem.title = _webView.title;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - 实现webView:didFailProvisionalNavigation:withError:协议
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
    [self.progressView setProgress:0.0f animated:NO];
}

#pragma mark - 实现webView:didFailNavigation:withError:协议
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
    [self.progressView setProgress:0.0f animated:NO];
}

#pragma mark - 实现webView:decidePolicyForNavigationAction:decisionHandler:协议
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - 实现webView:decidePolicyForNavigationResponse:decisionHandler:协议
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark - 实现webView:didFinishNavigation:协议
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
    [webView evaluateJavaScript:@"document.cookie" completionHandler:^(NSString *result, NSError * _Nullable error) {
        LogInfo(@"WinJSBridgeViewController didFinishNavigation result %@", [result componentsSeparatedByString:@"; "]);
    }];
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
    _callbackObj = nil;
    _cameraCallbackObj = nil;
    [_webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [_webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(title))];
    
//    NSString *serverUrl = [self getLoginServerUrl];
//    NSArray *urlCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:serverUrl]];
//    if (@available(iOS 11.0, *)) {
//        WKHTTPCookieStore *cookieStore = _webView.configuration.websiteDataStore.httpCookieStore;
//        for (NSHTTPCookie *cookie in urlCookies) {
//            [cookieStore deleteCookie:cookie completionHandler:^{}];
//        }
//    }
//    else {
//        NSHTTPCookieStorage *shareCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//        for (NSHTTPCookie *cookie in urlCookies) {
//            [shareCookie deleteCookie:cookie];
//        }
//    }
}

#pragma mark - 子视图布局方法
- (void)subWidgetLayout {
    
    NSString *urlStr = [self getOriginalUrl];
    CGFloat headHeight = 0.0f;
    if ([urlStr containsString:@"safeAreaDraw=1"]) {
        headHeight = [self getHeadHeight];
    }
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(headHeight);
        make.left.equalTo(self.view).offset(0.0f);
        make.right.equalTo(self.view).offset(0.0f);
        make.bottom.equalTo(self.view).offset(0.0f);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(4.0f);
    }];
}

#pragma mark - 获取原始url方法
- (NSString *)getOriginalUrl {
    
    NSString *urlStr = [NSString stringNotNilWithValue:self.externalOpenUrl];
    if (urlStr.length == 0) {
        urlStr = [NSString stringNotNilWithValue:self.currentFuncs.filter];
    }
    return urlStr;
}

#pragma mark - 获取头部高度方法
- (CGFloat)getHeadHeight {
    
    CGFloat statusBarHeight = 0.0f;
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIStatusBarManager *statusBarManager = windowScene.statusBarManager;
        statusBarHeight = statusBarManager.statusBarFrame.size.height;
    } else {
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    
    CGFloat safeAreaTopHeight = 0.0f;
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        safeAreaTopHeight = mainWindow.safeAreaInsets.top;
    }
    
    CGFloat headHeight = ((safeAreaTopHeight > 0) ? safeAreaTopHeight : statusBarHeight);
    return headHeight;
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
        
        WKHTTPCookieStore *cookieStore = self.webView.configuration.websiteDataStore.httpCookieStore;
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
    
    self.loadURL = [self getURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.loadURL];
    LogInfo(@"WinJSBridgeViewController loadRequest %@", request.URL.absoluteString);
    
    if (urlCookies.count > 0) {

        NSDictionary *reqHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:urlCookies];
        [request setValue:[reqHeader objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];

        for (NSHTTPCookie *cookie in urlCookies) {
            
            if ([cookie.name isEqualToString:@"JSESSIONID"]) {
                
                [request setValue:cookie.value forHTTPHeaderField:@"JSESSIONID"];
 
                NSString *cookieValue = [NSString stringWithFormat:@"'JSESSIONID =%@'", cookie.value];
                NSString *source = [NSString stringWithFormat: @"document.cookie = %@", cookieValue];
                WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
                [self.webView.configuration.userContentController addUserScript:cookieScript];
                
                LogInfo(@"WinJSBridgeViewController requestCookie callback source %@", source);
                break;
            }
        }
    }
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.webView loadRequest:request];
    });
}

#pragma mark - 获取url方法
- (NSURL *)getURL {
    
    NSString *urlStr = [self getOriginalUrl];
    
    if ([urlStr containsString:@"{empId}"]) {
        
        NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"{empId}" withString:empId];
    }
    
    if ([urlStr containsString:@"{routeId}"]) {
        
        NSString *dicRouteId = [self.externalInfoDic objectForKey:Win_JSBridge_URL_Replacing_RouteId_Mark];
        NSString *routeId = [NSString stringNotNilWithValue:dicRouteId];
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"{routeId}" withString:routeId];
    }
    
    if ([urlStr containsString:@"{storeId}"]) {
        
        NSString *storeId = [NSString stringNotNilWithValue:self.currentStore.Id];
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"{storeId}" withString:storeId];
    }
    if ([urlStr containsString:@"{storeName}"]) {
        
        NSString *storeName = [NSString stringNotNilWithValue:self.currentStore.name];
        storeName = [[NSString stringWithFormat:@"%@", storeName] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"{storeName}" withString:storeName];
    }
    
    if ([urlStr containsString:@"{headHeight}"]) {
        
        CGFloat headHeight = [self getHeadHeight];
        NSString *headHeightStr = [NSString stringWithFormat:@"%ld", (NSInteger)headHeight];
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"{headHeight}" withString:headHeightStr];
    }
    
    if ([urlStr containsString:@"{visitDate}"]) {
        
        NSString *dicVisitDate = [self.externalInfoDic objectForKey:Win_JSBridge_URL_Replacing_VisitDate_Mark];
        NSString *visitDate = [NSString stringNotNilWithValue:dicVisitDate];
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"{visitDate}" withString:visitDate];
    }
    if ([urlStr containsString:@"{messId}"]) {
        
        NSString *dicMsgIds = [self.externalInfoDic objectForKey:Win_JSBridge_URL_Replacing_MSGID_Mark];
        NSString *msgIds = [NSString stringNotNilWithValue:dicMsgIds];
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"{messId}" withString:msgIds];
    }
    if ([urlStr containsString:@"{isOnlyView}"]) {
        
        NSString * visitState = @"2";
        if([self.currentStore.actionState isEqualToString:VisitStoreDone]){
            visitState = @"1";
        }
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"{isOnlyView}" withString:visitState];
    }
    //替换掉空格
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    urlStr = [WSHttpURLHelper getNeedsSignUrl:urlStr];
    NSURL *requestUrl = [NSURL URLWithString:urlStr];
    return requestUrl;
}

#pragma mark - 请求位置方法
- (void)requestLocationWithIsHUD:(BOOL)isHUD isCallBack:(BOOL)isCallback {
    
    if (isHUD) {
        
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        NSString *text = NSLocalizedString(@"gps_wait_lable", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:text tips:nil tapTarget:nil action:nil];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.locationManager requestLocationWithCompletionBlock:^(WinNewLocationDescribe *_Nullable locationDescribe, NSError *_Nullable error) {
         
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (isHUD) {
            [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        }
        
        if (!isCallback) {
            if (!error) {
                [strongSelf saveRoutineLocationInfoWithLocationDescribe:locationDescribe];
            }
            return;
        }
        
        if (error) {
            [strongSelf locationFailWithError:error];
        }
        else {
            [strongSelf saveRoutineLocationInfoWithLocationDescribe:locationDescribe];
            [strongSelf locationSuccessWithLocationDescribe:locationDescribe];
        }
        return;
    }];
}

#pragma mark - 定位失败方法
- (void)locationFailWithError:(NSError *)error {
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:0.0f longitude:0.0f];
    [self getCurrentLocationJsCallbackWithLocation:location];
}

#pragma mark - 定位成功方法
- (void)locationSuccessWithLocationDescribe:(WinNewLocationDescribe *)locationDescribe {
    
    CLLocationDegrees latitude = locationDescribe.locationCoordinate.latitude;
    CLLocationDegrees longitude = locationDescribe.locationCoordinate.longitude;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [self getCurrentLocationJsCallbackWithLocation:location];
}

#pragma mark - 获取当前位置js交互回调方法
- (void)getCurrentLocationJsCallbackWithLocation:(CLLocation *)location {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:[NSString stringWithFormat:@"%f", location.coordinate.latitude] forKey:@"lat"];
    [dic setValue:[NSString stringWithFormat:@"%f", location.coordinate.longitude] forKey:@"lon"];
    
    LogInfo(@"WinJSBridgeViewController CurrentLocationJsCallback dic %@", dic);
    
    self.callbackObj([dic JSONString]);
    self.callbackObj = nil;
}

#pragma mark - 保存常规定位信息方法
- (void)saveRoutineLocationInfoWithLocationDescribe:(WinNewLocationDescribe *)locationDescribe {
    
    self.currentLocationDescribe = locationDescribe;
}

#pragma mark - 打开选项导航方法
- (void)openOptionsNavigationWithLatitude:(double)latitude longitude:(double)longitude {
    
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"please_select", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *baiduAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"baidu_map_title", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf jumpBaiduMapWithLatitude:latitude longitude:longitude];
    }];
    
    UIAlertAction *gaodeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"gaode_map_title", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf jumpGaodeMapWithLatitude:latitude longitude:longitude];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel_label", nil) style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:baiduAction];
    [alertController addAction:gaodeAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 跳转百度地图方法
- (void)jumpBaiduMapWithLatitude:(double)latitude longitude:(double)longitude {
    
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"install_baidu", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    NSString *urlString = nil;
    if ([WSEnvrionment getUseBaiduMap]) {
        
        urlString = [NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=bd09ll", latitude, longitude];
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    else if ([WSEnvrionment getuseGeoAmap]) {
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        CLLocationCoordinate2D bd09Coord = BMKCoordTrans(coordinate, BMK_COORDTYPE_COMMON, BMK_COORDTYPE_BD09LL);
        urlString = [NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=bd09ll", bd09Coord.latitude, bd09Coord.longitude];
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    else {
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        CLLocationCoordinate2D bd09Coord = BMKCoordTrans(coordinate, BMK_COORDTYPE_GPS, BMK_COORDTYPE_BD09LL);
        urlString = [NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=bd09ll", bd09Coord.latitude, bd09Coord.longitude];
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
    
    LogInfo(@"WinJSBridgeViewController jumpBaiduMap urlString %@  latitude = %f longitude = %f", urlString, latitude, longitude);
}

#pragma mark - 跳转高德地图方法
- (void)jumpGaodeMapWithLatitude:(double)latitude longitude:(double)longitude {
    
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"install_gaode", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    NSString *urlString = nil;
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    NSString *urlScheme = @"winsfa";
    
    if ([WSEnvrionment getUseBaiduMap]) {
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        CLLocationCoordinate2D gaodeCoordinate = AMapLocationCoordinateConvert(coordinate, AMapLocationCoordinateTypeBaidu);
        urlString = [NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&backScheme=%@&sid=BGVIS1&did=BGVIS2&dlat=%f&dlon=%f&dev=0&m=0&t=0",
                               appName, urlScheme, gaodeCoordinate.latitude, gaodeCoordinate.longitude];
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    else if ([WSEnvrionment getuseGeoAmap]) {
        
        urlString = [NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&backScheme=%@&sid=BGVIS1&did=BGVIS2&dlat=%f&dlon=%f&dev=0&m=0&t=0",
                               appName, urlScheme, latitude, longitude];
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    else {
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        CLLocationCoordinate2D gaodeCoordinate = AMapLocationCoordinateConvert(coordinate, AMapLocationCoordinateTypeGPS);
        urlString = [NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&backScheme=%@&sid=BGVIS1&did=BGVIS2&dlat=%f&dlon=%f&dev=0&m=0&t=0",
                               appName, urlScheme, gaodeCoordinate.latitude, gaodeCoordinate.longitude];
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
    
    LogInfo(@"WinJSBridgeViewController jumpGaodeMap urlString %@  latitude = %f longitude = %f", urlString, latitude, longitude);
}

#pragma mark - 请求门店信息方法
- (void)requestStoreInfoWithStoreId:(NSString *)storeId {
    
    if (storeId.length == 0) {
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:nil  tips:nil tapTarget:self action:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishRequest:) name:@"requestStoreInfoNotification" object:nil];
    
    [self.storeInfoTools requestStoreInfoWithStoreId:storeId notifyName:@"requestStoreInfoNotification"];
}

#pragma mark - 请求门店信息通知回调方法
- (void)finishRequest:(id)sender  {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"requestStoreInfoNotification" object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error) {
        
        NSString *text = [error ws_localizedDescription];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:text tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
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
    [self.storeInfoTools analysisAllStoresInfoToDBWithDictionary:storeDicInfo objId:objId];
    
    WSStoreBean *storeBean = [self.storeInfoTools queryStoreBeanWithStoreId:self.jumpStoreID];
    if (!storeBean) {
        return;
    }
    
    BOOL isVisitStore = [self.storeInfoTools isVisitStoreWithStoreId:storeBean funcsBean:self.currentFuncs];
    if (!isVisitStore) {
        return;
    }
    
    [self.storeInfoTools updateCurrentStoreWithStoreBean:storeBean storeInfo:uploadState objId:ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME];
    [self.storeInfoTools updateCurrentStoreOtherDataWithStoreBean:storeBean storeInfo:storeDicInfo flag:WSASVC_OUTPLANSTORE_REQUESTED_FLAG];
    
    self.currentStore = storeBean;
    [self jumpStore];
}

#pragma mark - 跳转门店方法
- (void)jumpStore {
    
    WSFuncsBean *realFuncBean = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:self.currentFuncs];
    WSWorkFlowViewController *wfvc = nil;
    WSVisitStoreActionObject *visitAction = [self.storeInfoTools findActionIDAndCreateNextAction:self.currentFuncs currentVisitAction:nil storeId:self.currentStore.Id
                                                                                subMenuFuncsCode:self.currentFuncs.fc storeBean:self.currentStore];
    
    if (self.currentStore.actionState == nil) {
        self.currentStore.actionState = (visitAction.status == nil ? @"0" : visitAction.status);
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

#pragma mark - 执行完成橙色认证脚本方法
- (void)executeCompleteOrangeAcquisitionLuaWithStoreId:(NSString *)storeId {
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *luaScriptResourceBundlePath = [mainBundle pathForResource:@"WinLuaScriptResource" ofType:@"bundle"];
    NSBundle *luaScriptResourceBundle = [NSBundle bundleWithPath:luaScriptResourceBundlePath];
    NSString *luaScriptPath = [luaScriptResourceBundle pathForResource:@"js_lua/completeOrangeAcquisition" ofType:@"lua"];
    NSData *luaScriptData = [[NSData alloc] initWithContentsOfFile:luaScriptPath];
    NSString *luaScript = [[NSString alloc] initWithData:luaScriptData encoding:NSUTF8StringEncoding];
    if (luaScript) {
        
        WSLuaExecutorManager *wsLuaExecutor = [WSLuaExecutorManager shareInstance];
        wsLuaExecutor.isErrorFromScript = NO;
        wsLuaExecutor.currentoperator = nil;
        [wsLuaExecutor executeLuaScript:luaScript functionName:@"function completeOrangeAcquisition(" params:storeId];
    }
}

#pragma mark - 执行完成oto认证脚本方法
- (void)executeCompleteOtoAcquisitionLuaWithStoreId:(NSString *)storeId {
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *luaScriptResourceBundlePath = [mainBundle pathForResource:@"WinLuaScriptResource" ofType:@"bundle"];
    NSBundle *luaScriptResourceBundle = [NSBundle bundleWithPath:luaScriptResourceBundlePath];
    NSString *luaScriptPath = [luaScriptResourceBundle pathForResource:@"js_lua/completeOtoAcquisition" ofType:@"lua"];
    NSData *luaScriptData = [[NSData alloc] initWithContentsOfFile:luaScriptPath];
    NSString *luaScript = [[NSString alloc] initWithData:luaScriptData encoding:NSUTF8StringEncoding];
    if (luaScript) {
        
        WSLuaExecutorManager *wsLuaExecutor = [WSLuaExecutorManager shareInstance];
        wsLuaExecutor.isErrorFromScript = NO;
        wsLuaExecutor.currentoperator = nil;
        [wsLuaExecutor executeLuaScript:luaScript functionName:@"function completeOtoAcquisition(" params:storeId];
    }
}

#pragma mark - 返回到离开门店方法
- (void)backToLeaveStoreImplementClose {

    WSLeaveStoreAcvtViewController *leaveStoreAcvtViewController = nil;
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[WSLeaveStoreAcvtViewController class]]) {
            leaveStoreAcvtViewController = (WSLeaveStoreAcvtViewController *)vc;
            break;
        }
    }
    
    if (leaveStoreAcvtViewController) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [leaveStoreAcvtViewController executeUpload];
        });
        [self.navigationController popToViewController:leaveStoreAcvtViewController animated:YES];
    }
}

#pragma mark - 设置上传图片工具方法
- (void)setupUploadImageToolWithStoreId:(NSString *)storeId uuid:(NSString *)uuid type:(WJBVCOpenCameraType)type {
    
    [WinQueueUploadImageTool sharedInstance].storeId = storeId;
    [WinQueueUploadImageTool sharedInstance].uuidH5 = uuid;
    
    if (type == WJBVCOpenCameraTypeSpeManagerFollowUp) {
        
        [WinQueueUploadImageTool sharedInstance].uploadURL = [WSHttpURLHelper getCompleteURL:@"otcnew/speManagerFollowUpImage.do?method=saveTskfImg"];
    }
    else {
        
        NSString *sql = @"select base_store_acvt_dis.acvt_qst_answer from base_store_acvt_dis join base_acvt_qst on base_acvt_qst.acvtId = base_store_acvt_dis.acvtId and base_acvt_qst.acvtQstId = base_store_acvt_dis.acvtQstId where 1=1 and base_acvt_qst.qstCod = 'wt_selectrole'";
        NSArray *dataArray = [[WSBaseStoreAcvtDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreAcvtDisObject"];
        WSBaseStoreAcvtDisObject *obj = [dataArray firstObject];
        NSString *role = obj.acvt_qst_answer;
        if ([role isEqualToString:@"SR"]) {
            [WinQueueUploadImageTool sharedInstance].uploadURL = [WSHttpURLHelper getCompleteURL:@"otcnew/speOrangeImage.do?method=saveTskfImg"];
        }
        else {
            [WinQueueUploadImageTool sharedInstance].uploadURL = [WSHttpURLHelper getCompleteURL:@"otcnew/speOrangeImage.do?method=savePchImg"];
        }
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:[NSString stringWithFormat:@"%f", self.currentLocationDescribe.locationCoordinate.latitude] forKey:@"lat"];
    [dic setValue:[NSString stringWithFormat:@"%f", self.currentLocationDescribe.locationCoordinate.longitude] forKey:@"lon"];
    [dic setValue:[NSString stringWithFormat:@"%@", self.currentLocationDescribe.address] forKey:@"addr"];
    [WinQueueUploadImageTool sharedInstance].otherInfoDic = dic;
    
    __weak __typeof__(self) weakSelf = self;
    __block WJBVCOpenCameraType typeBlock = type;
    [WinQueueUploadImageTool sharedInstance].uploadImageSuccessBlock = ^(NSString *successInfo, BOOL isAll) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        LogInfo(@"WinJSBridgeViewController setupUploadImageToolWithStoreId uploadImageSuccessBlock 1 successInfo = %@ isAll = %d", successInfo, isAll);
        strongSelf.cameraCallbackObj([NSString stringNotNilWithValue:successInfo]);
        
        if (isAll && strongSelf.isUploadImageHUD) {
            [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
            strongSelf.isUploadImageHUD = NO;
        }
        if (isAll && typeBlock == WJBVCOpenCameraTypeLocalPicture) {
            [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        }
    };
    [WinQueueUploadImageTool sharedInstance].uploadImageFailureBlock = ^(BOOL isAll) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        LogInfo(@"WinJSBridgeViewController setupUploadImageToolWithStoreId uploadImageFailureBlock 1 isAll = %d", isAll);
        
        if (isAll && strongSelf.isUploadImageHUD) {
            [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
            strongSelf.isUploadImageHUD = NO;
        }
        if (isAll && typeBlock == WJBVCOpenCameraTypeLocalPicture) {
            [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        }
    };
    
    [[WinQueueUploadImageTool sharedInstance] clearCacheData];
}

#pragma mark - 实现WSPaiPaiManagerDelegate---didFinishImage:withImgID:协议
- (void)didFinishImage:(UIImage *)image withImgID:(NSString *)imgID {
    
    LogInfo(@"WinJSBridgeViewController TraxCamera 1 image=%@", image);
    if (!image) {
        return;
    }
    
    NSString *newImageID = [NSString stringWithFormat:@"%@_%@", imgID, [WSCurrentTime getTimeMillisString]];
    LogInfo(@"WinJSBridgeViewController TraxCamera 2 image=%@ imgID=%@ newImageID=%@", image, imgID, newImageID);
    [[WinQueueUploadImageTool sharedInstance] uploadWithImage:image imageID:newImageID];
    
//    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
//    NSString *imageBase64Encoded = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//    LogInfo(@"WinJSBridgeViewController TraxCamera 2 image=%@ imgID=%@", image, imgID);
//
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setValue:[NSString stringWithFormat:@"%f", self.currentLocationDescribe.locationCoordinate.latitude] forKey:@"lat"];
//    [dic setValue:[NSString stringWithFormat:@"%f", self.currentLocationDescribe.locationCoordinate.longitude] forKey:@"lon"];
//    [dic setValue:[NSString stringWithFormat:@"%@", self.currentLocationDescribe.address] forKey:@"addr"];
//    [dic setValue:[NSString stringWithFormat:@"%@", [WSCurrentTime getDateString]] forKey:@"bizDate"];
//    [dic setValue:[NSString stringWithFormat:@"%@", [WSCurrentTime getTimeMillisString]] forKey:@"mobileClickTime"];
//    [dic setValue:[NSString stringWithFormat:@"%@", imageBase64Encoded] forKey:@"imgBase64"];
//
//    LogInfo(@"WinJSBridgeViewController TraxCamera 3 image=%@ imgID=%@ serverTime=%@", image, imgID, [WSCurrentTime getServerTime]);
//    self.cameraCallbackObj([dic JSONString]);
}

#pragma mark - 实现WSPaiPaiManagerDelegate---didFinishPhotoModelArray:协议
- (void)didFinishPhotoModelArray:(NSArray *)list {
    
}

#pragma mark - 实现TZImagePickerControllerDelegate--imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:infos:协议
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets
        isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    
    if (photos.count == 0) {
        
        LogInfo(@"WinJSBridgeViewController imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:infos: 无照片");
        return;
    }
    
    NSString *text = NSLocalizedString(@"uploading_prompt", nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:text tips:nil tapTarget:nil action:nil];
    
    for (int i = 0; i < photos.count; i++) {
        
        UIImage *newImage = [photos objectAtIndex:i];
        NSString *newImageID = [NSString stringWithFormat:@"%@_%i", [WSCurrentTime getTimeMillisString], i];
        
        LogInfo(@"WinJSBridgeViewController imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:infos: image=%@ newImageID=%@", newImage, newImageID);
        [[WinQueueUploadImageTool sharedInstance] uploadWithImage:newImage imageID:newImageID];
    }
}

@end
//====================================================================================================================================

#pragma mark - js桥接视图管理器 延展(注册处理器协议)
@implementation WinJSBridgeViewController (RegisterHandler)

#pragma mark - 注册处理器方法
- (void)registerHandler {
    
    NSArray *registerHandlerMethods = [self getRegisterHandlerProtocolMethods];
    [registerHandlerMethods enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        SEL selector = NSSelectorFromString(obj);
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL) = (void *)imp;
        func(self, selector);
    }];
}

#pragma mark - 获取注册处理器协议模型方法
- (NSArray *)getRegisterHandlerProtocolMethods {
    
    Protocol *protocol = objc_getProtocol("RegisterHandlerProtocol");
    unsigned int methodCount = 0;
    struct objc_method_description *method_description_list = protocol_copyMethodDescriptionList(protocol, YES, YES, &methodCount);

    NSMutableArray *protocolMethods = [NSMutableArray array];
    for (int i = 0; i < methodCount ; i++) {
        
        struct objc_method_description description = method_description_list[i];
        [protocolMethods addObject:NSStringFromSelector(description.name)];
    }
    free(method_description_list);

    return [NSArray arrayWithArray:protocolMethods];
}

#pragma mark - 注册close协议方法
- (void)registerHandler_close {
    
    __weak typeof(self) weakSelf = self;
    [_bridge registerHandler:@"close" handler:^(id data, WVJBResponseCallback responseCallback) {

        LogInfo(@"WinJSBridgeViewController registerHandler_close");
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.navigationController) {
            if(strongSelf.backBlcok){
                strongSelf.backBlcok();
            }
            [strongSelf.navigationController popViewControllerAnimated:YES];
        }
        else {
            
            [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
            strongSelf.externalOpenUrl = @"";
            [strongSelf dismissViewControllerAnimated:NO completion:nil];
        }
       
        if (strongSelf.backFreshOrangeState) {
            strongSelf.backFreshOrangeState();
        }
    }];
}

#pragma mark - 注册getCurrentLocation协议方法
- (void)registerHandler_getCurrentLocation {

    __weak typeof(self) weakSelf = self;
    [_bridge registerHandler:@"getCurrentLocation" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        LogInfo(@"WinJSBridgeViewController registerHandler_getCurrentLocation");
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.callbackObj = responseCallback;
        [strongSelf requestLocationWithIsHUD:YES isCallBack:YES];
    }];
}

#pragma mark - 注册openOptionsNavigation打协议方法
- (void)registerHandler_openOptionsNavigation {

    __weak typeof(self) weakSelf = self;
    [_bridge registerHandler:@"openOptionsNavigation" handler:^(id data, WVJBResponseCallback responseCallback) {

        NSDictionary *dic = nil;
        if ([data isKindOfClass:[NSDictionary class]]) {
            dic = (NSDictionary *)data;
        }
        else if ([data isKindOfClass:[NSString class]]) {
            NSString *info = (NSString *)data;
            dic = [info objectFromJSONString];
        }

        double latitude = ((NSString *)[dic objectForKey:@"storelat"]).doubleValue;
        double longitude = ((NSString *)[dic objectForKey:@"storelon"]).doubleValue;
        LogInfo(@"WinJSBridgeViewController registerHandler_openOptionsNavigation %f %f", latitude, longitude);
        if (latitude == 0 || longitude == 0) {
            return;
        }
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf openOptionsNavigationWithLatitude:latitude longitude:longitude];
    }];
}

#pragma mark - 跳转门店任务协议
- (void)registerHandler_jumpStoreTask {
    
    __weak typeof(self) weakSelf = self;
    [_bridge registerHandler:@"jumpStoreTask" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary *dic = nil;
        if ([data isKindOfClass:[NSDictionary class]]) {
            dic = (NSDictionary *)data;
        }
        else if ([data isKindOfClass:[NSString class]]) {
            NSString *info = (NSString *)data;
            dic = [info objectFromJSONString];
        }
        
        NSString *storeId = nil;
        id storeIdData = [dic objectForKey:@"storeId"];
        if ([storeIdData isKindOfClass:[NSString class]]) {
            storeId = [NSString stringWithFormat:@"%@", (NSString *)storeIdData];
        }
        else if ([storeIdData isKindOfClass:[NSNumber class]]) {
            storeId = [NSString stringWithFormat:@"%ld", [(NSNumber *)storeIdData integerValue]];
        }
        
        LogInfo(@"WinJSBridgeViewController registerHandler_jumpStoreTask %@", storeId);
        if (storeId.length == 0) {
            return;
        }
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.jumpStoreID = storeId;
        [strongSelf requestStoreInfoWithStoreId:storeId];
    }];
}

#pragma mark - 完成橙色采集协议
- (void)registerHandler_completeOrangeAcquisition {
    
    __weak typeof(self) weakSelf = self;
    [_bridge registerHandler:@"completeOrangeAcquisition" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary *dic = nil;
        if ([data isKindOfClass:[NSDictionary class]]) {
            dic = (NSDictionary *)data;
        }
        else if ([data isKindOfClass:[NSString class]]) {
            NSString *info = (NSString *)data;
            dic = [info objectFromJSONString];
        }
        
        NSString *storeId = [NSString stringNotNilWithValue:[dic objectForKey:@"storeId"]];
        LogInfo(@"WinJSBridgeViewController registerHandler_completeOrangeAcquisition storeId=%@", storeId);
        if (storeId.length == 0) {
            return;
        }
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf executeCompleteOrangeAcquisitionLuaWithStoreId:storeId];
    }];
}

#pragma mark - 完成oto采集协议
- (void)registerHandler_completeOtoAcquisition {
    
    __weak typeof(self) weakSelf = self;
    [_bridge registerHandler:@"completeOtoAcquisition" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary *dic = nil;
        if ([data isKindOfClass:[NSDictionary class]]) {
            dic = (NSDictionary *)data;
        }
        else if ([data isKindOfClass:[NSString class]]) {
            NSString *info = (NSString *)data;
            dic = [info objectFromJSONString];
        }
        
        NSString *storeId = [NSString stringNotNilWithValue:[dic objectForKey:@"storeId"]];
        LogInfo(@"WinJSBridgeViewController registerHandler_completeOtoAcquisition storeId=%@", storeId);
        if (storeId.length == 0) {
            return;
        }
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf executeCompleteOtoAcquisitionLuaWithStoreId:storeId];
    }];
}

#pragma mark - 获取退出门店数据协议
- (void)registerHandler_getExitStoreData {
    
    __weak typeof(self) weakSelf = self;
    [_bridge registerHandler:@"getExitStoreData" handler:^(id data, WVJBResponseCallback responseCallback) {

        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSMutableDictionary *callbackDic = [[NSMutableDictionary alloc] init];
        NSString *remarks = [strongSelf.externalInfoDic objectForKey:Win_JSBridge_Parameter_VisitStoreRemind_Mark];
        [callbackDic setValue:remarks forKey:@"remarks"];
        NSString *inStoreTime = [strongSelf.externalInfoDic objectForKey:Win_JSBridge_Parameter_VisitStoreDuration_Mark];
        [callbackDic setValue:inStoreTime forKey:@"inStoreTime"];
        
        LogInfo(@"WinJSBridgeViewController registerHandler_getExitStoreData callbackDic = %@", callbackDic);
        responseCallback([callbackDic JSONString]);
    }];
}

#pragma mark - 完成拜访门店协议
- (void)registerHandler_completeVisitStore {
    
    __weak typeof(self) weakSelf = self;
    [_bridge registerHandler:@"completeVisitStore" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        LogInfo(@"WinJSBridgeViewController registerHandler_completeVisitStore");
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf backToLeaveStoreImplementClose];
    }];
}

#pragma mark - 跳转网页协议
- (void)registerHandler_jumpWebView {
    
    __weak typeof(self) weakSelf = self;
    [_bridge registerHandler:@"jumpWebView" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary *dic = nil;
        if ([data isKindOfClass:[NSDictionary class]]) {
            dic = (NSDictionary *)data;
        }
        else if ([data isKindOfClass:[NSString class]]) {
            NSString *info = (NSString *)data;
            dic = [info objectFromJSONString];
        }
        
        NSString *webUrl = [NSString stringNotNilWithValue:[dic objectForKey:@"webUrl"]];
        LogInfo(@"WinJSBridgeViewController registerHandler_jumpWebView webUrl = %@", webUrl);
        if (webUrl.length == 0) {
            return;
        }
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSURL *url = [[NSURL alloc] initWithString:webUrl];
        WSReportFormController *vc = [[WSReportFormController alloc] initWithURL:url];
        if ([NSString stringNotNilWithValue:[dic objectForKey:@"title"]].length > 0) {
            vc.title = [NSString stringNotNilWithValue:[dic objectForKey:@"title"]];
        }
        [strongSelf.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - 保存门店动作协议
- (void)registerHandler_saveStoreAction {
    
    __weak typeof(self) weakSelf = self;
    [_bridge registerHandler:@"saveStoreAction" handler:^(id data, WVJBResponseCallback responseCallback) {
                
        __strong typeof(weakSelf) strongSelf = weakSelf;
        LogInfo(@"WinJSBridgeViewController registerHandler_saveStoreAction currentVisitAction=%@", strongSelf.currentVisitAction);
        
        if (strongSelf.currentVisitAction) {
            [[WSVisitStoreActionTable sharedTable] updateAction:strongSelf.currentVisitAction toStatus:ActionDone];
        }
    }];
}

#pragma mark - 消息阅读交互
- (void)registerHandler_readFinish {
    
    [_bridge registerHandler:@"ReadFinish" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary *dic = nil;
        if ([data isKindOfClass:[NSDictionary class]]) {
            dic = (NSDictionary *)data;
        }
        else if ([data isKindOfClass:[NSString class]]) {
            NSString *info = (NSString *)data;
            dic = [info objectFromJSONString];
        }
        
        NSString *messId = [NSString stringNotNilWithValue:[dic objectForKey:@"messId"]];
        LogInfo(@"WinJSBridgeViewController registerHandler_readFinish messIds：%@", messId);
        
        [WSComponyInfomationManager markAsReadedByMsg:messId];
    }];
}

#pragma mark - 打开Trax相机协议
- (void)registerHandler_openTraxCameraTask {
    
    __weak typeof(self) weakSelf = self;
    [_bridge registerHandler:@"openTraxCamera" handler:^(id data, WVJBResponseCallback responseCallback) {

        NSDictionary *dic = nil;
        if ([data isKindOfClass:[NSDictionary class]]) {
            dic = (NSDictionary *)data;
        }
        else if ([data isKindOfClass:[NSString class]]) {
            NSString *info = (NSString *)data;
            dic = [info objectFromJSONString];
        }
        
        NSString *acvtId = [NSString stringNotNilWithValue:[dic objectForKey:@"acvtId"]];
        NSString *storeId = [NSString stringNotNilWithValue:[dic objectForKey:@"storeId"]];
        NSString *uuid = [NSString stringNotNilWithValue:[dic objectForKey:@"uuid"]];
        LogInfo(@"WinJSBridgeViewController registerHandler_openTraxCameraTask acvtId=%@ storeId=%@ uuid=%@", acvtId, storeId, uuid);
        if (acvtId.length == 0 || storeId.length == 0 || uuid.length == 0) {
            return;
        }
                
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.cameraCallbackObj = responseCallback;
        
        NSString *type = [NSString stringNotNilWithValue:[dic objectForKey:@"type"]];
        if ([type isEqualToString:@"1"]) {
            [strongSelf setupUploadImageToolWithStoreId:storeId uuid:uuid type:WJBVCOpenCameraTypeSpeManagerFollowUp];
        }
        else {
            [strongSelf setupUploadImageToolWithStoreId:storeId uuid:uuid type:WJBVCOpenCameraTypeSpeOrange];
        }
        
        NSArray *params = @[uuid, storeId, acvtId];
        [[WSPaiPaiManager sharedInstance] createEngineWithBusinessDataIds:params];
        [WSPaiPaiManager sharedInstance].delegate = strongSelf;
        
        NSMutableDictionary *ppDictionary = [[NSMutableDictionary alloc] init];

        NSString *tiltValue = [NSString stringNotNilWithValue:[dic objectForKey:@"tiltKey"]];
        [ppDictionary setObject:tiltValue forKey:tiltKey];

//        if ([type isEqualToString:@"1"]) {
//            NSString *maxPhoto = [NSString stringNotNilWithValue:[dic objectForKey:@"maxPhoto"]];
//            [ppDictionary setObject:maxPhoto forKey:pzMaxKey];
//        }
        
        [[WSPaiPaiManager sharedInstance] jumpToPPZCameraWithPZType:PPCamera_Normal withVc:strongSelf extendParam:ppDictionary];
    }];
}

#pragma mark - 本地相册交互协议
- (void)registerHandler_getLocalPicture {
    
    __weak typeof(self) weakSelf = self;
    [_bridge registerHandler:@"getLocalPicture" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"无法打开相册" tips:nil tapTarget:nil action:nil];
            return;
        }
        
        NSDictionary *dic = nil;
        if ([data isKindOfClass:[NSDictionary class]]) {
            dic = (NSDictionary *)data;
        }
        else if ([data isKindOfClass:[NSString class]]) {
            NSString *info = (NSString *)data;
            dic = [info objectFromJSONString];
        }
                   
        NSString *acvtId = [NSString stringNotNilWithValue:[dic objectForKey:@"acvtId"]];
        NSString *storeId = [NSString stringNotNilWithValue:[dic objectForKey:@"storeId"]];
        NSString *uuid = [NSString stringNotNilWithValue:[dic objectForKey:@"uuid"]];
        LogInfo(@"WinJSBridgeViewController registerHandler_getLocalPicture acvtId=%@ storeId=%@ uuid=%@", acvtId, storeId, uuid);
        if (acvtId.length == 0 || storeId.length == 0 || uuid.length == 0) {
            return;
        }
        
        NSString *maxPhotoStr = [NSString stringNotNilWithValue:[dic objectForKey:@"maxPhoto"]];
        LogInfo(@"WinJSBridgeViewController registerHandler_getLocalPicture maxPhotoStr=%@", maxPhotoStr);
        if (maxPhotoStr.length == 0 || ([maxPhotoStr integerValue] <= 0)) {
            return;
        }
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.cameraCallbackObj = responseCallback;
        [strongSelf setupUploadImageToolWithStoreId:storeId uuid:uuid type:WJBVCOpenCameraTypeLocalPicture];

        TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initWithMaxImagesCount:[maxPhotoStr integerValue] columnNumber:4
                                                                                              delegate:strongSelf pushPhotoPickerVc:NO];
        imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
        imagePicker.allowPickingOriginalPhoto = NO;
        imagePicker.allowPickingVideo = NO;
        imagePicker.allowTakePicture = NO;
        imagePicker.allowPreview = NO;
        imagePicker.showSelectedIndex = YES;
        [strongSelf presentViewController:imagePicker animated:YES completion:nil];
    }];
}
#pragma mark - # 更新菜单活动数量协议
- (void)registerHandler_updateFuncsCount{
    
    [_bridge registerHandler:@"updateFuncsCount" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary *dic = nil;
        if ([data isKindOfClass:[NSDictionary class]]) {
            dic = (NSDictionary *)data;
        }
        else if ([data isKindOfClass:[NSString class]]) {
            NSString *info = (NSString *)data;
            dic = [info objectFromJSONString];
        }
        
        NSString *funCode = [NSString stringNotNilWithValue:[dic objectForKey:@"funCode"]];
        NSString *storeId = [NSString stringNotNilWithValue:[dic objectForKey:@"storeId"]];
        NSString *count = [NSString stringNotNilWithValue:[dic objectForKey:@"count"]];

        LogInfo(@"WinJSBridgeViewController registerHandler_updateFuncsCount acvtId=%@ storeId=%@", funCode, storeId);
        if (funCode.length == 0 || storeId.length == 0) {
            LogError(@"菜单或者门店 id 为空");
            return;
        }
        
        [WSFuncTipDBService updateTipWithFuncCode:funCode andStoreId:storeId count:count];
        
    }];
}
@end
//====================================================================================================================================
