//
//  WinCameraWatermarkView.m
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import "WinCameraWatermarkView.h"
#import "Masonry.h"
//=============================================================================================================================

#pragma mark - 相机水印视图 延展(内部)
@interface WinCameraWatermarkView ()

@property (nonatomic, strong) UIView *topWatermarkView;    //顶部水印视图
@property (nonatomic, strong) UIView *bottomWatermarkView; //底部水印视图

@end
//=============================================================================================================================

#pragma mark - 相机水印视图
@implementation WinCameraWatermarkView

#pragma mark - 获取topWatermarkView方法
- (UIView *)topWatermarkView {
    
    if (!_topWatermarkView) {
        _topWatermarkView = [[UIView alloc] init];
        _topWatermarkView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    }
    return _topWatermarkView;
}

#pragma mark - 获取bottomWatermarkView方法
- (UIView *)bottomWatermarkView {
    
    if (!_bottomWatermarkView) {
        _bottomWatermarkView = [[UIView alloc] init];
        _bottomWatermarkView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    }
    return _bottomWatermarkView;
}

#pragma mark - 重写initWithFrame:方法
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.topWatermarkView];
        [self addSubview:self.bottomWatermarkView];
        
        [self.topWatermarkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(0.0f);
            make.left.equalTo(self.mas_left).offset(0.0f);
            make.right.equalTo(self.mas_right).offset(0.0f);
        }];
        
        [self.bottomWatermarkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(0.0f);
            make.right.equalTo(self.mas_right).offset(0.0f);
            make.bottom.equalTo(self.mas_bottom).offset(0.0f);
        }];
    }
    
    return self;
}

#pragma mark - 设置顶部水印方法
- (void)setTopCustomizeWatermarkWithInfoArray:(NSArray<WinWatermarkInfo *> *)infoArray isShrink:(BOOL)isShrink {
    
    [self.topWatermarkView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (infoArray.count == 0) {
        return;
    }
    
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = [UIColor whiteColor];
    [self.topWatermarkView addSubview:topLine];
        
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topWatermarkView.mas_top).offset(2.0f);
        make.left.equalTo(self.topWatermarkView.mas_left).offset(5.0f);
        make.bottom.equalTo(self.topWatermarkView.mas_bottom).offset(-2.0f);
        make.width.mas_equalTo(1.0f);
    }];
    
    UIView *referenceView = self.topWatermarkView;
    for (NSInteger i = 0; i < infoArray.count; i++) {
        
        WinWatermarkInfo *watermarkInfo = [infoArray objectAtIndex:i];
        CGFloat fontSize = (isShrink ? 10.0f : watermarkInfo.tilteFontSize);
        
        UILabel *showLabel = [[UILabel alloc] init];
        showLabel.backgroundColor = [UIColor clearColor];
        showLabel.textAlignment = NSTextAlignmentLeft;
        showLabel.textColor = [UIColor whiteColor];
        showLabel.font = [UIFont systemFontOfSize:fontSize];
        showLabel.text = watermarkInfo.tilteInfo;
        [self.topWatermarkView addSubview:showLabel];
        
        if (i == 0 && i == infoArray.count - 1) {
            
            [showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.topWatermarkView.mas_top).offset(2.0f);
                make.left.equalTo(topLine.mas_right).offset(5.0f);
                make.bottom.equalTo(self.topWatermarkView.mas_bottom).offset(-2.0f);
            }];
            
            continue;
        }
        
        if (i == 0) {
            
            [showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.topWatermarkView.mas_top).offset(2.0f);
                make.left.equalTo(topLine.mas_right).offset(5.0f);
            }];
        }
        else if (i == infoArray.count - 1) {
            
            [showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(referenceView.mas_bottom).offset(0.0f);
                make.left.equalTo(topLine.mas_right).offset(5.0f);
                make.bottom.equalTo(self.topWatermarkView.mas_bottom).offset(-2.0f);
            }];
        }
        else {
            
            [showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(referenceView.mas_bottom).offset(0.0f);
                make.left.equalTo(topLine.mas_right).offset(5.0f);
            }];
        }
        
        referenceView = showLabel;
    }
}

#pragma mark - 设置底部水印方法
- (void)setBottomCustomizeWatermarkWithInfoArray:(NSArray<WinWatermarkInfo *> *)infoArray isShrink:(BOOL)isShrink {
    
    [self.bottomWatermarkView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (infoArray.count == 0) {
        return;
    }
    
    UIView *referenceView = self.bottomWatermarkView;
    for (NSInteger i = 0; i < infoArray.count; i++) {
        
        WinWatermarkInfo *watermarkInfo = [infoArray objectAtIndex:i];
        CGFloat fontSize = (isShrink ? 10.0f : watermarkInfo.tilteFontSize);
        CGFloat imageSize = (isShrink ? 10.0f : 12.0f);
        
        NSMutableAttributedString *textString = [[NSMutableAttributedString alloc] initWithString:watermarkInfo.tilteInfo];
        if (watermarkInfo.iconImage) {
            
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = watermarkInfo.iconImage;
            attachment.bounds = CGRectMake(0, -2.0f, imageSize, imageSize);
            
            NSAttributedString *iconString = [NSAttributedString attributedStringWithAttachment:attachment];
            [textString insertAttributedString:iconString atIndex:0];
            [textString insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
        }
        
        UILabel *showLabel = [[UILabel alloc] init];
        showLabel.backgroundColor = [UIColor clearColor];
        showLabel.textAlignment = NSTextAlignmentRight;
        showLabel.textColor = [UIColor whiteColor];
        showLabel.font = [UIFont systemFontOfSize:fontSize];
        showLabel.numberOfLines = 0;
        showLabel.attributedText = textString;
        [self.bottomWatermarkView addSubview:showLabel];
        
        if (i == 0 && i == infoArray.count - 1) {
            
            [showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.bottomWatermarkView.mas_top).offset(2.0f);
                make.left.equalTo(self.bottomWatermarkView.mas_left).offset(5.0f);
                make.right.equalTo(self.bottomWatermarkView.mas_right).offset(-5.0f);
                make.bottom.equalTo(self.bottomWatermarkView.mas_bottom).offset(-2.0f);
            }];
            
            continue;
        }
        
        if (i == 0) {
            
            [showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.bottomWatermarkView.mas_top).offset(2.0f);
                make.left.equalTo(self.bottomWatermarkView.mas_left).offset(5.0f);
                make.right.equalTo(self.bottomWatermarkView.mas_right).offset(-5.0f);
            }];
        }
        else if (i == infoArray.count - 1) {
            
            [showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(referenceView.mas_bottom).offset(0.0f);
                make.left.equalTo(self.bottomWatermarkView.mas_left).offset(5.0f);
                make.right.equalTo(self.bottomWatermarkView.mas_right).offset(-5.0f);
                make.bottom.equalTo(self.bottomWatermarkView.mas_bottom).offset(-2.0f);
            }];
        }
        else {
            
            [showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(referenceView.mas_bottom).offset(0.0f);
                make.left.equalTo(self.bottomWatermarkView.mas_left).offset(5.0f);
                make.right.equalTo(self.bottomWatermarkView.mas_right).offset(-5.0f);
            }];
        }
                       
        referenceView = showLabel;
    }
}

@end
//=============================================================================================================================
