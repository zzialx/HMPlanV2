//
//  WSCustomDrawSlider.m
//  WinSFA
//
//  Created by yuanji on 2017/10/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSCustomDrawSlider.h"
//================================================================================================================================================

#pragma mark - 自定义绘制滑杆
@interface WSCustomDrawSlider ()

@property (nonatomic, strong) UIImageView *centerImageView; //中心图片视图
@property (nonatomic, strong) UIButton *minButton;          //小值按键
@property (nonatomic, strong) UIButton *maxButton;          //大值按键
@property (nonatomic, assign) CGFloat centerPosition;       //中心位置

- (void)handleCenterSliderGesture:(UIPanGestureRecognizer *)gesture;//处理中心滑动手势方法 gesture:手势
- (void)minButtonClick:(id)sender;                                  //小值按键响应方法 sender:按键
- (void)maxButtonClick:(id)sender;                                  //大值按键响应方法 sender:按键

@end
//================================================================================================================================================

#pragma mark - 自定义绘制滑杆 延展(工具)
@interface WSCustomDrawSlider (Tools)

- (void)initDefaultProperty;                                                    //初始化默认属性方法
- (void)setupContent;                                                           //设置内容方法
- (void)setupLayout;                                                            //设置布局方法
- (CGFloat)valueTransformationCenterPosition;                                   //数值转换中心位置方法
- (void)drawRoundedRectWithContext:(CGContextRef)context inRect:(CGRect)rect;   //绘制圆角矩形方法 context:上下文 rect:绘制区域
- (void)drawFrameWithContext:(CGContextRef)context inRect:(CGRect)rect;         //绘制边框方法 context:上下文 rect:绘制区域
- (CGFloat)getDrawSliderMaxLength;                                              //获取绘制滑杆最大长度方法

@end
//================================================================================================================================================

#pragma mark - 自定义绘制滑杆
@implementation WSCustomDrawSlider

#pragma mark - 重写init方法
- (id)init
{
    self = [super init];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
        [self initDefaultProperty];
        [self setupContent];
    }
    return self;
}

#pragma mark - 重写initWithFrame:方法
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
        [self initDefaultProperty];
        [self setupContent];
    }
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupLayout];
}

#pragma mark - 重写drawRect:方法
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawRoundedRectWithContext:context inRect:rect];
    [self drawFrameWithContext:context inRect:rect];
    
    [[UIColor clearColor] set];
    CGContextAddEllipseInRect(context, self.centerImageView.frame);
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextFillPath(context);
}

#pragma mark - 重写设置sliderCurrentValue:方法
- (void)setSliderCurrentValue:(CGFloat)sliderCurrentValue
{
    if(sliderCurrentValue >= self.sliderMinValue && sliderCurrentValue <= self.sliderMaxValue && sliderCurrentValue != self.sliderCurrentValue)
    {
        _sliderCurrentValue = sliderCurrentValue;
        [self reloadDrawSlider];
        
        if ([self.delegate respondsToSelector:@selector(customDrawSlider:sliderValue:)])
            [self.delegate customDrawSlider:self sliderValue:sliderCurrentValue];
        
        if (self.sliderValueChangBlock)
            self.sliderValueChangBlock(self, sliderCurrentValue);
    }
}

#pragma mark - 重载绘制滑杆方法
- (void)reloadDrawSlider
{
    [self.minButton setImage:self.minAuxiliaryButtonImage forState:UIControlStateNormal];
    [self.maxButton setImage:self.maxAuxiliaryButtonImage forState:UIControlStateNormal];
    self.centerImageView.image = self.sliderCenterImage;
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

#pragma mark - 处理中心滑动手势方法 gesture:手势
- (void)handleCenterSliderGesture:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [gesture translationInView:self];
        if(self.sliderOrientation == WSSliderOrientationTransverse)
            self.centerPosition += translation.x;
        else
            self.centerPosition += translation.y;
        
        CGFloat maxLength = [self getDrawSliderMaxLength];
        if (self.centerPosition > maxLength)
            self.centerPosition = maxLength;
        if (self.centerPosition < 0.0f)
            self.centerPosition = 0.0f;
        
        [gesture setTranslation:CGPointZero inView:self];
        self.sliderCurrentValue = (self.centerPosition * (self.sliderMaxValue - self.sliderMinValue) / maxLength) + self.sliderMinValue;
    }
}

#pragma mark - 小值按键响应方法 sender:按键
- (void)minButtonClick:(id)sender
{
    self.sliderCurrentValue -= self.sliderOffsetValue;
}

#pragma mark - 大值按键响应方法 sender:按键
- (void)maxButtonClick:(id)sender
{
    self.sliderCurrentValue += self.sliderOffsetValue;
}

@end
//================================================================================================================================================

#pragma mark - 自定义绘制滑杆 延展(工具)
@implementation WSCustomDrawSlider (Tools)

