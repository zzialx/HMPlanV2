//
//  WSCustomGestrueScrollView.m
//  WinSFA
//
//  Created by Stephanie on 16/8/28.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSCustomGestrueScrollView.h"

@implementation WSCustomGestrueScrollView

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if(gestureRecognizer.state != 0) {
        return YES;
    }else {
        return NO;
    }
}

@end
