//
//  WCDownLoadingAndShowingImageView.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 7/15/13.
//
//

#import "WCDownLoadingAndShowingImageView.h"
#import "WCDownloadImageView.h"
#import "WCHImageDownLoading.h"
#import "MBProgressHUD.h"
#import "UIImage+Resize.h"
#import "JFTakeCountButton.h"
#import "WSRequestHelper.h"

@interface WCDownLoadingAndShowingImageView()<WCHImageDownLoadingDelegate, UIScrollViewDelegate>

@property (nonatomic, copy)NSString *iImageURL;
@property (nonatomic, strong)WCDownloadImageView *iFetchingImageView;
@property (nonatomic, assign)BOOL bSuccessed;
@property (nonatomic, strong)UIImage *iFullsizeImage;
@property (nonatomic, strong)WCHImageDownLoading *iImageDownloadHandler;
@property (nonatomic, strong)MBProgressHUD *iProgressHUD;
@property (nonatomic, assign)unsigned long long downloadedSize;
@property (nonatomic, strong)UIImageView *iImageView;
@property (nonatomic, strong)UIScrollView *iScrollView;
@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)JFTakeCountButton  *durationButton;


@end

@implementation WCDownLoadingAndShowingImageView

@synthesize iImageURL = _iImageURL;
@synthesize iFetchingImageView = _iFetchingImageView;
@synthesize bSuccessed = _bSuccessed;
@synthesize iFullsizeImage = _iFullsizeImage;
@synthesize iImageDownloadHandler = _iImageDownloadHandler;
@synthesize downloadedSize = _downloadedSize;
@synthesize iImageView = _iImageView;
@synthesize iScrollView = _iScrollView;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withImageURL:(NSString *)aUrl withImage:(UIImage*)image withDuration:(int)duration withProductName:(NSString *)name
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        self.removeOnTouch = YES;
        self.refreshLoadingOnTouch = NO;
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scrollView.delegate = self;
        scrollView.maximumZoomScale = 2.0;
        scrollView.minimumZoomScale = 0.5;
        scrollView.multipleTouchEnabled = YES;
        scrollView.bounces = YES;
        scrollView.contentSize = frame.size;
        scrollView.backgroundColor = [UIColor clearColor];
        self.iScrollView = scrollView;
        [self addSubview:scrollView];
        
        if (name != nil && [name length] > 0) {
            UIFont *font = [UIFont boldSystemFontOfSize:18.0];
            CGFloat width = 250.0;
            CGSize stringSize = [name ws_sizeWithFont:font constrainedToWidth:width];

            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width - width)/2, 40, width, stringSize.height)];
            label.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.7];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            label.text = name;
            label.font = font;
            label.shadowColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.8];
            label.shadowOffset = CGSizeMake(1.0, 1.0);
            label.layer.cornerRadius = 5.0;
            label.numberOfLines = 0;
            self.nameLabel = label;
            [self addSubview:self.nameLabel];
        }
        
        if (image) {
            self.iImageView = [[UIImageView alloc] initWithImage:image];
            
            self.iImageView.userInteractionEnabled = YES;
            CGRect mainRect = self.iScrollView.bounds;
            CGRect imageframe = self.iImageView.frame;
            if (imageframe.size.width < mainRect.size.width) {
                imageframe.origin.x = (mainRect.size.width - imageframe.size.width)/2.0;
            }else{
                imageframe.origin.x =  0;
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
                //
                if (imageframe.size.width < mainRect.size.width) {
                    imageframe.origin.x = (mainRect.size.width - imageframe.size.width) / 2.0;
                }
            }
            self.iImageView.frame = imageframe;
            
            [self.iScrollView addSubview:self.iImageView];
        }else {
            self.iImageURL = aUrl;
            self.bSuccessed = YES;
            [self startLoad];
        }
        
        if (duration > 0) {
            UIColor *navBarButtonTitleColor = [UIColor colorForKey:@"NavigationBarButtonTitleColor"];
            if (!navBarButtonTitleColor) {
                navBarButtonTitleColor = [UIColor colorWithRed:63.0/255.0 green:175.0/255.0 blue:246.0/255.0 alpha:1.0];
            }
            self.durationButton = [JFTakeCountButton initWithCount:duration
                                                         withTitle:nil
                                                    withTitleColor:navBarButtonTitleColor
                                                     withTitleFont:[UIFont boldSystemFontOfSize:30.0f]
                                                         withBlock:^{
                                                             if ([_delegate respondsToSelector:@selector(touchShowImageViewEnd:)]) {
                                                                 [_delegate touchShowImageViewEnd:self];
                                                             }
                                                         }];
            [self.durationButton startTakeCount];
            [self.durationButton setFrame:CGRectMake(0, 20, 60, 60)];
            [self addSubview:self.durationButton];
        }else {
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
            [self addGestureRecognizer:singleTap];
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withImageURL:(NSString *)aUrl withProductName:(NSString *)name
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        self.iImageURL = aUrl;
        
        self.removeOnTouch = YES;
        self.refreshLoadingOnTouch = NO;
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scrollView.delegate = self;
        scrollView.maximumZoomScale = 2.0;
        scrollView.minimumZoomScale = 0.5;
        scrollView.multipleTouchEnabled = YES;
        scrollView.bounces = YES;
        scrollView.contentSize = frame.size;
        scrollView.backgroundColor = [UIColor clearColor];
        self.iScrollView = scrollView;
        [self addSubview:scrollView];
        
        if (name != nil && [name length] > 0) {
            UIFont *font = [UIFont boldSystemFontOfSize:18.0];
            CGFloat width = 250.0;
            CGSize stringSize = [name ws_sizeWithFont:font constrainedToWidth:width];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width - width)/2, 40, width, stringSize.height)];
            label.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.7];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            label.text = name;
            label.font = font;
            label.shadowColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.8];
            label.shadowOffset = CGSizeMake(1.0, 1.0);
            label.layer.cornerRadius = 5.0;
            label.numberOfLines = 0;
            self.nameLabel = label;
            [self addSubview:self.nameLabel];
        }
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
        [self addGestureRecognizer:singleTap];
        self.bSuccessed = YES;
        
        [self startLoad];
        
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.closeButton setFrame:CGRectMake((self.bounds.size.width - 80) / 2.0, self.bounds.size.height - 80 - 10., 80, 80)];
        [self.closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(closeImageview:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeButton];
    }
    return self;
}

