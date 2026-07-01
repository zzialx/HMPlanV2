//
//  UINavigationBar+Image.h
// Core
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (Image)

// 设置导航条背景图片
- (void)setNavigationBarWithImageKey:(NSString *)imageKey;
// 清空导航条的背景图片，使恢复到系统默认状态
- (void)clearNavigationBarImage;
@end


/*
@interface RSNavigationBar : UINavigationBar {
    UIImage* _bgImage;
}

@property(nonatomic, retain) UIImage* bgImage;

// 设置导航条背景图片
- (void)setNavigationBarWithImageKey:(NSString *)imageKey;

- (void)setNavigationBarWithImage:(UIImage *)image;

// 清空导航条的背景图片，使恢复到系统默认状态
- (void)clearNavigationBarImage;

@end
*/