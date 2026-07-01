//
//  WSAboutUsController.m
//  WinSFA
//
//  Created by zhiqing on 16/8/31.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSAboutUsController.h"
#import "WSRichModel.h"
#import "WSRichItemModel.h"
#import "PureLayout.h"
#import <WebKit/WebKit.h>

// 随机颜色
#define RANDOM [UIColor colorWithRed:arc4random()%255 /255.0  green:arc4random()%255 /255.0  blue:arc4random()%255 /255.0  alpha:0.6]
#define CACHE_DIR [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface WSAboutUsController ()

@end

@implementation WSAboutUsController

- (void)viewDidLoad {
    [super viewDidLoad];
    WSRichItemModel  *model;
    if (self.allItemModel.count > 0) {
        model = self.allItemModel[0];
    }
    if (model) {
        WKWebView *webView = [[WKWebView alloc] init];
        [webView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self.view addSubview:webView];
        
        NSString *imgStr = [NSString stringWithFormat:@"%@/richMedia/%@/index.html", CACHE_DIR, model.h5_add];
        NSURL *url = [NSURL URLWithString:imgStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
    }
}

@end
