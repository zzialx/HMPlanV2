//
//  WSImagePickerController.m
//  WinSFA
//
//  Created by yang on 13-12-19.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSImagePickerController.h"
#import "WSCameraControlView.h"
#import "UIView+Additions.h"
#import "WSCustomDrawSlider.h"
#import "WSMotionTool.h"
#import "WSCGRect.h"

#define kCameraPreviewLayerYOffset (INTERFACE_IS_PHONE ? 44.0 : 0.0)

#define kCameraBottomViewDefaultHeight 80
#define kTakePhotoButtonWidth 80
#define kCancelButtonWidth 90
#define kCancelButtonHeight 60
#define kImgButtonWH     44
#define kMaxScale               15
#define kFlashKey               @"flashActive"
#define kScaleWidthRatio        (INTERFACE_IS_PHONE ? 1.0 : 0.7)


//#define INTERFACE_IS_PAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//#define INTERFACE_IS_PHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define isIphoneX ({\
int tmp = 0;\
if (@available(iOS 11.0, *)) {\
if (!UIEdgeInsetsEqualToEdgeInsets([UIApplication sharedApplication].delegate.window.safeAreaInsets, UIEdgeInsetsZero)) {\
tmp = 1;\
}else{\
tmp = 0;\
}\
}else{\
tmp = 0;\
}\
tmp;\
})

@interface WSImagePickerController ()<AVCapturePhotoCaptureDelegate>
{
    /*陀螺仪监听设备方向*/
    WSMotionTool *motionTool;
    UIDeviceOrientation _deviceOrientation;
    /*Jira - SFA-14192 记录摄像头是前置还是后置 默认是NO 后置 create by sunhongfu 2017-11-18*/
    BOOL isCaptureDevicePositionFront;
}

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
//取景框图片成像输出
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
//取景框图片成像输出（10.0 以后系统方法）
@property (nonatomic, strong) AVCapturePhotoOutput* photoOutput;
@property (nonatomic, assign) AVCamSetupResult setupResult;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer; //捕获视频（图片）预览layer
//取景框图片
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIView *cameraBottomView;
@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) UIView *controlView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *reTakeButton;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *switchCameraButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIView *flashView;
@property (nonatomic, strong) UIButton *flashAutoButton;
@property (nonatomic, strong) UIButton *flashOnButton;
@property (nonatomic, strong) UIButton *flashOffButton;
@property (nonatomic, strong) WSCameraControlView *cameraControlView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) NSTimer *hideZoomTimer;
@property (nonatomic, strong) UIImageView *flashOnImageView;
@property (nonatomic, assign) CGFloat maxScaleFactor;

//2017-10-25-yuanji-SFA-12340
@property (nonatomic, strong) WSCustomDrawSlider *drawSlider;
//@property (nonatomic, strong) UISlider *zoomSlider;
//@property (nonatomic, strong) UIView *zoomView;
//@property (nonatomic, assign) CGFloat lastScale;
@property (nonatomic, assign) CGFloat scale;

#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_queue_t sessionQueue;
#else
@property (nonatomic, assign) dispatch_queue_t sessionQueue;
#endif
@property (nonatomic ,assign) BOOL isNeedLockedAutorotate;

@property (nonatomic ,assign) BOOL isPhotosing;
@property (nonatomic, assign) BOOL isSessionStart;

// MSTD-7860
@property (nonatomic,strong) UIView *coverView;         // 自定义取景框预览时的背景view，用于遮挡相机取景框
@property (nonatomic, strong) WSTipView *tipView;       // 问题提示view
@property (nonatomic, assign) BOOL isAddNoWaterMark;    // 是否显示原图，也标识是否显示自定义取景框



- (void)handleDeviceOrientationDidChange:(NSDictionary *)notification;  //方向变化通知回调方法 notification:通知
- (void)applicationBecomeActive:(NSNotification *)notification;         //app从后台回到前台通知回调方法 notification:通知
- (void)applicationEnterBackground:(NSNotification *)notification;      //app进入后台通知回调方法 notification:通知

- (void)cameraControlTransformRestore;                                  //相机控件转换复原方法
- (void)cameraControlTransform:(CGFloat)angle;                          //相机控件转换方法 angle:角度

@end

@implementation WSImagePickerController

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [self cancelHideZoom];
    
    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    if (device && [device hasFlash]) {
        [device removeObserver:self forKeyPath:kFlashKey];
    }
}

#pragma marm - app从后台回到前台通知回调方法 notification:通知
- (void)applicationBecomeActive:(NSNotification*)notification {
    
    __weak __typeof(self) wself = self;
    dispatch_async(self.sessionQueue, ^{
        [wself.session startRunning];
        wself.isSessionStart = YES;
    });
}

#pragma mark - app进入后台通知回调方法 notification:通知
- (void)applicationEnterBackground:(NSNotification*)notification {
    
    __weak __typeof(self) wself = self;
    dispatch_async(self.sessionQueue, ^{
        [wself.session stopRunning];
        wself.isSessionStart = NO;

    });
}