- (void) closeImageview:(id)sender
{
    if ([self superview]) {
        [self removeFromSuperview];
    }
}

- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.removeOnTouch = YES;
        self.refreshLoadingOnTouch = NO;
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scrollView.delegate = self;
        scrollView.maximumZoomScale = 3.0;
        scrollView.minimumZoomScale = 1.0;
        scrollView.multipleTouchEnabled = YES;
        scrollView.bounces = YES;
        scrollView.contentSize = frame.size;
        scrollView.backgroundColor = [UIColor clearColor];
        self.iScrollView = scrollView;
        [self addSubview:scrollView];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
        [self addGestureRecognizer:singleTap];
        
        // 压缩导致图片放大后模糊
        /*
        UIImage *showImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:self.bounds.size interpolationQuality:kCGInterpolationDefault];
        if (showImage) {
            self.iImageView = [[UIImageView alloc] initWithImage:showImage];
        }else{
            self.iImageView = [[UIImageView alloc] initWithImage:image];
        }
        */
        self.iImageView = [[UIImageView alloc] initWithImage:image];
        
        self.iImageView.userInteractionEnabled = YES;
        CGRect mainRect = self.iScrollView.bounds;
        CGRect imageframe = self.iImageView.frame;
        if (imageframe.size.width < mainRect.size.width) {
            imageframe.origin.x = (mainRect.size.width - imageframe.size.width)/2.0;
        }else{
            imageframe.origin.x =  0;
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
            //
            if (imageframe.size.width < mainRect.size.width) {
                imageframe.origin.x = (mainRect.size.width - imageframe.size.width) / 2.0;
            }
        }
        self.iImageView.frame = imageframe;
        
        [self.iScrollView addSubview:self.iImageView];
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.closeButton setFrame:CGRectMake((self.bounds.size.width - 80) / 2.0, self.bounds.size.height - 80 - 10., 80, 80)];
        [self.closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(closeImageview:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeButton];
    }
    return self;
}

