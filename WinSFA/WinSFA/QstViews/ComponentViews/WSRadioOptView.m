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
        self=[[[NSBundle mainBundle] loadNibNamed:@"WSRadioOptView" owner:self options:nil] firstObject];
        self.frame=frame;

        self.optLabel.text=optName;
        UIFont* font=[UIFont systemFontOfSize:UI_Font];
        self.optLabel.font=font;
        
        self.button.tag=tag;

        CGSize size=[optName sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:CGSizeMake(self.optLabel.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
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
