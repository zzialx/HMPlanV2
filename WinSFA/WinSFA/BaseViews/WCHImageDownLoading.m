//
//  WCHImageDownLoading.m
//  ImageDownLoading
//
//  Created by xiaotang.wang on 9/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WCHImageDownLoading.h"
#import "NSString+Hash.h"
#import "SDWebImageDownloaderOperation.h"

@interface WCHImageDownLoading()

typedef enum {
    ImageDownLoadingNormal,
    ImageDownLoadRunning
} WCHImageDownLoadingState;

@property (nonatomic, strong)SDWebImageDownloaderOperation *mSDWebImageDownloaderOperation;
@property (nonatomic, strong)UIImage *iImage;
@property (nonatomic, assign)WCHImageDownLoadingState iState;

@end

@implementation WCHImageDownLoading

@synthesize iImageURL = _iImageURL;
@synthesize iImageName = _iImageName;
@synthesize iDelegate = _iDelegate;
@synthesize iImage = _iImage;
@synthesize iState = _iState;

#pragma mark - init & dealloc

- (id)initWithImageURL:(NSString *)aImageURL
{
    self = [super init];
    if (self) {
        _iImageURL = [aImageURL copy];
        _iState = ImageDownLoadingNormal;
        return self;
    }
    return nil;
}

- (void)dealloc
{
    self.iImageURL = nil;
    self.iDelegate = nil;
    if (![self.mSDWebImageDownloaderOperation isFinished]) {
        [self.mSDWebImageDownloaderOperation cancel];
    }
      self.mSDWebImageDownloaderOperation = nil;
}

#pragma mark - public method

+ (UIImage *)hasDownLoadedImage:(NSString *)aImageURL
{
    if (!aImageURL || ![aImageURL length]) 
        return nil;
    
    UIImage *image = nil;
    NSString *cachePath = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
    
    if ([paths count]) {
        cachePath = [paths objectAtIndex:0];
    }
    cachePath = [cachePath stringByAppendingPathComponent:@"imageCaches"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:cachePath]) {
        return  nil;
    }
    
    NSString *hash = [aImageURL md5];
    NSString *file = [cachePath stringByAppendingPathComponent:hash];
    if ([fm fileExistsAtPath:file]) {
        image = [UIImage imageWithContentsOfFile:file];
        return image;
    }
    return nil;
}

- (void)startAsyncDownLoading
{
    if (self.iState == ImageDownLoadRunning)
    {
        NSLog(@"It is running");
        return;
    }
    
    if (!self.iImageURL || [self.iImageURL length] == 0) return;
    
    // Create request
    self.iImage = nil;
    NSURL *url = [NSURL URLWithString:self.iImageURL];
    self.iState = ImageDownLoadRunning;
    __weak __typeof(self) wself = self;
    self.mSDWebImageDownloaderOperation = [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if ([wself.iDelegate respondsToSelector:@selector(imageDownLoading:InProgress:TotalSize:)]) {
            [wself.iDelegate imageDownLoading:wself InProgress:receivedSize TotalSize:expectedSize];
        }
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        
        if (finished && image) {
            wself.iImage = image;
            wself.iState = ImageDownLoadingNormal;
            if ([wself.iDelegate respondsToSelector:@selector(imageDownLoadingCompletion:)]) {
                [wself.iDelegate imageDownLoadingCompletion:wself];
            }
        }else if (error){
            wself.iImage = nil;
            wself.iState = ImageDownLoadingNormal;
            if ([wself.iDelegate respondsToSelector:@selector(imageDownLoadingCompletion:)]) {
                [wself.iDelegate imageDownLoadingCompletion:wself];
            }
        }
    }];

}

- (void)setIImageURL:(NSString *)iImageURL
{
    if (_iImageURL != iImageURL) {
        _iImageURL = nil;
        _iImageURL = [iImageURL copy];
        self.iImage = nil;
    }
}

- (void)stopDownLoading
{
    if (![self.mSDWebImageDownloaderOperation isFinished]) {
        [self.mSDWebImageDownloaderOperation cancel];
    }
    self.mSDWebImageDownloaderOperation = nil;
    self.iState = ImageDownLoadingNormal;
}


- (UIImage *)downloadingImage
{
    if (self.iState == ImageDownLoadRunning) {
        return nil;
    }
    UIImage *image = nil;
    if (self.iImage) {
        image = [UIImage imageWithCGImage:[self.iImage CGImage]];
    }
    return image;
}

- (BOOL)isRunning
{
    return (self.iState == ImageDownLoadRunning);
}

@end
