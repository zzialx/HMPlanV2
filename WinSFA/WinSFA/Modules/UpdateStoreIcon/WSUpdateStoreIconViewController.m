//
//  WSUpdateStoreIconViewController.m
//  WinSFA
//
//  Created by mac on 2018/4/26.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSUpdateStoreIconViewController.h"
#import "WSRequestHelper.h"
#import "WSJSONBuilder.h"
#import "WSPhotoLogicService.h"
#import "WSImagePathTable.h"
#import "WSBaseAcvtDBService.h"
#import "WSBaseAcvtdisDBService.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define updateStoreIconTitel        @"更新门头照"
#define kImageViewLeftMargin        23
#define kImageViewTopMargin         64
#define kImageViewImageHeight       238
#define IMAGE_UPLOAD_NOTIFY_NAME    @"IMAGE_UPLOAD_NOTIFY_NAME"

@interface WSUpdateStoreIconViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property(nonatomic,strong)UIImageView * storeImageView;   // 显示的图片
@property (nonatomic , strong) UIButton * takePhotoButton; // 拍照按钮
@property (nonatomic , copy) NSString *imageID;
@property (nonatomic , copy) NSString *imageIndex;
@property (nonatomic , strong) WSBaseAcvtDBService * acvtDBService;

@end

@implementation WSUpdateStoreIconViewController

-(UIImageView *)storeImageView{
    if (!_storeImageView) {
        _storeImageView = [[UIImageView alloc]init];
        [_storeImageView setImage:[UIImage imageNamed:@"shop_default"]];
        _storeImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _storeImageView;
}

-(UIButton *)takePhotoButton{
    if (!_takePhotoButton) {
        _takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_takePhotoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [_takePhotoButton setTitle:NSLocalizedString(@"update_store_icon", nil)  forState:UIControlStateNormal];
        [_takePhotoButton setBackgroundColor:MAIN_TINT_COLOR];
    }
    return _takePhotoButton;
}

-(WSBaseAcvtDBService *)acvtDBService{
    if (!_acvtDBService) {
        _acvtDBService = [[WSBaseAcvtDBService alloc]init];
    }
    return _acvtDBService;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    // 2018-05-23-Lixiang-YIHAIKERRY-2808
    CGFloat storeImageWidth  = self.view.width - 2 * kImageViewLeftMargin;
    CGFloat storeImageHeight = kImageViewImageHeight;
    if (self.storeImageView.image) {
        storeImageHeight = storeImageWidth * self.storeImageView.image.size.height / self.storeImageView.image.size.width;
    }
    self.storeImageView.frame = CGRectMake(kImageViewLeftMargin, kImageViewTopMargin, storeImageWidth, storeImageHeight);
    self.takePhotoButton.frame = CGRectMake(0, self.view.height - MAIN_CELL_HEIGHT, self.view.width, MAIN_CELL_HEIGHT);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = updateStoreIconTitel;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [self getSaveButton];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.view addSubview:self.storeImageView];
    [self.view addSubview:self.takePhotoButton];
    [self setStoreImage];
}

#pragma mark- 获取保存按钮
-(UIBarButtonItem *)getSaveButton{
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, 24, 24)];
    [saveBtn setBackgroundColor:[UIColor clearColor]];
    //    [saveBtn setTitle:NSLocalizedString(@"save_label", nil) forState:UIControlStateNormal];
    //    [saveBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    //    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"icon_upload"] forState:UIControlStateNormal];
    //    [saveBtn setBackgroundImage:[UIImage imageNamed:@"icon_upload"] forState:UIControlStateDisabled];
    [saveBtn addTarget:self action:@selector(uploadImage) forControlEvents:UIControlEventTouchUpInside];
    return  [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
}

#pragma mark- 设置图片
-(void)setStoreImage{
    if ([self.store.storeImg rangeOfString:@"."].location != NSNotFound) {
        //        [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:self.store.storeImg] imageView:self.storeImageView placeholderImage:[UIImage imageForName:@"shop_default@2x"]];
        
        //YIHAIKERRY-3524   此处显示门店大图标bigImgUrl
        NSString * urlstring = [[[WSBaseAcvtdisDBService alloc]init] queryStoreImageUrlWithStoreId:self.store.Id imgType:WSStoreImgTypeBig];
        [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:urlstring] imageView:self.storeImageView placeholderImage:[UIImage imageForName:@"shop_default@2x"]];
        
    }else{
        NSArray * imagePathArray = [[WSImagePathTable sharedTable]queryWithImageIDX:self.store.storeImg];
        WSImagePathObject * object = [imagePathArray lastObject];
        UIImage * image = [[SDImageCache sharedImageCache] imageFromKey:object.img_path fromDisk:YES];
        if (image) {
            self.storeImageView.image = image;
        }else{
            self.storeImageView.image = [UIImage imageForName:@"shop_default@2x"];
        }
    }
    
}
#pragma mark- 网络请求
-(void)uploadImage{
    
    if (!self.imageID) {
        return;
    }
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"uploading_prompt",nil)  tips:nil tapTarget:self action:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadDataFinish:) name:IMAGE_UPLOAD_NOTIFY_NAME object:nil];
    // 自己生成一个ImageIndex，用门店id生成，避免门头照对应不上门店
    NSString *imageIndex = [WSPhotoLogicService getAcvtImageIndexWithFC:@"FC_UpdateStoreIcon" acvtMD5:@"" acvtQstId:self.store.Id];
    self.imageIndex = imageIndex;
    
    NSMutableDictionary *params = [[WSJSONBuilder buildImageParamsDicByImageID:self.imageID] mutableCopy];
    // 传个门店ID
    [params setObject:[NSString stringNotNilWithValue:self.store.Id] forKey:@"store_id"];
    NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:self.imageID];
    
    [[WSRequestHelper shareInstance] uploadImageWithFilePath:filePath
                                                      params:params
                                                         url:URL_IMAGEUPLOAD
                                                  notifyName:IMAGE_UPLOAD_NOTIFY_NAME
                                                         md5:imageIndex];
    
}

