//
//  WSCustomDrawSlider.h
//  WinSFA
//
//  Created by yuanji on 2017/10/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSCustomDrawSlider;
@protocol WSCustomDrawSliderDelegate;

#pragma mark - 定义滑杆方向枚举
typedef NS_ENUM(NSInteger, WSSliderOrientation)
{
    WSSliderOrientationTransverse,  //横向
    WSSliderOrientationPortrait     //纵向
};

#pragma mark - 定义绘制滑杆数值改变闭包 slider:滑杆 sliderValue:滑杆值
typedef void (^WSCustomDrawSliderValueChangBlock)(WSCustomDrawSlider *slider, CGFloat sliderValue);
//================================================================================================================================================

#pragma mark - 自定义绘制滑杆
@interface WSCustomDrawSlider : UIView

@property (nonatomic, weak) id <WSCustomDrawSliderDelegate> delegate;               //绘制滑杆代理指针
@property (nonatomic, copy) WSCustomDrawSliderValueChangBlock sliderValueChangBlock;//绘制滑杆数值改变闭包

@property (nonatomic, strong) UIColor *sliderInsetColor;                            //滑杆内容颜色
@property (nonatomic, strong) UIColor *sliderFrameColor;                            //滑杆边框颜色
@property (nonatomic, assign) CGFloat sliderFrameWidth;                             //滑杆边框宽度
@property (nonatomic, strong) UIImage *sliderCenterImage;                           //滑杆中心图片
@property (nonatomic, assign) WSSliderOrientation sliderOrientation;                //滑杆方向
@property (nonatomic, assign) CGFloat sliderCornerRoundnes;                         //滑杆边角圆度
@property (nonatomic, assign) CGFloat sliderCurrentValue;                           //滑杆当前值
@property (nonatomic, assign) CGFloat sliderMinValue;                               //滑杆最小值
@property (nonatomic, assign) CGFloat sliderMaxValue;                               //滑杆最大值
@property (nonatomic, assign) BOOL isAuxiliaryButtonOperation;                      //是否辅助按键操作
@property (nonatomic, strong) UIImage *minAuxiliaryButtonImage;                     //最小助按键图片
@property (nonatomic, strong) UIImage *maxAuxiliaryButtonImage;                     //最大助按键图片
@property (nonatomic, assign) CGFloat auxiliaryButtonThickness;                     //辅助按键厚度
@property (nonatomic, assign) CGFloat sliderThickness;                              //滑杆厚度
@property (nonatomic, assign) CGFloat sliderOffsetValue;                            //滑杆偏移值

#pragma mark - 重载绘制滑杆方法
- (void)reloadDrawSlider;

@end
//================================================================================================================================================

#pragma mark - 绘制滑杆代理协议
@protocol WSCustomDrawSliderDelegate <NSObject>

@optional //可选

#pragma mark - 自定义绘制滑杆值变化协议 slider:滑杆 sliderValue:滑杆值
- (void)customDrawSlider:(WSCustomDrawSlider *)slider sliderValue:(CGFloat)sliderValue;

@end
//================================================================================================================================================