#pragma mark - 方向变化通知回调方法 notification:通知
- (void)handleDeviceOrientationDidChange:(NSDictionary *)notification
{
    if (INTERFACE_IS_PHONE)
    {
        __weak typeof(self) weakSelf = self;
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        switch (orientation)
        {
            case UIDeviceOrientationPortrait:
            {
                [UIView animateWithDuration:0.2f animations:^{
                    [weakSelf cameraControlTransformRestore];
                } completion:^(BOOL finished) {
                }];
            }
                break;
            case UIDeviceOrientationPortraitUpsideDown:
            {
                [weakSelf cameraControlTransformRestore];
                [UIView animateWithDuration:0.2f animations:^{
                    [weakSelf cameraControlTransform:M_PI];
                } completion:^(BOOL finished) {
                }];
            }
                break;
            case UIDeviceOrientationLandscapeLeft:
            {
                [weakSelf cameraControlTransformRestore];
                [UIView animateWithDuration:0.2f animations:^{
                    [weakSelf cameraControlTransform:M_PI_2];
                } completion:^(BOOL finished) {
                }];
            }
                break;
            case UIDeviceOrientationLandscapeRight:
            {
                [weakSelf cameraControlTransformRestore];
                [UIView animateWithDuration:0.2f animations:^{
                    [weakSelf cameraControlTransform:-M_PI_2];
                } completion:^(BOOL finished) {
                }];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - 相机控件转换复原方法
- (void)cameraControlTransformRestore
{
    _switchCameraButton.transform = CGAffineTransformIdentity;
    _flashButton.transform = CGAffineTransformIdentity;
    _flashAutoButton.transform = CGAffineTransformIdentity;
    _flashOnButton.transform = CGAffineTransformIdentity;
    _flashOffButton.transform = CGAffineTransformIdentity;
    _cancelButton.transform = CGAffineTransformIdentity;
    _reTakeButton.transform = CGAffineTransformIdentity;
    _confirmButton.transform = CGAffineTransformIdentity;
}

#pragma mark - 相机控件转换方法 angle:角度
- (void)cameraControlTransform:(CGFloat)angle
{
    _switchCameraButton.transform = CGAffineTransformMakeRotation(angle);
    _flashButton.transform = CGAffineTransformMakeRotation(angle);
    _flashAutoButton.transform = CGAffineTransformMakeRotation(angle);
    _flashOnButton.transform = CGAffineTransformMakeRotation(angle);
    _flashOffButton.transform = CGAffineTransformMakeRotation(angle);
    _cancelButton.transform = CGAffineTransformMakeRotation(angle);
    _reTakeButton.transform = CGAffineTransformMakeRotation(angle);
    _confirmButton.transform = CGAffineTransformMakeRotation(angle);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.view.backgroundColor = [UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];

    /*Jira - SFA-13822  初始化陀螺仪tool create by 孙洪福 2017-11-13*/
    motionTool = [[WSMotionTool alloc] init];
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetPhoto];

    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    
    self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    self.setupResult = AVCamSetupResultSuccess;
    
    dispatch_async(self.sessionQueue, ^{
        [self configurationSession];
    });
    
    [self resetCamera];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Why are we dispatching this to the main queue?
        // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
        // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
        NSLog(@"initPreviewLayer interfaceOrientation :%ld" ,(long)[self preferredInterfaceOrientationForPresentation]);
        [[self.previewLayer connection] setVideoOrientation:(AVCaptureVideoOrientation)[self preferredInterfaceOrientationForPresentation]];
        
    });
    
    
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = INTERFACE_IS_PAD ? [[UIColor blackColor] colorWithAlphaComponent:0.6] : [UIColor blackColor];
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.cameraBottomView = bottomView;
    
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        UIButton *switchCameraButton = [[UIButton alloc] init];
        [switchCameraButton setImage:[UIImage imageNamed:@"switch_camera"] forState:UIControlStateNormal];
        [switchCameraButton addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
        self.switchCameraButton = switchCameraButton;
        
        if (INTERFACE_IS_PHONE) {
            UIView *controlView = [[UIView alloc] init];
            controlView.backgroundColor = [UIColor blackColor];
            [self.view addSubview:controlView];
            self.controlView = controlView;
        }
        [bottomView addSubview:switchCameraButton];
    }
    
    if (INTERFACE_IS_PHONE) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasFlash]) {
            [self setFlashMode:AVCaptureFlashModeAuto];
            
            UIButton *flashButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kImgButtonWH, kImgButtonWH)];
            [flashButton setImage:[UIImage imageNamed:@"camera_flash"] forState:UIControlStateNormal];
            [flashButton addTarget:self action:@selector(flash:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:flashButton];
            self.flashButton = flashButton;
            
            CGFloat flashWidth = self.view.bounds.size.width - 4 * kImgButtonWH;
            CGFloat flashHeight = kImgButtonWH;
            UIView *flashView = [[UIView alloc] initWithFrame:CGRectMake(kImgButtonWH * 2, 0, flashWidth, flashHeight)];
            [flashView setHidden:YES];
            [self.view addSubview:flashView];
            self.flashView = flashView;
            
            CGFloat buttonFontSize = 14;
            UIButton *torchAutoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, flashWidth / 3 , flashHeight)];
            NSString *autoTitle = NSLocalizedString(@"Auto", nil);
            [torchAutoButton setTitle:autoTitle forState:UIControlStateNormal];
            torchAutoButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
            [torchAutoButton setTitleColor:kCameraControlColor forState:UIControlStateSelected];
            [torchAutoButton addTarget:self action:@selector(flashAuto:) forControlEvents:UIControlEventTouchUpInside];
            [flashView addSubview:torchAutoButton];
            self.flashAutoButton = torchAutoButton;
            
            UIButton *flashOnButton = [[UIButton alloc] initWithFrame:CGRectMake(flashWidth / 3, 0, flashWidth / 3, flashHeight)];
            NSString *onTitle = NSLocalizedString(@"On", nil);
            [flashOnButton setTitle:onTitle forState:UIControlStateNormal];
            flashOnButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
            [flashOnButton setTitleColor:kCameraControlColor forState:UIControlStateSelected];
            [flashOnButton addTarget:self action:@selector(flashOn:) forControlEvents:UIControlEventTouchUpInside];
            [flashView addSubview:flashOnButton];
            self.flashOnButton = flashOnButton;
            
            UIButton *flashOffButton = [[UIButton alloc] initWithFrame:CGRectMake(flashWidth / 3 * 2, 0, flashWidth / 3, flashHeight)];
            NSString *offTitle = NSLocalizedString(@"Off", nil);
            [flashOffButton setTitle:offTitle forState:UIControlStateNormal];
            flashOffButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
            [flashOffButton setTitleColor:kCameraControlColor forState:UIControlStateSelected];
            [flashOffButton addTarget:self action:@selector(flashOff:) forControlEvents:UIControlEventTouchUpInside];
            [flashView addSubview:flashOffButton];
            self.flashOffButton = flashOffButton;
            
            AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
            if (device) {
                [device addObserver:self forKeyPath:kFlashKey options:NSKeyValueObservingOptionNew context:nil];
            }
            
        }
    }
    
    
    UIButton *cacelButton = [[UIButton alloc] init];
    NSString *cancelTitle = NSLocalizedString(@"cancel_label", nil);
    [cacelButton setTitle:cancelTitle forState:UIControlStateNormal];
    [cacelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cacelButton.titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
    //[cacelButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [cacelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton = cacelButton;
    [bottomView addSubview:cacelButton];
    
    UIButton *button = [[UIButton alloc] init];
    //    [button setTitle:@"camera_capture" forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"take_photo"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"take_photo_touch"] forState:UIControlStateHighlighted];
    [button.titleLabel setFont:[UIFont systemFontOfSize:25]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTintColor:[UIColor orangeColor]];
    [button addTarget:self action:@selector(captureStillImage) forControlEvents:UIControlEventTouchUpInside];
    self.captureButton = button;
    [bottomView addSubview:button];
    
    [self.view addSubview:self.cameraBottomView];
    
    self.previewView = [[UIView alloc] init];
    self.previewView.backgroundColor = self.cameraBottomView.backgroundColor;
    self.previewView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    UIButton *reTakeButton = [[UIButton alloc] init];
    NSString *retakeTitle = NSLocalizedString(@"redo_capture", nil);
    [reTakeButton setTitle:retakeTitle forState:UIControlStateNormal];
    [reTakeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [reTakeButton.titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
    //[reTakeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [reTakeButton addTarget:self action:@selector(reTake) forControlEvents:UIControlEventTouchUpInside];
    self.reTakeButton = reTakeButton;
    [self.previewView addSubview:reTakeButton];
    
    UIButton *confirmButton = [[UIButton alloc] init];
    NSString *confirmTitle = NSLocalizedString(@"use_photo", nil);
    [confirmButton setTitle:confirmTitle forState:UIControlStateNormal];
    [confirmButton.titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[confirmButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [confirmButton addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    self.confirmButton = confirmButton;
    [self.previewView addSubview:confirmButton];
    [self.view insertSubview:self.previewView belowSubview:self.cameraBottomView];
    self.previewView.hidden = YES;

    //2017-10-25-yuanji-SFA-12340
    CGFloat drawSliderWidth = self.view.width * kScaleWidthRatio;
    CGFloat drawSliderHeight = 44.0f;
    CGFloat drawSliderX = (self.view.width - drawSliderWidth) / 2;
    CGFloat drawSliderY = self.view.height - drawSliderHeight;
    _drawSlider = [[WSCustomDrawSlider alloc] initWithFrame:CGRectMake(drawSliderX, drawSliderY, drawSliderWidth, drawSliderHeight)];
    _drawSlider.sliderMinValue = 1.0f;
    _drawSlider.sliderMaxValue = kMaxScale;
    __weak typeof(self) weakSelf = self;
    [_drawSlider setSliderValueChangBlock:^(WSCustomDrawSlider *slider, CGFloat sliderValue)
     {
         weakSelf.scale = sliderValue;
         [weakSelf zoomFromSlider:YES];
     }];
    [_drawSlider reloadDrawSlider];
    _drawSlider.hidden = YES;
    [self.bgView addSubview:_drawSlider];
    
    // MSTD-7860
    _coverView = [[UIView alloc] initWithFrame: [self getPreControlFrame]];
    _coverView.backgroundColor = [UIColor blackColor];
    _coverView.hidden = YES;
    [self.view addSubview:_coverView];

    self.scale = 1;
    
    [self adjustControlFrame];

    [self setupGesture];
}

#pragma mark- 初始化相机
- (void)configurationSession {
    
    NSError *error = nil;
    
    [self.session beginConfiguration];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    if (!device) {
        LogError(@"Not find camera device!");
        [self.session commitConfiguration];
        return;
    }
    
    //输入设置
    AVCaptureDeviceInput* captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (!captureDeviceInput) {
        LogError(@"Could not create video device input: %@", error);
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }
    
    if([self.session canAddInput:captureDeviceInput]) {
        [self.session addInput:captureDeviceInput];
        self.captureDeviceInput = captureDeviceInput;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
            AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
            if (statusBarOrientation != UIInterfaceOrientationUnknown) {
                initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
            }
            self.previewLayer.connection.videoOrientation = initialVideoOrientation;
        });
    }else {
        LogError(@"Could not add video device input to the session");
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.session commitConfiguration];
        return;
    }
    
    //输出设置
    if (IOS10_OR_LATER) {
        AVCapturePhotoOutput* photoOutput = [[AVCapturePhotoOutput alloc] init];
        if ([self.session canAddOutput:photoOutput]) {
            [self.session addOutput:photoOutput];
            self.photoOutput = photoOutput;
            self.photoOutput.highResolutionCaptureEnabled = YES;
            
        }else {
            LogError(@"Could not add photo output to the session");
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
            [self.session commitConfiguration];
            return;
        }
        
    }else {
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = @{ AVVideoCodecKey : AVVideoCodecJPEG};
        [self.stillImageOutput setOutputSettings:outputSettings];
        
        if ([self.session canAddOutput:self.stillImageOutput]) {
            [self.session addOutput:self.stillImageOutput];
        }else{
            LogError(@"Could not add photo output to the session");
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
            [self.session commitConfiguration];
            return;
        }
        
    }
   
    [self.session commitConfiguration];
    
}

//- (void)viewWillLayoutSubviews
//{
//    [self adjustPreviewLayerFrame];
//    
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    __weak __typeof(self) wself = self;
    dispatch_async(self.sessionQueue, ^{
        [wself.session startRunning];
        wself.isSessionStart = YES;
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    __weak __typeof(self) wself = self;
    dispatch_async(self.sessionQueue, ^{
        [wself.session stopRunning];
        wself.isSessionStart = NO;
    });
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 点击拍照
- (void)captureStillImage {
    
    LogInfo(@"WSImagePickerController captureStillImage isPhotosing = %d isSessionStart = %d self.session.isRunning = %d",
            self.isPhotosing, self.isSessionStart, self.session.isRunning);
    if (self.isPhotosing || !self.isSessionStart || !self.session.isRunning) {
        return;
    }
    
    //SFA-26157 点击拍照时要验证照片数是否达到最大值，如果达到则弹框并且返回。
    if ([[self delegate] respondsToSelector:@selector(imagePickerIsToMaxNum:)]) {
        if ([[self delegate] imagePickerIsToMaxNum:self]) {
            return;
        }
    }

    self.isNeedLockedAutorotate = YES;
    //    在拍照处理中 禁止 转换摄像头  MMSH-4328 董宏  设置but setEnabled 不好用所以加了变量
    self.isPhotosing = YES;
    
    if (@available(iOS 10.0, *)) {
        AVCaptureVideoOrientation videoPreviewLayerVideoOrientation = _previewLayer.connection.videoOrientation;
        AVCaptureConnection* photoOutputConnection = [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];
        photoOutputConnection.videoOrientation = videoPreviewLayerVideoOrientation;
        AVCapturePhotoSettings  *photoSettings = [AVCapturePhotoSettings photoSettings];
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        photoSettings.flashMode = AVCaptureFlashModeAuto;
        [self.photoOutput capturePhotoWithSettings:photoSettings delegate:self];
        
    }else{
        AVCaptureConnection *videoConnection = nil;
        for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
            for (AVCaptureInputPort *port in [connection inputPorts]) {
                if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                    videoConnection = connection;
                    break;
                }
            }
            if (videoConnection) { break; }
        }
        LogInfo(@"previewLayer interfaceOrientation = %ld" ,(long)[[self.previewLayer connection] videoOrientation]);
        [videoConnection setVideoOrientation:[[self.previewLayer connection] videoOrientation]];
        [videoConnection setVideoScaleAndCropFactor:self.scale];
        LogInfo(@"stillImageOutput interfaceOrientation = %ld" ,(long)[videoConnection videoOrientation]);
      
        LogInfo(@"可用内存：%f MB", [UIDevice freeMemory]/1024.0/1024.0);
        LogInfo(@"已用内存：%f MB", [UIDevice usedMemory]/1024.0/1024.0);

        BOOL __block isGetDeviceOrientation = NO;
        __weak __typeof(self) wself = self;
        [motionTool startMotionManagerGetDeviceOrientationWithInterval:1 withBlock:^(UIDeviceOrientation deviceOrientation) {
           
            [motionTool stopMotion];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!isGetDeviceOrientation) {
                    isGetDeviceOrientation = YES;
                    _deviceOrientation = deviceOrientation;
                    [wself capturePicWithConnection:videoConnection];
                    wself.isPhotosing = NO;
                }
            });
        }];
    }
}

