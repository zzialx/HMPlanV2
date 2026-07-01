//
//  WSShareItem.m
//  WinSFA
//
//  Created by winchannel on 2017/7/3.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSShareItem.h"

@implementation WSShareItem

-(instancetype)initWithTitle:(NSString *)title Icon:(NSString *)icon{
    self = [super init];
    if (self) {
        self.title = title;
        self.icon = icon;
    }
    return self;
}

@end
