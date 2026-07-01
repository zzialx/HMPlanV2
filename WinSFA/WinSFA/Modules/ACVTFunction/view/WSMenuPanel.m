//
//  WSMenuPanel.m
//  WinSFA
//
//  Created by winchannel on 15/10/20.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSMenuPanel.h"

@implementation WSMenuPanel
- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self ) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
    }
    return self;
}

- (void)addMenuPanelData:(NSArray *)array{
    
    
    for ( int i =0 ; i < array.count; i++) {
        
        NSString *title = [array objectAtIndex:i];
        
        UIView *bgView = [[UIView alloc] init];
        //bgView.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1.0];
        bgView.backgroundColor =[UIColor redColor];
         bgView.frame = CGRectMake(80*i, 0, 80, self.frame.size.height);
        [self addSubview:bgView];
        
        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.tag = i;
        [menuBtn addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        menuBtn.frame = CGRectMake((80 - 60)/2, (self.frame.size.height - 40)/2, 60, 40);
        [menuBtn setTitle:title forState:UIControlStateNormal];
        
        //[menuBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",[[array objectAtIndex:i] objectForKey:@"stateNormal"]]] forState:UIControlStateNormal];
        [bgView addSubview:menuBtn];
        
    }
    
}

- (void)menuBtnClick:(id)sender{
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn  = (UIButton *)sender;
        [self.delegate ChooseMenuIndex:btn.tag];
    }
    
}



@end
