//
//  WinCameraTools.m
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import "WinCameraTools.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
//=============================================================================================================================

#pragma mark - 相机工具
@implementation WinCameraTools

#pragma mark - 获取顶部安全区域高度方法
+ (CGFloat)safeAreaInsetsTopHeight {
    
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIWindow *window = windowScene.windows.firstObject;
        return window.safeAreaInsets.top;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        return window.safeAreaInsets.top;
    }
        
    return 0.0f;
}

#pragma mark - 获取底部安全区域高度方法
+ (CGFloat)safeAreaInsetsBottomHeight {
    
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIWindow *window = windowScene.windows.firstObject;
        return window.safeAreaInsets.bottom;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        return window.safeAreaInsets.bottom;
    }
        
    return 0.0f;
}

#pragma mark - 相机授权方法
+ (void)authCameraWithBlock:(authDoneBlock)doneBlock {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (doneBlock) {
                    doneBlock(granted);
                }
            });
        }];
        return;
    }
    
    if (authStatus == AVAuthorizationStatusAuthorized) {
        
        if (doneBlock) {
            doneBlock(YES);
        }
        return;
    }
    
    if (doneBlock) {
        doneBlock(NO);
    }
}

#pragma mark - 相册授权方法
+ (void)authPhotoLibraryWithBlock:(authDoneBlock)doneBlock {
    
    PHAuthorizationStatus status = PHAuthorizationStatusNotDetermined;
    if (@available(iOS 14, *)) {
        status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
    }
    else {
        status = [PHPhotoLibrary authorizationStatus];
    }
    
    if (status == PHAuthorizationStatusNotDetermined) {
        
        if (@available(iOS 14, *)) {
            
            [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self handlePhotoAuthorizationStatus:status block:doneBlock];
                });
            }];
        }
        else {
            
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self handlePhotoAuthorizationStatus:status block:doneBlock];
                });
            }];
        }
        
        return;
    }
    
    [self handlePhotoAuthorizationStatus:status block:doneBlock];
}

#pragma mark - 处理相册授权结果方法
+ (void)handlePhotoAuthorizationStatus:(PHAuthorizationStatus)status block:(authDoneBlock)doneBlock {
    
    if (@available(iOS 14, *)) {
        
        if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
            
            if (doneBlock) {
                doneBlock(YES);
            }
        
            return;
        }
    }
    else {
        
        if (status == PHAuthorizationStatusAuthorized) {
            
            if (doneBlock) {
                doneBlock(YES);
            }
        
            return;
        }
    }
    
    if (doneBlock) {
        doneBlock(NO);
    }
}

#pragma mark - 获取捕获设备方法
+ (NSArray<AVCaptureDevice *> *)captureDevices {
    
    NSArray<AVCaptureDeviceType> *deviceTypes = @[AVCaptureDeviceTypeBuiltInWideAngleCamera];
    AVCaptureDeviceDiscoverySession *session = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes
                                                                                                      mediaType:AVMediaTypeVideo
                                                                                                       position:AVCaptureDevicePositionUnspecified];
    return session.devices;
}

