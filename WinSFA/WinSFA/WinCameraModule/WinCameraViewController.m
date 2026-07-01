//
//  WinCameraViewController.m
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import "WinCameraViewController.h"
#import "Masonry.h"
#import "WinCameraTools.h"
#import "WinCameraWatermarkView.h"
#import "WinWatermarkInfo.h"

NSString *const WinCameraErrorDomain = @"WinCameraErrorDomain";
//=============================================================================================================================

#pragma mark - 相机控制器 延展(内部)
@interface WinCameraViewController () <AVCapturePhotoCaptureDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) WinCameraWatermarkView *watermarkView;                //水印视图
@property (nonatomic, strong) UIView *preview;                                      //预览层视图
@property (nonatomic, strong) dispatch_queue_t captureSessionQueue;                 //捕获会话队列
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;             //捕获设备输入
@property (nonatomic, strong) AVCapturePhotoOutput *capturePhotoOutput;             //捕获照片输出
@property (nonatomic, strong) AVCaptureSession *captureSession;                     //捕获会话
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer; //捕获视频预览层
@property (nonatomic, assign) AVCaptureFlashMode flashMode;                         //闪光灯模式
@property (nonatomic, strong) CALayer *focusBoxLayer;                               //焦点图层
@property (nonatomic, strong) CABasicAnimation *focusBoxAnimation;                  //焦点动画
@property (nonatomic, assign) BOOL processingPhoto;                                 //处理照片标识
@property (nonatomic, assign) CGFloat beginGestureScale;                            //开始缩放比例
@property (nonatomic, assign) CGFloat effectiveScale;                               //当前有效缩放比例

@end
//=============================================================================================================================

#pragma mark - 相机控制器
@implementation WinCameraViewController

#pragma mark - 获取watermarkView方法
- (WinCameraWatermarkView *)watermarkView {
    
    if (!_watermarkView) {
        _watermarkView = [[WinCameraWatermarkView alloc] init];
        _watermarkView.backgroundColor = [UIColor clearColor];
    }
    return _watermarkView;
}

#pragma mark - 获取preview方法
- (UIView *)preview {
    
    if (!_preview) {
        _preview = [[UIView alloc] initWithFrame:CGRectZero];
        _preview.backgroundColor = [UIColor clearColor];
    }
    return _preview;
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    self.view.backgroundColor = [UIColor blackColor];
    
    _captureSessionQueue = dispatch_queue_create("com.capture.session.queue", DISPATCH_QUEUE_SERIAL);
    _cameraQuality = AVCaptureSessionPresetPhoto;
    _flashMode = AVCaptureFlashModeOff;
    _effectiveScale = 1.0f;
    
    [self.view addSubview:self.preview];
    [self.view addSubview:self.watermarkView];
    
    if ([self.dataSource respondsToSelector:@selector(topWatermarksInCameraVc:)]) {
        NSArray *topWatermarkArray = [self.dataSource topWatermarksInCameraVc:self];
        [self.watermarkView setTopCustomizeWatermarkWithInfoArray:topWatermarkArray isShrink:NO];
    }
    if ([self.dataSource respondsToSelector:@selector(bottomWatermarksInCameraVc:)]) {
        NSArray *bottomWatermarkArray = [self.dataSource bottomWatermarksInCameraVc:self];
        [self.watermarkView setBottomCustomizeWatermarkWithInfoArray:bottomWatermarkArray isShrink:NO];
    }
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinchGesture.delegate = self;
    [self.view addGestureRecognizer:pinchGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapped:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.delaysTouchesEnded = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    [self addDefaultFocusBox];
}

#pragma mark - 获取prefersStatusBarHidden方法
- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

#pragma mark - 获取supportedInterfaceOrientations方法
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - 获取preferredInterfaceOrientationForPresentation方法
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationPortrait;
}

