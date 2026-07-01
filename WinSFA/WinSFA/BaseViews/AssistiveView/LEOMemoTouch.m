//
//  LEOMemoTouch.m
//  WinSFA
//
//  Created by yuanji on 2025/8/5.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "LEOMemoTouch.h"
#import "LEOAssistiveWindow.h"
#import "LEOAssistiveWindowMainItem.h"
#import "LEOAssistiveViewController.h"
#import "WSReportFormController.h"
#import "WSAppDelegate.h"
#import "WSApplicationWindowsRelationManager.h"
#import "WSEMSDKManager.h"
#import "WSOnlineConsultationService.h"
#import "WSBaseStoreOtherDataTable.h"
//===========================================================================================================================================

#pragma mark - 辅助按键(备忘录) 延展(内部)
@interface LEOMemoTouch () <LEOAssistiveWindowDelegate>

@property (nonatomic, strong) LEOAssistiveWindow *window; //悬浮window

@end
//===========================================================================================================================================

#pragma mark - 辅助按键(备忘录)
@implementation LEOMemoTouch

#pragma mark - 单例方法(针对根视图)
+ (instancetype)rootSharedInstance {
    
    static dispatch_once_t rootOnceToken;
    static LEOMemoTouch *rootInstance = nil;
    dispatch_once(&rootOnceToken, ^{
        rootInstance = [[LEOMemoTouch alloc] init];
    });
    
    return rootInstance;
}

#pragma mark - 单例方法(针对指定视图)
+ (instancetype)subSharedInstance {
    
    static dispatch_once_t subOnceToken;
    static LEOMemoTouch *subInstance = nil;
    dispatch_once(&subOnceToken, ^{
        subInstance = [[LEOMemoTouch alloc] init];
    });
    
    return subInstance;
}

#pragma mark - 判断是否显示备忘录网页方法
+ (NSString *)isShowMemoURL {
    
    NSArray *memoArray = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:@[@"type"] ArgumentsValue:@[ELECTRONICMEMO]];
    WSBaseStoreOtherDataObject *memoObject = [memoArray firstObject];
    if ([memoObject.item1 isEqualToString:@"1"] && memoObject.item2.length > 0) {
        return memoObject.item2;
    }
    return nil;
}

#pragma mark - 重写init方法
- (instancetype)init {
    
    self = [super init];
    if (self) {

        CGFloat x = [UIScreen mainScreen].bounds.size.width - kDragMainItemWidth;
        CGFloat y = [UIScreen mainScreen].bounds.size.height - kDragWindowHeight - 200;
        _window = [[LEOAssistiveWindow alloc] initWithFrame:CGRectMake(x, y,  kDragMainItemWidth, kDragWindowHeight)];
        _window.windowLevel = UIWindowLevelAlert;
        _window.backgroundColor = [UIColor clearColor];
        _window.hidden = YES;
        _window.clipsToBounds = YES;
        _window.assistiveDelegate = self;
        _window.rootViewController = [[LEOAssistiveViewController alloc] init];
        
        LEOAssistiveWindowMainItem *mainbtn = [[LEOAssistiveWindowMainItem alloc] init];
        [mainbtn setImage:[UIImage imageNamed:@"icon_online_memo"] forState:UIControlStateNormal];
        [mainbtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _window.mainButton = mainbtn;
    }
    return self;
}

#pragma mark - 设置主按键图片方法(对外)
- (void)setMainBtnImage:(UIImage *)image {
    
    [_window.mainButton setImage:image forState:UIControlStateNormal];
}

#pragma mark - 显示方法(对外)
- (void)show {
    
    _window.hidden = NO;
}

#pragma mark - 隐藏方法(对外)
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

#pragma mark - 复位窗口位置方法
- (void)resetWindowFrame {

    CGFloat x = [UIScreen mainScreen].bounds.size.width - kDragMainItemWidth;
    CGFloat y = [UIScreen mainScreen].bounds.size.height - kDragWindowHeight - 200;
    _window.frame = CGRectMake(x, y,  kDragMainItemWidth, kDragWindowHeight);
}

@end
//===========================================================================================================================================
