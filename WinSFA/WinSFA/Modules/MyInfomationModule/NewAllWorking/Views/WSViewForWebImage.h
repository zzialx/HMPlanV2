//
//  WSPhotoView.h
//  WinSFA
//
//  Created by admin on 16/1/26.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSViewForWebImage : UIScrollView

@property (nonatomic, strong) UIImageView *imageView;

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image andUrl:(NSURL *)imageUrl;

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image andUrl:(NSURL *)imageUrl placeholderImage:(UIImage *)placeholderImage;

@end
