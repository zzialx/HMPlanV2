//
//  WSRadioButton.m
//  WinSFA
//
//  Created by zhangke on 15/2/2.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSRadioOptView.h"


@implementation WSRadioOptView

- (id)initWithFrame:(CGRect)frame optName:(NSString*)optName tag:(NSInteger)tag
{
    self=[super initWithFrame:frame];
    if(self){
        

        
        self.button=[UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self.button setImage:[UIImage imageNamed:@"selected_no_radio"] forState:UIControlStateNormal];
        [self.button setImage:[UIImage imageNamed:@"selected_yes_radio"]forState:UIControlStateSelected];
        [self.button setImage:[UIImage imageNamed:@"selected_no_radio_disabled"] forState:UIControlStateDisabled];
        self.button.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
        [self addSubview:self.button];

        CGFloat labelWidth = frame.size.width - 15 - self.button.imageView.size.width;
        self.optLabel=[[UILabel alloc] initWithFrame:CGRectMake(15, 0, labelWidth, frame.size.height)];
        self.optLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.optLabel.numberOfLines = 2;
        [self addSubview:self.optLabel];

        self.optLabel.text=optName;
        UIFont* font=[UIFont systemFontOfSize:UI_Font];
        self.optLabel.font=font;
        
        self.button.tag=tag;

        CGSize size = [optName ws_sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToWidth:self.optLabel.frame.size.width lineBreakMode:NSLineBreakByWordWrapping];
        if(size.height>self.frame.size.height){
            CGRect rect=self.optLabel.frame;
            rect.size.height=size.height;
            self.optLabel.frame=rect;
            
            rect=self.button.frame;
            rect.size.height=size.height;
            self.button.frame=rect;
            
            rect=self.frame;
            rect.size.height=size.height;
            self.frame=rect;
        }

    }
    return self;
}


@end
