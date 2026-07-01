//
//  WSCompositeImageView.m
//  WinSFA
//
//  Created by winchannel on 2018/1/4.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSCompositeImageView.h"


@implementation WSCompositeImageView

- (id)initWithFrame:(CGRect)frame withSubImageArray:(NSArray *)subImageArray withSubViewScale:(float)scale{
    
    self = [super initWithFrame:frame];
    if (self) {
        _subImages = subImageArray;
        _scale = scale;
        [self setSubViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withSubImageArray:(NSArray *)subImageArray {
   return [self initWithFrame:frame withSubImageArray:subImageArray withSubViewScale:1.0];
}

- (void)setSubViews{
    
    for (int i = 0 ; i < _subImages.count ; i++) {
        WSStoreOtherBean *object = [self.subImages objectAtIndex:i];
        CGFloat x = [object.item4 floatValue] *_scale;
        CGFloat y = [object.item5 floatValue] *_scale;
        CGFloat width = ([object.item6 floatValue]  - [object.item4 floatValue]) *_scale;
        CGFloat height = ([object.item7 floatValue]  - [object.item5 floatValue]) *_scale;
        UIControl *touchView = [[UIControl alloc]initWithFrame:CGRectMake(x, y, width, height)];
        touchView.tag = i;
        [touchView addTarget:self action:@selector(touchViewClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:touchView];
    }

}


- (void)touchViewClick:(UIControl *)imageView{
    
    [self.delegate selectItem:imageView.tag];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
