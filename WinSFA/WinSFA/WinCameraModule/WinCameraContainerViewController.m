//
//  WinCameraContainerViewController.m
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import "WinCameraContainerViewController.h"
#import "UIImage+CameraBundle.h"
#import "UIImage+CameraTintColor.h"
#import "Masonry.h"
#import "WinCameraTools.h"
#import "WinCameraViewController.h"
#import "WinCameraPhotoViewController.h"
#import "SVProgressHUD+CameraShow.h"
#import "WinMotionManager.h"
#import "WinCameraWatermarkView.h"
//=============================================================================================================================

#pragma mark - 相机容器控制器 延展(内部)
@interface WinCameraContainerViewController () <WinCameraDataSource>

@property (nonatomic, strong) UIView *topContainerBar;              //顶部内容栏
@property (nonatomic, strong) UIButton *switchButton;               //转换按键
@property (nonatomic, strong) UIButton *flashButton;                //闪光灯按键
@property (nonatomic, strong) UIView *bottomContainerBar;           //底部内容栏
@property (nonatomic, strong) UIButton *closeButton;                //关闭按键
@property (nonatomic, strong) UIButton *captureButton;              //捕获按键
@property (nonatomic, strong) WinCameraViewController *camera;      //相机视图管理器
@property (nonatomic, assign) UIDeviceOrientation deviceOrientation;//设备方向

@end
//=============================================================================================================================

#pragma mark - 相机容器控制器
@implementation WinCameraContainerViewController

#pragma mark - 获取topContainerBar方法
- (UIView *)topContainerBar {
    
    if (!_topContainerBar) {
        _topContainerBar = [[UIView alloc] initWithFrame:CGRectZero];
        _topContainerBar.backgroundColor = [UIColor clearColor];
    }
    return _topContainerBar;
}

