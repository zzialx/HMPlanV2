//
//  WSUpKeyBoardView.m
//  WinSFA
//
//  Created by zhangke on 15/1/26.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSUpKeyBoardView.h"

#define kButtonFont [UIFont systemFontOfSize:14]

@implementation WSUpKeyBoardView
@synthesize operationDelegate;

-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor colorWithHexString:@"#eaeaea"];
        
        CGFloat buttonWidth = 80;
        
        UIButton* cButton=[UIButton buttonWithType:UIButtonTypeSystem];
        [cButton setTitle:NSLocalizedString(@"cancel_label", nil) forState:UIControlStateNormal];
        cButton.frame=CGRectMake(MAIN_CELL_PADDING, 0, buttonWidth, self.height);
        cButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        cButton.titleLabel.font = kButtonFont;
        [self addSubview:cButton];
        cButton.tag=98;
        _cancelButton = cButton;
        
        UIButton* oButton=[UIButton buttonWithType:UIButtonTypeSystem];
        [oButton setTitle:NSLocalizedString(@"complete", nil) forState:UIControlStateNormal];
        oButton.frame=CGRectMake(self.width - buttonWidth - MAIN_CELL_PADDING, 0, buttonWidth, self.height);
        oButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self addSubview:oButton];
        oButton.tag=100;
        oButton.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
        oButton.titleLabel.font = kButtonFont;
        _finishButton = oButton;

//        UIButton* lButton=[UIButton buttonWithType:UIButtonTypeSystem];
//        [lButton setTitle:@"zoom_in" forState:UIControlStateNormal];
//        lButton.frame=CGRectMake(self.width-90, 0, 45, self.height);
//        lButton.hidden=YES;
//        [self addSubview:lButton];
//        lButton.tag=99;
//        lButton.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
//        _zoomInButton = lButton;

    }
    return self;
}

@end
