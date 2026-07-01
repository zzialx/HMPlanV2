//
//  WSIMagePickerModule.m
//  WinSFA
//
//  Created by winchannel on 2017/6/7.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSIMagePickerModule.h"

@implementation WSIMagePickerModule

+ (WSIMagePickerModule*) getInstance
{
    static WSIMagePickerModule *instance = nil;
    @synchronized(self){
        if (instance == nil) {
            instance = [[WSIMagePickerModule alloc] init];
        }
        
        return instance;
    }
}
- (void)showImagePickerViewControllerWithParentVC:(UIViewController *)parentVC
                                    andSourceType:(NSInteger )sourceType
                                    andImageBlock:(WSImagePickerBlock)aBlock{
    
    self.imagePickerBlok = aBlock;
    //初始化UIImagePickerController
    UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
    //获取方式1：通过相册（呈现全部相册），UIImagePickerControllerSourceTypePhotoLibrary
    //获取方式2，通过相机，UIImagePickerControllerSourceTypeCamera
    //获取方法3，通过相册（呈现全部图片），UIImagePickerControllerSourceTypeSavedPhotosAlbum
    PickerImage.sourceType = sourceType;
    //允许编辑，即放大裁剪
    //PickerImage.allowsEditing = YES;
    //自代理
    PickerImage.delegate = self;
    
    self.imagePickerVC = PickerImage;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    [parentVC presentViewController:PickerImage animated:YES completion:nil];

}

#pragma mark - @protocol UIImagePickerControllerDelegate<NSObject> method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
 
    
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imagePickerBlok(originalImage);
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO  withAnimation:UIStatusBarAnimationSlide];
        [picker removeFromParentViewController];
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO  withAnimation:UIStatusBarAnimationSlide];
        [picker removeFromParentViewController];
    }];
    
}

-(void)dealloc{

}
@end