- (WCHImageDownLoading *)iImageDownloadHandler
{
    if (!_iImageDownloadHandler) {
        _iImageDownloadHandler = [[WCHImageDownLoading alloc] initWithImageURL:_iImageURL];
        _iImageDownloadHandler.iDelegate = self;
    }
    return _iImageDownloadHandler;
}

- (void)dealloc
{
    [self cancelLoad];
}

- (void)singleTapAction:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (self.removeOnTouch) {
            [self cancelLoad];
            /*
            [self removeFromSuperview];
             */
            if ([_delegate respondsToSelector:@selector(touchShowImageViewEnd:)]) {
                [_delegate touchShowImageViewEnd:self];
            }
        }
        
        if (self.refreshLoadingOnTouch) {
            if ([self.iImageDownloadHandler isRunning])
                return;
            
            if (self.iImageView) {
                [self.iImageView removeFromSuperview];
                self.iImageView = nil;
            }
            
            if (self.iProgressHUD) {
                [self.iProgressHUD removeFromSuperview];
            }
            
            MBProgressHUD *hubView = [[MBProgressHUD alloc] initWithView:self];
            [hubView setMode:MBProgressHUDModeDeterminate];
            [hubView setOpacity:0.2f];
            [hubView show:YES];
            self.iProgressHUD = hubView;
            [self addSubview:hubView];
            
            self.iImageDownloadHandler.iImageURL = self.iImageURL;
            [self.iImageDownloadHandler startAsyncDownLoading];
            self.bSuccessed = NO;
        }
        
    }
}

- (void)startLoad
{
    if (!(self.iImageURL) || ![self.iImageURL length]) return;
    
    self.iImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    MBProgressHUD *hubView = [[MBProgressHUD alloc] initWithView:self];
    [hubView setMode:MBProgressHUDModeDeterminate];
    [hubView setOpacity:0.2f];
    [hubView show:YES];
    self.iProgressHUD = hubView;
    [self addSubview:hubView];
    
    [[WSRequestHelper shareInstance] downloadImageWithUrl:self.iImageURL imageView:self.iImageView placeholderImage:nil progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        self.iProgressHUD.progress = (float)receivedSize / (float)expectedSize;
    } completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
    
        if (self.iProgressHUD) {
            [self.iProgressHUD removeFromSuperview];
            self.iProgressHUD = nil;
        }
        
        if (error) {
            
            if (self.iImageView) {
                [self.iImageView removeFromSuperview];
                self.iImageView = nil;
            }
            
            UIImage *errorimage = [UIImage imageNamed:@"picture_loading_failed"];
            self.iImageView = [[UIImageView alloc] initWithImage:errorimage];
            self.iImageView.userInteractionEnabled = NO;
            CGRect mainRect = self.iScrollView.bounds;
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
            [self.iScrollView addSubview:self.iImageView];
            return;
        }
        self.iFullsizeImage = image;
        UIImage *newImage = [self.iFullsizeImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:self.bounds.size interpolationQuality:kCGInterpolationDefault];
        
        if (!newImage) {
            self.iImageView = [[UIImageView alloc] initWithImage:newImage];
        }else{
            self.iImageView = [[UIImageView alloc] initWithImage:self.iFullsizeImage];
        }
        self.bSuccessed = YES;
        
        self.iImageView.userInteractionEnabled = YES;
        CGRect mainRect = self.iScrollView.bounds;
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
        imageframe.origin.x = (mainRect.size.width - imageframe.size.width)/2.0;
        imageframe.origin.y = (mainRect.size.height - imageframe.size.height)/2.0;
        self.iImageView.frame = imageframe;
        
        [self.iScrollView addSubview:self.iImageView];
    }];
    
    /*
    UIImage *image = [WCHImageDownLoading hasDownLoadedImage:self.iImageURL];
    if (image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.refreshLoadingOnTouch = NO;
        });
        
        self.iFullsizeImage = image;
        UIImage *image = [self.iFullsizeImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:self.bounds.size interpolationQuality:kCGInterpolationDefault];
        
        if (!image) {
            self.iImageView = [[UIImageView alloc] initWithImage:image];
        }else{
            self.iImageView = [[UIImageView alloc] initWithImage:self.iFullsizeImage];
        }
        self.bSuccessed = YES;
        
        self.iImageView.userInteractionEnabled = YES;
        CGRect mainRect = self.iScrollView.bounds;
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
        imageframe.origin.x = (mainRect.size.width - imageframe.size.width)/2.0;
        imageframe.origin.y = (mainRect.size.height - imageframe.size.height)/2.0;
        self.iImageView.frame = imageframe;
        
        [self.iScrollView addSubview:self.iImageView];

        return;
    }
    else {
        if ([self.iImageDownloadHandler isRunning])
            return;
        MBProgressHUD *hubView = [[MBProgressHUD alloc] initWithView:self];
        [hubView setMode:MBProgressHUDModeDeterminate];
        [hubView setOpacity:0.2f];
        [hubView show:YES];
        self.iProgressHUD = hubView;
        [self addSubview:hubView];
        
        self.iImageDownloadHandler.iImageURL = self.iImageURL;
        [self.iImageDownloadHandler startAsyncDownLoading];
        self.bSuccessed = NO;
    }
     */
}