#pragma mark - 获取前置摄像头方法
+ (AVCaptureDevice *)frontCaptureDevice {
    
    AVCaptureDevice *captureDevice = nil;
    NSArray<AVCaptureDevice *> *deviceDevices = [WinCameraTools captureDevices];
    for (AVCaptureDevice *device in deviceDevices) {
        
        if (![device hasMediaType:AVMediaTypeVideo]) {
            continue;
        }
        
        if (device.position == AVCaptureDevicePositionFront) {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

#pragma mark - 获取后置摄像头方法
+ (AVCaptureDevice *)backCaptureDevice {
    
    AVCaptureDevice *captureDevice = nil;
    NSArray<AVCaptureDevice *> *deviceDevices = [WinCameraTools captureDevices];
    for (AVCaptureDevice *device in deviceDevices) {
        
        if (![device hasMediaType:AVMediaTypeVideo]) {
            continue;
        }
        
        if (device.position == AVCaptureDevicePositionBack) {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

#pragma mark - 转换击打点方法
+ (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
                                          previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer
                                                 ports:(NSArray<AVCaptureInputPort *> *)ports {
    
    CGPoint pointOfInterest = CGPointMake(0.5f, 0.5f);
    CGSize frameSize = previewLayer.frame.size;
    
    if ([previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResize]) {
        
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.0f - (viewCoordinates.x / frameSize.width));
        return pointOfInterest;
    }
    
    CGRect cleanAperture;
    for (AVCaptureInputPort *port in ports) {
        
        if (port.mediaType == AVMediaTypeVideo) {
            
            cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
            CGSize apertureSize = cleanAperture.size;
            CGPoint point = viewCoordinates;
                            
            CGFloat apertureRatio = apertureSize.height / apertureSize.width;
            CGFloat viewRatio = frameSize.width / frameSize.height;
            CGFloat xc = 0.5f;
            CGFloat yc = 0.5f;
            
            if ([previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
                                
                if (viewRatio > apertureRatio) {
                    CGFloat y2 = frameSize.height;
                    CGFloat x2 = frameSize.height * apertureRatio;
                    CGFloat x1 = frameSize.width;
                    CGFloat blackBar = (x1 - x2) / 2;
                    if (point.x >= blackBar && point.x <= blackBar + x2) {
                        xc = point.y / y2;
                        yc = 1.0f - ((point.x - blackBar) / x2);
                    }
                }
                else {
                    CGFloat y2 = frameSize.width / apertureRatio;
                    CGFloat y1 = frameSize.height;
                    CGFloat x2 = frameSize.width;
                    CGFloat blackBar = (y1 - y2) / 2;
                    if (point.y >= blackBar && point.y <= blackBar + y2) {
                        xc = ((point.y - blackBar) / y2);
                        yc = 1.0f - (point.x / x2);
                    }
                }
            }
            else if ([previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                
                if (viewRatio > apertureRatio) {
                    CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                    xc = (point.y + ((y2 - frameSize.height) / 2.0f)) / y2;
                    yc = (frameSize.width - point.x) / frameSize.width;
                }
                else {
                    CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                    yc = 1.0f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                    xc = point.y / frameSize.height;
                }
            }
                            
            pointOfInterest = CGPointMake(xc, yc);
            break;
        }
    }
    
    return pointOfInterest;
}

#pragma mark - 等比缩放图片方法
+ (UIImage *)scaleImageToWidth:(UIImage *)image targetWidth:(CGFloat)targetWidth {
    
    if (!image) {
        return nil;
    }
    if (targetWidth <= 0) {
        return image;
    }
    
    CGFloat originalWidth = image.size.width;
    CGFloat originalHeight = image.size.height;
    CGFloat scale = targetWidth / originalWidth;
    CGSize newSize = CGSizeMake(targetWidth, originalHeight * scale);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - 视图转图片方法
+ (UIImage *)imageFromView:(UIView *)view {
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0f);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - 合成图片方法
+ (UIImage *)mergeImage:(UIImage *)baseImage withOverlayImage:(UIImage *)overlayImage {
    
    UIGraphicsBeginImageContextWithOptions(baseImage.size, NO, [UIScreen mainScreen].scale);
    [baseImage drawInRect:CGRectMake(0.0f, 0.0f, baseImage.size.width, baseImage.size.height)];
    [overlayImage drawInRect:CGRectMake(0.0f, 0.0f, baseImage.size.width, baseImage.size.height)];
    UIImage *mergedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return mergedImage;
}

#pragma mark - 裁切图片方法
+ (UIImage *)cropImage:(UIImage *)image usingPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer {
    
    CGRect previewBounds = previewLayer.bounds;
    CGRect outputRect = [previewLayer metadataOutputRectOfInterestForRect:previewBounds];
    
    CGImageRef takenCGImage = image.CGImage;
    size_t width = CGImageGetWidth(takenCGImage);
    size_t height = CGImageGetHeight(takenCGImage);
    CGRect cropRect = CGRectMake(outputRect.origin.x * width, outputRect.origin.y * height,
                                 outputRect.size.width * width, outputRect.size.height * height);
    
    CGImageRef cropCGImage = CGImageCreateWithImageInRect(takenCGImage, cropRect);
    image = [UIImage imageWithCGImage:cropCGImage scale:1.0f orientation:image.imageOrientation];
    CGImageRelease(cropCGImage);
    
    return image;
}

@end
//=============================================================================================================================
