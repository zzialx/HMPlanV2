//
//  LEOAssistiveTouch.m
//  AssistiveTouch
//
//  Created by chinabkorse on 15/10/20.
//  Copyright © 2015年 Leo. All rights reserved.
//

#import "LEOAssistiveTouch.h"
#import "LEOAssistiveWindow.h"
#import "LEOAssistiveWindowMainItem.h"
#import "LEOAssistiveViewController.h"
#import "WSReportFormController.h"
#import "WSAppDelegate.h"
#import "WSApplicationWindowsRelationManager.h"
#import "WSEMSDKManager.h"
#import "WSOnlineConsultationService.h"
//===========================================================================================================================================

#pragma mark - 辅助按键(在线咨询) 延展(内部)
@interface LEOAssistiveTouch () <LEOAssistiveWindowDelegate>

@property (nonatomic, strong) LEOAssistiveWindow *window; //悬浮window

@end
//===========================================================================================================================================

#pragma mark - 辅助按键(在线咨询)
@implementation LEOAssistiveTouch

#pragma mark - 单例方法
+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    static LEOAssistiveTouch *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[LEOAssistiveTouch alloc] init];
    });
    
    return instance;
}

#pragma mark - 重写init方法
- (instancetype)init {
    
    self = [super init];
    if (self) {

        CGFloat x = [UIScreen mainScreen].bounds.size.width - kDragMainItemWidth;
        CGFloat y = [UIScreen mainScreen].bounds.size.height - kDragWindowHeight - 60;
        _window = [[LEOAssistiveWindow alloc] initWithFrame:CGRectMake(x, y,  kDragMainItemWidth, kDragWindowHeight)];
        _window.windowLevel = UIWindowLevelAlert;
        _window.backgroundColor = [UIColor clearColor];
        _window.hidden = YES;
        _window.clipsToBounds = YES;
        _window.assistiveDelegate = self;
        _window.rootViewController = [[LEOAssistiveViewController alloc] init];
        
        LEOAssistiveWindowMainItem *mainbtn = [[LEOAssistiveWindowMainItem alloc] init];
        [mainbtn setImage:[UIImage imageNamed:@"icon_online_chat"] forState:UIControlStateNormal];
        [mainbtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _window.mainButton = mainbtn;
    }
    return self;
}

#pragma mark - 设置主按键图片方法(对外)
- (void)setMainBtnImage:(UIImage *)image {
    
    [_window.mainButton setImage:image forState:UIControlStateNormal];
}

#pragma mark - 显示浮窗方法(对外)
+ (void)show {
    
    [[LEOAssistiveTouch sharedInstance] show];
}

#pragma mark - 隐藏浮窗方法(对外)
+ (void)hide {
    
    [[LEOAssistiveTouch sharedInstance] hide];
}

#pragma mark - 显示方法
- (void)show {
    
    _window.hidden = NO;
}

#pragma mark - 隐藏方法
- (void)hide {
    
    _window.hidden = YES;
}

#pragma mark - 设置点击闭包方法
- (void)setMainBtnClickedCallbackBlock:(mainBtnClickedCallback)mainBtnClickedCallbackBlock {
    
    if (mainBtnClickedCallbackBlock) {
        _mainBtnClickedCallbackBlock = mainBtnClickedCallbackBlock;
    }
}

#pragma mark - 实现LEOAssistiveWindowDelegate--assistiveWindowMainButtonEvent:协议 主按键点击方法
- (void)assistiveWindowMainButtonEvent:(LEOAssistiveWindow *)window {

    if (_mainBtnClickedCallbackBlock) {
        
        _mainBtnClickedCallbackBlock();
        _mainBtnClickedCallbackBlock = nil;
    }
    else {
        
        WSOnlineConsultationService *onlineConsultationService = [WSOnlineConsultationService shareInstance];
        [onlineConsultationService gotoNextOnlineConsultationReportFormViewControllerWithOnlineConsultationString:nil];
    }
}

@end
//===========================================================================================================================================