#pragma mark - 初始化默认属性方法
- (void)initDefaultProperty
{
    _sliderInsetColor = [UIColor grayColor];
    _sliderFrameColor = [UIColor whiteColor];
    _sliderFrameWidth = 0.5f;
    _sliderCenterImage = [UIImage imageNamed:@"slider_zoom"];
    _sliderOrientation = WSSliderOrientationTransverse;
    _sliderCornerRoundnes = 0.3f;
    _sliderCurrentValue = 0.0f;
    _sliderMinValue = 0.0f;
    _sliderMaxValue = 10.0f;
    _isAuxiliaryButtonOperation = YES;
    _minAuxiliaryButtonImage = [UIImage imageNamed:@"btn_zoom_out"];
    _maxAuxiliaryButtonImage = [UIImage imageNamed:@"btn_zoom_in"];
    _auxiliaryButtonThickness = 0.0f;
    _sliderThickness = 15.0f;
    _sliderOffsetValue = 1.0f;
    _centerPosition = 0.0f;
}

#pragma mark - 设置内容方法
- (void)setupContent
{
    _minButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _minButton.backgroundColor = [UIColor clearColor];
    [_minButton setImage:self.minAuxiliaryButtonImage forState:UIControlStateNormal];
    [_minButton addTarget:self action:@selector(minButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_minButton];
    
    _maxButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _maxButton.backgroundColor = [UIColor clearColor];
    [_maxButton setImage:self.maxAuxiliaryButtonImage forState:UIControlStateNormal];
    [_maxButton addTarget:self action:@selector(maxButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_maxButton];
    
    _centerImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _centerImageView.backgroundColor = [UIColor clearColor];
    _centerImageView.image = self.sliderCenterImage;
    _centerImageView.userInteractionEnabled = YES;
    UIPanGestureRecognizer *centerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCenterSliderGesture:)];
    [_centerImageView addGestureRecognizer:centerPan];
    [self addSubview:_centerImageView];
}

#pragma mark - 设置布局方法
- (void)setupLayout
{
    self.centerPosition = [self valueTransformationCenterPosition];
    
    if(self.sliderOrientation == WSSliderOrientationTransverse)
    {
        if(self.isAuxiliaryButtonOperation)
        {
            CGSize buttonSize = CGSizeMake((self.auxiliaryButtonThickness > 0 ? self.auxiliaryButtonThickness : CGRectGetHeight(self.frame)), CGRectGetHeight(self.frame));
            self.minButton.frame = CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height);
            self.maxButton.frame = CGRectMake(CGRectGetWidth(self.frame) - buttonSize.width, 0.0f, buttonSize.width, buttonSize.height);
        }
        else
        {
            self.minButton.frame = CGRectZero;
            self.maxButton.frame = CGRectZero;
        }
        
        CGFloat x = CGRectGetMaxX(self.minButton.frame) + self.centerPosition;
        CGFloat y = (CGRectGetHeight(self.frame) - self.sliderCenterImage.size.height) / 2;
        CGFloat w = self.sliderCenterImage.size.width;
        CGFloat h = self.sliderCenterImage.size.height;
        self.centerImageView.frame = CGRectMake(x, y, w, h);
    }
    else
    {
        if(self.isAuxiliaryButtonOperation)
        {
            CGSize buttonSize = CGSizeMake(CGRectGetWidth(self.frame), (self.auxiliaryButtonThickness > 0 ? self.auxiliaryButtonThickness : CGRectGetWidth(self.frame)));
            self.minButton.frame = CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height);
            self.maxButton.frame = CGRectMake(0.0f, CGRectGetHeight(self.frame) - buttonSize.height, buttonSize.width, buttonSize.height);
        }
        else
        {
            self.minButton.frame = CGRectZero;
            self.maxButton.frame = CGRectZero;
        }
        
        CGFloat x = (CGRectGetWidth(self.frame) - self.sliderCenterImage.size.width) / 2;
        CGFloat y = CGRectGetMaxY(self.minButton.frame) + self.centerPosition;
        CGFloat w = self.sliderCenterImage.size.width;
        CGFloat h = self.sliderCenterImage.size.height;
        self.centerImageView.frame = CGRectMake(x, y, w, h);
    }
}

#pragma mark - 数值转换中心位置方法
- (CGFloat)valueTransformationCenterPosition
{
    if(self.sliderMaxValue <= self.sliderMinValue)
        return 0.0f;
    
    CGFloat maxLength = [self getDrawSliderMaxLength];
    return ((self.sliderCurrentValue - self.sliderMinValue) * maxLength) / (self.sliderMaxValue - self.sliderMinValue);
}

