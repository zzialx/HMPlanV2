//
//  WSIMagePickerModule.h
//  WinSFA
//
//  Created by winchannel on 2017/6/7.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WSImagePickerBlock)(UIImage *image);


@interface WSIMagePickerModule : NSObject<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, copy) WSImagePickerBlock imagePickerBlok;

@property (nonatomic, strong) UIImagePickerController *imagePickerVC;

+ (WSIMagePickerModule*) getInstance;

- (void)showImagePickerViewControllerWithParentVC:(UIViewController *)parentVC  andSourceType:(NSInteger )sourceType andImageBlock:(WSImagePickerBlock)aBlock;
@end