- (void)cancelLoad
{
    if (_iImageDownloadHandler) {
        _iImageDownloadHandler.iDelegate = nil;
        [_iImageDownloadHandler stopDownLoading];
    }
}

- (void)disMissView:(id)sender
{
    [self.iFetchingImageView cancelLoad];
    [self removeFromSuperview];
}

#pragma mark - Class WCHImageDownLoading delegate

- (void)imageDownLoadingCompletion:(WCHImageDownLoading *)aImageDownLoading
{
    if (self.iProgressHUD) {
        [self.iProgressHUD removeFromSuperview];
        self.iProgressHUD = nil;
    }
    
    if (self.iImageView) {
        [self.iImageView removeFromSuperview];
        self.iImageView = nil;
    }
    
    self.refreshLoadingOnTouch = NO;
    self.iFullsizeImage  = [self.iImageDownloadHandler downloadingImage];
    
   UIImage *image = [self.iFullsizeImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:self.bounds.size interpolationQuality:kCGInterpolationDefault];
    if (image) {
        self.iImageView = [[UIImageView alloc] initWithImage:image];
    }else{
        self.iImageView = [[UIImageView alloc] initWithImage:self.iFullsizeImage];
    }
    self.bSuccessed = YES;
    
    self.iImageView.userInteractionEnabled = YES;
    CGRect mainRect = self.iScrollView.bounds;
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
    
    [self.iScrollView addSubview:self.iImageView];
}


- (void)imageDownLoading:(WCHImageDownLoading *)aImageDownLoading FailureError:(NSError *)aError
{
    if (self.iProgressHUD) {
        [self.iProgressHUD removeFromSuperview];
        self.iProgressHUD = nil;
    }
    
    //Cancel the request
    if (aError.code == 4) {
        return;
    }
    
    if (self.iImageView) {
        [self.iImageView removeFromSuperview];
        self.iImageView = nil;
    }
    
    UIImage *errorimage = [UIImage imageNamed:@"downloadimage_failed.png"];
    self.iImageView = [[UIImageView alloc] initWithImage:errorimage];    
    self.iImageView.userInteractionEnabled = NO;
    CGRect mainRect = self.iScrollView.bounds;
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
    [self.iScrollView addSubview:self.iImageView];
}

- (void)imageDownLoading:(WCHImageDownLoading *)aImageDownLoading
              InProgress:(unsigned long long)aProgressSize
               TotalSize:(unsigned long long) aTotalSize
{
    self.downloadedSize += aProgressSize;
    self.iProgressHUD.progress = (float)self.downloadedSize/aTotalSize;
}

#pragma - UIScrollView delegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    float offsetX = (self.iScrollView.bounds.size.width > self.iScrollView.contentSize.width) ?
    (self.iScrollView.bounds.size.width - self.iScrollView.contentSize.width)/2 : 0.0;
    
    float offsetY = (self.iScrollView.bounds.size.height > self.iScrollView.contentSize.height) ?
    (self.iScrollView.bounds.size.height - self.iScrollView.contentSize.height)/2 : 0.0;
    
    self.iImageView.center = CGPointMake(self.iScrollView.contentSize.width/2+offsetX, self.iScrollView.contentSize.height/2 + offsetY);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;
{
    return self.iImageView;
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}

- (void) setIsShowCloseButton:(BOOL)isShowCloseButton
{
    _isShowCloseButton = isShowCloseButton;
    self.closeButton.hidden = !_isShowCloseButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
