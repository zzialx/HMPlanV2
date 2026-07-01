//
//  WSGridImageHeaderView.m
//  WinSFA
//
//  Created by Stephanie on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSGridImageHeaderView.h"
#import "WSRequestHelper.h"

@interface WSGridImageHeaderView ()


@end

@implementation WSGridImageHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 3, kGridImageHeaderViewImageWith, self.height - 6)];
        self.imageView = imageView;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kGridImageHeaderViewImageWith, 0, self.width - kGridImageHeaderViewImageWith, self.height)];
        self.textLabel = label;
        self.textLabel.backgroundColor = [UIColor whiteColor];
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:label];
    }
    
    return self;
}

- (void)setText:(NSString *)text
{
    self.textLabel.text = text;
}

- (NSString *)text
{
    return self.textLabel.text;
}

- (void)setImageURL:(NSString *)imageURL
{
    _imageURL = imageURL;
    
    [[WSRequestHelper shareInstance] downloadImageWithUrl:imageURL imageView:self.imageView];
}

@end