#pragma mark - 获取switchButton方法
- (UIButton *)switchButton {
    
    if (!_switchButton) {
        _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchButton setBackgroundColor:[UIColor clearColor]];
        [_switchButton setImage:[[UIImage imageInBundleNamed:@"SwitchCamera"] tintImageWithColor:self.tintColor] forState:UIControlStateNormal];
        [_switchButton setImage:[[UIImage imageInBundleNamed:@"SwitchCamera"] tintImageWithColor:self.selectedTintColor] forState:UIControlStateSelected];
        [_switchButton addTarget:self action:@selector(switchButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _switchButton;
}

#pragma mark - 获取flashButton方法
- (UIButton *)flashButton {
    
    if (!_flashButton) {
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashButton setBackgroundColor:[UIColor clearColor]];
        [_flashButton setImage:[[UIImage imageInBundleNamed:@"FlashCamera"] tintImageWithColor:self.tintColor] forState:UIControlStateNormal];
        [_flashButton setImage:[[UIImage imageInBundleNamed:@"FlashCamera"] tintImageWithColor:self.selectedTintColor] forState:UIControlStateSelected];
        [_flashButton addTarget:self action:@selector(flashButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _flashButton;
}

#pragma mark - 获取bottomContainerBar方法
- (UIView *)bottomContainerBar {
    
    if (!_bottomContainerBar) {
        _bottomContainerBar = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomContainerBar.backgroundColor = [UIColor clearColor];
    }
    return _bottomContainerBar;
}

#pragma mark - 获取closeButton方法
- (UIButton *)closeButton {
    
    if (!_closeButton) {
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setBackgroundColor:[UIColor clearColor]];
        [_closeButton setImage:[[UIImage imageInBundleNamed:@"CloseCamera"] tintImageWithColor:self.tintColor] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _closeButton;
}

#pragma mark - 获取captureButton方法
- (UIButton *)captureButton {
    
    if (!_captureButton) {
        
        _captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_captureButton setBackgroundColor:self.tintColor];
        [_captureButton setImage:[UIImage imageInBundleNamed:@"CaptureCamera"] forState:UIControlStateNormal];
        [_captureButton addTarget:self action:@selector(captureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_captureButton.layer setCornerRadius:(WIN_CAMERA_CONTAINER_BAR_HEIGHT / 2)];
        _captureButton.clipsToBounds = YES;
    }

    return _captureButton;
}

#pragma mark - 获取camera方法
- (WinCameraViewController *)camera {
    
    if (!_camera) {
        _camera = [[WinCameraViewController alloc] init];
        _camera.dataSource = self;
    }
    return _camera;
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    self.view.backgroundColor = [UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.tintColor = [UIColor whiteColor];
    self.selectedTintColor = [UIColor cyanColor];
    self.deviceOrientation = UIDeviceOrientationPortrait;
    
    [self initLayout];
    [self initInteraction];
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

#pragma mark - 重写viewWillAppear:方法
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[WinMotionManager sharedManager] startMotionHandler];
    [self.camera startCamera];
}

#pragma mark - 重写viewWillDisappear:方法
- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[WinMotionManager sharedManager] stopMotionHandler];
    [self.camera stopCamera];
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - app到后台通知回调方法
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    
    [self handleCameraDismiss];
}

#pragma mark - 处理相机解除视图方法(.h对外)
- (void)handleCameraDismiss {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - 继续拍照方法
- (void)continueTakePhoto {
    
    UIViewController *visibleViewController = self.navigationController.visibleViewController;
    if ([visibleViewController isKindOfClass:[WinCameraPhotoViewController class]]) {
        
        WinCameraPhotoViewController *vc = (WinCameraPhotoViewController *)visibleViewController;
        [vc.navigationController popViewControllerAnimated:NO];
        return;
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}








#pragma mark - 初始化布局方法
- (void)initLayout {
    
    CGFloat topHeight = [WinCameraTools safeAreaInsetsTopHeight];
    CGFloat bottomHeight = [WinCameraTools safeAreaInsetsBottomHeight];
    
    [self.view addSubview:self.topContainerBar];
    [self.topContainerBar addSubview:self.switchButton];
    [self.topContainerBar addSubview:self.flashButton];
    
    [self.topContainerBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(topHeight);
        make.left.equalTo(self.view.mas_left).offset(0.0f);
        make.right.equalTo(self.view.mas_right).offset(0.0f);
        make.height.mas_equalTo(WIN_CAMERA_CONTAINER_BAR_HEIGHT);
    }];
    
    [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topContainerBar.mas_left).offset(WIN_CAMERA_CONTAINER_BAR_ELEMENT_MARGIN);
        make.centerY.equalTo(self.topContainerBar.mas_centerY).offset(0.0f);
    }];
     
    [self.flashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topContainerBar.mas_right).offset(-WIN_CAMERA_CONTAINER_BAR_ELEMENT_MARGIN);
        make.centerY.equalTo(self.topContainerBar.mas_centerY).offset(0.0f);
    }];
    
    [self.view addSubview:self.bottomContainerBar];
    [self.bottomContainerBar addSubview:self.closeButton];
    [self.bottomContainerBar addSubview:self.captureButton];
    
    [self.bottomContainerBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(0.0f);
        make.right.equalTo(self.view.mas_right).offset(0.0f);
        make.bottom.equalTo(self.view.mas_bottom).offset(-bottomHeight);
        make.height.mas_equalTo(WIN_CAMERA_CONTAINER_BAR_HEIGHT);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomContainerBar.mas_left).offset(WIN_CAMERA_CONTAINER_BAR_ELEMENT_MARGIN);
        make.centerY.equalTo(self.bottomContainerBar.mas_centerY).offset(0.0f);
    }];
    
    [self.captureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bottomContainerBar.mas_centerX).offset(0.0f);
        make.centerY.equalTo(self.bottomContainerBar.mas_centerY).offset(0.0f);
        make.width.mas_equalTo(WIN_CAMERA_CONTAINER_BAR_HEIGHT);
        make.height.mas_equalTo(WIN_CAMERA_CONTAINER_BAR_HEIGHT);
    }];
    
    [self.camera attachToViewController:self withFrame:CGRectZero];
    [self.camera.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topContainerBar.mas_bottom).offset(2.0f);
        make.left.equalTo(self.view.mas_left).offset(0.0f);
        make.right.equalTo(self.view.mas_right).offset(0.0f);
        make.bottom.equalTo(self.bottomContainerBar.mas_top).offset(-2.0f);
    }];
}