- (void)capturePicWithConnection:(AVCaptureConnection *)videoConnection {
    __weak __typeof(self) wself = self;
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         
         __strong __typeof(wself) sself = wself;
         //获取图片
         if (error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 sself.isNeedLockedAutorotate = NO;
                 sself.isPhotosing = NO;
             });
             LogError(@"capture still image error.%@",error);
         } else if (imageSampleBuffer){
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             UIImage *image = [UIImage imageWithData:imageData];
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (image) {
                     [sself showPreviewViewWithIamge:image];
                 }
                 sself.isNeedLockedAutorotate = NO;
                 sself.isPhotosing = NO;
             });
         }
         
     }];
    
}
#pragma mark - AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error {
    __weak __typeof(self) wself = self;

    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong __typeof(wself) sself = wself;

        if (error) {
            self.isNeedLockedAutorotate = NO;
            self.isPhotosing = NO;
            LogError(@"capture still image error.%@",error);
        } else if (photoSampleBuffer) {
            NSData *imageData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    [self showPreviewViewWithIamge:image];
                }
                sself.isNeedLockedAutorotate = NO;
                sself.isPhotosing = NO;
            });
        } else {
            self.isNeedLockedAutorotate = NO;
            self.isPhotosing = NO;
        }
    });
    
}
/*11.0以上系统会调用此方法*/
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error  API_AVAILABLE(ios(11.0)){
    __weak __typeof(self) wself = self;

    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong __typeof(wself) sself = wself;

        if (error) {
            self.isNeedLockedAutorotate = NO;
            sself.isPhotosing = NO;
            LogError(@"capture still image error.%@",error);
        } else if (@available(iOS 11.0, *)) {
            if (photo.fileDataRepresentation) {
                UIImage *image = [UIImage imageWithData:photo.fileDataRepresentation];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        [sself showPreviewViewWithIamge:image];
                    }
                    sself.isNeedLockedAutorotate = NO;
                    sself.isPhotosing = NO;
                });
            } else {
                sself.isNeedLockedAutorotate = NO;
                sself.isPhotosing = NO;
            }
        } else {
            // Fallback on earlier versions
            sself.isNeedLockedAutorotate = NO;
            sself.isPhotosing = NO;
        }
    });
}
#pragma mark - # 显示图片
- (void)showPreviewViewWithIamge:(UIImage*)image{
    
    if (self.previewImageView == nil) {
        CGRect rect = [self getPreviewFrame];
        if (self.isAddNoWaterMark) {
           rect = [self.viewingView getAbsHollowRect];
        }
        self.previewImageView = [[UIImageView alloc] initWithFrame:rect];
        self.previewImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.previewImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }

    self.drawSlider.hidden = YES;
    [self.cameraControlView setHidden:YES];
    
    UIImage *newImage = image;
    // MSTD-7860 这个地方取出的图片是逆时针旋转90度的，需要给转到竖屏的形式
    if (self.isAddNoWaterMark) {
        newImage = [image fixOrientation];
    }

    if (isCaptureDevicePositionFront && INTERFACE_IS_PHONE)
    {
       newImage = [UIImage imageWithCGImage:newImage.CGImage scale:1.0f orientation:UIImageOrientationLeftMirrored];
    }

    
    if (isCaptureDevicePositionFront && INTERFACE_IS_PAD &&(_deviceOrientation == UIDeviceOrientationPortrait || _deviceOrientation == UIDeviceOrientationPortraitUpsideDown))
    {
          newImage = [UIImage imageWithCGImage:newImage.CGImage scale:1.0f orientation:UIImageOrientationDown];
    }
    
    // MSTD-7860 配置 sself.isAddNoWaterMark = YES, 需要截取照片
    if (self.isAddNoWaterMark) {
        UIImage *clipImage = [UIImage getSubImage:newImage rect:[WSCGRect caculateNewRect:[self.viewingView getHollowRect] previewRect:self.viewingView.frame imageSize:newImage.size]];
        
        newImage = clipImage;
        
        if (!self.viewingView.hidden) {
            self.viewingView.hidden = YES;
        }
        if (self.coverView.hidden) {
            self.coverView.hidden = NO;
        }
        [self.view bringSubviewToFront:_coverView];
        
    }
    
    [self.previewImageView setImage:newImage];
    [self.view addSubview:self.previewImageView];

    if (self.previewView.hidden) {
        self.previewView.hidden = NO;
    }
    if (INTERFACE_IS_PAD && !self.controlView.hidden) {
        self.controlView.hidden = YES;
    }
    if (self.flashButton && !self.flashButton.hidden) {
        self.flashButton.hidden = YES;
    }
    if (self.flashView && !self.flashView.hidden) {
        self.flashView.hidden = YES;
    }

    [self.view bringSubviewToFront:self.previewView];
    
    if (self.cameraOverlayView && !self.cameraOverlayView.hidden) {
        [self.view bringSubviewToFront:self.cameraOverlayView];
    }
}
- (void)cancel {

    [self resetCamera];
    
    if ([[self delegate] respondsToSelector:@selector(imagePickerDidCancel:)]) {
        [[self delegate] imagePickerDidCancel:self];
    }
}

