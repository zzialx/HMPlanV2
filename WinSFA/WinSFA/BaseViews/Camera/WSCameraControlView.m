//
//  WSCameraControlView.m
//  WinSFA
//
//  Created by Alicia on 2017/8/17.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSCameraControlView.h"
#import "WSCustomSlider.h"
#import "WSCustomDrawSlider.h"


#define kSliderHeight       20
#define kViewWH             134
#define kSliderOffsetX      5.0f

@interface WSCameraControlView ()

@property (nonatomic, strong) UIImageView *focusImageView;
@property (nonatomic, strong) NSTimer *hideTimer;
//@property (nonatomic, strong) WSCustomSlider *exposureSlider;
@property (nonatomic, strong) WSCustomDrawSlider *drawSlider;//绘制滑杆 //2017-10-25-yuanji-SFA-12340
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, assign) CGFloat defaultValue;

@end

@implementation WSCameraControlView

- (instancetype)initWithDevice:(AVCaptureDevice *)device {
    self = [super init];
    if (self) {
        _device = device;
        [self setupViews];
    }
    return self;
}


- (void)setupViews {
    self.bounds = CGRectMake(0, 0, kViewWH, kViewWH);
    
    _focusImageView = [[UIImageView alloc] init];
    _focusImageView.image = [UIImage imageNamed:@"brightness_focus"];
    [self addSubview:_focusImageView];
    
    if (self.device)
    {
        if (IOS8_OR_LATER)
        {
            //self.defaultValue = CMTimeGetSeconds(self.device.exposureDuration);
            //CGFloat minValue = MAX(CMTimeGetSeconds(self.device.activeFormat.minExposureDuration), 0.000001);
            //CGFloat maxValue = MIN(CMTimeGetSeconds(self.device.activeFormat.maxExposureDuration), self.defaultValue * 2);
            CGFloat minValue = self.device.activeFormat.minISO;
            CGFloat maxValue = self.device.activeFormat.maxISO;
            self.defaultValue = (maxValue - minValue) * 0.5;
            
            _drawSlider = [[WSCustomDrawSlider alloc] initWithFrame:CGRectZero];
            _drawSlider.sliderCenterImage = [UIImage imageNamed:@"icon_brightness"];
            _drawSlider.sliderOrientation = WSSliderOrientationPortrait;
            _drawSlider.sliderFrameWidth = 0.0f;
            _drawSlider.sliderInsetColor = kCameraControlColor;
            _drawSlider.sliderThickness = 3.0f;
            _drawSlider.sliderOffsetValue = 10.0f;
            _drawSlider.isAuxiliaryButtonOperation = NO;
            _drawSlider.sliderMinValue = minValue;
            _drawSlider.sliderMaxValue = maxValue;
            _drawSlider.sliderCurrentValue = self.defaultValue;
            __weak typeof(self) weakSelf = self;
            [_drawSlider setSliderValueChangBlock:^(WSCustomDrawSlider *slider, CGFloat sliderValue)
             {
                 [weakSelf hideAfterDelay];
                 [weakSelf setExposureValue:sliderValue];
             }];
            
            [_drawSlider reloadDrawSlider];
            [self addSubview:_drawSlider];
            
            //_exposureSlider = [[WSCustomSlider alloc] init];
            //[_exposureSlider setBackgroundColor:[UIColor clearColor]];
            //[_exposureSlider setThumbImage:[UIImage imageNamed:@"icon_brightness"] forState:UIControlStateNormal];
            //[_exposureSlider setMaximumTrackTintColor:kCameraControlColor];
            //[_exposureSlider setMinimumTrackTintColor:kCameraControlColor];
            //[_exposureSlider setTrackHeight:1];
            //[self resetExposureValue];
            //[_exposureSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            //[_exposureSlider setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
            //[self addSubview:_exposureSlider];
        }
        else
        {
            LogInfo(@"Device is not support exposure setting");
        }
    }
    else
    {
        LogError(@"Device is null");
    }
    
    [self setIsExposureLeft:NO];
}