#pragma mark - 初始化互动方法
- (void)initInteraction {
    
    AVCaptureDevice *frontDevice = [WinCameraTools frontCaptureDevice];
    AVCaptureDevice *backDevice = [WinCameraTools backCaptureDevice];
    self.switchButton.hidden = ((frontDevice && backDevice) ? NO : YES);
    self.flashButton.hidden = ((backDevice.hasFlash && backDevice.isFlashAvailable) ? NO : YES);

    __weak __typeof__(self) weakSelf = self;
    [self.camera setOnError:^(WinCameraViewController *camera, NSError *error) {
        
        if (![error.domain isEqualToString:WinCameraErrorDomain]) {
            return;
        }
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf handleCameraErrorWithCode:error.code];
    }];
    
    [self.camera setOnTakePhoto:^(WinCameraViewController *camera, UIImage *image) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf jumpCameraPhotoWithImage:image];
    }];
    
    [[WinMotionManager sharedManager] setMotionRotationHandler:^(UIDeviceOrientation orientation, NSError * _Nullable error) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf rotationChanged:orientation];
    }];
}

#pragma mark - 处理相机错误方法
- (void)handleCameraErrorWithCode:(NSInteger)code {
    
    NSString *errorStr = nil;
    if (code == WinCameraErrorCodePermission) {
        errorStr = WinCameraLocalizedStrings(@"camera_error_permission");
    }
    else if (code == WinCameraErrorCodeHardware) {
        errorStr = WinCameraLocalizedStrings(@"camera_error_hardware");
    }
    else if (code == WinCameraErrorCodeSwitchCamera) {
        errorStr = WinCameraLocalizedStrings(@"camera_error_switchCamera");
    }
    else if (code == WinCameraErrorCodeTakePhotoProgress) {
        errorStr = WinCameraLocalizedStrings(@"camera_error_takePhotoProgress");
    }
    else if (code == WinCameraErrorCodeTakeConnection) {
        errorStr = WinCameraLocalizedStrings(@"camera_error_takePhotoConnection");
    }
    else if (code == WinCameraErrorCodeGestureScale) {
        //缩放手势错误 暂时不处理
    }
    else if (code == WinCameraErrorCodeFocus) {
        //聚焦错误 暂时不处理
    }
    
    if (errorStr.length == 0) {
        return;
    }
    
    if (code == WinCameraErrorCodeSwitchCamera || code == WinCameraErrorCodeTakePhotoProgress || code == WinCameraErrorCodeTakeConnection) {
        [SVProgressHUD showWithInfo:errorStr];
        return;
    }
    
    NSString *title = WinCameraLocalizedStrings(@"camera_prompt_title");
    NSString *confirm = WinCameraLocalizedStrings(@"camera_confirm_title");
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:errorStr
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:confirm style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf handleCameraDismiss];
    }];
        
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 展示相机照片方法
- (void)jumpCameraPhotoWithImage:(UIImage *)image {
    
    CGFloat finalWidth = ((self.scaleWidth <= 0) ? [[UIScreen mainScreen] bounds].size.width : self.scaleWidth);
    UIImage *finalImage = nil;
    
    if (self.topWatermarkInfos.count == 0 && self.bottomWatermarkInfos.count == 0) {
        
        finalImage = [WinCameraTools scaleImageToWidth:image targetWidth:finalWidth];
    }
    else {
        
        UIImage *scaleImage = [WinCameraTools scaleImageToWidth:image targetWidth:finalWidth];
        
        BOOL isShrink = ((scaleImage.size.width > scaleImage.size.height) ? YES : NO);
        WinCameraWatermarkView *watermarkView = [[WinCameraWatermarkView alloc] init];
        watermarkView.backgroundColor = [UIColor clearColor];
        [watermarkView setFrame:CGRectMake(0.0f, 0.0f, scaleImage.size.width, scaleImage.size.height)];
        [watermarkView setTopCustomizeWatermarkWithInfoArray:self.topWatermarkInfos isShrink:isShrink];
        [watermarkView setBottomCustomizeWatermarkWithInfoArray:self.bottomWatermarkInfos isShrink:isShrink];
        [watermarkView setNeedsLayout];
        [watermarkView layoutIfNeeded];
        
        UIImage *watermarkViewImage = [WinCameraTools imageFromView:watermarkView];
        UIImage *mergeImage = [WinCameraTools mergeImage:scaleImage withOverlayImage:watermarkViewImage];
        finalImage = mergeImage;
    }

    WinCameraPhotoViewController *vc = [[WinCameraPhotoViewController alloc] init];
    [vc setupShowDetailWithImage:finalImage];
    
    __weak __typeof__(self) weakSelf = self;
    [vc setOnUsePhoto:^(UIImage *image) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(camera:didFinishWithImage:)]) {
            [strongSelf.delegate camera:strongSelf didFinishWithImage:image];
        }
    }];
        
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark - 旋转变化方法
- (void)rotationChanged:(UIDeviceOrientation)orientation {
    
    if (orientation == UIDeviceOrientationUnknown || orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown ||
        orientation == UIDeviceOrientationPortraitUpsideDown) {
        return;
    }
    
    if (orientation == self.deviceOrientation) {
        return;
    }

    self.deviceOrientation = orientation;
    
    [self cameraControlTransformRestore];
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        [self cameraControlTransform:M_PI_2];
    }
    else if (orientation == UIDeviceOrientationLandscapeRight) {
        [self cameraControlTransform:-M_PI_2];
    }
    
    [self.camera deviceRotateWithOrientation:orientation];
}

