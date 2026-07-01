//
//  WSInsetLabel.m
//  WinSFA
//
//  Created by Leo Wen on 2017/4/5.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSInsetLabel.h"

@implementation WSInsetLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id) initWithFrame:(CGRect)frame andInsets: (UIEdgeInsets) insets{

    self = [super initWithFrame:frame];
    if(self){
        self.insets = insets;
    }
    return self;
}
-(id) initWithInsets: (UIEdgeInsets) insets{
    
    self = [super init];
    if(self){
        self.insets = insets;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect{
    
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}
@end
