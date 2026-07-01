//
//  WSCustomSlider.m
//  WinSFA
//
//  Created by Alicia on 2017/8/21.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSCustomSlider.h"

@implementation WSCustomSlider

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initWithValue];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithValue];
    }
    return self;
}

- (void)initWithValue {
    self.trackHeight = 3;
}


- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGRect newBounds = CGRectMake(0, 0, bounds.size.width, self.trackHeight);
    return newBounds;
}


@end
