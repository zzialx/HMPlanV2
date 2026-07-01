//
//  WCOverlayView.h
//  QuadCore
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum RROverlayStatus {
    EOverlayStatusRemove = 1,    //无提示
    EOverlayStatusLoading,    //加载中
    EOverlayStatusEmpty,     //数据空
    EOverlayStatusError,    //网络错误
    EOverlayStatusForbit,   //无权限
}RROverlayStatus;
#define kOverlayImageHeight 125
#define kOverlayTextHeight 57
#define kIndicatorWidth 30.0

@interface WCOverlayView : UIView{
    // 状态
    RROverlayStatus _overlayStatus;
    // 图片
    UIImageView *_imgView;
    // label
    UILabel *_label;
    // 加载文本
    NSString *_loadingText;
    // 空数据文本
    NSString *_emptyText;
    // 加载出错文本
    NSString *_errorText;
    // 无权限文本
    NSString *_forbitText;
    // 菊花
    UIActivityIndicatorView *_indicatorView;
    // 是否支持换肤
    BOOL _supportSkin;
    // 是否支持动画,淡入淡出
    BOOL _animate;
}

// 适配
- (void)suitForStatus:(RROverlayStatus)status;
// 换肤
- (void)changeSkinAction;

@property (nonatomic, assign) RROverlayStatus status;
@property (nonatomic, retain) UIImageView *imgView;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, copy) NSString *loadingText;
@property (nonatomic, copy) NSString *emptyText;
@property (nonatomic, copy) NSString *errorText;
@property (nonatomic, copy) NSString *forbitText;
@property (nonatomic, retain) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) BOOL supportSkin;
@property (nonatomic, assign) BOOL animate;

@end
