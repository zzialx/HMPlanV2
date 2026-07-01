//
//  CustomSlider.h
//  WinSFA
//
//  Created by huzepei on 16/7/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface CustomSlider : UIView

@property(nonatomic, strong)UIImageView *leftView;
@property(nonatomic, strong)UIImageView *rightView;
@property(nonatomic, strong)UILabel *ValueLabel;
@property(nonatomic, assign)int MaxValue;
-(void)setLeftFrame:(int)tempValue;

@end
