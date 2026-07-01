//
//  WSStoreVisitNextView.m
//  WinSFA
//
//  Created by Alicia on 2017/8/14.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSStoreVisitNextView.h"

#define kImageLeft      10
#define kImageWH        15
#define kLabelLeft      35
#define kLabelWidth     50
#define kLabelFontSize  12
#define kBgColor        [UIColor colorWithRed:249.0f/255 green:249.0f/255 blue:249.0f/255 alpha:1.0f]

@interface WSStoreVisitNextView ()

@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIImageView *tipsImageView;

@end


@implementation WSStoreVisitNextView

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
    self.backgroundColor = kBgColor;
    UILabel *label = [[UILabel alloc] init];
    [label setTextColor:[UIColor lightGrayColor]];
    [label setFont:FONT_SIZE_PINGFANG_REGULAR(kLabelFontSize)];
    [label setNumberOfLines:-1];
    [self addSubview:label];
    self.tipsLabel = label;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"icon_arrow_more"];
    [self addSubview:imageView];
    self.tipsImageView = imageView;
    
    [self setIsRelease:NO];
}

- (void)layoutSubviews {
    self.tipsImageView.frame = CGRectMake(kImageLeft, (self.height - kImageWH) / 2, kImageWH, kImageWH);
    self.tipsLabel.frame = CGRectMake(kLabelLeft, 0, kLabelWidth, self.height);
}


- (void)setIsRelease:(BOOL)isRelease {
    _isRelease = isRelease;
    
    if (isRelease) {
        NSString *release = NSLocalizedString(@"Release to View", nil);
        [self.tipsLabel setText:release];
        [self rotateImageViewToPI:YES];
    } else {
        NSString *viewMore = NSLocalizedString(@"View More", nil);
        [self.tipsLabel setText:viewMore];
        [self rotateImageViewToPI:NO];
    }
}



- (void)rotateImageViewToPI:(BOOL)isToPI {
    if (!isToPI) {
        [UIView animateWithDuration:0.5 animations:^{
            self.tipsImageView.transform = CGAffineTransformMakeRotation(0);
        } completion:nil];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.tipsImageView.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:nil];
    }
}

@end
