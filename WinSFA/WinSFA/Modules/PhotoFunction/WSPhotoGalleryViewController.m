//
//  ViewController.m
//  PhotoBrowserTest
//
//  Created by Jiepeng Zheng on 12-8-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSPhotoGalleryViewController.h"
#import "WSTouchImageView.h"
#import "WSPhotoBrowserViewController.h"
#import <SDImageCache.h>
#import "WSJSONBuilder.h"
#import "WSCurrentTime.h"
#import "WSImagePickerController.h"
#import "WSInterAction.h"
#import "WidgetConstant.h"
#import "WSEnvrionment.h"
#import "UIView+Additions.h"
#import "WSCameraAuthHelper.h"

#define kColNum ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 3 : 4)
#define kImageViewGap (INTERFACE_IS_PAD ? 20.0f : 10.0f)



@interface WSPhotoGalleryViewController ()<WSImagePickerControllerDelegate>
{
    CGPoint scrollOffset;
    UILabel *countLabel;
}

@property (nonatomic, strong) UIImagePickerController *mImagePicker;
@property (nonatomic, strong) UIPopoverController *popController;
@property (nonatomic, weak) WSImagePickerController *imagePickerController;

@end

@interface WSPhotoGalleryViewController (Tools)

#pragma mark - 处理图片方法
- (UIImage *)changeImageOrientationWithDeviceOrientation:(UIDeviceOrientation)deviceOrientation withISCaptureDevicePositionFront:(BOOL)isCaptureDevicePositionFront
                                               withImage:(UIImage *)img;

#pragma mark - 完成图片方法
- (void)didFinishPickingImage:(UIImage *)image;

#pragma mark - 获取图片压缩比方法
- (NSNumber *)getImageCompress;

#pragma mark - 获取图片宽度方法
- (NSNumber *)getImageShootWidth;

@end

@implementation WSPhotoGalleryViewController

@synthesize imageIDArray = _imageIDArray;
@synthesize scrollView = _scrollView;
@synthesize delegate;


#pragma mark init & dealloc

- (id)initWithImageIDArray:(NSMutableArray *)aImageIDArray
{
    self = [super init];
    if (self)
    {
        _imageIDArray = aImageIDArray;
    }
    return self;
}



#pragma mark viewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.executeParam.execute_class_param isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dic = (NSDictionary *)self.executeParam.execute_class_param;
        
        _imageIDArray = (NSMutableArray *)[dic objectForKey:@"photoIDArray"];
        _maxPhotoCount = [[dic objectForKey:@"maxPhotoCount"] integerValue];
        _imagePickerControllerSourceType = [[dic objectForKey:@"imagePickerControllerSourceType"] integerValue];
        self.storeName = [dic objectForKey:@"storeName"];
    }
    
    if (_imagePickerControllerSourceType == 0 || _imagePickerControllerSourceType == 2) {
        _imagePickerControllerSourceType = UIImagePickerControllerSourceTypeCamera;
    }else if (_imagePickerControllerSourceType == 1) {
        _imagePickerControllerSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }else if (_imagePickerControllerSourceType == 3) {
        _imagePickerControllerSourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (!self.title) {
        self.title= NSLocalizedString(@"photo_preview", nil);
    }
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(makePhoto:)];
    self.navigationItem.rightBarButtonItem = item;
    
    NSNumber *isUseSystemCamera = [[NSUserDefaults standardUserDefaults] objectForKey:USE_SYSTEM_CAMERA];
    
    if (isUseSystemCamera && [isUseSystemCamera boolValue] == YES) {
        
        _mImagePicker = [[UIImagePickerController alloc] init];
        _mImagePicker.delegate = self;
        
#if TARGET_IPHONE_SIMULATOR
        _mImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#elif TARGET_OS_IPHONE
//        _mImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        _mImagePicker.showsCameraControls = YES;
        _mImagePicker.sourceType = _imagePickerControllerSourceType;
#endif
//        _mImagePicker.wantsFullScreenLayout = YES;
    }
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44 - 20)];
    countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width, 50)];
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.textColor = [UIColor grayColor];
    countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"photo_count", nil), [_imageIDArray count]];
    
    [_scrollView addSubview:countLabel];
    
    if (self.imageIDArray.count == 0) {
        [self makePhoto:nil];
    }
}

