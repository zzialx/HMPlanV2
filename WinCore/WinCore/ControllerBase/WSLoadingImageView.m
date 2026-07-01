//
//  WSLoadingImageView.m
//  WinSFA
//
//  Created by Alicia on 2017/7/26.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSLoadingImageView.h"

@implementation WSLoadingImageView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}


- (void)setupViews {
    NSInteger imageCount = 8;
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:imageCount];
    for (NSInteger i = 1; i <= imageCount; i++) {
        NSString *imageName = [NSString stringWithFormat:@"loading_0%ld", (long)i];
        UIImage *loadingImage = [UIImage imageNamed:imageName];
        [imageArray addObject:loadingImage];
    }

    self.animationImages = imageArray;
    self.animationDuration = 0.6;

}

@end
