//
//  CustomSlider.h
//  WinSFA
//
//  Created by huzepei on 16/7/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//


#import "CustomSlider.h"

@implementation CustomSlider
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor lightGrayColor];
    self.leftView = [[UIImageView alloc]init];
    self.leftView.frame = CGRectMake(0, 0, 0, self.frame.size.height);
    self.leftView.backgroundColor = MAIN_TINT_COLOT;
    [self addSubview:self.leftView];
    self.ValueLabel = [[UILabel alloc]initWithFrame:self.bounds];
    self.ValueLabel.textAlignment = NSTextAlignmentCenter;
    self.ValueLabel.font = [UIFont systemFontOfSize:17];
    self.ValueLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.ValueLabel];
    return self;
}
-(void)setLeftFrame:(int)tempValue{
    
    self.leftView.frame = CGRectMake(0, 0, self.frame.size.width * (tempValue / 100.0), self.frame.size.height);
}


@end