- (void)makePhoto:(id)sender
{
    WSCameraAuthHelper *authHelper = [[WSCameraAuthHelper alloc] init];
    [authHelper authCameraWithBlock:^(BOOL isOK) {
        if (isOK) {
            [self showCamera];
        }
    }];
}

- (void)showCamera {

    if (_maxPhotoCount > 0 && [_imageIDArray count] >= _maxPhotoCount) {
    
        NSString *msg= [NSString stringWithFormat:@"%@%ld%@", NSLocalizedString(@"camera_max_capture_hint1", nil), _maxPhotoCount, NSLocalizedString(@"camera_max_capture_hint2", nil)];
       
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];

        LogInfo(@"拍照数量达到上限：%ld", (long)_maxPhotoCount);
        
        return;
    }
    
//    NSNumber *isUseSystemCamera = [[NSUserDefaults standardUserDefaults] objectForKey:USE_SYSTEM_CAMERA];
    NSNumber *isUseSystemCamera;
#if TARGET_IPHONE_SIMULATOR
    isUseSystemCamera = @YES;
#else
    isUseSystemCamera = @NO;
#endif
    
    if (isUseSystemCamera && [isUseSystemCamera boolValue] == YES) {
        UIImagePickerControllerSourceType sourceType; //= UIImagePickerControllerSourceTypePhotoLibrary;
#if TARGET_IPHONE_SIMULATOR
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#elif TARGET_OS_IPHONE
        sourceType = _imagePickerControllerSourceType;
#endif
        if([UIImagePickerController isSourceTypeAvailable:sourceType]){
            
            if(INTERFACE_IS_PAD && sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
                
                UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:self.mImagePicker];
                self.popController = popover;
                
                [popover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            } else {
                self.mImagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:self.mImagePicker animated:YES completion:^{
                    
                }];
            }
            
        }
    }
    else
    {
        WSImagePickerController *imagePick =  [[WSImagePickerController alloc] init];
        self.imagePickerController = imagePick;
        self.imagePickerController.delegate = self;
        NSString *image_watermark = [NSString stringWithValue:[[NSUserDefaults standardUserDefaults] objectForKey:IMAGE_WATERMARK]];
        if ([image_watermark isEqualToString:@"1"]) {
            CGRect overlayFrame = [self.imagePickerController getPreControlFrame];
            WSWatermarkOverlayView *overlayView = [[WSWatermarkOverlayView alloc] initWithFrame:overlayFrame];
            [self setOverlayViewValue:overlayView];
            self.imagePickerController.cameraOverlayView = overlayView;
        }
        
        if (self.imagePickerController) {
            self.imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:self.imagePickerController animated:YES completion:nil];
            
        }
    }

    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __weak typeof (self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *newImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        [weakSelf didFinishPickingImage:newImage];
    }];

}

- (UIImage *)getOldStyleWaterMarkImage:(UIImage *)image width:(CGFloat)width height:(CGFloat)height {
    UIImage *newImage = [UIImage addTextsAndScaleImage:image scaleToSize:CGSizeMake(floor(width), floor(height)) time:[WSCurrentTime getShortTimeString] date:[WSCurrentTime getLocalizedWeekAndDateString] empName:nil storeName:self.storeName storeAddr:nil];
    return newImage;
}

- (UIImage *)getNewStyleWaterMarkImage:(UIImage *)image width:(CGFloat)width height:(CGFloat)height {
    NSNumber *isUseSystemCamera = [[NSUserDefaults standardUserDefaults] objectForKey:USE_SYSTEM_CAMERA];
    if (isUseSystemCamera && [isUseSystemCamera boolValue] == YES) {
        CGRect overlayFrame = CGRectMake(0, 0, width, height);
        WSWatermarkOverlayView *overlayView = [[WSWatermarkOverlayView alloc] initWithFrame:overlayFrame];
        [self setOverlayViewValue:overlayView];
        
        UIImage *waterMarkImg = [overlayView convertViewToImage];
        UIImage * newImage = [UIImage mergeImage:waterMarkImg toImage:image width:width height:height];
        return newImage;
    } else {
        return image;
    }
}

