//
//  WSPhotoView.h
//  WinSFA
//
//  Created by heju on 16/5/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
//=============================================================================================================================

#pragma mark - 照片视图
@interface WSPhotoView : UIView

@property (nonatomic, assign) UIViewContentMode contentMode;            //内容模式(针对imageView的contentMode)
@property (nonatomic, strong) UIImageView *imageView;                   //照片图片视图
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;   //活动指示器
@property (nonatomic, strong) NSString *imageID;                        //图片ID标识
@property (nonatomic, strong) NSString *urlStr;                         //图片url

- (void)showIndicatorView;  //显示活动指示器方法
- (void)hideIndicatorView;  //隐藏活动指示器方法

@end
//=============================================================================================================================
