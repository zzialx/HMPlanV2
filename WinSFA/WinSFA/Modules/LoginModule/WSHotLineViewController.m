//
//  WSHotLineViewController.m
//  WinSFA
//
//  Created by huzepei on 16/6/21.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSHotLineViewController.h"
#import "UIView+Extension.h"
#import <WebKit/WebKit.h>

#define k_webViewHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 240 : 320)
#define k_webViewWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? (self.view.width - 2 * WSWebViewOffset): 320)
#define WSWebViewOffset 20

@interface WSHotLineViewController ()<WKNavigationDelegate, WKUIDelegate, UINavigationControllerDelegate>
{
    BOOL _isFirstCallHotline;
}
@end

@implementation WSHotLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    webView.backgroundColor = [UIColor whiteColor];
    webView.center = CGPointMake(self.view.width / 2, self.view.height + k_webViewWidth);
    webView.bounds = CGRectMake(0, 0, k_webViewWidth, k_webViewHeight);
    webView.backgroundColor = [UIColor whiteColor];
    webView.layer.cornerRadius = 15;
    webView.layer.masksToBounds = YES;
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    webView.backgroundColor = [UIColor whiteColor];
    
    
    NSString *baseStr = @"http://inside.winchannel.net:4013/kehu_FAQ/";
    NSString *appName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
    
    //MSTD-5159
    //http://inside.winchannel.net:4013/kehu_FAQ/项目名/语言简码（例:zh_CN）/index.html
    NSString *url_str = [NSString stringWithFormat:@"%@%@/%@/index.html",baseStr,appName,[UIDevice getPreferredLanguage]];
    
    
    
    
    NSURL *url = [NSURL URLWithString:url_str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [webView loadRequest:request];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.1 animations:^{
            webView.center = CGPointMake(self.view.width/2, self.view.height/2);
            [webView loadRequest:request];
        }];
    });
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickView)];
    [self.view addGestureRecognizer:tapGesture];
}
/**
 *  点击View,将modal dismiss
 */
-(void)clickView
{
    [self dismissViewControllerAnimated:NO completion:nil];
}
#pragma mark delegate

#pragma mark - # WKDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    if ([navigationAction.request.URL.absoluteString rangeOfString:@"modifypassword"].location != NSNotFound) {

        NSString *findPasswordMjet = [WSPlistHelper valueForKey:kGET_PASSWORD_URL withPlistName:kConfilgFileName];
        if ([findPasswordMjet length] > 0) {
            
            if (self.checkChangePwd) {
                self.checkChangePwd();
            }
        }
        else {
            
            if (self.findBackPwd) {
                self.findBackPwd();
            }
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
