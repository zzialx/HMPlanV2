//
//  WSVisualDiagnosticTestView.h
//  WinSFA
//
//  Created by HZH on 16/10/17.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSVisualDiagnosticTestView : UIView

// 能实时获取progress的时候调用
- (void)setProgress:(CGFloat)progress andTextWhenTestFinishedWithUseTime:(long)testUseTime;
// 不能实时获取progress的时候调用（服务器未返回Content-Length）
- (void)setProgressAndTextWhenTestFinishedWithUseTime:(long)testUseTime;
//
- (id)initWithFrame:(CGRect)frame andTestContentString:(NSString *)contentString;

@end
