//
//  ViewController.h
//  PhotoBrowserTest
//
//  Created by Jiepeng Zheng on 12-8-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSTouchImageView.h"
#import "WSPhotoBrowserViewController.h"
#import "WCBaseViewController.h"

@class WSPhotoGalleryViewController;

@protocol PhotoGalleryViewControllerDelegate <NSObject>

@optional
- (void)updatePhotoData:(NSMutableArray *)images;
- (void)updatePhotoData:(WSPhotoGalleryViewController *)aPhotoGalleryViewController photoArray:(NSMutableArray *)images;
- (void)photoGallery:(WSPhotoGalleryViewController *)photoGallery addImage:(NSString *)imageID;
- (void)photoGalleryDeletePhoto:(WSPhotoGalleryViewController *)photoGallery;

@end

@interface WSPhotoGalleryViewController : WCBaseViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, ImageViewDeleagte, WSPhotoBrowserDelegate>

@property (nonatomic, copy) NSString *storeName;
@property (nonatomic, strong) NSMutableArray *imageIDArray;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger maxPhotoCount;
@property (nonatomic, weak) id<PhotoGalleryViewControllerDelegate> delegate;
// 对应UIImagePickerControllerSourceType 从1开始
/*
{
    ImagePickerControllerSourceTypePhotoLibrary = 1,
    ImagePickerControllerSourceTypeCamera,
    ImagePickerControllerSourceTypeSavedPhotosAlbum
}
 */
@property (nonatomic, assign) NSInteger imagePickerControllerSourceType;

- (IBAction)makePhoto:(id)sender;
- (id)initWithImageIDArray:(NSMutableArray *)aImageIDArray;

@end