#pragma mark - 绘制圆角矩形方法 context:上下文 rect:绘制区域
- (void)drawRoundedRectWithContext:(CGContextRef)context inRect:(CGRect)rect
{
    CGRect newRect = CGRectZero;
    CGFloat maxLength = [self getDrawSliderMaxLength];
    
    if(self.sliderOrientation == WSSliderOrientationTransverse)
    {
        newRect = CGRectMake(CGRectGetWidth(self.centerImageView.frame) / 2, (CGRectGetHeight(rect) - self.sliderThickness) / 2, maxLength, self.sliderThickness);
        if(self.isAuxiliaryButtonOperation)
            newRect.origin.x += CGRectGetMaxX(self.minButton.frame);
    }
    else
    {
        newRect = CGRectMake((CGRectGetWidth(rect) - self.sliderThickness) / 2, CGRectGetHeight(self.centerImageView.frame) / 2, self.sliderThickness, maxLength);
        if(self.isAuxiliaryButtonOperation)
            newRect.origin.y += CGRectGetMaxY(self.minButton.frame);
    }
    
    CGContextSaveGState(context);
    CGContextBeginPath(context);
    CGContextSetFillColorWithColor(context, [self.sliderInsetColor CGColor]);
    CGFloat radius = self.sliderThickness * self.sliderCornerRoundnes;
    CGFloat puffer = 0.0f;
    if(self.sliderOrientation == WSSliderOrientationTransverse)
        puffer = CGRectGetMaxY(newRect) * 0.1f;
    else
        puffer = CGRectGetMaxX(newRect) * 0.1f;
    CGFloat maxX = CGRectGetMaxX(newRect) - puffer;
    CGFloat maxY = CGRectGetMaxY(newRect) - puffer;
    CGFloat minX = CGRectGetMinX(newRect) + puffer;
    CGFloat minY = CGRectGetMinY(newRect) + puffer;
    CGContextAddArc(context, maxX - radius, minY + radius, radius, M_PI + (M_PI / 2.0f), 0.0f, 0.0f);
    CGContextAddArc(context, maxX - radius, maxY - radius, radius, 0.0f, M_PI / 2.0f, 0.0f);
    CGContextAddArc(context, minX + radius, maxY - radius, radius, M_PI / 2.0f, M_PI, 0.0f);
    CGContextAddArc(context, minX + radius, minY + radius, radius, M_PI, M_PI + M_PI / 2.0f, 0.0f);
    CGContextClosePath(context);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
}

#pragma mark - 绘制边框方法 context:上下文 rect:绘制区域
- (void)drawFrameWithContext:(CGContextRef)context inRect:(CGRect)rect
{
    CGRect newRect = CGRectZero;
    CGFloat maxLength = [self getDrawSliderMaxLength];
    
    if(self.sliderOrientation == WSSliderOrientationTransverse)
    {
        newRect = CGRectMake(CGRectGetWidth(self.centerImageView.frame) / 2, (CGRectGetHeight(rect) - self.sliderThickness) / 2, maxLength, self.sliderThickness);
        if(self.isAuxiliaryButtonOperation)
            newRect.origin.x += CGRectGetMaxX(self.minButton.frame);
    }
    else
    {
        newRect = CGRectMake((CGRectGetWidth(rect) - self.sliderThickness) / 2, CGRectGetHeight(self.centerImageView.frame) / 2, self.sliderThickness, maxLength);
        if(self.isAuxiliaryButtonOperation)
            newRect.origin.y += CGRectGetMaxY(self.minButton.frame);
    }
    
    CGContextSaveGState(context);
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, self.sliderFrameWidth);
    CGContextSetStrokeColorWithColor(context, [self.sliderFrameColor CGColor]);
    CGFloat radius = self.sliderThickness * self.sliderCornerRoundnes;
    CGFloat puffer = 0.0f;
    if(self.sliderOrientation == WSSliderOrientationTransverse)
        puffer = CGRectGetMaxY(newRect) * 0.1f;
    else
        puffer = CGRectGetMaxX(newRect) * 0.1f;
    CGFloat maxX = CGRectGetMaxX(newRect) - puffer;
    CGFloat maxY = CGRectGetMaxY(newRect) - puffer;
    CGFloat minX = CGRectGetMinX(newRect) + puffer;
    CGFloat minY = CGRectGetMinY(newRect) + puffer;
    CGContextAddArc(context, maxX-radius, minY+radius, radius, M_PI+(M_PI/2.0f), 0.0f, 0.0f);
    CGContextAddArc(context, maxX-radius, maxY-radius, radius, 0.0f, M_PI/2.0f, 0.0f);
    CGContextAddArc(context, minX+radius, maxY-radius, radius, M_PI/2.0f, M_PI, 0.0f);
    CGContextAddArc(context, minX+radius, minY+radius, radius, M_PI, M_PI+M_PI/2.0f, 0.0f);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

#pragma mark - 获取绘制滑杆最大长度方法
- (CGFloat)getDrawSliderMaxLength
{
    CGFloat maxLength = 0.0f;
    if(self.sliderOrientation == WSSliderOrientationTransverse)
    {
        maxLength = CGRectGetWidth(self.frame) - CGRectGetWidth(self.centerImageView.frame);
        if(self.isAuxiliaryButtonOperation)
            maxLength -= (CGRectGetWidth(self.minButton.frame) + CGRectGetWidth(self.maxButton.frame));
    }
    else
    {
        maxLength = CGRectGetHeight(self.frame) - CGRectGetHeight(self.centerImageView.frame);
        if(self.isAuxiliaryButtonOperation)
            maxLength -= (CGRectGetHeight(self.minButton.frame) + CGRectGetHeight(self.maxButton.frame));
    }
    
    return maxLength;
}

@end
//================================================================================================================================================