//重拍
- (void)reTake {
    [self.view bringSubviewToFront:self.cameraBottomView];
    self.previewView.hidden = YES;
    self.controlView.hidden = NO;

    [self.previewImageView removeFromSuperview];
    self.previewImageView.image = nil;

    // MSTD-7860
    self.coverView.hidden = YES;
    if (self.tipView) {
        self.tipView.hidden = NO;
    }
    
    if (self.viewingView) {
        self.viewingView.hidden = NO;
    }
    
    if (self.flashButton) {
        AVCaptureDevicePosition devicePosition = [[self.captureDeviceInput device] position];
        if (devicePosition == AVCaptureDevicePositionBack) {
            self.flashButton.hidden = NO;
        }
    }
    if (self.switchCameraButton) {
        self.switchCameraButton.hidden = NO;
    }

    if (self.cameraOverlayView) {
        self.cameraOverlayView.hidden = NO;
    }
}

//使用照片
- (void)confirm {
    [self resetCamera];
    if (self.previewImageView.image)
    {
        if ([[self delegate] respondsToSelector:@selector(imagePicker:didFinishPickingImage:withDeviceOrientation:withISCaptureDevicePositionFront:)])
        {
            /*Jira - MSTD-6797 create by sunhongfu 2017-11-14 区分iphone和ipad 根据设备不同拍摄角度 设置图片方向*/
            [[self delegate] imagePicker:self didFinishPickingImage:self.previewImageView.image withDeviceOrientation:_deviceOrientation withISCaptureDevicePositionFront:isCaptureDevicePositionFront];
        }
    }
}

