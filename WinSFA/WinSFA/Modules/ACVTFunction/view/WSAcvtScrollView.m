//
//  WSAcvtScrollView.m
//  WinSFA
//
//  Created by yang on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAcvtScrollView.h"
#import "WSAcvtView.h"
#import "WSConstant.h"


#import "WSTAAcvtDataGridViewPanel.h"


@implementation WSAcvtScrollView

- (id)initWithFrame:(CGRect)frame andAcvtBean:(WSAcvtBean *)acvtBean{

    return [self initWithFrame:frame andAcvtBean:acvtBean qstArray:nil];
}

- (id)initWithFrame:(CGRect)frame andAcvtBean:(WSAcvtBean *)acvtBean qstArray:(NSArray *)qstArray
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeScrollViewContent:) name:GAIN_KEYBORE_HEIGHT_NOTIFICTION_NAME object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reduceScrollViewContentSizeHeight) name:UIKeyboardWillHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeScrollViewOffSet:) name:CHANGE_ACVTSCROLLVIEW_OFFSET_NOTIFICATION object:nil];
        
        UIColor *bgColor = [UIColor colorForKey:@"AcvtViewBackgroundColor"];
        if (!bgColor) {
            bgColor = [UIColor whiteColor];
        }
        self.backgroundColor = bgColor;
        self.bounces = NO;
        self.acvtView = [[WSAcvtView alloc] initWithFrame:self.bounds andAcvtBean:acvtBean qstArray:qstArray];
        if (INTERFACE_IS_PAD && frame.size.width == SCREEN_WIDTH)
        {
            self.acvtView.frame = CGRectMake(120, 0, self.width-2*120, self.height);
        }
        
        self.acvtView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:self.acvtView];
        
        self.delegate = self;
        
        self.isResetOffset = YES;
        
        
        return self;
    }
    
    return nil;
}

- (void)changeScrollViewContent:(NSNotification*)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    CGFloat keyBord_height = [userInfo[WS_KEYBORD_HEIGTH] floatValue];
//    CGFloat acvtView_move_height = [userInfo[WS_ACVT_VIEW_MOVE_HEIGHT] floatValue];
    self.scrollViewChangeHeight = keyBord_height;
//    if (acvtView_move_height < 0) {
//        self.scrollViewChangeHeight = keyBord_height + acvtView_move_height;
//    }
    self.contentSize = CGSizeMake(self.acvtView.width, self.acvtView.height + self.scrollViewChangeHeight);
}


//- (void)reduceScrollViewContentSizeHeight {
//    if (self.scrollViewChangeHeight > 0) {
//        self.contentSize = CGSizeMake(self.acvtView.width, self.acvtView.height);
//        self.scrollViewChangeHeight = 0;
//    }
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.contentSize.height != self.acvtView.height) {
        CGFloat contentHeight = self.acvtView.height;
        if (self.scrollViewChangeHeight > 0) {
            contentHeight += self.scrollViewChangeHeight;
        }
        self.contentSize = CGSizeMake(self.acvtView.width, contentHeight);
    }
}


- (void)changeScrollViewOffSet:(NSNotification*)notification {
    if (!self.isResetOffset) {
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    
    CGFloat changeHeight = [userInfo[WSTEXTVIEWPANEL_CHANGED_HEIGHT] floatValue];
    self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y + changeHeight);
}

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:GAIN_KEYBORE_HEIGHT_NOTIFICTION_NAME object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGE_ACVTSCROLLVIEW_OFFSET_NOTIFICATION object:nil];
    self.delegate = nil;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    
//    if (self.isDragging) {
//        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
//    }
//}


- (WSAcvtScrollView *)getSubScrollView {
    
    if (self.acvtView.isInAcvtTabMode) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[WSAcvtView class]]) {
                for (UIView *subView in view.subviews) {
                    if ([subView isKindOfClass:[WSAcvtScrollView class]]) {
                        return (WSAcvtScrollView *)subView;
                    }
                }
                break;
            }
        }
    }
    
    return nil;
    
}

@end