-(void)imageSaveSuccess:(NSNotification*)aNot
{
    LogTrace();
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SDImageSaveSuccess object:nil];
    
    NSArray* array=(NSArray*)aNot.object;
    NSString* imageID=[array objectAtIndex:1];
    
    [_imageIDArray addObject:imageID];
    
    [self reloadImageViews];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoGallery:addImage:)]) {
        [self.delegate performSelector:@selector(photoGallery:addImage:) withObject:self withObject:imageID];
    }
}

-(void)reloadImageViews
{
    LogTrace();
    countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"photo_count", nil), [_imageIDArray count]];

    
    if (self.delegate && [self.delegate respondsToSelector:@selector(updatePhotoData:)])
    {
        [self.delegate updatePhotoData:_imageIDArray];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(updatePhotoData:photoArray:)]) {
        [self.delegate performSelector:@selector(updatePhotoData:photoArray:) withObject:self withObject:_imageIDArray];
    }
    
    if (_imageIDArray != nil)
    {
        NSInteger num = 0;
        /*  显示照片 宽度
         */
        float width = (self.view.bounds.size.width - (kColNum + 1) * kImageViewGap) / kColNum;
        /*  计算显示照片 高度
         *  默认 与 宽度 一致
         */
        float height = width;
        for (NSString *imageId in _imageIDArray) {
            if ([imageId length] == 0) {
                [_imageIDArray removeObject:imageId];
            }
        }
        if ([_imageIDArray count] != 0) {
            NSString *imageID = [_imageIDArray objectAtIndex:0];
            UIImage *image = [[SDImageCache sharedImageCache] imageFromKey:imageID fromDisk:YES];
            if (image) {
                height = (width / image.size.width) * image.size.height;
            }
        }
        
        for (NSString *imageID in _imageIDArray)
        {
            WSTouchImageView *imageView = [[WSTouchImageView alloc] initWithFrame:CGRectMake(kImageViewGap + (num % kColNum) * (width + kImageViewGap), kImageViewGap + (num / kColNum) * (height + kImageViewGap), width, height)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            UIImage *image = [[SDImageCache sharedImageCache] imageFromKey:imageID fromDisk:YES];
            [imageView setImage:image];
            [imageView setImageID:imageID];
            imageView.userInteractionEnabled = YES;
            imageView.delegate = self;
            
            [_scrollView addSubview:imageView];
            
            _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, kImageViewGap + ((num / kColNum) + 1) * (height + kImageViewGap));
            num++;
        }
        
        if ([_imageIDArray count] == 0)
        {
            countLabel.frame = CGRectMake(0, 10, self.view.bounds.size.width, 50);
        }
        else
        {
            CGSize photoSize = _scrollView.contentSize;
            CGRect labelRect = CGRectMake(0, photoSize.height, self.view.bounds.size.width, 50);
            countLabel.frame = labelRect;
            
            photoSize.height = photoSize.height + labelRect.size.height;
            _scrollView.contentSize = photoSize;
            
            _scrollView.contentOffset = scrollOffset;
        }
    }
    _scrollView.frame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:_scrollView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self reloadImageViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    for (UIView *subView in [_scrollView subviews])
    {
        if([subView isKindOfClass:[WSTouchImageView class]]){
            [subView removeFromSuperview];
        }
    }
    scrollOffset = _scrollView.contentOffset;
    [_scrollView removeFromSuperview];
}

- (void)imageTouch:(WSTouchImageView *)imageView
{
    WSPhotoBrowserViewController *photoBrowser = [[WSPhotoBrowserViewController alloc] initWithImageIDs:_imageIDArray];
    photoBrowser.delegate = self;
    
    [photoBrowser gotoPage:[_imageIDArray indexOfObject:imageView.imageID]];
    [self presentViewController:photoBrowser animated:YES completion:nil];
}

- (void)photoBrowserDeletePhoto:(NSString *)imageID {
    [self.imageIDArray removeObject:imageID];
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoGalleryDeletePhoto:)]) {
        [self.delegate photoGalleryDeletePhoto:self];
    }
}
#pragma mark - WaterMark 

