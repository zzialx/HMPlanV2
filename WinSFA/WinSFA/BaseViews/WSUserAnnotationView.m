//
//  WSUserAnnotationView.m
//  WinSFA
//
//  Created by heju on 14/12/17.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSUserAnnotationView.h"

@implementation WSUserAnnotationView


- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        
        self.image = [UIImage imageForName:@"mapUserLocationPlus.png"];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"mapUserLocation.png"]];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration = 0.8;                                       // 动画持续时间
        animation.repeatCount = INTMAX_MAX;                             // 重复次数
        animation.autoreverses = YES;                                   // 是否执行逆动画
        animation.fromValue = [NSNumber numberWithFloat:0.8];           // 开始时的倍率
        animation.toValue = [NSNumber numberWithFloat:1.0];             // 结束时的倍率
        [imageView.layer addAnimation:animation forKey:@"scale-layer"];
        [self addSubview:imageView];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        self.image = [UIImage imageForName:@"mapUserLocationPlus.png"];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"mapUserLocation.png"]];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration = 0.8;                                       // 动画持续时间
        animation.repeatCount = INTMAX_MAX;                             // 重复次数
        animation.autoreverses = YES;                                   // 是否执行逆动画
        animation.fromValue = [NSNumber numberWithFloat:0.8];           // 开始时的倍率
        animation.toValue = [NSNumber numberWithFloat:1.0];             // 结束时的倍率
        [imageView.layer addAnimation:animation forKey:@"scale-layer"];
        [self addSubview:imageView];
        
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
