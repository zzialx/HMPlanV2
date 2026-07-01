//
//  WCHImageDownLoading.h
//  ImageDownLoading
//
//  Created by xiaotang.wang on 9/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCHImageDownLoading;

@protocol WCHImageDownLoadingDelegate <NSObject>

@required

- (void)imageDownLoadingCompletion:(WCHImageDownLoading *)aImageDownLoading;
- (void)imageDownLoading:(WCHImageDownLoading *)aImageDownLoading FailureError:(NSError *)aError;

@optional
- (void)imageDownLoading:(WCHImageDownLoading *)aImageDownLoading 
              InProgress:(unsigned long long)aProgressSize 
               TotalSize:(unsigned long long) aTotalSize;

@end

@interface WCHImageDownLoading : NSObject

@property (nonatomic, copy)NSString *iImageURL;
@property (nonatomic, copy)NSString *iImageName;// Path
@property (nonatomic, weak)id<WCHImageDownLoadingDelegate> iDelegate;

// If has image return image , not return null
+ (UIImage *)hasDownLoadedImage:(NSString *)aImageURL;

- (id)initWithImageURL:(NSString *)aImageURL;

- (UIImage *)downloadingImage;

- (void)startAsyncDownLoading;
- (void)stopDownLoading;

- (BOOL)isRunning;

@end