- (void)setOverlayViewValue:(WSWatermarkOverlayView *)overlayView {
    NSString *storeCode = nil;
    NSString *storeName = nil;
    NSString *storeAddress = nil;
    if ([self.currentStore.name length] > 0) {
        storeName = self.currentStore.name;
        storeCode = self.currentStore.code;
        storeAddress = self.currentStore.addr;
    } else {
        storeName = self.storeName;
    }
    
    [overlayView setFuncName:nil empName:[WSAppData getObjectbyKey:EMPNAME] storeCode:storeCode storeName:storeName storeAddress:storeAddress storeLocation:nil lua:nil];
}

#pragma mark - WSImagePickerControllerDelegate

/*MENGNIU-1738 参照SFA-14742修改*/
- (void)imagePicker:(WSImagePickerController *)picker didFinishPickingImage:(UIImage *)image withDeviceOrientation:(UIDeviceOrientation)deviceOrientation withISCaptureDevicePositionFront:(BOOL)iSCaptureDevicePositionFront
{
    LogTrace();
    __weak typeof (self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *newImage = [weakSelf changeImageOrientationWithDeviceOrientation:deviceOrientation withISCaptureDevicePositionFront:iSCaptureDevicePositionFront withImage:image];
        [weakSelf didFinishPickingImage:newImage];
    }];
}

- (void)imagePicker:(WSImagePickerController *)picker didFinishPickingImage:(UIImage *)image
{
    LogTrace();
    __weak typeof (self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf didFinishPickingImage:image];
    }];
}