- (void)switchCamera:(UIButton *)button {
    if (self.isPhotosing) {
        return;
    }
    NSString *transitionType;
    AVCaptureDevice *device;
    AVCaptureDevicePosition position = [[self.captureDeviceInput device] position];
    if (position == AVCaptureDevicePositionBack) {
        device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        /*Jira - SFA-14192 记录摄像头前置*/
        isCaptureDevicePositionFront = YES;
        transitionType = kCATransitionFromRight;
    } else if (position == AVCaptureDevicePositionFront) {
        device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        /*Jira - SFA-14192 记录摄像头后置 */
        isCaptureDevicePositionFront = NO;
        transitionType = kCATransitionFromLeft;
    } else {
        return;
    }
    
    if (!device) {
        LogError(@"Not find camera device!");
        return;
    }
    NSError *error;
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    
    if (newVideoInput != nil) {
        if (self.flashButton) {
            if (position == AVCaptureDevicePositionBack) {
                [self.flashButton setHidden:YES];
                [self.flashView setHidden:YES];
                [self.flashOnImageView setHidden:YES];
            } else if (position == AVCaptureDevicePositionFront) {
                [self.flashButton setHidden:NO];
                BOOL isFlashActive = device.flashActive;
                if (isFlashActive) {
                    [self.flashOnImageView setHidden:NO];
                }
            }
        }
        [self setTransitionWithType:transitionType];
        [self.session beginConfiguration];
        [self.session removeInput:self.captureDeviceInput];
        if ([self.session canAddInput:newVideoInput]) {
            [self.session addInput:newVideoInput];
            self.captureDeviceInput = newVideoInput;
        } else {
            [self.session addInput:self.captureDeviceInput];
        }
        [self.session commitConfiguration];
        
        [self.cameraControlView setHidden:YES];
        
        [self.cameraControlView resetDevice:device];
        
        [self resetAutoFocusAndExposureWithCenter:CGPointZero];
        
    } else if (error) {
        LogInfo(@"switchCamera Failed = %@", error);
    }
}

- (void)setTransitionWithType:(NSString *)type {
    CATransition *animation = [CATransition animation];
    animation.duration = MAIN_ANIM_DURATION;
    animation.type = @"oglFlip";
    animation.subtype = type;
    animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
  
    [self.previewLayer addAnimation:animation forKey:nil];
}


- (void)flash:(UIButton *)button {
    if (self.flashView.hidden) {
        [self.flashView setHidden:NO];
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureFlashMode flashMode = device.flashMode;
        switch (flashMode) {
            case AVCaptureFlashModeOff:
                [self.flashOffButton setSelected:YES];
                break;
            case AVCaptureFlashModeOn:
                [self.flashOnButton setSelected:YES];
                break;
            case AVCaptureFlashModeAuto:
                [self.flashAutoButton setSelected:YES];
                break;
            default:
                [self.flashAutoButton setSelected:YES];
                break;
        }
        
//        if (self.switchCameraButton) {
//            [self.switchCameraButton setHidden:YES];
//        }
    } else {
        [self.flashView setHidden:YES];
//        if (self.switchCameraButton) {
//            [self.switchCameraButton setHidden:NO];
//        }
    }
}

- (void)flashAuto:(UIButton *)button {
    [self setFlashMode:AVCaptureFlashModeAuto];
    [self.flashView setHidden:YES];
    [self.switchCameraButton setHidden:NO];
    [self.flashButton setImage:[UIImage imageNamed:@"camera_flash"] forState:UIControlStateNormal];
    
    [self.flashAutoButton setSelected:YES];
    [self.flashOnButton setSelected:NO];
    [self.flashOffButton setSelected:NO];
}