- (void)dealloc
{
    [self cancelHide];
}

//#pragma mark - Action
//- (void)sliderValueChanged:(UISlider *)slider
//{
//    [self hideAfterDelay];
//    [self setExposureValue:slider.value];
//}

#pragma mark - Public Method
- (void)resetDevice:(AVCaptureDevice *)device
{
    if (device)
    {
        self.device = device;
        [self resetExposureValue];
    }
}

- (void)setIsExposureLeft:(BOOL)isExposureLeft
{
    _isExposureLeft = isExposureLeft;
    
    if (!isExposureLeft)
    {
        [self.focusImageView setFrame:CGRectMake(0, (kViewWH - kFocusImgWH) / 2, kFocusImgWH, kFocusImgWH)];
        //[self.exposureSlider setFrame:CGRectMake(kFocusImgWH + kSliderHeight - 0, 0, kSliderHeight, kViewWH)];
        self.drawSlider.frame = CGRectMake(kFocusImgWH + kSliderOffsetX, 0, kSliderHeight, kViewWH);
    }
    else
    {
        [self.focusImageView setFrame:CGRectMake(kSliderHeight + kSliderOffsetX, (kViewWH - kFocusImgWH) / 2, kFocusImgWH, kFocusImgWH)];
        //[self.exposureSlider setFrame:CGRectMake(0, 0, kSliderHeight, kViewWH)];
        self.drawSlider.frame = CGRectMake(0, 0, kSliderHeight, kViewWH);
    }
}

- (void)resetExposureValue
{
    if (!self.device)
    {
        return;
    }
    
//    self.defaultValue = CMTimeGetSeconds(self.device.exposureDuration);
//    CGFloat minValue = MAX(CMTimeGetSeconds(self.device.activeFormat.minExposureDuration), 0.000001);
//    CGFloat maxValue = MIN(CMTimeGetSeconds(self.device.activeFormat.maxExposureDuration), self.defaultValue * 2);
    CGFloat minValue = self.device.activeFormat.minISO;
    CGFloat maxValue = self.device.activeFormat.maxISO;
    self.defaultValue = (maxValue - minValue) * 0.5;
    self.drawSlider.sliderMinValue = minValue;
    self.drawSlider.sliderMaxValue = maxValue;
    self.drawSlider.sliderCurrentValue = self.defaultValue;
    
    //    CGFloat minValue = MAX(CMTimeGetSeconds(self.device.activeFormat.minExposureDuration), 0.000001);
    //    [self.exposureSlider setMinimumValue:minValue];
    //    [self.exposureSlider setValue:self.defaultValue];
    //    CGFloat maxValue = MIN(CMTimeGetSeconds(self.device.activeFormat.maxExposureDuration), self.defaultValue * 2);
    //    [self.exposureSlider setMaximumValue:maxValue];
}

- (void)resetExposureSliderValue
{
    //[self.exposureSlider setValue:self.defaultValue];
    self.drawSlider.sliderCurrentValue = self.defaultValue;
}

- (void)cancelHide
{
    if (self.hideTimer)
    {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
    }
}

- (void)hideAfterDelay
{
    if (![self isHidden])
    {
        [self cancelHide];
        self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(hideFocusView) userInfo:nil repeats:NO];
    }
}

#pragma mark - Private Method
- (void)hideFocusView
{
    [self setHidden:YES];
}

- (void)setExposureValue:(CGFloat)value
{
    if (!self.device)
    {
        return;
    }
    
    if ([self.device lockForConfiguration:nil] && [self.device isExposureModeSupported:AVCaptureExposureModeCustom])
    {
        [self.device setExposureMode:AVCaptureExposureModeCustom];
        //[self.device setExposureModeCustomWithDuration:CMTimeMake(value * 100000000, 100000000) ISO:AVCaptureISOCurrent completionHandler:nil];
        [self.device setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:value completionHandler:nil];
        [self.device unlockForConfiguration];
    }
}

@end