#pragma mark - 重写viewWillLayoutSubviews方法
- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    self.preview.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.watermarkView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    CGRect bounds = self.preview.bounds;
    self.captureVideoPreviewLayer.bounds = bounds;
    self.captureVideoPreviewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
    _captureDeviceInput = nil;
    _capturePhotoOutput = nil;
    _captureSession = nil;
}

#pragma mark - 附加控制器方法(.h对外)
- (void)attachToViewController:(UIViewController *)vc withFrame:(CGRect)frame {
    
    [vc addChildViewController:self];
    self.view.frame = frame;
    [vc.view addSubview:self.view];
    [self didMoveToParentViewController:vc];
}

#pragma mark - 启动相机方法(.h对外)
- (void)startCamera {
    
    __weak __typeof__(self) weakSelf = self;
    [WinCameraTools authCameraWithBlock:^(BOOL isAuth) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (isAuth) {
            [strongSelf initializeCamera];
            return;
        }
        
        NSError *error = [NSError errorWithDomain:WinCameraErrorDomain code:WinCameraErrorCodePermission userInfo:nil];
        [strongSelf passError:error];
    }];
}

#pragma mark - 停止相机方法(.h对外)
- (void)stopCamera {
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(self.captureSessionQueue, ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.captureSession isRunning]) {
            [strongSelf.captureSession stopRunning];
        }
    });
}

#pragma mark - 切换相机方法(.h对外)
- (void)switchCameraWithPosition:(AVCaptureDevicePosition)position {
    
    if (position != AVCaptureDevicePositionBack && position != AVCaptureDevicePositionFront) {
        return;
    }
    
    AVCaptureDevicePosition currentPosition = self.captureDeviceInput.device.position;
    if (currentPosition == position) {
        return;
    }
    
    NSError *error;
    AVCaptureDeviceInput *newVideoInput;
    if (position == AVCaptureDevicePositionBack) {
        AVCaptureDevice *device = [WinCameraTools backCaptureDevice];
        newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    }
    else {
        AVCaptureDevice *device = [WinCameraTools frontCaptureDevice];
        newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    }
    
    if (error) {
        NSError *switchError = [NSError errorWithDomain:WinCameraErrorDomain code:WinCameraErrorCodeSwitchCamera userInfo:nil];
        [self passError:switchError];
        return;
    }
    
    [self.captureSession beginConfiguration];
    [self.captureSession removeInput:self.captureDeviceInput];
    
    if ([self.captureSession canAddInput:newVideoInput]) {
        [self.captureSession addInput:newVideoInput];
    }
    self.captureDeviceInput = newVideoInput;
    
    [self.captureSession commitConfiguration];
    
    self.effectiveScale = 1.0f;
}

#pragma mark - 切换闪光灯方法(.h对外)
- (void)switchFlashWithMode:(AVCaptureFlashMode)flashMode {
    
    self.flashMode = ((flashMode == AVCaptureFlashModeOff) ? AVCaptureFlashModeOff : AVCaptureFlashModeOn);
}