- (void)imagePickerDidCancel:(WSImagePickerController *)picker
{
    LogTrace();
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

@end

@implementation WSPhotoGalleryViewController (Tools)

#pragma mark - 处理图片方法
- (UIImage *)changeImageOrientationWithDeviceOrientation:(UIDeviceOrientation)deviceOrientation withISCaptureDevicePositionFront:(BOOL)isCaptureDevicePositionFront
                                               withImage:(UIImage *)img
{
    if (INTERFACE_IS_PHONE)
    {
        switch (deviceOrientation)
        {
            case UIDeviceOrientationLandscapeLeft:
                if (isCaptureDevicePositionFront)
                    img = [UIImage imageWithCGImage:img.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored];
                else
                    img = [UIImage imageWithCGImage:img.CGImage scale:1.0f orientation:UIImageOrientationUp];
                break;
            case UIDeviceOrientationLandscapeRight:
                if (isCaptureDevicePositionFront)
                    img = [UIImage imageWithCGImage:img.CGImage scale:1.0f orientation:UIImageOrientationUpMirrored];
                else
                    img = [UIImage imageWithCGImage:img.CGImage scale:1.0f orientation:UIImageOrientationDown];
                break;
            default:
                break;
        }
    }
    else
    {
        switch (deviceOrientation)
        {
            case UIDeviceOrientationPortrait:
                if (isCaptureDevicePositionFront)
                    img = [UIImage imageWithCGImage:img.CGImage scale:1.0f orientation:UIImageOrientationLeftMirrored];
                else
                    img = [UIImage imageWithCGImage:img.CGImage scale:1.0f orientation:UIImageOrientationRight];
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                if (isCaptureDevicePositionFront)
                    img = [UIImage imageWithCGImage:img.CGImage scale:1.0f orientation:UIImageOrientationRightMirrored];
                else
                    img = [UIImage imageWithCGImage:img.CGImage scale:1.0f orientation:UIImageOrientationLeft];
                break;
            default:
                break;
        }
    }
    
    return img;
}

#pragma mark - 完成图片方法
- (void)didFinishPickingImage:(UIImage *)image
{
    LogTrace();
    if (image)
    {
        float width = 320.0;
        //NSNumber *imgWidth = [[NSUserDefaults standardUserDefaults] objectForKey:IMAGE_WIDTH];
        NSNumber *imgWidth = [self getImageShootWidth];
        if (imgWidth && [imgWidth floatValue] > 0) {
            width = [imgWidth floatValue];
        }
        
        float imgScale = image.size.width/image.size.height;
        float newHight = width / imgScale;
        
        
        NSString *image_watermark = [NSString stringWithValue:[[NSUserDefaults standardUserDefaults] objectForKey:IMAGE_WATERMARK]];
        UIImage *newImage = nil;
        if ([image_watermark isEqualToString:@"1"])
        {
            newImage = [self getNewStyleWaterMarkImage:image width:width height:newHight];
        }
        else
        {
            newImage = [UIImage scaleImage:image scaleToSize:CGSizeMake(floor(width), floor(newHight))];
        }
        
        
        if (newImage)
        {
            NSString *imageID = [[[WSJSONBuilder gen_uuid] md5] lowercaseString];
            //NSNumber *imgCompress = [[NSUserDefaults standardUserDefaults] objectForKey:@"ImgCompress"];
            NSNumber *imgCompress = [self getImageCompress];
            float compressScale = imgCompress.intValue / 100.0f;
            
            if (_imageIDArray == nil)
                _imageIDArray = [[NSMutableArray alloc] init];
            
            NSData *photodata = UIImageJPEGRepresentation(newImage, compressScale/*0.0f*/);
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageSaveSuccess:) name:SDImageSaveSuccess object:nil];
            [[SDImageCache sharedImageCache] storeImage:image imageData:photodata forKey:imageID toDisk:YES toDocument:YES];
        }
        else
        {
            LogError(@"获取照片失败");
            NSString *title = NSLocalizedString(@"photo_save_failure", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }
    }
    else
    {
        LogError(@"获取照片失败");
        NSString *title = NSLocalizedString(@"photo_save_failure", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}

#pragma mark - 获取图片压缩比方法
- (NSNumber *)getImageCompress {
    
    if (self.currentFuncs.opt.imgCompress_iOS && self.currentFuncs.opt.imgCompress_iOS.length > 0) {
        NSInteger imgCompress = [self.currentFuncs.opt.imgCompress_iOS integerValue];
        NSNumber *optImgCompressNumber = [NSNumber numberWithInteger:imgCompress];
        return optImgCompressNumber;
    }

    if (self.currentFuncs.opt.imgCompress && self.currentFuncs.opt.imgCompress.length > 0) {
        NSInteger imgCompress = [self.currentFuncs.opt.imgCompress integerValue];
        NSNumber *optImgCompressNumber = [NSNumber numberWithInteger:imgCompress];
        return optImgCompressNumber;
    }
    
    NSNumber *imgCompressNumber_ios = [[NSUserDefaults standardUserDefaults] objectForKey:@"ImgCompress_IOS"];
    if (imgCompressNumber_ios) {
        return imgCompressNumber_ios;
    }
    
    NSNumber *imgCompressNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"ImgCompress"];
    return imgCompressNumber;
}

#pragma mark - 获取图片宽度方法
- (NSNumber *)getImageShootWidth {
    
    if (self.currentFuncs.opt.imgShootWidth_iOS && self.currentFuncs.opt.imgShootWidth_iOS.length > 0) {
        CGFloat imgShootWidth = [self.currentFuncs.opt.imgShootWidth_iOS floatValue];
        NSNumber *optImgShootWidthNumber = [NSNumber numberWithFloat:imgShootWidth];
        return optImgShootWidthNumber;
    }

    if (self.currentFuncs.opt.imgShootWidth && self.currentFuncs.opt.imgShootWidth.length > 0) {
        CGFloat imgShootWidth = [self.currentFuncs.opt.imgShootWidth floatValue];
        NSNumber *optImgShootWidthNumber = [NSNumber numberWithFloat:imgShootWidth];
        return optImgShootWidthNumber;
    }
    
    NSNumber *imgWidth_ios = [[NSUserDefaults standardUserDefaults] objectForKey:@"IMAGE_WIDTH_IOS"];
    if (imgWidth_ios) {
        return imgWidth_ios;
    }
    
    NSNumber *imgWidth = [[NSUserDefaults standardUserDefaults] objectForKey:IMAGE_WIDTH];
    return imgWidth;
}

@end