- (void)flashOn:(UIButton *)button {
    [self setFlashMode:AVCaptureFlashModeOn];
    [self.flashView setHidden:YES];
    [self.switchCameraButton setHidden:NO];
    [self.flashButton setImage:[UIImage imageNamed:@"camera_flash_on"] forState:UIControlStateNormal];
    
    [self.flashAutoButton setSelected:NO];
    [self.flashOnButton setSelected:YES];
    [self.flashOffButton setSelected:NO];
}

- (void)flashOff:(UIButton *)button {
    [self setFlashMode:AVCaptureFlashModeOff];
    [self.flashView setHidden:YES];
    [self.switchCameraButton setHidden:NO];
    [self.flashButton setImage:[UIImage imageNamed:@"camera_flash_off"] forState:UIControlStateNormal];
    
    [self.flashAutoButton setSelected:NO];
    [self.flashOnButton setSelected:NO];
    [self.flashOffButton setSelected:YES];
}

- (void)setFlashMode:(AVCaptureFlashMode)mode {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    [device setFlashMode:mode];
    [device unlockForConfiguration];
}

- (void)cancelHideZoom {
    if (self.hideZoomTimer) {
        [self.hideZoomTimer invalidate];
        self.hideZoomTimer = nil;
    }
}

- (void)hideZoomAfterDelay {
    //if (![self.zoomView isHidden]) {
    if (![self.drawSlider isHidden])
    {
        [self cancelHideZoom];
        self.hideZoomTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideZoomView) userInfo:nil repeats:NO];
    }
}

- (void)hideZoomView
{
    self.drawSlider.hidden = YES;
    //[self.zoomView setHidden:YES];
}

- (void)zoomSliderValueChanged:(UISlider *)sender {
    self.scale = sender.value;
    [self zoomFromSlider:YES];
}

- (void)zoomInAction:(id)sender {
    self.scale = self.scale + 1;
    [self zoomFromSlider:NO];
}

- (void)zoomOutAction:(id)sender {
    self.scale = self.scale - 1;
    [self zoomFromSlider:NO];
}

- (void)zoomFromSlider:(BOOL)isFromSlider {
    [self hideZoomAfterDelay];
    
    if (self.scale < 1.0){
        self.scale = 1.0;
    }
    if (self.scale > kMaxScale) {
        self.scale = kMaxScale;
    }
    
    if (!isFromSlider) {
        //[self.zoomSlider setValue:self.scale];
        self.drawSlider.sliderCurrentValue = self.scale;
    }
    
    [UIView animateWithDuration:0.025 animations:^{
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.scale, self.scale)];
    }];
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:kFlashKey]) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        BOOL isFlashActive = device.flashActive;
        if (isFlashActive) {
            if ([self.flashOnImageView isHidden]) {
                [self.flashOnImageView setHidden:NO];
            }
        } else if (!isFlashActive) {
            if (![self.flashOnImageView isHidden]) {
                [self.flashOnImageView setHidden:YES];
            }
        }
    }
}

#pragma mark - WaterMark
- (void)setCameraOverlayView:(WSWatermarkOverlayView *)cameraOverlayView {
    _cameraOverlayView = cameraOverlayView;
    [self.view addSubview:_cameraOverlayView];
    
    if (INTERFACE_IS_PHONE) {
//        CGRect zoomFrame = self.zoomView.frame;
//        zoomFrame.origin.y = CGRectGetMaxY(self.bgView.bounds) - [cameraOverlayView getBottomViewOffsetY] - zoomFrame.size.height;
//        self.zoomView.frame = zoomFrame;
        CGRect zoomFrame = self.drawSlider.frame;
        zoomFrame.origin.y = CGRectGetMaxY(self.bgView.bounds) - [cameraOverlayView getBottomViewOffsetY] - zoomFrame.size.height;
        self.drawSlider.frame = zoomFrame;
    }
    
    [self.view bringSubviewToFront:self.bgView];
}

// MSTD-7860 问题提示view
-(void)setTipView {
    CGRect rect;
    CGSize size = [WSTipView getTipViewFrame:self.tip iconImage:[UIImage imageNamed:@"icon_tips"]];
    CGFloat offsetY = MAIN_CELL_PADDING;
    CGFloat offsetX = MAIN_CELL_PADDING;
    if (self.cameraOverlayView && !self.isAddNoWaterMark) {
        CGPoint point = [self.cameraOverlayView getLineBottomPoint];
        offsetY += point.y;
        offsetX = point.x;
    }else if (self.cameraOverlayView && self.isAddNoWaterMark){
        CGPoint point = [self.cameraOverlayView getLineBottomPoint];
        offsetY = point.y + MAIN_CELL_PADDING;
        offsetX = point.x;
    }
    
    CGRect rectOne = [self.viewingView getHollowRect];
    rect = CGRectMake(rectOne.origin.x + MAIN_HORIZONTAL_GROUP_SPACE ,self.viewingView.origin.y + rectOne.origin.y + MAIN_CELL_PADDING, size.width, size.height + MAIN_TEXT_IMG_PADDING * 2);
    WSTipView *tipView = [[WSTipView alloc] initWithFrame:rect image:[UIImage imageNamed:@"icon_tips"] tip:self.tip];
    tipView.backgroundColor = [UIColor whiteColor];
    tipView.layer.cornerRadius = 5;
    self.tipView = tipView;
    [self.view addSubview:tipView];
}

// MSTD-7860 自定义取景框
-(void)setViewingView {
    CGFloat width = [[self.dic objectForKey:@"width"] floatValue];
    CGFloat height = [[self.dic objectForKey:@"height"] floatValue];
    CGFloat maxCameraperHeight = [[self.dic objectForKey:@"maxCameraperHeight"] floatValue];
    self.isAddNoWaterMark = [[self.dic objectForKey:@"waterMark"] boolValue];
    WSViewingView *viewingView = [[WSViewingView alloc] initWithFrame:[self getPreviewFrame] width:width height:height maxCameraperHeight:maxCameraperHeight];
    self.viewingView = viewingView;
    [self.view addSubview:self.viewingView];
}

#pragma mark - Gesture
- (void)setupGesture {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusAction:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self.view addGestureRecognizer:pinchRecognizer];
}

