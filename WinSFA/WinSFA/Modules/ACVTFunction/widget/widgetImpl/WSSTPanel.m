//
//  WSSTPanel.m
//  WinSFA
//
//  Created by yang on 16/3/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSTPanel.h"

@implementation WSSTPanel

- (void)buildDisplayContent
{
    self.hidden = YES;
    [self setFrame:CGRectZero];
}

- (NSObject *)getResultDirectly
{
    return @"1";
}

@end
