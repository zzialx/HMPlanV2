//
//  WSAlbumAuthHelper.m
//  WinSFA
//
//  Created by yuanji on 2018/9/17.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSAlbumAuthHelper.h"
#import <Photos/Photos.h>

@implementation WSAlbumAuthHelper

+ (BOOL)isAlbumAuthorize
{
    NSString *takePhotoAlbum = [[NSUserDefaults standardUserDefaults] objectForKey:TAKE_PHOTO_ALBUM];
    return ([takePhotoAlbum isEqualToString:@"1"] ? YES : NO);
}

+ (void)savePhotoWithImage:(UIImage *)image
{
    if (!image) {
        return;
    }
    
    if (IOS8_OR_LATER) {
        PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
        if (photoAuthorStatus == PHAuthorizationStatusAuthorized) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                request.creationDate = [NSDate date];
            } completionHandler:^(BOOL success, NSError *error) {
            }];
        }
    }
}

- (void)authAlbumWithBlock:(albumAuthHelperAuthorizeBlock)authorizeBlock {
    
    if (IOS8_OR_LATER) {
        
        PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
        
        if (photoAuthorStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self blockCallbackWithIsSuccess:YES authorizeBlock:authorizeBlock];
                }
                else {
                    [self authorizeFailTips];
                    [self blockCallbackWithIsSuccess:NO authorizeBlock:authorizeBlock];
                }
            }];
        }
        else if (photoAuthorStatus == PHAuthorizationStatusDenied) {
            [self authorizeFailTips];
            [self blockCallbackWithIsSuccess:NO authorizeBlock:authorizeBlock];
        }
        else if (photoAuthorStatus == PHAuthorizationStatusAuthorized) {
            [self blockCallbackWithIsSuccess:YES authorizeBlock:authorizeBlock];
        }
        else {
            [self blockCallbackWithIsSuccess:NO authorizeBlock:authorizeBlock];
        }
    }
}

- (void)authorizeFailTips
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *title = NSLocalizedString(@"js_alert_title", nil);
        NSString *message = NSLocalizedString(@"album_permission", nil);
        NSString *confirm = NSLocalizedString(@"confirm", nil);
        BlockAlertView *alert = [BlockAlertView alertWithTitle:title message:message];
        [alert setCancelButtonWithTitle:confirm block:nil];
        [alert show];
    });
}

- (void)blockCallbackWithIsSuccess:(BOOL)isSuccess authorizeBlock:(albumAuthHelperAuthorizeBlock)authorizeBlock
{
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (authorizeBlock) {
            authorizeBlock(weakSelf, isSuccess);
        }
    });
}

@end