- (void)focusAction:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.view];
    CGRect previewRect = [self getPreControlFrame];
    BOOL isPointInPreviewRect = CGRectContainsPoint(previewRect, location);
    if (!isPointInPreviewRect) {
        return;
    }
    
    if (![self.cameraControlView isHidden]) {
        CGPoint locationControl = [recognizer locationInView:self.bgView];
        BOOL isPointInCameraControlRect = CGRectContainsPoint(self.cameraControlView.frame, locationControl);
        if (isPointInCameraControlRect) {
            return;
        }
    }
    
    if (![self.drawSlider isHidden]) {
        CGRect zoomTouchFrame = CGRectInset(self.drawSlider.frame, 0, -kFocusImgWH / 2);
        BOOL isPointInZoomRect = CGRectContainsPoint(zoomTouchFrame, location);
        if (isPointInZoomRect) {
            return;
        }
    }
//    if (![self.zoomView isHidden]) {
//        CGRect zoomTouchFrame = CGRectInset(self.zoomView.frame, 0, -kFocusImgWH / 2);
//        BOOL isPointInZoomRect = CGRectContainsPoint(zoomTouchFrame, location);
//        if (isPointInZoomRect) {
//            return;
//        }
//    }
    
    
    if (location.y + kFocusImgWH / 2 > CGRectGetMaxY(previewRect)) {
        location.y -= kFocusImgWH / 2;
    }

    [self.cameraControlView setCenter:location];
    [self.cameraControlView setHidden:NO];
    
    BOOL isExposureLeft = NO;
    if (location.x + self.cameraControlView.width >= self.view.width) {
        isExposureLeft = YES;
    }
    [self.cameraControlView setIsExposureLeft:isExposureLeft];

    [self.cameraControlView hideAfterDelay];

    [self resetAutoFocusAndExposureWithCenter:location];
}

