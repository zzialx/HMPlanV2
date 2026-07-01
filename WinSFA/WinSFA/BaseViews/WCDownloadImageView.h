//
//  WCDownloadImageView.h
//  ImageDownLoading
//
//  Created by xiaotang.wang on 9/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UiKit/UIKit.h>

@class WCDownloadImageView;

@protocol WCDownloadImageViewDelegate <NSObject>

@optional

- (void)downloadImageview:(WCDownloadImageView *)aImageView downloadImage:(UIImage *)aImage;

@end

@interface WCDownloadImageView : UIImageView

@property (nonatomic, copy)NSString *imageUrl;
@property (nonatomic, copy)NSString *iDownloadFailureImage;
@property (nonatomic, weak)id<WCDownloadImageViewDelegate> delegate;

- (void)startLoad;
- (void)cancelLoad;

@end