#pragma mark - 拍照方法(.h对外)
- (void)takePhotoWithOrientation:(UIDeviceOrientation)deviceOrientation {
    
    if (self.processingPhoto) {
        NSError *error = [NSError errorWithDomain:WinCameraErrorDomain code:WinCameraErrorCodeTakePhotoProgress userInfo:nil];
        [self passError:error];
        return;
    }
    
    self.processingPhoto = YES;
    
    AVCaptureConnection *videoConnection = [self captureConnection];
    if (!videoConnection) {
        
        self.processingPhoto = NO;
        
        NSError *error = [NSError errorWithDomain:WinCameraErrorDomain code:WinCameraErrorCodeTakeConnection userInfo:nil];
        [self passError:error];
        return;
    }
    
    if ([videoConnection isVideoOrientationSupported]) {
        
        switch (deviceOrientation) {
            case UIDeviceOrientationPortraitUpsideDown: {
                [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
            }
                break;
            case UIDeviceOrientationLandscapeLeft: {
                [videoConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
            }
                break;
            case UIDeviceOrientationLandscapeRight: {
                [videoConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
            }
                break;
            default: {
                [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
            }
                break;
        }
    }
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(self.captureSessionQueue, ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        AVCapturePhotoSettings *photoSettings = [AVCapturePhotoSettings photoSettings];
        photoSettings.flashMode = strongSelf.flashMode;
        [strongSelf.capturePhotoOutput capturePhotoWithSettings:photoSettings delegate:strongSelf];
    } );
}

#pragma mark - 设备旋转方法(.h对外)
- (void)deviceRotateWithOrientation:(UIDeviceOrientation)deviceOrientation {
    
    if (deviceOrientation == UIDeviceOrientationPortrait) {
        
        self.watermarkView.transform = CGAffineTransformIdentity;
    }
    else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
        
        self.watermarkView.transform = CGAffineTransformIdentity;
        self.watermarkView.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
        
        self.watermarkView.transform = CGAffineTransformIdentity;
        self.watermarkView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
}








#pragma mark - 实现AVCapturePhotoCaptureDelegate---captureOutput:didFinishProcessingPhoto:error:协议(成像回调)
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error {
    
    self.processingPhoto = NO;
    
    if (error) {
        
        NSError *error = [NSError errorWithDomain:WinCameraErrorDomain code:WinCameraErrorCodeTakeConnection userInfo:nil];
        [self passError:error];
        return;
    }
    
    NSData *imageData = [photo fileDataRepresentation];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    image = [WinCameraTools cropImage:image usingPreviewLayer:self.captureVideoPreviewLayer];
    
    if (self.onTakePhoto) {
        self.onTakePhoto(self, image);
    }
}








#pragma mark - 单击手势响应方法
- (void)previewTapped:(UIGestureRecognizer *)gestureRecognizer {
    
    AVCaptureDevice *device = self.captureDeviceInput.device;
    if (!device.isFocusPointOfInterestSupported || ![device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        return;
    }
    
    CGPoint touchedPoint = [gestureRecognizer locationInView:self.preview];
    CGPoint pointOfInterest = [WinCameraTools convertToPointOfInterestFromViewCoordinates:touchedPoint
                                                                             previewLayer:self.captureVideoPreviewLayer
                                                                                    ports:self.captureDeviceInput.ports];
    [self focusAtPoint:pointOfInterest];
    [self showFocusBox:touchedPoint];
}

#pragma mark - 实现UIGestureRecognizerDelegate--gestureRecognizerShouldBegin:协议(开始触摸回调)
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        self.beginGestureScale = self.effectiveScale;
    }
    
    return YES;
}

#pragma mark - 捏合手势响应方法
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches];
    for (NSUInteger i = 0; i < numTouches; ++i) {
        
        CGPoint location = [recognizer locationOfTouch:i inView:self.preview];
        CGPoint convertedLocation = [self.preview.layer convertPoint:location fromLayer:self.view.layer];
        if (![self.preview.layer containsPoint:convertedLocation]) {
            
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if (allTouchesAreOnThePreviewLayer) {
        
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0f) {
            self.effectiveScale = 1.0f;
        }
        if (self.effectiveScale > self.captureDeviceInput.device.activeFormat.videoMaxZoomFactor) {
            self.effectiveScale = self.captureDeviceInput.device.activeFormat.videoMaxZoomFactor;
        }
        
        NSError *error = nil;
        if ([self.captureDeviceInput.device lockForConfiguration:&error]) {
            [self.captureDeviceInput.device rampToVideoZoomFactor:self.effectiveScale withRate:100.0f];
            [self.captureDeviceInput.device unlockForConfiguration];
        }
        else {
            NSError *error = [NSError errorWithDomain:WinCameraErrorDomain code:WinCameraErrorCodeGestureScale userInfo:nil];
            [self passError:error];
        }
    }
}








#pragma mark - 初始化相机方法
- (void)initializeCamera {
    
    if (self.captureSession && [self.captureSession isRunning]) {
        return;
    }
    
    if (self.captureSession) {
        [self queueStartCamera];
        return;
    }
    
    AVCaptureDevice *captureDevice = [WinCameraTools backCaptureDevice];

    NSError *initializeError = nil;
    AVCaptureDeviceInput *captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&initializeError];
    if (initializeError) {
        
        NSError *error = [NSError errorWithDomain:WinCameraErrorDomain code:WinCameraErrorCodeHardware userInfo:nil];
        [self passError:error];
        return;
    }
    
    AVCapturePhotoOutput *capturePhotoOutput = [[AVCapturePhotoOutput alloc] init];
    
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    captureSession.sessionPreset = self.cameraQuality;
    if ([captureSession canAddInput:captureDeviceInput]) {
        [captureSession addInput:captureDeviceInput];
    }
    if ([captureSession canAddOutput:capturePhotoOutput]) {
        [captureSession addOutput:capturePhotoOutput];
    }
    
    self.captureDeviceInput = captureDeviceInput;
    self.capturePhotoOutput = capturePhotoOutput;
    self.captureSession = captureSession;
    
    CGRect bounds = self.preview.layer.bounds;
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.captureVideoPreviewLayer.bounds = bounds;
    self.captureVideoPreviewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [self.preview.layer addSublayer:self.captureVideoPreviewLayer];
    
    [self queueStartCamera];
}

