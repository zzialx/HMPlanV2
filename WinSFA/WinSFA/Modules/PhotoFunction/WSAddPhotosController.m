//
//  WSAddPhotosController.m
//  WinSFA
//
//  Created by winchannel on 16/1/14.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSAddPhotosController.h"
#import "WSInterAction.h"

@interface WSAddPhotosController ()

@property (nonatomic, assign) BOOL hasModified;

@end

@implementation WSAddPhotosController

- (void)viewDidLoad{
    
    if ([[self.executeParam execute_class_param] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)[self.executeParam execute_class_param];
        if ([[dic objectForKey:@"cellPhotos"] isKindOfClass:[NSArray class]]) {
            self.photoArray = [[dic objectForKey:@"cellPhotos"] mutableCopy];
        }
        
        if ([dic objectForKey:@"imei"]) {
            self.title = [dic objectForKey:@"imei"];
        }
        
    }
    
    if (!self.photoArray) {
        self.photoArray =[[NSMutableArray alloc]init];
    }
    
    [self addPictureWithSupperLocalPicture:NO withMaxPhotoNnumber:1000];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];

    NSString *UploadString = NSLocalizedString(@"confirm", nil);
    
    UIBarButtonItem *upload =[[UIBarButtonItem alloc]initWithTitle:UploadString style:UIBarButtonItemStyleDone target:self action:@selector(uploadPhotos)];
    
    NSArray *RightTooBarArr =[NSArray arrayWithObjects:upload,nil];
    
    self.navigationItem.rightBarButtonItems = RightTooBarArr;
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, MAIN_BUTTON_WH, 44)];
    [backBtn setBackgroundColor:[UIColor clearColor]];
    [backBtn setImage:[UIImage scaledImageForName:@"icon_back" ofType:@"png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(comBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = homeButtonItem;
    
}
-(void)addPictureWithSupperLocalPicture:(BOOL)isSupperLocalPicture
                    withMaxPhotoNnumber:(NSInteger)maxPhoto{
    //拍照放在页面里面
    if (self.photoBrowseView == nil) {
        
        WSPhotoBrowseView *photoView = [[WSPhotoBrowseView alloc]initWithFrame:CGRectMake(10, 84, self.view.frame.size.width, PHOTO_PANEL_HEIGHT)
                                                                          funs:nil
                                                              withImageIDArray:self.photoArray
                                                            withSupperLocalPic:isSupperLocalPicture
                                                             withSupperHttpPic:NO
                                                               withMaxPhotoNum:maxPhoto
                                                                      delegate:nil  
                                                                            align:nil
                                                                  withDisPlayMode:nil];
        
        photoView.delegate = self;
        photoView.viewController = self;
        photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        photoView.currentStore = nil;
        self.photoBrowseView = photoView;
        [self.view addSubview:photoView];
        
    }
}

- (void)uploadPhotos
{
//    if ([self.photoArray count] == 0) {
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"pls_take_photo", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//        return;
//    }

    if (self.wcBaseViewdelegate && [self.wcBaseViewdelegate respondsToSelector:@selector(callBackWhenFinishTask:)]) {
        self.executeParam.execute_result = self.photoArray;
        [self.wcBaseViewdelegate callBackWhenFinishTask:self.executeParam];
    }
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (void)comBack{
    
    if (self.hasModified) {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"修改的数据未保存，请确认是否保存？", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"save_label", nil) block:^{
            if (self.wcBaseViewdelegate && [self.wcBaseViewdelegate respondsToSelector:@selector(callBackWhenFinishTask:)]) {
                self.executeParam.execute_result = self.photoArray;
                [self.wcBaseViewdelegate callBackWhenFinishTask:self.executeParam];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addButtonWithTitle:NSLocalizedString(@"give_up", nil) block:^{
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }];
        [alert show];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -WSPhotoBrowseViewDelegate

- (void)photoBrowseView:(WSPhotoBrowseView *)photoBrowseView   didAddedImageForID:(NSString *)imageID{
    
    
    if (![self.photoArray containsObject:imageID]) {
        
        [self.photoArray addObject:imageID];
        
        self.hasModified = YES;
    }
    
}
- (void)photoBrowseView:(WSPhotoBrowseView *)photoBrowseView didSelectImageId:(NSString *)imageId{
    
    if (!photoBrowseView.imageIDArray || !imageId) {
        return;
    }
    WSPhotoBrowserViewController *photoBrowser = nil;
    
    photoBrowser =[[WSPhotoBrowserViewController alloc]initWithImageIDs:photoBrowseView.imageIDArray];
   
    photoBrowser.delegate = photoBrowseView;
   
    [photoBrowser gotoPage:[photoBrowseView.imageIDArray indexOfObject:imageId]];
    
     photoBrowser.enableEdit = photoBrowseView.enableEdit;
    photoBrowser.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:photoBrowser animated:YES completion:nil];
}
- (void)photoBrowseView:(WSPhotoBrowseView *)photoBrowseView didDeletedImageForID:(NSString *)imageID{
    
    if ([self.photoArray containsObject:imageID]) {
        [self.photoArray removeObject:imageID];
        
        self.hasModified = YES;
    }
}
@end
