//
//  WSRichMediaOptionCell.m
//  选项卡
//
//  Created by huzepei on 16/8/1.
//  Copyright © 2016年 huzepei. All rights reserved.
//

#import "WSRichMediaOptionCell.h"
#import "PureLayout.h"

#define WSColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
@interface WSRichMediaOptionCell()



@end

@implementation WSRichMediaOptionCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _btn  = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.userInteractionEnabled = NO;
        [_btn setBackgroundColor:[UIColor clearColor]];
        [_btn setTitleColor:WSColor(237, 90, 43) forState:UIControlStateSelected];
        [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
        [_btn addTarget:self action:@selector(choose:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_btn];
        [_btn autoPinEdgesToSuperviewEdges];
    }
    return self;
}
-(void)setTitle:(NSString *)title
{
    _title = title;
    [_btn setTitle:_title forState:UIControlStateNormal];
}
-(void)choose:(UIButton *)btn
{
    btn.selected = !btn.selected;
}
@end
