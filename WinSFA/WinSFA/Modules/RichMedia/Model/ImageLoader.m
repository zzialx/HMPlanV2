//
//  ImageLoader.m
//
//  Created by Kirill Shashkov on 12/2/11.
//  Copyright (c) 2011 IntexSoft LLC. All rights reserved.
//

#import "ImageLoader.h"
#import "UIImage+Resize.m"

@implementation ImageLoader

static int instanceCount = 0;

- (id)init {
    if (self = [super init]) {
        imagesCache = [[NSCache alloc] init];
        
        loadingQueue = dispatch_queue_create([[NSString stringWithFormat:@"com.github.kirillsh.imageLoader[%d]", instanceCount++] UTF8String], NULL);
    }
    return self;
}

- (void)displayImage:(NSString *)imagePath inImageView:(UIImageView *)imageView {    
    [self displayImage:imagePath inSize:imageView.bounds.size contentMode:imageView.contentMode callbackTarget:imageView callbackSelector:@selector(setImage:)];    
}

- (void)displayImage:(NSString *)imagePath inSize:(CGSize)size contentMode:(UIViewContentMode)contentMode callbackTarget:(id)target callbackSelector:(SEL)selector {
    UIImage *imageFromCache = [imagesCache objectForKey:imagePath];
    
    if (!imageFromCache) {
        dispatch_async(loadingQueue, ^{
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            
            if (!image) {
                return;
            }
            
            [imagesCache setObject:image forKey:imagePath];
            
            UIImage *resizedImage = [image resizedImageWithContentMode:contentMode bounds:size interpolationQuality:kCGInterpolationHigh];
            
            dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [target performSelector:selector withObject:resizedImage];
#pragma clang diagnostic pop
            });
        });
    } else {
        dispatch_async(loadingQueue, ^{
            UIImage *resizedImage = [imageFromCache resizedImageWithContentMode:contentMode bounds:size interpolationQuality:kCGInterpolationHigh];
            
            dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [target performSelector:selector withObject:resizedImage];
#pragma clang diagnostic pop
            });
        });
    }
}

@end
