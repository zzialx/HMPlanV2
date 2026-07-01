//
//  UIView+TouchEvent.m
//  WinSFA
//
//  Created by zhangke on 14/6/30.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "UIView+TouchEvent.h"
#import "WSTouchRecord.h"


@implementation UIView (TouchEvent)


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    NSString* lockout= [[NSUserDefaults standardUserDefaults] objectForKey:LOCK_TIMEOUT];
    if(lockout.integerValue>0){
        [[WSTouchRecord sharedManager] resetTimer];
    }
}

@end