-(void)uploadDataFinish:(NSNotification *)noti{
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    NSString *info = [[noti userInfo] objectForKey:DATAS];
    NSDictionary * dic = [info objectFromJSONString];
    if ([[dic objectForKey:@"result"] isEqualToString:@"1"]) {
        // 本地门头照表入库
        NSArray* array = [NSArray arrayWithObjects:self.imageIndex,self.imageID,[WSAppData getObjectbyKey:APPDATA_BIZDATE],[WSCurrentTime getDateTime],@"0",nil];
        [[WSImagePathTable sharedTable] updateWithImageIDX:self.imageIndex withValuesArray:@[array]];
        // 刷新拜访页门头照
        if (self.reloadStoreImage)
            self.reloadStoreImage(self.imageIndex);
        
        // 更新门头照的回显
        WSAcvtBean_qst * qst = [self.acvtDBService queryQstWithAcvtQstCode:@"smallImgUrl"];
        
        NSString * urlstring = [[[WSBaseAcvtdisDBService alloc]init] queryStoreImageUrlWithStoreId:self.store.Id imgType:WSStoreImgTypeSmall];
        NSString * sql;
        if (urlstring.length > 0) {
            sql = [NSString stringWithFormat:@"update base_store_acvt_dis set acvt_qst_answer = '%@' where sid='%@' and acvtQstId = '%@' and emp_id = '%@'",self.imageIndex,self.store.Id,qst.acvtQstId,[WSAppData getObjectbyKey:APPDATA_EMPID]];
        }else{
            sql = [NSString stringWithFormat:@"INSERT INTO base_store_acvt_dis (acvt_qst_answer, sid, acvtId,acvtQstId,emp_id) VALUES ('%@', '%@','%@', '%@','%@')",self.imageIndex,self.store.Id,qst.acvtId,qst.acvtQstId,[WSAppData getObjectbyKey:APPDATA_EMPID]];
        }
        [[[WSSqliteUtil alloc]init] executeUpdateWithSqls:@[sql]];
        [self.navigationController popViewControllerAnimated:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CHANGE_STOREICON_RELOAD_STORE_LIST object:nil];

    }else{
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"fail_upload", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)takePhoto:(UIButton *)button{
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)) {
        
        [self tips];
    }
    else if (authStatus == AVAuthorizationStatusNotDetermined) {
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self takePhoto:nil];
                });
            }
        }];
    } 
    else if ([PHPhotoLibrary authorizationStatus] == 2) {
        
        [self tips];
    }
    else {
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        pickerController.delegate = self;
        UIImagePickerControllerSourceType source = UIImagePickerControllerSourceTypeCamera;
        if (TARGET_IPHONE_SIMULATOR) source = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerController.sourceType = source;
        [self presentViewController:pickerController animated:YES completion:nil];
    }
}

#pragma mark- 提示授权信息
-(void)tips{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"photo_permission", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"confirm", nil) otherButtonTitles:nil];
    [alert show];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //SFA益海嘉里YIHAIKERRY-3569 SFA 益海嘉里-传统渠道【200家门店列表】【IOS】进入门店更新门店门头照上传后返回，各页面上方缺少显示一部分（不隐藏状态栏）
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO  withAnimation:UIStatusBarAnimationSlide];
    }];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self.storeImageView setImage:image];
        [self viewDidLayoutSubviews];
        [self saveImage:image];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

// 取消选取调用的方法 //SFA益海嘉里YIHAIKERRY-3569
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO  withAnimation:UIStatusBarAnimationSlide];
    }];
}

-(void)saveImage:(UIImage *)image{
    
    NSString *imageID = [[[WSJSONBuilder gen_uuid] md5] lowercaseString];
    self.imageID = imageID;
    LogInfo(@"imageID:%@",imageID);
    
    if (imageID == nil) return;
    
    NSNumber *imgCompress = [[NSUserDefaults standardUserDefaults] objectForKey:@"ImgCompress"];
    [[SDImageCache sharedImageCache] storeImage:image imageImgCompress:imgCompress forKey:imageID toDisk:YES toDocument:YES isSynchronized:YES];
}
@end


