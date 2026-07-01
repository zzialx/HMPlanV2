//
//  WinFilingInfoViewController.m
//  WinSFA
//
//  Created by yuanji on 2024/4/1.
//  Copyright © 2024 WinChannel. All rights reserved.
//

#import "WinFilingInfoViewController.h"
#import <WebKit/WebKit.h>

@interface WinFilingInfoViewController () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;           //网页视图
@property (nonatomic, strong) UIProgressView *progressView; //进度条视图

@end

@implementation WinFilingInfoViewController

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
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
#endif
    }
    
    return _webView;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    [self subWidgetLayout];
    [self.webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
    NSString *urlStr = [NSString stringNotNilWithValue:@"https://beian.miit.gov.cn/"];
    NSURL *requestUrl = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    [self.webView loadRequest:request];
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

#pragma mark - 重写dealloc方法
- (void)dealloc {

    [_webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [_webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(title))];
}

#pragma mark - 重写shouldCustomInteractivePopGestureRecognizerDelegate方法
- (BOOL)shouldCustomInteractivePopGestureRecognizerDelegate {
    
    return YES; //授权左滑返回启动
}

#pragma mark - 子视图布局方法
- (void)subWidgetLayout {
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f));
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(4.0f);
    }];
}

@end
