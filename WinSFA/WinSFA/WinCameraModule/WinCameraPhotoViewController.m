//
//  WinCameraPhotoViewController.m
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import "WinCameraPhotoViewController.h"
#import "Masonry.h"
#import "WinCameraTools.h"
//=============================================================================================================================

#pragma mark - 相机照片控制器 延展(内部)
@interface WinCameraPhotoViewController ()

@property (nonatomic, strong) UIView *topContainerBar;      //顶部内容栏
@property (nonatomic, strong) UIButton *cancelButton;       //取消按键
@property (nonatomic, strong) UIButton *useButton;          //使用按键
@property (nonatomic, strong) UIView *bottomContainerBar;   //底部内容栏
@property (nonatomic, strong) UIImageView *imageView;       //图片视图
@property (nonatomic, strong) UIImage *completeImage;       //完成图片

@end
//=============================================================================================================================

#pragma mark - 相机照片控制器
@implementation WinCameraPhotoViewController

#pragma mark - 获取topContainerBar方法
- (UIView *)topContainerBar {
    
    if (!_topContainerBar) {
        _topContainerBar = [[UIView alloc] initWithFrame:CGRectZero];
        _topContainerBar.backgroundColor = [UIColor clearColor];
    }
    return _topContainerBar;
}

#pragma mark - 获取bottomContainerBar方法
- (UIView *)bottomContainerBar {
    
    if (!_bottomContainerBar) {
        _bottomContainerBar = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomContainerBar.backgroundColor = [UIColor clearColor];
    }
    return _bottomContainerBar;
}

#pragma mark - 获取cancelButton方法
- (UIButton *)cancelButton {
    
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setBackgroundColor:[UIColor clearColor]];
        [_cancelButton setTitle:WinCameraLocalizedStrings(@"camera_cancel_title") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

#pragma mark - 获取useButton方法
- (UIButton *)useButton {
    
    if (!_useButton) {
        _useButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_useButton setBackgroundColor:[UIColor clearColor]];
        [_useButton setTitle:WinCameraLocalizedStrings(@"camera_use_title") forState:UIControlStateNormal];
        [_useButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _useButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _useButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_useButton addTarget:self action:@selector(useButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _useButton;
}

#pragma mark - 获取imageView方法
- (UIImageView *)imageView {
    
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self initLayout];
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
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

#pragma mark - 设置显示详情方法(.h对外)
- (void)setupShowDetailWithImage:(UIImage *)image {
    
    self.completeImage = image;
    self.imageView.image = image;
}








#pragma mark - 取消按键响应方法
- (void)cancelButtonAction:(UIButton *)button {
    
    [self.navigationController popViewControllerAnimated:NO];
}
   
#pragma mark - 使用按键响应方法
- (void)useButtonAction:(UIButton *)button {
    
    if (self.onUsePhoto) {
        self.onUsePhoto(self.completeImage);
    }
}








#pragma mark - 初始化布局方法
- (void)initLayout {
    
    CGFloat topHeight = [WinCameraTools safeAreaInsetsTopHeight];
    CGFloat bottomHeight = [WinCameraTools safeAreaInsetsBottomHeight];
        
    [self.view addSubview:self.topContainerBar];
    [self.topContainerBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(topHeight);
        make.left.equalTo(self.view.mas_left).offset(0.0f);
        make.right.equalTo(self.view.mas_right).offset(0.0f);
        make.height.mas_equalTo(WIN_CAMERA_CONTAINER_BAR_HEIGHT);
    }];
    
    [self.view addSubview:self.bottomContainerBar];
    [self.bottomContainerBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(0.0f);
        make.right.equalTo(self.view.mas_right).offset(0.0f);
        make.bottom.equalTo(self.view.mas_bottom).offset(-bottomHeight);
        make.height.mas_equalTo(WIN_CAMERA_CONTAINER_BAR_HEIGHT);
    }];
    
    
    [self.bottomContainerBar addSubview:self.cancelButton];
    [self.bottomContainerBar addSubview:self.useButton];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomContainerBar.mas_left).offset(WIN_CAMERA_CONTAINER_BAR_ELEMENT_MARGIN);
        make.centerY.equalTo(self.bottomContainerBar.mas_centerY).offset(0.0f);
        make.width.mas_greaterThanOrEqualTo(50.0f);
        make.height.mas_greaterThanOrEqualTo(50.0f);
    }];
    [self.useButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomContainerBar.mas_right).offset(-WIN_CAMERA_CONTAINER_BAR_ELEMENT_MARGIN);
        make.centerY.equalTo(self.bottomContainerBar.mas_centerY).offset(0.0f);
        make.width.mas_greaterThanOrEqualTo(50.0f);
        make.height.mas_greaterThanOrEqualTo(50.0f);
    }];
    
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topContainerBar.mas_bottom).offset(2.0f);
        make.left.equalTo(self.view.mas_left).offset(0.0f);
        make.right.equalTo(self.view.mas_right).offset(0.0f);
        make.bottom.equalTo(self.bottomContainerBar.mas_top).offset(-2.0f);
    }];
}

@end
//=============================================================================================================================
