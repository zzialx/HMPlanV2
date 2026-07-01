//
//  WSShipView.m
//  WinSFA
//
//  Created by zhiqing on 16/8/26.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSShipView.h"

#import "PureLayout.h"
#define k_view_space 10
@interface WSShipView ()
{
    UILabel  *redDot;
    UILabel  *greenDot;
    UILabel  *orangeDot;
    UILabel  *graygeDot;
    
    UILabel  *redShip;
    UILabel  *greenShip;
    UILabel  *orangeShip;
    UILabel  *graygeShip;


}
@end

@implementation WSShipView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
    }
    return self;
}

-(void)setupSubViews{

    redDot = [[UILabel alloc]initWithFrame:CGRectMake(k_view_space, 5,  k_view_space,  k_view_space)];
    redDot.backgroundColor = [UIColor colorWithRed:253/255.0 green:120/255.0 blue:122/255.0 alpha:1];
    redDot.layer.cornerRadius = k_view_space /2;
    redDot.clipsToBounds = YES;
    redShip = [[UILabel alloc]initWithFrame:CGRectMake(redDot.right, 0, 60, 2 * k_view_space)];
    redShip.text = @"拜访异常";
    redShip.font = [UIFont systemFontOfSize:13];
    redShip.textColor =  [UIColor colorWithHexString:@"#a3a3a3"];
    greenDot = [[UILabel alloc]initWithFrame:CGRectMake(redShip.right, 5,  k_view_space,  k_view_space)];
    greenDot.backgroundColor = [UIColor colorWithRed:70/255.0 green:192/255.0 blue:168/255.0 alpha:1];
    greenDot.layer.cornerRadius = k_view_space /2;
    greenDot.clipsToBounds = YES;
    greenShip = [[UILabel alloc]initWithFrame:CGRectMake(greenDot.right, 0, 60, 2 * k_view_space)];
    greenShip.text = @"正常拜访";
    greenShip.font = [UIFont systemFontOfSize:13];
    greenShip.textColor =  [UIColor colorWithHexString:@"#a3a3a3"];

    orangeDot = [[UILabel alloc]initWithFrame:CGRectMake(greenShip.right, 5,  k_view_space, k_view_space)];
    orangeDot.backgroundColor =  [UIColor colorWithRed:121/255.0 green:176/255.0 blue:252/255.0 alpha:1];
    orangeDot.layer.cornerRadius = k_view_space /2;
    orangeDot.clipsToBounds = YES;
    orangeShip = [[UILabel alloc]initWithFrame:CGRectMake(orangeDot.right, 0, 45, 2 * k_view_space)];
    orangeShip.text = @"already_prepare";
    orangeShip.font = [UIFont systemFontOfSize:13];
    orangeShip.textColor =  [UIColor colorWithHexString:@"#a3a3a3"];

    graygeDot = [[UILabel alloc]initWithFrame:CGRectMake(orangeShip.right, 5,  k_view_space, k_view_space)];
    graygeDot.backgroundColor =  [UIColor colorWithRed:129/255.0 green:129/255.0 blue:129/255.0 alpha:1];
    graygeDot.layer.cornerRadius = k_view_space /2;
    graygeDot.clipsToBounds = YES;
    
    graygeShip = [[UILabel alloc]initWithFrame:CGRectMake(graygeDot.right, 0, 60, 2 * k_view_space)];
    graygeShip.text = @"noalready_prepare";
    graygeShip.font = [UIFont systemFontOfSize:13];
    graygeShip.textColor =  [UIColor colorWithHexString:@"#a3a3a3"];

    [self addSubview:redDot];
    [self addSubview:greenDot];
    [self addSubview:orangeDot];
    [self addSubview:graygeDot];
    
    [self addSubview:greenShip];
    [self addSubview:redShip];
    [self addSubview:orangeShip];
    [self addSubview:graygeShip];


}
@end
