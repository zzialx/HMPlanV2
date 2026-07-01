//
//  WCDownloadImageView.m
//  ImageDownLoading
//
//  Created by xiaotang.wang on 9/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WCDownloadImageView.h"
#import "MBProgressHUD.h"
#import "WCHImageDownLoading.h"
#import "UIImage+Resize.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"

#define WCHREQUESTCANCELERROR 4

@interface WCDownloadImageView()<UIScrollViewDelegate>

//@property (nonatomic, retain)WCHImageDownLoading *iImageDownloadHandler;
@property (nonatomic, strong)UIImage *iFullsizeImage;
@property (nonatomic, assign)BOOL bSuccessed;
@property (nonatomic, assign)unsigned long long downloadedSize;
//@property (nonatomic, retain)MBProgressHUD *iProgressHUD;
@property (nonatomic, strong)UIScrollView *iShowImageView;
@property (nonatomic, strong)UIImageView *iImageView;


@end

@implementation WCDownloadImageView

@synthesize imageUrl = _imageUrl;
@synthesize iFullsizeImage = _iFullsizeImage;
@synthesize bSuccessed = _bSuccessed;
@synthesize downloadedSize = _downloadedSize;
@synthesize iDownloadFailureImage = _iDownloadFailureImage;
@synthesize delegate = _delegate;
@synthesize iShowImageView = _iShowImageView;
@synthesize iImageView = _iImageView;

#pragma mark - init and dealloc
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSetup];
    }
    return self;
}

- (void)initSetup {
    self.userInteractionEnabled = YES;
    self.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    [self addGestureRecognizer:singleTap];
    self.bSuccessed = YES;
}

- (void)dealloc
{
    self.delegate = nil;
}

- (void)setImageUrl:(NSString *)imageUrl
{
    if (_imageUrl != imageUrl) {
        _imageUrl = [imageUrl copy];
        [self startLoad];
    }
}

#pragma mark - Gesture method

//UIImageView *fullsizeImageView = nil;
- (void)singleTapAction:(UIGestureRecognizer *)aGestureRecognizer {
    if (!self.image) {
        return;
    }
    
    if (!self.bSuccessed) {
        self.image = nil;
        // delay 1 sec, so that even without network, there should be some screen change so that user knows the image will reload
        [self performSelector:@selector(startLoad) withObject:nil afterDelay:1];
        return;
    }
    
//    CGRect showimageRect = [[UIScreen mainScreen] applicationFrame];
    UIWindow *wc = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView* rootView= wc.rootViewController.view;
    self.iShowImageView = [[UIScrollView alloc] initWithFrame:rootView.bounds];
    self.iShowImageView.delegate = self;
    self.iShowImageView.maximumZoomScale = 2.0;
    self.iShowImageView.minimumZoomScale = 0.5;
    self.iShowImageView.multipleTouchEnabled = YES;
    self.iShowImageView.bounces = YES;
    self.iShowImageView.contentSize = rootView.frame.size;
    self.iShowImageView.backgroundColor = [UIColor blackColor];
    [rootView addSubview:self.iShowImageView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullSizeViewTap:)];
    [self.iShowImageView addGestureRecognizer:singleTap];
    
    self.iImageView = [[UIImageView alloc] initWithImage:self.iFullsizeImage];
    self.iImageView.userInteractionEnabled = YES;
    
    CGRect mainRect = self.iShowImageView.bounds;
    CGRect imageframe = self.iImageView.frame;
    if (imageframe.size.width < mainRect.size.width) {
        imageframe.origin.x = (mainRect.size.width - imageframe.size.width)/2.0;
    }else{
        imageframe.origin.x = 0;
        float scale = mainRect.size.width / imageframe.size.width;
        imageframe.size.width *= scale;
        imageframe.size.height *= scale;
    }
    
    if (imageframe.size.height < mainRect.size.height) {
        imageframe.origin.y = (mainRect.size.height - imageframe.size.height) / 2.0;
    }else{
        imageframe.origin.y = 0;
        float scale = mainRect.size.height / imageframe.size.height;
        imageframe.size.height *= scale;
        imageframe.size.width *= scale;
    }
    self.iImageView.frame = imageframe;
    
    [self.iShowImageView addSubview:self.iImageView];
    
    self.iShowImageView.alpha = 0.f;
    [UIView animateWithDuration:0.5 animations:^{
        self.iShowImageView.alpha = 1.f;
        self.alpha = 0.f;
    }];
    
}

- (void)fullSizeViewTap:(UIGestureRecognizer *)aGestureRecognizer {
    [UIView animateWithDuration:0.5 animations:^{
        self.iShowImageView.alpha = 0.f;
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        [self.iShowImageView removeFromSuperview];
        self.iShowImageView = nil;
        self.iImageView = nil;
    }];
}


#pragma - UIScrollView delegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    float offsetX = (self.iShowImageView.bounds.size.width > self.iShowImageView.contentSize.width) ?
    (self.iShowImageView.bounds.size.width - self.iShowImageView.contentSize.width)/2 : 0.0;
    
    float offsetY = (self.iShowImageView.bounds.size.height > self.iShowImageView.contentSize.height) ?
    (self.iShowImageView.bounds.size.height - self.iShowImageView.contentSize.height)/2 : 0.0;
    
    self.iImageView.center = CGPointMake(self.iShowImageView.contentSize.width/2+offsetX, self.iShowImageView.contentSize.height/2 + offsetY);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;
{
    return self.iImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}

#pragma mark - public method

- (void)startLoad
{
    if (self.imageUrl == nil || [self.imageUrl length] == 0 ) return;
    
    // setting HUD
    self.image = nil;
    // start downloading image
    self.bSuccessed = NO;
    __weak WCDownloadImageView *imageViewSelf = self;
    NSURL *url = [NSURL URLWithString:self.imageUrl];
    UIImage *defaultImage = [UIImage imageNamed:@"downloadimage_failed.png"];
    
    [self sd_setImageWithURL:url placeholderImage:defaultImage options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (error.code != 0) {
            
            imageViewSelf.image = (imageViewSelf.iDownloadFailureImage != nil && [imageViewSelf.iDownloadFailureImage length] > 0 ) ? [UIImage imageNamed:imageViewSelf.iDownloadFailureImage] : [UIImage imageNamed:@"downloadimage_failed.png"];
            
        }else{
            
            imageViewSelf.iFullsizeImage = image;
            if (imageViewSelf.delegate != nil && [imageViewSelf.delegate respondsToSelector:@selector(downloadImageview:downloadImage:)]) {
                [imageViewSelf.delegate performSelector:@selector(downloadImageview:downloadImage:) withObject:imageViewSelf withObject:imageViewSelf.iFullsizeImage];
            }
            
            imageViewSelf.image = [imageViewSelf.iFullsizeImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:imageViewSelf.bounds.size interpolationQuality:kCGInterpolationDefault];
            
            if (imageViewSelf.image == nil) {
                imageViewSelf.image = imageViewSelf.iFullsizeImage;
            }
            imageViewSelf.bSuccessed = YES;
        }
        
    }];
    
}

- (void)cancelLoad
{    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self sd_cancelCurrentImageLoad];
}

@end
