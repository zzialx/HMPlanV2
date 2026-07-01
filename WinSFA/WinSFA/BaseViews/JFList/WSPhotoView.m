//
//  WSPhotoView.m
//  WinSFA
//
//  Created by heju on 16/5/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSPhotoView.h"
//=============================================================================================================================

#pragma mark - 照片视图
@implementation WSPhotoView

#pragma mark - 获取imageView方法
- (UIImageView *)imageView {
    
    if (!_imageView) {
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor clearColor];
    }
    return _imageView;
}

#pragma mark - 获取indicatorView方法
- (UIActivityIndicatorView *)indicatorView {
    
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _indicatorView;
}

#pragma mark - 设置contentMode方法
- (void)setContentMode:(UIViewContentMode)contentMode {
    
    _contentMode = contentMode;
    self.imageView.contentMode = contentMode;
}

#pragma mark - 重写initWithFrame:方法
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {

        [self addSubview:self.imageView];
        [self addSubview:self.indicatorView];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(0.0f);
            make.left.equalTo(self.mas_left).offset(0.0f);
            make.right.equalTo(self.mas_right).offset(0.0f);
            make.bottom.equalTo(self.mas_bottom).offset(0.0f);
        }];
        
        [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX).offset(0.0f);
            make.centerY.equalTo(self.mas_centerY).offset(0.0f);
        }];
    }
    
    return self;
}

#pragma mark - 显示活动指示器方法
- (void)showIndicatorView {
    
    [self.indicatorView startAnimating];
}

#pragma mark - 隐藏活动指示器方法
- (void)hideIndicatorView {
    
    [self.indicatorView stopAnimating];
}

@end
//=============================================================================================================================
