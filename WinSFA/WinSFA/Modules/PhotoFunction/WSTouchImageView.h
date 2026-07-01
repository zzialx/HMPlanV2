//
//  TouchImageView.h
//  PhotoBrowserTest
//
//  Created by Jiepeng Zheng on 12-8-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSTouchImageView;

@protocol ImageViewDeleagte <NSObject>

@optional

- (void)imageTouch:(WSTouchImageView *)imageView;

@end

@interface WSTouchImageView : UIImageView

@property (nonatomic, copy) NSString *imageID;
@property (nonatomic, weak) id<ImageViewDeleagte> delegate;

@end