#pragma mark - 添加默认聚焦箱方法
- (void)addDefaultFocusBox {
    
    CALayer *focusBox = [[CALayer alloc] init];
    focusBox.cornerRadius = 5.0f;
    focusBox.bounds = CGRectMake(0.0f, 0.0f, 75.0f, 75.0f);
    focusBox.borderWidth = 3.0f;
    focusBox.borderColor = [[UIColor yellowColor] CGColor];
    focusBox.opacity = 0.0f;
    [self.view.layer addSublayer:focusBox];
    
    CABasicAnimation *focusBoxAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    focusBoxAnimation.duration = 2.0f;
    focusBoxAnimation.autoreverses = NO;
    focusBoxAnimation.repeatCount = 0.0f;
    focusBoxAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
    focusBoxAnimation.toValue = [NSNumber numberWithFloat:0.0f];
    
    self.focusBoxLayer = focusBox;
    self.focusBoxAnimation = focusBoxAnimation;
}

#pragma mark - 队列启动相机方法
- (void)queueStartCamera {
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(self.captureSessionQueue, ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.captureSession startRunning];
    });
}

#pragma mark - 处理错误方法
- (void)passError:(NSError *)error {
    
    if (self.onError) {
        self.onError(self, error);
    }
}

#pragma mark - 获取捕获连接方法
- (AVCaptureConnection *)captureConnection {
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.capturePhotoOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    return videoConnection;
}

#pragma mark - 聚焦方法
- (void)focusAtPoint:(CGPoint)point {
    
    AVCaptureDevice *device = self.captureDeviceInput.device;
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        
        device.focusPointOfInterest = point;
        device.focusMode = AVCaptureFocusModeAutoFocus;
        [device unlockForConfiguration];
        
        return;
    }
    
    NSError *focusError = [NSError errorWithDomain:WinCameraErrorDomain code:WinCameraErrorCodeFocus userInfo:nil];
    [self passError:focusError];
}

#pragma mark - 显示聚焦框方法
- (void)showFocusBox:(CGPoint)point {
    
    if (self.focusBoxLayer) {
        
        [self.focusBoxLayer removeAllAnimations];
        
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        self.focusBoxLayer.position = point;
        [CATransaction commit];
    }
    
    if (self.focusBoxAnimation) {
        [self.focusBoxLayer addAnimation:self.focusBoxAnimation forKey:@"animateOpacity"];
    }
}

@end
//=============================================================================================================================
