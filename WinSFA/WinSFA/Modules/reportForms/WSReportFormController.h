//
//  WSReportFormController.h
//  WinSFA
//
//  Created by Nemo on 14-4-11.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"

//链接中包含这个字符串，表示新窗口打开链接
#define kNewWindowWhenClickLink        (@"winsfaioshyperlink")

@class WSAcvtBean;

typedef NS_ENUM(NSInteger,WSReportFormControllerWorkMode) {
    WSReportFormControllerWorkModeReportForm = 0,
    WSReportFormControllerWorkModeURL
};

typedef void(^showTips)(void);

@protocol WSReportFormControllerDelegate <NSObject>

@optional

- (void)didGetDataFromReportForm:(NSString *)data;

- (void)resetFrame;

// YIHAIKERRY-2653 获取报表表单返回数据之后需实时请求调查问卷数据，并更新问卷
- (void)realTimeRefreshAcvtDatasWithGetDataFromReportForm:(NSString *)data;

@end


@interface WSReportFormController : BaseViewController<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

/**
 *  @author weida
 *
 *  @brief 页面点击是否调整至新控制器，默认NO,注意链接中包含winsfaioshyperlink的才能识别
 */
// SFA-14118 屏蔽掉该逻辑，跟安卓不一致，而且外部设置该值的方式破坏了封装性，并且还会产生 Bug
//@property(nonatomic,assign) BOOL shouldPushNewControllerWhenClick;

@property(nonatomic,assign) BOOL shouldReloadWhenAppear;

@property (nonatomic, strong) WSAcvtBean *currentAcvtBean;

@property (nonatomic, weak) id<WSReportFormControllerDelegate> delegate;

@property (nonatomic, strong) UIBarButtonItem *buttonItem;

@property (nonatomic, assign) BOOL isInContainerView;

@property (nonatomic, strong)NSURL *loadURL;

@property (nonatomic, copy)showTips showTips;///<显示弹框

-(id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean*)store;

-(id)initWithFuncs:(WSFuncsBean *)funcs;

-(id)initWithURL:(NSURL *)url;

- (id)initWithURL:(NSURL *)url WithIsNeedCookie:(BOOL)isNeedCookie;

@end