#pragma mark - 相机控件转换复原方法
- (void)cameraControlTransformRestore {
    
    self.switchButton.transform = CGAffineTransformIdentity;
    self.flashButton.transform = CGAffineTransformIdentity;
    self.closeButton.transform = CGAffineTransformIdentity;
    self.captureButton.transform = CGAffineTransformIdentity;
}

#pragma mark - 相机控件转换方法
- (void)cameraControlTransform:(CGFloat)angle {
    
    self.switchButton.transform = CGAffineTransformMakeRotation(angle);
    self.flashButton.transform = CGAffineTransformMakeRotation(angle);
    self.closeButton.transform = CGAffineTransformMakeRotation(angle);
    self.captureButton.transform = CGAffineTransformMakeRotation(angle);
}








#pragma mark - 实现WinCameraDataSource--topWatermarksInCameraVc:协议(获取顶部水印信息数据源)
- (NSArray<WinWatermarkInfo *> *)topWatermarksInCameraVc:(WinCameraViewController *)vc {
    
    return self.topWatermarkInfos;
}

#pragma mark - 实现WinCameraDataSource--bottomWatermarksInCameraVc:协议(获取底部水印信息数据源)
- (NSArray<WinWatermarkInfo *> *)bottomWatermarksInCameraVc:(WinCameraViewController *)vc {
    
    return self.bottomWatermarkInfos;
}








#pragma mark - 转换相机按键响应方法(选中是前置摄像头/未选中是后置摄像头)
- (void)switchButtonAction:(UIButton *)button {
    
    [button setSelected:!button.isSelected];
    
    if (self.flashButton.isSelected) {
        [self flashButtonAction:self.flashButton];
    }
    self.flashButton.enabled = (button.isSelected ? NO : YES);
    
    AVCaptureDevicePosition position = (button.isSelected ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack);
    [self.camera switchCameraWithPosition:position];
}

#pragma mark - 闪光灯按键响应方法
- (void)flashButtonAction:(UIButton *)button {
    
    [button setSelected:!button.isSelected];
    
    AVCaptureFlashMode flashMode = (button.isSelected ? AVCaptureFlashModeOn : AVCaptureFlashModeOff);
    [self.camera switchFlashWithMode:flashMode];
}

#pragma mark - 关闭按键响应方法
- (void)closeButtonAction:(UIButton *)button {
    
    [self handleCameraDismiss];
}
   
#pragma mark - 捕获按键响应方法
- (void)captureButtonAction:(UIButton *)button {
    
    [self.camera takePhotoWithOrientation:self.deviceOrientation];
}

@end
//=============================================================================================================================