- (void)setCaptureDeviceCenter:(CGPoint)location {
    CGPoint pointInsect = [self.previewLayer captureDevicePointOfInterestForPoint:location];
    if ([[self.captureDeviceInput device] isFocusPointOfInterestSupported] &&
        [[self.captureDeviceInput device] isFocusModeSupported:AVCaptureFocusModeAutoFocus])  {
        NSError *error;
        if ([[self.captureDeviceInput device] lockForConfiguration:&error])  {
            if ([[self.captureDeviceInput device] isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [[self.captureDeviceInput device] setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                [[self.captureDeviceInput device] setFocusPointOfInterest:pointInsect];
            }
            
            [[self.captureDeviceInput device] unlockForConfiguration];
        }
    }
    
    if([[self.captureDeviceInput device] isExposurePointOfInterestSupported] &&
       [[self.captureDeviceInput device]isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])  {
        NSError *error;
        if ([[self.captureDeviceInput device] lockForConfiguration:&error])  {
            
            [[self.captureDeviceInput device] setExposurePointOfInterest:pointInsect];
            [[self.captureDeviceInput device] setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            
            [[self.captureDeviceInput device] unlockForConfiguration];
        }
    }
}


- (void)pinchAction:(UIPinchGestureRecognizer *)recognizer
{
    //[self.zoomView setHidden:NO];
    //self.scale = self.lastScale * recognizer.scale;
    [self.drawSlider setHidden:NO];
    self.scale = self.drawSlider.sliderCurrentValue * recognizer.scale;
    [self zoomFromSlider:NO];
    
//    if (recognizer.state == UIGestureRecognizerStateEnded)
//        self.lastScale = self.scale;
}


#pragma mark - Camera
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}


#pragma mark - About rotate

// iOS6以前
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (INTERFACE_IS_PAD) {
        return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    }
    else
    {
        return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    }
    
}

// iOS6及以后
- (BOOL)shouldAutorotate
{
    return !self.isNeedLockedAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (INTERFACE_IS_PAD) {
        return UIInterfaceOrientationMaskLandscape;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

//ios8,later
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    
    UIInterfaceOrientation fromInterfaceOrientation = [self preferredInterfaceOrientationForPresentation];
    LogInfo(@"fromInterfaceOrientation = %ld" ,(long)[self preferredInterfaceOrientationForPresentation]);
    if (INTERFACE_IS_PAD) {
        if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            [[self.previewLayer connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
        }else if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft){
            [[self.previewLayer connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
        }
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    LogInfo(@"fromInterfaceOrientation = %ld" ,(long)[self preferredInterfaceOrientationForPresentation]);
    LogInfo(@"toInterfaceOrientation = %ld" ,(long)toInterfaceOrientation);
    [[self.previewLayer connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self adjustPreviewLayerFrame];
}

- (CGRect)getPreviewFrame {
    CGRect viewBounds = self.view.bounds;
    float cameraWidth = viewBounds.size.width;
    float cameraHeight = cameraWidth * 4 / 3;
    if (isIphoneX) {
        cameraHeight = cameraWidth * 5 / 3;
    }
    if (cameraHeight > viewBounds.size.height) {
        cameraHeight = viewBounds.size.height;
    }
    /*SFA-15583 */
    if (IS_IPHONE_4S) {
        cameraHeight = self.view.bounds.size.height - 100;
    }
   
    
    return CGRectMake(0, kCameraPreviewLayerYOffset, cameraWidth, cameraHeight);
}

- (CGRect)getPreControlFrame {
    CGRect previewFrame = [self getPreviewFrame];
    if (INTERFACE_IS_PAD) {
        previewFrame.size.width -= kCameraBottomViewDefaultHeight;
    }
    return previewFrame;
}

////调整取景框的位置
-(void) adjustPreviewLayerFrame
{
    if (self.previewLayer) {
        self.previewLayer.frame = [self getPreviewFrame];
    }
}

- (void)resetAutoFocusAndExposureWithCenter:(CGPoint)centerPoint {
    if (CGPointEqualToPoint(centerPoint, CGPointZero)) {
        CGRect previewFrame = [self getPreviewFrame];
        centerPoint = CGPointMake(CGRectGetMidX(previewFrame), CGRectGetMidY(previewFrame));
    }
    [self setCaptureDeviceCenter:centerPoint];
    
    [self.cameraControlView resetExposureSliderValue];
}

- (void)resetCamera {
    [self adjustPreviewLayerFrame];
    [self resetAutoFocusAndExposureWithCenter:CGPointZero];
}

- (void)adjustControlFrame {
    CGRect viewBounds = self.view.bounds;
    
    
    CGFloat padOffsetX = 0;
    CGFloat bottomViewHeight = 0;
    CGRect bottomFrame;
    if (INTERFACE_IS_PHONE) {
        bottomViewHeight = viewBounds.size.height - kCameraPreviewLayerYOffset - CGRectGetHeight(self.previewLayer.frame);
        bottomFrame = CGRectMake(0, viewBounds.size.height - bottomViewHeight, viewBounds.size.width, bottomViewHeight);
    } else {
        bottomViewHeight = kCameraBottomViewDefaultHeight;
        padOffsetX = viewBounds.size.width - bottomViewHeight;
        bottomFrame = CGRectMake(padOffsetX, 0, bottomViewHeight, viewBounds.size.width);
    }
    self.cameraBottomView.frame = bottomFrame;
    
    if (self.controlView) {
        self.switchCameraButton.frame = CGRectMake(viewBounds.size.width - MAIN_CELL_PADDING - kImgButtonWH, (bottomViewHeight - kImgButtonWH ) / 2, kImgButtonWH + MAIN_CELL_PADDING, kImgButtonWH);
        self.controlView.frame = CGRectMake(0, 0, viewBounds.size.width, kCameraPreviewLayerYOffset);
    } else {
        if (INTERFACE_IS_PAD && self.switchCameraButton) {
            self.switchCameraButton.frame = CGRectMake((bottomFrame.size.width - kCancelButtonWidth)/2, MAIN_CELL_PADDING, kCancelButtonWidth, kCancelButtonHeight);
        }
    }
    
    CGFloat cancelButtonWidth = [self.cancelButton.titleLabel.text ws_sizeWithFont:self.cancelButton.titleLabel.font constrainedToHeight:kCancelButtonHeight].width;
    CGFloat bottomViewX = bottomFrame.size.width;
    CGRect cancelFrame;
    if (INTERFACE_IS_PHONE) {
        cancelFrame = CGRectMake(MAIN_CELL_PADDING, (bottomFrame.size.height - kCancelButtonHeight)/2, cancelButtonWidth, kCancelButtonHeight);
    } else {
        bottomViewX = viewBounds.size.height;
        cancelFrame = CGRectMake(0, bottomViewX  - kCancelButtonHeight - MAIN_CELL_PADDING, cancelButtonWidth, kCancelButtonHeight);
    }
    self.cancelButton.frame = cancelFrame;
    
    CGRect captureFrame;
    if (INTERFACE_IS_PHONE) {
        captureFrame = CGRectMake((bottomViewX - kTakePhotoButtonWidth)/2, 0, kTakePhotoButtonWidth, bottomFrame.size.height);
    } else {
        captureFrame = CGRectMake(0, (bottomViewX - kTakePhotoButtonWidth)/2,kTakePhotoButtonWidth, bottomFrame.size.width);
    }
    self.captureButton.frame = captureFrame;
    
    
    CGRect previewFrame;
    if (INTERFACE_IS_PHONE) {
        previewFrame = CGRectMake(0, viewBounds.size.height - bottomViewHeight, viewBounds.size.width, bottomViewHeight);
    } else {
        previewFrame = CGRectMake(padOffsetX, 0, bottomViewHeight, viewBounds.size.width);
    }
    self.previewView.frame = previewFrame;
    
    CGFloat reTakeButtonWidth = [self.reTakeButton.titleLabel.text ws_sizeWithFont:self.reTakeButton.titleLabel.font constrainedToHeight:kCancelButtonHeight].width;
    CGRect reTakeFrame;
    if (INTERFACE_IS_PHONE) {
        reTakeFrame = CGRectMake(MAIN_CELL_PADDING, (self.previewView.size.height - kCancelButtonHeight)/2, reTakeButtonWidth, kCancelButtonHeight);
    } else {
        reTakeFrame = CGRectMake(0, MAIN_CELL_PADDING, reTakeButtonWidth, kCancelButtonHeight);
    }
    self.reTakeButton.frame = reTakeFrame;
    
    CGFloat confirmButtonWidth = [self.confirmButton.titleLabel.text ws_sizeWithFont:self.confirmButton.titleLabel.font constrainedToHeight:kCancelButtonHeight].width;
    CGRect confirmFrame;
    CGFloat confirmButtonX;
    if (INTERFACE_IS_PHONE) {
        confirmButtonX = self.previewView.size.width - confirmButtonWidth - MAIN_CELL_PADDING;
        confirmFrame = CGRectMake(confirmButtonX, (self.previewView.size.height - kCancelButtonHeight)/2, confirmButtonWidth, kCancelButtonHeight);
    } else {
        confirmButtonX = bottomViewX  - kCancelButtonHeight - MAIN_CELL_PADDING;
        confirmFrame = CGRectMake(0, confirmButtonX, confirmButtonWidth, kCancelButtonHeight);
    }
    self.confirmButton.frame = confirmFrame;
    
//    CGRect zoomFrame = self.zoomView.frame;
//    zoomFrame.origin.y = self.bgView.height - zoomFrame.size.height;
//    self.zoomView.frame = zoomFrame;
    CGRect zoomFrame = self.drawSlider.frame;
    zoomFrame.origin.y = self.bgView.height - zoomFrame.size.height;
    self.drawSlider.frame = zoomFrame;
}

#pragma mark - Property
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:[self getPreControlFrame]];
        [_bgView setClipsToBounds:YES];
        [self.view addSubview:_bgView];
    }
    return _bgView;
}

- (WSCameraControlView *)cameraControlView {
    if (!_cameraControlView) {
        _cameraControlView = [[WSCameraControlView alloc] initWithDevice:[self.captureDeviceInput device]];
        [_cameraControlView setHidden:YES];
        
        [self.bgView addSubview:_cameraControlView];
    
    }
    return _cameraControlView;
}

- (UIImageView *)flashOnImageView {
    if (!_flashOnImageView) {
        UIImage *flashOnImage = [UIImage imageNamed:@"icon_flash_opening"];
        _flashOnImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.width - flashOnImage.size.width) / 2 , kCameraPreviewLayerYOffset + MAIN_CELL_PADDING, flashOnImage.size.width, flashOnImage.size.height)];
        _flashOnImageView.image = flashOnImage;
        [self.view addSubview:_flashOnImageView];
    }
    return _flashOnImageView;
}

@end
