//
//  WSCenterAnotationView.m
//  WinSFA
//
//  Created by heju on 16/5/13.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSCenterAnotationView.h"

@implementation WSCenterAnotationView


-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self setFrame:frame];
        self.image = [UIImage imageForName:@"map_center.png"];
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
