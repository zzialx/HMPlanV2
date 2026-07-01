//
//  TitleButton.m
//  demo
//
//  Created by zhiqingPC on 15/10/20.
//  Copyright (c) 2015年 zhiqingPC. All rights reserved.
//

#import "TitleButton.h"
#import "UIView+Extension.h"
#import "UIButton+EnlagerTouchPoint.h"

@implementation TitleButton
/*
-(id)initWithTitle:(NSString *)title itemNum:(NSInteger)itemNum allItemNum:(NSInteger)allItemNum{
    self = [super init];
    if (self) {
        
        [self setTitle:[NSString stringWithFormat:@"%@",title] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:INTERFACE_IS_PHONE ? 18 : 26];
            UIImage * normalImg = [UIImage imageNamed:@"menu_xialan_arrow"];
            UIColor *titlecolor = [UIColor colorForKey:@"NavigationBarButtonTitleColor"];
                    [self setImage:normalImg forState:UIControlStateNormal];
            [self setImage:normalImg forState:UIControlStateHighlighted];
         [self setTitleColor:titlecolor forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:INTERFACE_IS_PHONE ? 18 : 26 ];
        [self sizeToFit];
    }

    return self;
}

-(void)layoutSubviews{

    [super layoutSubviews];

    // 先调整titleLable的x为0
    self.titleLabel.x = 5;
    self.imageView.x = CGRectGetMaxX(self.titleLabel.frame) + MARGIN;
    
    self.width = self.titleLabel.width +  self.imageView.width + MARGIN;
    
    self.centerX = self.superview.width * 0.5;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self =  [super initWithFrame:frame];
    if (self) {
        UIColor *titlecolor = [UIColor colorForKey:@"NavigationBarButtonTitleColor"];
        [self setTitleColor:titlecolor forState:UIControlStateNormal];
    }
    
    return self;
}
*/
//- (void)layoutSubviews{
//    [super layoutSubviews];
//
//    //先调整titleLabel的x为0
//
//    self.titleLabel.x = 0;
//
//    self.imageView.x = CGRectGetMaxX(self.titleLabel.frame) + MARGIN;
//
//    self.width = self.titleLabel.width + self.imageView.width + MARGIN;
//    // self.centerX = self.superview.width * 0.5;
//}


- (void)setTitle:(NSString *)title forState:(UIControlState)state{
    [super setTitle:title forState:state];
    self.titleLabel.font = [UIFont systemFontOfSize:INTERFACE_IS_PHONE ? 18 : 20 ];
//    [self sizeToFit];
    [self setImageRightTitleLeftWithSpacing:1.0];

}

- (void)setImage:(UIImage *)image forState:(UIControlState)state{
    [super setImage:image forState:state];
//    [self sizeToFit];
}
@end
