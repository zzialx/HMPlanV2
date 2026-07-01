//
//  WSGridPhotoButton.m
//  WinSFA
//
//  Created by Alicia on 2018/6/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSGridPhotoButton.h"
#import "PhotoTypeButton.h"
#import "WSInterAction.h"

@interface WSGridPhotoButton() <UIActionSheetDelegate, PhotoTypeButtonDelegate,PhotoGalleryViewControllerDelegate>

@property (nonatomic, assign) BOOL isSetMd5;

@end

@implementation WSGridPhotoButton


- (void)setupView {
    PhotoTypeButton *button = [[PhotoTypeButton alloc] init];

    button.customDelegate = self;
    button.maxPhotoCount = [self.param.max integerValue];
    button.isSupperLocalPhoto = self.param.isSupperLocalPhoto;
    
    
    // TODO
    button.iRow = (unsigned int)self.iRow;
    button.iColumn = (unsigned int)self.iColumn;

    self.photoButton = button;
     
}

- (UIView *)getView {
    if (!self.isSetMd5) {
        self.isSetMd5 = YES;
        
        if (!self.delegate) {
            LogError(@"Not Set delegate");
            return nil;
        }
        
        NSString *mImageIdx = [NSString stringWithFormat:@"%@_%@",[self.delegate dataSourceGetGridMc], [self.delegate dataSourceGetGridMd5]];
        NSString *cellKey = [NSString stringWithFormat:@"%ld_%@", self.iRow, self.m_col];
        self.photoButton.imageMD5 = [Md5Manager getMd5ByEmpId:nil
                                                      sotreId:nil
                                                      bizDate:nil
                                                     funcCode:nil
                                                       acvtId:mImageIdx
                                                         memo:cellKey];
    }
    
    return self.photoButton;
}

- (NSString *)getUploadValue {
    NSString *value = @"";
    if ([self.photoButton.photoIDArray count] > 0) {
        value = self.photoButton.imageMD5;
    }
    return value;
}

- (NSString *)getDBValue {
    if ([self.photoButton.photoIDArray count] > 0) {
        return [self.photoButton.photoIDArray componentsJoinedByString:@","];
    } else {
        return nil;
    }
}

- (void)setValue:(NSString *)value {
    if (value && ![value isEqualToString:@"null"]) {
        NSArray *array = [value componentsSeparatedByString:@","];
        
        if (array && [array count] > 0) {
            self.photoButton.photoIDArray = [NSMutableArray arrayWithArray:array];
            [[NSNotificationCenter defaultCenter] postNotificationName:PhotoTypeButton_Notification object:nil];
        }
    }
}

#pragma mark - Action
- (void)photoTypeButtonClick:(PhotoTypeButton *)aPhotoTypeButton {
    if (!self.delegate) {
        return;
    }
    
    if (aPhotoTypeButton.photoIDArray == nil) {
        aPhotoTypeButton.photoIDArray = [[NSMutableArray alloc] init];
    }
    
    BOOL isSupperLocalPhoto = aPhotoTypeButton.isSupperLocalPhoto;
    if (isSupperLocalPhoto) {
        UIViewController *controller = [self.delegate dataSourceGetController];
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"cancel_label" destructiveButtonTitle:nil otherButtonTitles:@"photo_library", @"camera_capture", nil];
        [actionsheet showInView:controller.view];
    } else {
        [self photoTypeButtonExecuteInterActionWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }
}


#pragma mark - UIActionSheetDelegate实现代理方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (0 == buttonIndex || 1 == buttonIndex) {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if (0 == buttonIndex) {  // 点击了相册按钮
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        } else if (1 == buttonIndex) { // 点击了拍照按钮
            sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        [self photoTypeButtonExecuteInterActionWithSourceType:sourceType];
    }
}

- (void)photoTypeButtonExecuteInterActionWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    NSMutableDictionary *dic = [@{@"photoIDArray":self.photoButton.photoIDArray,@"maxPhotoCount":[NSNumber numberWithInteger:self.photoButton.maxPhotoCount], @"imagePickerControllerSourceType":[NSNumber numberWithInteger:sourceType + 1]} mutableCopy];
    [self.delegate dataSourceInterActionPhotoGalleryWithGridWidget:self dic:dic];
}

- (void)photoGallery:(WSPhotoGalleryViewController *)photoGallery addImage:(NSString *)imageID {
    self.photoButton.isValueChange = YES;
}

- (void)photoGalleryDeletePhoto:(WSPhotoBrowserViewController *)photoGallery {
    self.photoButton.isValueChange = YES;
}

- (void)updatePhotoData:(WSPhotoGalleryViewController *)aPhotoGalleryViewController photoArray:(NSMutableArray *)images {
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoTypeButton_Notification object:nil];
    [self.delegate dataSourceDidChange:images];
}
//
@end
