//
//  GridNameLabel.m
//  WinChannelFrameWork
//
//  Created by Jiepeng Zheng on 12-7-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import "GridNameLabel.h"

@interface GridNameLabel()
{
    CGRect oldRect;
}

@end

@implementation GridNameLabel

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

    NSLog(@"GridNameLabel touch");
    NSString *text = self.text;
    
    
    [self showAlert:text];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
//    self.frame = CGRectMake(oldRect.origin.x, oldRect.origin.y, oldRect.size.width, oldRect.size.height); 
//    self.numberOfLines = 1;
}

- (void)showAlert:(NSString *)message{
    NSString *LoginfailString = NSLocalizedString(@"table_dict_title_project",nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:LoginfailString tips:message tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
