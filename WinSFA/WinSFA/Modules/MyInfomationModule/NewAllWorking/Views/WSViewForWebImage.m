//
//  WSPhotoView.m
//  WinSFA
//
//  Created by admin on 16/1/26.
//  Copyright © 2016年 WinChannel. All rights reserved.
//



#import "WSViewForWebImage.h"
#import "WSRequestHelper.h"

@interface UIImage (VIUtil)

- (CGSize)sizeThatFits:(CGSize)size;

@end

@implementation UIImage (VIUtil)

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize imageSize = CGSizeMake(self.size.width / self.scale,
                                  self.size.height / self.scale);
    
    CGFloat widthRatio = imageSize.width / size.width;
    CGFloat heightRatio = imageSize.height / size.height;
    
    if (widthRatio > heightRatio) {
        imageSize = CGSizeMake(imageSize.width / widthRatio, imageSize.height / widthRatio);
    } else {
        imageSize = CGSizeMake(imageSize.width / heightRatio, imageSize.height / heightRatio);
    }
    
    return imageSize;
}

@end

@interface UIImageView (VIUtil)

- (CGSize)contentSize;

@end

@implementation UIImageView (VIUtil)

- (CGSize)contentSize
{
    return [self.image sizeThatFits:self.bounds.size];
}

@end

@interface WSViewForWebImage () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *containerView;


@property (nonatomic) BOOL rotating;
@property (nonatomic) CGSize minSize;

@end

@implementation WSViewForWebImage

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image andUrl:(NSURL *)imageUrl placeholderImage:(UIImage *)placeholderImage{

    if (!self) {
        self = [super initWithFrame:frame];
    }

    if (self) {
        self.delegate = self;
        self.bouncesZoom = YES;
        
        
        UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
        containerView.backgroundColor = [UIColor clearColor];
        [self addSubview:containerView];
        _containerView = containerView;
        
        // 添加图片
        
        UIImageView *imageView = [[UIImageView alloc] init];
        
        if (image) {
            imageView.image = image;
        }else if (imageUrl){
            /******网络返回的的图片用SD进行图片加载******/
            [[WSRequestHelper shareInstance] downloadImageWithUrl:[imageUrl absoluteString] imageView:imageView placeholderImage:placeholderImage   completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
                UIImage * realImage;
                if (!error) {
                    realImage = image;
                }else{ // 如果下载失败的话 应该设置占位图
                    realImage = placeholderImage;
                    imageView.image = placeholderImage;
                }
                // 图像适配屏幕大小
                CGSize bounsSize = [realImage sizeThatFits:self.bounds.size];
                self.containerView.frame = CGRectMake(0, 0, bounsSize.width, bounsSize.height);
                imageView.bounds = CGRectMake(0, 0, bounsSize.width, bounsSize.height);
                imageView.center = CGPointMake(bounsSize.width / 2, bounsSize.height / 2);
                
                self.contentSize = bounsSize;
                self.minSize = CGSizeMake(bounsSize.width , bounsSize.height);
                 [self setMaxMinZoomScale];
               // 中心位置
                [self centerContent];
            }];
        }else if (placeholderImage){
            imageView.image = placeholderImage;
        }
        imageView.frame = containerView.bounds;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [containerView addSubview:imageView];
        _imageView = imageView;
        
        // 图像适配屏幕大小
        CGSize imageSize = imageView.contentSize;
        self.containerView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        imageView.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
        imageView.center = CGPointMake(imageSize.width / 2, imageSize.height / 2);
        
        self.contentSize = imageSize;
        self.minSize = CGSizeMake(imageSize.width , imageSize.height);
        
        
        [self setMaxMinZoomScale];
        
        // 中心位置
        [self centerContent];
        
        // 添加手势等
        [self setupGestureRecognizer];
        [self setupRotationNotification];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image andUrl:(NSURL *)imageUrl
{
    return [self initWithFrame:frame andImage:image andUrl:imageUrl placeholderImage:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.rotating) {
        self.rotating = NO;
        
        // 更新图片frame
        CGSize containerSize = self.containerView.frame.size;
        BOOL containerSmallerThanSelf = (containerSize.width < CGRectGetWidth(self.bounds)) && (containerSize.height < CGRectGetHeight(self.bounds));
        
        CGSize imageSize = [self.imageView.image sizeThatFits:self.bounds.size];
        CGFloat minZoomScale = imageSize.width / self.minSize.width;
        self.minimumZoomScale = minZoomScale;
        if (containerSmallerThanSelf || self.zoomScale == self.minimumZoomScale) { // 宽度或高度 都小于 self 的宽度和高度
            self.zoomScale = minZoomScale;
        }
        
        
        [self centerContent];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup

- (void)setupRotationNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)setupGestureRecognizer
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [_containerView addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerContent];
}

#pragma mark - GestureRecognizer

- (void)tapHandler:(UITapGestureRecognizer *)recognizer
{
    if (self.zoomScale > self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else if (self.zoomScale < self.maximumZoomScale) {
        CGPoint location = [recognizer locationInView:recognizer.view];
        CGRect zoomToRect = CGRectMake(0, 0, 50, 50);
        zoomToRect.origin = CGPointMake(location.x - CGRectGetWidth(zoomToRect)/2, location.y - CGRectGetHeight(zoomToRect)/2);
        [self zoomToRect:zoomToRect animated:YES];
    }
}

#pragma mark - Notification

- (void)orientationChanged:(NSNotification *)notification
{
    self.rotating = YES;
}

#pragma mark - Helper

- (void)setMaxMinZoomScale
{
    CGSize imageSize = self.imageView.image.size;
    CGSize imagePresentationSize = self.imageView.contentSize;
    CGFloat maxScale = MAX(imageSize.height / imagePresentationSize.height, imageSize.width / imagePresentationSize.width);
    self.maximumZoomScale = MAX(1,2 * maxScale); // 不能小于1
    self.minimumZoomScale = 1;
}

- (void)centerContent
{
    CGRect frame = self.containerView.frame;
    
    CGFloat top = 0, left = 0;
    if (self.contentSize.width < self.bounds.size.width) {
        left = (self.bounds.size.width - self.contentSize.width) * 0.5f;
    }
    if (self.contentSize.height < self.bounds.size.height) {
        top = (self.bounds.size.height - self.contentSize.height) * 0.5f;
    }
    
    top -= frame.origin.y;
    left -= frame.origin.x;
    
    self.contentInset = UIEdgeInsetsMake(top, left, top, left);
}

@end
