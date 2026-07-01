//
//  WSMediaOptionBtn.m
//  WinSFA
//
//  Created by huzepei on 16/7/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSMediaOptionBtn.h"
#import "UIView+Extension.h"
#import "PureLayout.h"

#define margin 0

@interface WSMediaOptionBtn()

@property (nonatomic,strong) UIImageView *outImageView;
@end

@implementation WSMediaOptionBtn

- (void)setup
{
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    
    if ([self.layOuttype isEqualToString:@"Horizontal"]) {
        self.imageView.contentMode = UIViewContentModeCenter;
    }
}

-(void)setLayOuttype:(NSString *)layOuttype
{
    _layOuttype = layOuttype;
    if ([_layOuttype isEqualToString:@"Horizontal"]) {
        self.imageView.contentMode = UIViewContentModeCenter;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

-(void)setChoosed:(BOOL)Choosed
{
    _Choosed = Choosed;
    
    if (_Choosed) {
        if ([self.layOuttype isEqualToString:@"Horizontal"]) {
//            _outImageView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"richMedia_checked"]];
//            [self insertSubview:self.outImageView belowSubview:self.imageView];
//            [_outImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(-4, -2, 0, -10)];
            [_outImageView removeFromSuperview];
        }
    }else{
        
        if ([self.layOuttype isEqualToString:@"Horizontal"]) {
            [_outImageView removeFromSuperview];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    if ([self.layOuttype isEqualToString:@"back"]) {
        self.imageView.contentMode = UIViewContentModeCenter;
//    }
    self.imageView.width = self.width * 0.3;
    self.imageView.height = self.imageView.width;
    self.imageView.y = self.height * 0.2;
    self.imageView.centerX = self.width * 0.5;
    
    self.titleLabel.x = 0;
    self.titleLabel.y = CGRectGetMaxY(self.imageView.frame);
    self.titleLabel.width = self.width;
    self.titleLabel.height = self.height - self.titleLabel.y - margin;
}

@end
