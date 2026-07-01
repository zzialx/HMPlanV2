//
//  WSPhotoView.m
//  WinSFA
//
//  Created by yang on 14-5-30.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSPhotoBrowseView.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import <SDImageCache.h>
#import "UIImage+CameraBundle.h"
#import "WSJSONBuilder.h"
#import "WSPhotoView.h"
#import "WSBaseStoreTable.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "WSPhotoLogicService.h"
#import "WSEnterStoreAcvtModel.h"
#import "WSRequestHelper.h"
#import "WSAlbumAuthHelper.h"
#import "WSAcvtScrollView.h"
#import "WSPaiPaiManager.h"
#import "WinCameraTools.h"
#import "WinWatermarkInfo.h"
#import "WinCameraWatermarkView.h"
#import "WinCameraNavigationController.h"
#import "WinCameraContainerViewController.h"

#define KImageIDSuffix      @"_originalPic"
#define kNotExcuseActionLua @"notExcuseActionLua"

typedef enum {
    EPickerSourceType_Camera,   //相机
    EPickerSourceType_Photo     //相册
} EPickerSourceType;            //资源枚举
//=============================================================================================================================

#pragma mark - 照片浏览视图 延展(内部)
@interface WSPhotoBrowseView () <UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
TZImagePickerControllerDelegate, WSPaiPaiManagerDelegate, WinCameraContainerDelegate>

@property (nonatomic, assign) NSInteger maxPhotoCount;              //照片最大数量标识
@property (nonatomic, assign) BOOL isCreateNewlenz;                 //是否创建trax引擎密钥标识
@property (nonatomic, copy) NSString *enginekey;                    //trax引擎密钥
@property (nonatomic, strong) WSFuncsBean *currentFuncs;            //当前菜单
@property (nonatomic, strong) UIScrollView *scrollView;             //滚动视图
@property (nonatomic, strong) UIView *photoContentView;             //照片内容视图
@property (nonatomic, strong) UIButton *takePhotoButton;            //拍照按键
@property (nonatomic, strong) NSMutableArray *disImageIDArray;      //照片id数组(去除不包含水印原始图片id后的数据源)
@property (nonatomic, weak) UIScrollView *superScrollView;          //父级别滚动视图(弱引用)

@end
//=============================================================================================================================

#pragma mark - 照片浏览视图
@implementation WSPhotoBrowseView

#pragma mark - 获取disImageIDArray方法
- (NSMutableArray *)disImageIDArray {
    
    if (!_disImageIDArray) {
        _disImageIDArray = [[NSMutableArray alloc] init];
    }
    return _disImageIDArray;
}

#pragma mark - 获取imageIDArray方法
- (NSMutableArray *)imageIDArray {
    
    if (!_imageIDArray) {
        _imageIDArray = [[NSMutableArray alloc] init];
    }
    return _imageIDArray;
}

#pragma mark - 获取photoViewArray方法
- (NSMutableArray *)photoViewArray {
    
    if (!_photoViewArray) {
        _photoViewArray = [[NSMutableArray alloc] init];
    }
    return _photoViewArray;
}

#pragma mark - 获取imageArray方法
- (NSMutableArray *)imageArray {
    
    if (!_imageArray) {
        _imageArray = [[NSMutableArray alloc] init];
    }
    return _imageArray;
}

#pragma mark - 自定义初始化方法1
- (id)initWithFrame:(CGRect)frame funs:(WSFuncsBean *)funcs withImageIDArray:(NSArray *)imageIDArray withSupperLocalPic:(BOOL)isSupperLocalPic
  withSupperHttpPic:(BOOL)isSupperHttpPic withMaxPhotoNum:(NSInteger)maxPhoto delegate:(id<WSPhotoBrowseViewDelegate>)delegateObj
              align:(NSString *)align withDisPlayMode:(NSString *)disPalyMode {
    
    return [self initWithFrame:frame funs:funcs withImageIDArray:imageIDArray withSupperLocalPic:isSupperLocalPic withSupperHttpPic:isSupperHttpPic
               withMaxPhotoNum:maxPhoto delegate:delegateObj align:align withDisPlayMode:disPalyMode xbuildInfo: nil];
}

#pragma mark - 自定义初始化方法2
- (id)initWithFrame:(CGRect)frame funs:(WSFuncsBean *)funcs withImageIDArray:(NSArray *)imageIDArray withSupperLocalPic:(BOOL)isSupperLocalPic
  withSupperHttpPic:(BOOL)isSupperHttpPic withMaxPhotoNum:(NSInteger)maxPhoto delegate:(id<WSPhotoBrowseViewDelegate>)delegateObj
              align:(NSString *)align withDisPlayMode:(NSString *)disPalyMode xbuildInfo:(WSAcvtBean_qst *)xbuildInfo {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.currentFuncs = funcs;
        self.isSupperLocalPhoto = isSupperLocalPic;
        self.isSupperHttpPhoto = isSupperHttpPic;
        self.delegate = delegateObj;
        self.maxPhotoCount = ((maxPhoto > 0) ? maxPhoto : 100);
        
        if (imageIDArray && !isSupperHttpPic) {
            [self.imageIDArray addObjectsFromArray:imageIDArray];
        }
        
        [self setUpView];
        
        if (isSupperHttpPic) {
            [self fetchImagesFromNetWorkWith:imageIDArray];
        }
        else {
            [self reloadData];
        }
    }
    
    return self;
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
}








#pragma mark - 设置视图方法
- (void)setUpView {
    
    UIButton *takePhotoButton = [[UIButton alloc] initWithFrame:CGRectZero];
    takePhotoButton.backgroundColor = [UIColor clearColor];
    [takePhotoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [takePhotoButton setBackgroundImage:[UIImage scaledImageForName:@"take_photo_btn" ofType:@"png"] forState:UIControlStateNormal];
    [self addSubview:takePhotoButton];
    self.takePhotoButton = takePhotoButton;
    
    CGFloat offx = (self.isSupperHttpPhoto ? 0.0f : 15.0f);
    CGFloat wh = (self.isSupperHttpPhoto ? 0.0f : 75.0f);
    takePhotoButton.hidden = (self.isSupperHttpPhoto ? YES : NO);
    [takePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(0.0f);
        make.left.equalTo(self.mas_left).offset(offx);
        make.width.mas_equalTo(wh);
        make.height.mas_equalTo(wh);
    }];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(0.0f);
        make.left.equalTo(self.takePhotoButton.mas_right).offset(15.0f);
        make.right.equalTo(self.mas_right).offset(-15.0f);
        make.bottom.equalTo(self.mas_bottom).offset(0.0f);
    }];
    
    UIView *photoContentView = [[UIView alloc] init];
    photoContentView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:photoContentView];
    self.photoContentView = photoContentView;
    
    [photoContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.height.equalTo(self.scrollView);
    }];
}

#pragma mark - 从网络获取/加载图片方法
- (void)fetchImagesFromNetWorkWith:(NSObject *)value {
    
    [self.photoContentView removeAllSubviews];
    [self.imageIDArray removeAllObjects];
    [self.disImageIDArray removeAllObjects];
    [self.photoViewArray removeAllObjects];
    
    LogInfo(@"WSPhotoBrowseView fetchImagesFromNetWorkWith value = %@", value);
    if (!value) {
        return;
    }
    
    NSMutableArray *tmpImgIdArray = [NSMutableArray array];
    if ([value isKindOfClass:[NSArray class]]) {
        
        NSArray *valueArray = (NSArray *)value;
        [tmpImgIdArray addObjectsFromArray:valueArray];
    }
    else if ([value isKindOfClass:[NSString class]]) {
        
        NSString *valueStr = (NSString *)value;
        NSArray *urlArrays = [valueStr componentsSeparatedByString:@","];
        for (NSInteger i = 0; i < [urlArrays count]; i++) {
            
            NSString *valueStr = [urlArrays objectAtIndex:i];
            NSString *imageUrl = [WSPhotoLogicService getPhotoURLFromServerRedisValue:valueStr];
            if (imageUrl) {
                [tmpImgIdArray addObject:imageUrl];
            }
        }
    }
    
    LogInfo(@"WSPhotoBrowseView fetchImagesFromNetWorkWith tmpImgIdArray = %@", tmpImgIdArray);
    if (tmpImgIdArray.count == 0) {
        return;
    }
    
    for (int index = 0; index < tmpImgIdArray.count; index++) {
        
        NSString *url = [tmpImgIdArray objectAtIndex:index];
        if ([url containsString:@"@"]) {
            url = [WSPhotoLogicService getPhotoURLFromServerRedisValue:url];
        }
        
        NSString *stringURL = [WSHttpURLHelper getImageCompleteURL:url];
        
        NSString *imageID = [self fetchImageIdWithImageUrl:stringURL];
        if (imageID.length == 0) {
            imageID = [[[WSJSONBuilder gen_uuid] md5] lowercaseString];
            [self saveServerRedisImageUrl:stringURL foImageId:imageID];
        }
        
        WSPhotoView *photoView = [[WSPhotoView alloc] initWithFrame:CGRectZero];
        photoView.imageID = imageID;
        photoView.urlStr = stringURL;
        photoView.contentMode = UIViewContentModeScaleAspectFit;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImage:)];
        [photoView addGestureRecognizer:tapGesture];
        
        [self.photoContentView addSubview:photoView];
        [self.photoViewArray addObject:photoView];
        [self.imageIDArray addObject:imageID];
        
        __weak __typeof__(self) weakSelf = self;
        __block NSString *blockImageID = imageID;
        [[WSRequestHelper shareInstance] downloadImageWithUrl:stringURL
                                                    imageView:photoView.imageView
                                             placeholderImage:[UIImage imageNamed:@"photo_loading_failed.png"]
                                                     progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                                                    completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (image && !error) {
                
                if ([strongSelf.delegate respondsToSelector:@selector(photoBrowseView:didLoadNetWorkImageFinish:)]) {
                    [strongSelf.delegate photoBrowseView:strongSelf didLoadNetWorkImageFinish:YES];
                }
                
                NSNumber *imgCompress = [strongSelf getImageCompress];
                [[SDImageCache sharedImageCache] storeImage:image imageImgCompress:imgCompress forKey:blockImageID toDisk:YES toDocument:YES isSynchronized:YES];
            }
        }];
    }
    
    [self reloadAllSubViewLayout];
}

#pragma mark - 重载数据方法
- (void)reloadData {
    
    [self.photoContentView removeAllSubviews];
    [self.photoViewArray removeAllObjects];
    [self getDisplayImageArray];
    
    LogInfo(@"WSPhotoBrowseView reloadData disImageIDArray = %@", self.disImageIDArray);
    
    for (int i = 0; i < [self.disImageIDArray count]; ++i) {
        
        NSString *imageID = [self.disImageIDArray objectAtIndex:i];
        
        WSPhotoView *photoView = [[WSPhotoView alloc] initWithFrame:CGRectZero];
        photoView.imageID = imageID;
        photoView.contentMode = UIViewContentModeScaleAspectFill;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImage:)];
        [photoView addGestureRecognizer:tapGesture];
        
        [self.photoContentView addSubview:photoView];
        [self.photoViewArray addObject:photoView];
        
        if ([WSPhotoLogicService isServerRedisPhoto:imageID]) {
            
            NSString *imgKey = [WSPhotoLogicService getPhotoKeyFromServerRedisValue:imageID];
            UIImage *image = [[SDImageCache sharedImageCache] imageFromKey:imgKey fromDisk:YES];
            if (!image) {
                NSString *urlStr = [WSPhotoLogicService getPhotoURLFromServerRedisValue:imageID];
                image = [[SDImageCache sharedImageCache] imageFromKey:[WSHttpURLHelper getImageCompleteURL:urlStr] fromDisk:YES];
            }
            
            if (image) {
                photoView.imageView.image = image;
            }
            else {
                
                NSString *urlStr = [WSHttpURLHelper getImageCompleteURL:[WSPhotoLogicService getPhotoURLFromServerRedisValue:imageID]];
                __weak __typeof__(self) weakSelf = self;
                [[WSRequestHelper shareInstance] downloadImageWithUrl:urlStr
                                                            imageView:photoView.imageView
                                                     placeholderImage:[UIImage imageNamed:@"photo_loading_failed.png"]
                                                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                                                            completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
                    
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    
                    if (image && !error) {
                        
                        if ([strongSelf.delegate respondsToSelector:@selector(photoBrowseView:didLoadNetWorkImageFinish:)]) {
                            [strongSelf.delegate photoBrowseView:self didLoadNetWorkImageFinish:YES];
                        }
                    }
                }];
            }
        }
        else {
            
            UIImage *image = [[SDImageCache sharedImageCache] imageFromKey:imageID fromDisk:YES];
            photoView.imageView.image = (image ? image : [UIImage imageNamed:@"photo_loading_failed.png"]);
        }
    }
    
    [self reloadAllSubViewLayout];
}

#pragma mark - 重新加载全部子视图布局方法
- (void)reloadAllSubViewLayout {
    
    if (self.photoContentView.subviews.count == 0) {
        return;
    }
    
    if (self.photoContentView.subviews.count == 1) {
        
        WSPhotoView *photoView = [self.photoContentView.subviews firstObject];
        [photoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.photoContentView.mas_top).offset(0.0f);
            make.left.equalTo(self.photoContentView.mas_left).offset(0.0f);
            make.width.mas_equalTo(75.0f);
            make.height.mas_equalTo(75.0f);
            make.right.equalTo(self.photoContentView.mas_right).offset(0.0f);
        }];
        
        return;
    }
    
    WSPhotoView *offPhotoView = nil;
    for (int i = 0; i < self.photoContentView.subviews.count; i++) {
        
        WSPhotoView *photoView = [self.photoContentView.subviews objectAtIndex:i];
        if (i == 0) {
            
            [photoView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.photoContentView.mas_top).offset(0.0f);
                make.left.equalTo(self.photoContentView.mas_left).offset(0.0f);
                make.width.mas_equalTo(75.0f);
                make.height.mas_equalTo(75.0f);
            }];
        }
        else if (i == (self.photoContentView.subviews.count - 1)) {
            
            [photoView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.photoContentView.mas_top).offset(0.0f);
                make.left.equalTo(offPhotoView.mas_right).offset(15.0f);
                make.width.mas_equalTo(75.0f);
                make.height.mas_equalTo(75.0f);
                make.right.equalTo(self.photoContentView.mas_right).offset(0.0f);
            }];
        }
        else {
            
            [photoView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.photoContentView.mas_top).offset(0.0f);
                make.left.equalTo(offPhotoView.mas_right).offset(15.0f);
                make.width.mas_equalTo(75.0f);
                make.height.mas_equalTo(75.0f);
            }];
        }
        
        offPhotoView = photoView;
    }
}

#pragma mark - 设置readOnly方法
- (void)setReadOnly:(BOOL)readOnly {
    
    _readOnly = readOnly;
    
    [self setTakePhotoButtonHidden:(readOnly ? YES : NO)];
}








#pragma mark - 脚本调用相机
- (void)takePhotoAction:(NSString *)sender {
    
    if ([sender isKindOfClass:[NSString class]]) {
        
        NSString *params = (NSString *)sender;
        if ([params isEqualToString:kNotExcuseActionLua]) {
            
            LogInfo(@"WSPhotoBrowseView takePhotoAction: 拍照脚本执行完毕 开始拍照");
            [self showCamera];
        }
    }
}

#pragma mark - 拍照按键相应方法
- (void)takePhoto:(id)sender {
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    BOOL isCantNext = NO;
    if ([self.delegate respondsToSelector:@selector(photoBrowseViewTakePhotoOnClickExecuteScript:)]) {
        isCantNext = [self.delegate photoBrowseViewTakePhotoOnClickExecuteScript:self];
    }
    if (isCantNext) {
        LogInfo(@"WSPhotoBrowseView takePhoto: 拍照脚本校验 需要执行脚本拍照");
        return;
    }
    
    LogInfo(@"WSPhotoBrowseView takePhoto: 点击拍照按键");
    [self showCamera];
}

#pragma mark - 显示相机方法
- (void)showCamera {
    
    if (self.disImageIDArray.count >= self.maxPhotoCount) {
        
        [self showToMaxNumView];
        return;
    }
    
    if (self.isSupperLocalPhoto) {
        
        __weak typeof(self) weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"please_select", nil) message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"camera_capture", nil) style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf sheetAction:EPickerSourceType_Camera];
        }];
        
        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"phone album", nil) style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf sheetAction:EPickerSourceType_Photo];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel_label", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cameraAction];
        [alertController addAction:photoAction];
        [alertController addAction:cancelAction];
        
        [self presentViewControllerWithVc:alertController];
        return;
    }
    
    [self sheetAction:EPickerSourceType_Camera];
}

#pragma mark - 表格选项卡按键响应方法
- (void)sheetAction:(EPickerSourceType)sourceType {
    
    if (sourceType == EPickerSourceType_Camera) {
        
        __weak __typeof__(self) weakSelf = self;
        [WinCameraTools authCameraWithBlock:^(BOOL isAuth) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (isAuth) {
                [strongSelf startCameraOrPhotoWithType:EPickerSourceType_Camera];
            }
            else {
                [strongSelf showAuthorizationDeniedAlertWithType:EPickerSourceType_Camera];
            }
        }];
        
        return;
    }
    
    if (sourceType == EPickerSourceType_Photo) {
        
        __weak __typeof__(self) weakSelf = self;
        [WinCameraTools authPhotoLibraryWithBlock:^(BOOL isAuth) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (isAuth) {
                [strongSelf startCameraOrPhotoWithType:EPickerSourceType_Photo];
            }
            else {
                [strongSelf showAuthorizationDeniedAlertWithType:EPickerSourceType_Photo];
            }
        }];
        
        return;
    }
}

#pragma mark - 启动相机方法
- (void)startCameraOrPhotoWithType:(EPickerSourceType)type {
    
    if (type == EPickerSourceType_Photo) {
        
        NSInteger count = self.maxPhotoCount - self.imageIDArray.count;
        TZImagePickerController *pickerController = [[TZImagePickerController alloc] initWithMaxImagesCount:count delegate:self];
        pickerController.modalPresentationStyle = UIModalPresentationFullScreen;
        pickerController.allowTakePicture = NO;
        pickerController.allowPickingVideo = NO;
        pickerController.allowPickingOriginalPhoto = NO;
        pickerController.allowPreview = NO;
        pickerController.showSelectedIndex = YES;
        
        [self presentViewControllerWithVc:pickerController];
        return;
    }
    
    if (type == EPickerSourceType_Camera) {
        
        if ([WSAlbumAuthHelper isAlbumAuthorize] || [self isPPZTakePhotoType]) {
            
            __weak __typeof__(self) weakSelf = self;
            [WinCameraTools authPhotoLibraryWithBlock:^(BOOL isAuth) {
                
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (isAuth) {
                    [strongSelf jumpCamera];
                }
                else {
                    [strongSelf showAuthorizationDeniedAlertWithType:EPickerSourceType_Photo];
                }
            }];
            
            return;
        }
        
        [self jumpCamera];
        return;
    }
}

#pragma mark - 跳转相机方法
- (void)jumpCamera {
    
    if ([self isPPZTakePhotoType]) {
        [self jumpToPaipaiCamera];
    }
    else {
        [self jumpToNormalCamera];
    }
}

#pragma mark - 跳转trax相机方法
- (void)jumpToPaipaiCamera {
    
    UIViewController *responder = [self getResponderViewController];
    if (!responder) {
        LogInfo(@"WSPhotoBrowseView jumpToPaipaiCamera responder null");
        return;
    }
    
    if (!self.isCreateNewlenz) {
        
        WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
        
        NSString *uuid = [NSString stringNotNilWithValue:self.pz_uuid];
        if (uuid.length == 0 && [self.pz_type isEqualToString:@"4"]) {
            NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
            NSString *time = [WSCurrentTime getDateTime];
            uuid = [NSString stringWithFormat:@"%@_%@", empId, time];
        }
        NSString *storeid = [NSString stringNotNilWithValue:model.currentStore.Id];
        NSString *genId = [NSString stringNotNilWithValue:model.md5];
        
        NSArray *params = @[uuid, storeid, genId];
        NSString *time = [WSCurrentTime getMD5TimeWithDataType:@"E"];
        self.enginekey = [NSString stringWithFormat:@"%@_%@", genId, time];
        self.isCreateNewlenz = [[WSPaiPaiManager sharedInstance] createEngineWithBusinessDataIds:params engineKey:self.enginekey];
    }
    
    BOOL tiltValue = ([self.pz_tiltModel isEqualToString:@"false"] ? NO : YES);
    NSDictionary *extendParamDic = @{tiltKey:[NSNumber numberWithBool:tiltValue], pzMaxKey:[NSNumber numberWithInteger:0]};
    LogInfo(@"WSPhotoBrowseView jumpToPaipaiCamera extendParamDic %@ enginekey %@", extendParamDic, self.enginekey);
    
    [WSPaiPaiManager sharedInstance].delegate = self;
    [[WSPaiPaiManager sharedInstance] jumpToPPZCameraWithPZType:self.pz_type withVc:responder engineKey:self.enginekey extendParam:extendParamDic];
}

#pragma mark - 跳转普通相机方法
- (void)jumpToNormalCamera {
    
    WinCameraContainerViewController *vc = [[WinCameraContainerViewController alloc] init];
    vc.delegate = self;
    vc.scaleWidth = [self getPhotoMaxWidth];
    
    BOOL isImageAddWatermark = [self isImageAddWatermark];
    if (isImageAddWatermark) {
        vc.topWatermarkInfos = [self getTopPhotoWatermarkInfo];
        vc.bottomWatermarkInfos = [self getBottomPhotoWatermarkInfo];
    }
    
    WinCameraNavigationController *nav = [[WinCameraNavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewControllerWithVc:nav];
}

#pragma mark - 照片视图(WSPhotoView)手势点击事件响应方法
- (void)tappedImage:(UIGestureRecognizer *)gestureRecognizer {
    
    UIView *view = [gestureRecognizer view];
    if ([view isKindOfClass:[WSPhotoView class]]) {
        
        WSPhotoView *photoView = (WSPhotoView *)view;
        if ([self.delegate respondsToSelector:@selector(photoBrowseView:didSelectImageId:)]) {
            [self.delegate photoBrowseView:self didSelectImageId:photoView.imageID];
        }
    }
}








#pragma mark - 实现TZImagePickerControllerDelegate--imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:infos:协议(照片选择完毕)
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets
        isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    
    LogInfo(@"WSPhotoBrowseView imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:infos: photos %@", photos);
    
    for (int i = 0; i < photos.count; i++) {
        
        UIImage *image = [photos objectAtIndex:i];
        [self processAndAddImage:image withTraxImgID:nil];
    }
}

#pragma mark - 实现WinCameraContainerDelegate--camera:didFinishWithImage:协议(使用照片)
- (void)camera:(WinCameraContainerViewController *)vc didFinishWithImage:(UIImage *)image {
    
    LogInfo(@"WSPhotoBrowseView camera:didFinishWithImage: image %@", image);
    
    NSString *imageID = [self getImageID];
    [self addImage:image imageID:imageID];
    
    if ([self.qstItem.memo isEqualToString:@"1"]) {
        
        if (self.disImageIDArray.count < self.maxPhotoCount) {
            [vc continueTakePhoto];
            return;
        }
    }

    [vc handleCameraDismiss];
}

#pragma mark - 实现WSPaiPaiManagerDelegate-didFinishImage:withImgID:协议(拍照完成协议-针对trax普通相机)
- (void)didFinishImage:(UIImage *)image withImgID:(NSString *)imgID {
    
    LogInfo(@"WSPhotoBrowseView didFinishImage:withImgID: imgID %@", imgID);
    
    [self processAndAddImage:image withTraxImgID:imgID];
}

#pragma mark - 实现WSPaiPaiManagerDelegate-didFinishPhotoModelArray:协议(拍照完成协议-针对trax拼接相机)
- (void)didFinishPhotoModelArray:(NSArray *)list {
    
    [self.photoContentView removeAllSubviews];
    [self.imageIDArray removeAllObjects];
    [self.photoViewArray removeAllObjects];
    [self getDisplayImageArray];
    
    for (LTImageItem *model in list) {
        
        UIImage *image = [[WSPaiPaiManager sharedInstance] getImageWithModel:model];
        
        NSString *imgId = model.localIdentifier;
        if (imgId.length == 0) {
            
            if ([model.name containsString:@"."]) {
                imgId = [[model.name componentsSeparatedByString:@"."] firstObject];
            }
            else {
                imgId = ((model.name.length == 0) ? @"" : model.name);
            }
        }
        
        [self addImage:image imageID:imgId];
    }
}

#pragma mark - 实现WSPhotoBrowserDelegate--photoBrowserDeletePhoto:协议(删除)
- (void)photoBrowserDeletePhoto:(NSString *)imageID {
    
    if (imageID.length == 0) {
        LogInfo(@"WSPhotoBrowseView photoBrowserDeletePhoto: imageID null");
        return;
    }
    
    NSInteger index = [self.disImageIDArray indexOfObject:imageID];
    if (index == NSNotFound) {
        LogInfo(@"WSPhotoBrowseView photoBrowserDeletePhoto: index null");
        return;
    }
    
    WSPhotoView *imageView = [self.photoViewArray objectAtIndex:index];
    if (![imageView.imageID isEqualToString:imageID]) {
        LogInfo(@"WSPhotoBrowseView photoBrowserDeletePhoto: imageView null");
        return;
    }
    
    LogInfo(@"WSPhotoBrowseView photoBrowserDeletePhoto: imageID %@", imageID);
    
    if ([self isPPZTakePhotoType]) {
        [[WSPaiPaiManager sharedInstance] deleteImageWithImgID:imageID];
    }
    
    [self.disImageIDArray removeObjectAtIndex:index];
    [self.photoViewArray removeObjectAtIndex:index];
    
    index = [self getIndexFromImageIDArray:imageID];
    if (index >= 0) {
        [self.imageIDArray removeObjectAtIndex:index];
    }
    
    [imageView removeFromSuperview];
    [self reloadAllSubViewLayout];
    
    if ([self.delegate respondsToSelector:@selector(photoBrowseView:didDeletedImageForID:)]) {
        [self.delegate photoBrowseView:self didDeletedImageForID:imageID];
    }
}

#pragma mark - 实现WSPhotoBrowserDelegate--photoBrowserEditPhoto:协议(编辑)
- (void)photoBrowserEditPhoto:(NSString *)imageID {
    
    if (imageID == nil) {
        LogInfo(@"WSPhotoBrowseView photoBrowserEditPhoto: imageID null");
        return;
    }
    
    NSInteger index = [self.disImageIDArray indexOfObject:imageID];
    if (index == NSNotFound) {
        LogInfo(@"WSPhotoBrowseView photoBrowserEditPhoto: index null");
        return;
    }
    
    WSPhotoView *imageView = [self.photoViewArray objectAtIndex:index];
    if (![imageView.imageID isEqualToString:imageID]) {
        LogInfo(@"WSPhotoBrowseView photoBrowserEditPhoto: imageView null");
        return;
    }
    
    imageView.imageView.image = [[SDImageCache sharedImageCache] imageFromKey:imageID fromDisk:YES];
}








#pragma mark - 实现UIScrollViewDelegate--scrollViewWillBeginDragging:协议(开始滚动)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (self.superScrollView) {
        self.superScrollView.scrollEnabled = NO;
        return;
    }
    
    UIScrollView *queryScrollView = [self getSuperViewWithView:self];
    if (queryScrollView) {
        self.superScrollView = queryScrollView;
        self.superScrollView.scrollEnabled = NO;
    }
}

#pragma mark - 实现UIScrollViewDelegate--scrollViewDidEndDecelerating:协议(停止滚动)
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (self.superScrollView) {
        self.superScrollView.scrollEnabled = YES;
        self.superScrollView = nil;
    }
}








#pragma mark - 处理照片过程方法
- (void)processAndAddImage:(UIImage *)image withTraxImgID:(NSString *)traxImgID {
    
    if (!image) {
        LogInfo(@"WSPhotoBrowseView processAndAddImage:withTraxImgID: image null");
        return;
    }
    
    CGFloat finalWidth = [self getPhotoMaxWidth];
    UIImage *finalImage = nil;
    
    BOOL isImageAddWatermark = [self isImageAddWatermark];
    if (isImageAddWatermark) {
        
        UIImage *scaleImage = [WinCameraTools scaleImageToWidth:image targetWidth:finalWidth];
                
        BOOL isShrink = ((image.size.width > image.size.height) ? YES : NO);
        NSArray *topWatermarkInfos = [self getTopPhotoWatermarkInfo];
        NSArray *bottomPhotoWatermarkInfo = [self getBottomPhotoWatermarkInfo];
        
        WinCameraWatermarkView *watermarkView = [[WinCameraWatermarkView alloc] init];
        watermarkView.backgroundColor = [UIColor clearColor];
        [watermarkView setFrame:CGRectMake(0.0f, 0.0f, scaleImage.size.width, scaleImage.size.height)];
        [watermarkView setTopCustomizeWatermarkWithInfoArray:topWatermarkInfos isShrink:isShrink];
        [watermarkView setBottomCustomizeWatermarkWithInfoArray:bottomPhotoWatermarkInfo isShrink:isShrink];
        [watermarkView setNeedsLayout];
        [watermarkView layoutIfNeeded];
                
        UIImage *watermarkViewImage = [WinCameraTools imageFromView:watermarkView];
        UIImage *mergeImage = [WinCameraTools mergeImage:scaleImage withOverlayImage:watermarkViewImage];
        finalImage = mergeImage;
    }
    else {
        
        finalImage = [WinCameraTools scaleImageToWidth:image targetWidth:finalWidth];
    }
    
    if (!finalImage) {
        LogInfo(@"WSPhotoBrowseView processAndAddImage:withTraxImgID: finalImage null");
        return;
    }
    
    NSString *imageID = ([self isPPZTakePhotoType] ? traxImgID : [self getImageID]);
    [self addImage:finalImage imageID:imageID];
}

#pragma mark - 添加图片到视图方法
- (void)addImage:(UIImage *)image imageID:(NSString *)imageID {
    
    if (imageID.length == 0) {
        LogInfo(@"WSPhotoBrowseView addImage:imageID:display imageID null");
        return;
    }
        
    if (!image) {
        
        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageID];
        if (!image) {
            LogInfo(@"WSPhotoBrowseView addImage:imageID:display image null");
            return;
        }
    }
    
    NSNumber *imgCompress = [self getImageCompress];
    [[SDImageCache sharedImageCache] storeImage:image imageImgCompress:imgCompress forKey:imageID toDisk:YES toDocument:YES isSynchronized:YES];
    
    LogInfo(@"WSPhotoBrowseView addImage:imageID:display imageID %@", imageID);
    [self.imageIDArray addObject:imageID];
    [self getDisplayImageArray];

    WSPhotoView *photoView = [[WSPhotoView alloc] initWithFrame:CGRectZero];
    photoView.contentMode = UIViewContentModeScaleAspectFill;
    photoView.imageID = imageID;
    photoView.imageView.image = image;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImage:)];
    [photoView addGestureRecognizer:tapGesture];
    
    [self.photoContentView addSubview:photoView];
    [self.photoViewArray addObject:photoView];
    
    [self reloadAllSubViewLayout];
    
    if ([WSAlbumAuthHelper isAlbumAuthorize]) {
        
        __block UIImage *blockFinalImage = image;
        dispatch_async(dispatch_get_main_queue(), ^{
            [WSAlbumAuthHelper savePhotoWithImage:blockFinalImage];
        });
    }
        
    if ([self.delegate respondsToSelector:@selector(photoBrowseView:didAddedImageForID:)]) {
        [self.delegate photoBrowseView:self didAddedImageForID:imageID];
    }
}








#pragma mark - 获取指定id标识索引位置方法
- (NSInteger)getIndexFromImageIDArray:(NSString *)imageID {
    
    for (int i = 0; i < self.imageIDArray.count; i ++) {
        
        if (self.imageIDArray[i] == imageID) {
            return i;
        }
    }
    
    return -1;
}

#pragma mark - 去除原始图片ID数据方法
- (void)getDisplayImageArray {
    
    [self.disImageIDArray removeAllObjects];
    
    for (NSInteger i = 0; i < self.imageIDArray.count; i++) {
        
        NSString *imageID = self.imageIDArray[i];
        if (![imageID containsString:KImageIDSuffix]) {
            [self.disImageIDArray addObject:imageID];
        }
    }
}

#pragma mark - 获取图片ID方法
- (NSString *)getImageID {
    
    NSString *newImageID = [[[WSJSONBuilder gen_uuid] md5] lowercaseString];
    return newImageID;
}

#pragma mark - 设置拍照按键是否隐藏方法
- (void)setTakePhotoButtonHidden:(BOOL)isHidden {
    
    if (self.isSupperHttpPhoto) {
        return;
    }
    
    self.takePhotoButton.hidden = isHidden;
    
    CGFloat offx = (isHidden ? 0.0f : 15.0f);
    CGFloat wh = (isHidden ? 0.0f : 75.0f);
    [self.takePhotoButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(0.0f);
        make.left.equalTo(self.mas_left).offset(offx);
        make.width.mas_equalTo(wh);
        make.height.mas_equalTo(wh);
    }];
}

#pragma mark - 查找照片id(依据照片url)方法
- (NSString *)fetchImageIdWithImageUrl:(NSString *)urlStr {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *imageId = [userDefaults objectForKey:urlStr];
    return imageId;
}

#pragma mark - 存储照片id(依据照片url)方法
- (void)saveServerRedisImageUrl:(NSString *)url foImageId:(NSString *)imageId {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:imageId forKey:url];
    [userDefaults synchronize];
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

#pragma mark - 显示最大照片数量提醒方法
- (void)showToMaxNumView {
    
    NSString *hint1 = NSLocalizedString(@"camera_max_capture_hint1", nil);
    NSString *hint2 = NSLocalizedString(@"camera_max_capture_hint2", nil);
    NSString *msg = [NSString stringWithFormat:@"%@%ld%@", hint1, self.maxPhotoCount, hint2];
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}

#pragma mark - 是否trax类型方法
- (BOOL)isPPZTakePhotoType {
    
    if ([self.pz_type isEqualToString:PPCamera_connect] ||
        [self.pz_type isEqualToString:PPCamera_Normal] ||
        [self.pz_type isEqualToString:PPCamera_StoreFP]) {
        return YES;
    }
    return NO;
}

#pragma mark - 显示授权拒绝提醒方法
- (void)showAuthorizationDeniedAlertWithType:(EPickerSourceType)type {
    
    if (type != EPickerSourceType_Camera && type != EPickerSourceType_Photo) {
        return;
    }
    
    LogInfo(@"WSPhotoBrowseView showAuthorizationDeniedAlertWithType: = %d", type);
    
    NSString *title = NSLocalizedString(@"js_alert_title", nil);
    NSString *confirm = NSLocalizedString(@"confirm", nil);
    NSString *message = ((type == EPickerSourceType_Camera) ? NSLocalizedString(@"photo_permission", nil) : NSLocalizedString(@"album_permission", nil));

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:confirm style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:confirmAction];
    
    [self presentViewControllerWithVc:alertController];
}

#pragma mark - 是否需要增加水印方法
- (BOOL)isImageAddWatermark {
    
    NSString *userDefaultsMark = [NSString stringWithValue:[[NSUserDefaults standardUserDefaults] objectForKey:IMAGE_WATERMARK]];
    NSString *qstItemMark = [NSString stringWithValue:self.qstItem.is_not_water_mark];
    
    BOOL isImageAddWatermark = NO;
    if ([qstItemMark isEqualToString:@"1"]) {
        isImageAddWatermark = NO;
    }
    else if ([qstItemMark isEqualToString:@"0"] || [userDefaultsMark isEqualToString:@"1"]) {
        isImageAddWatermark = YES;
    }
    else {
        isImageAddWatermark = NO;
    }
    
    return isImageAddWatermark;
}

#pragma mark - 获取应答者视图管理器方法
- (UIViewController *)getResponderViewController {
    
    for (UIView *next = [self superview]; next; next = next.superview) {
        
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    
    return nil;
}

#pragma mark - 模态呈现视图管理器方法
- (void)presentViewControllerWithVc:(UIViewController *)vc {
        
    if (!vc) {
        return;
    }
    
    UIViewController *responderVc = [self getResponderViewController];
    if (responderVc) {
        [responderVc presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    if (self.viewController) {
        [self.viewController presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(photoBrowseView:presentViewController:animated:)]) {
        [self.delegate photoBrowseView:self presentViewController:vc animated:YES];
    }
}

#pragma mark - 获取照片上方水印信息方法
- (NSArray *)getTopPhotoWatermarkInfo {
    
    WinWatermarkInfo *info1 = [[WinWatermarkInfo alloc] init];
    info1.tilteInfo = APP_DISPLAY_NAME;
    info1.tilteFontSize = 12.0f;
    
    WinWatermarkInfo *info2 = [[WinWatermarkInfo alloc] init];
    info2.tilteInfo = [WSCurrentTime getShortTimeString];
    info2.tilteFontSize = 24.0f;
    
    WinWatermarkInfo *info3 = [[WinWatermarkInfo alloc] init];
    info3.tilteInfo = [WSCurrentTime getLocalizedWeekAndDateStringFormatDot];
    info3.tilteFontSize = 12.0f;
    
    NSArray *infoArray = [[NSArray alloc] initWithObjects:info1, info2, info3, nil];
    return infoArray;
}

#pragma mark - 获取照片下方水印信息方法
- (NSArray *)getBottomPhotoWatermarkInfo {
    
    NSMutableArray *infoArray = [[NSMutableArray alloc] init];
    
    NSString *qstName = [self getQstName];
    if (qstName.length > 0) {
        
        WinWatermarkInfo *info = [[WinWatermarkInfo alloc] init];
        info.tilteInfo = qstName;
        info.tilteFontSize = 12.0f;
        
        [infoArray addObject:info];
    }
    
    NSString *funcName = [self getFuncName];
    if (funcName.length > 0) {
        
        WinWatermarkInfo *info = [[WinWatermarkInfo alloc] init];
        info.tilteInfo = funcName;
        info.tilteFontSize = 12.0f;
        
        [infoArray addObject:info];
    }
    
    NSString *empName = [self getEmpName];
    if (empName.length > 0) {
        
        WinWatermarkInfo *info = [[WinWatermarkInfo alloc] init];
        info.tilteInfo = empName;
        info.tilteFontSize = 12.0f;
        
        [infoArray addObject:info];
    }
    
    NSString *sql = @"select * from ws_base_store_table where store_Id = '-1'";
    NSArray *sqlStoreBeanArray = [[WSBaseStoreTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSStoreBean"];
    WSStoreBean *sqlStoreBean = [sqlStoreBeanArray firstObject];
    
    NSString *storeCodeName = [self getStoreCodeNameWithStoreBean:sqlStoreBean];
    if (storeCodeName.length > 0) {
        
        WinWatermarkInfo *info = [[WinWatermarkInfo alloc] init];
        info.tilteInfo = storeCodeName;
        info.tilteFontSize = 12.0f;
        
        [infoArray addObject:info];
    }
    
    NSString *storeLocation = [self getStoreLocation];
    if (storeLocation.length > 0) {
        
        WinWatermarkInfo *info = [[WinWatermarkInfo alloc] init];
        info.tilteInfo = storeLocation;
        info.tilteFontSize = 12.0f;
        
        [infoArray addObject:info];
    }
    
    NSString *storeAddress = [self getStoreAddressWithStoreBean:sqlStoreBean];
    if (storeAddress.length > 0) {
        
        WinWatermarkInfo *info = [[WinWatermarkInfo alloc] init];
        info.tilteInfo = storeAddress;
        info.tilteFontSize = 12.0f;
        info.iconImage = [UIImage imageInBundleNamed:@"LocationWatermarkCamera"];
        
        [infoArray addObject:info];
    }
    
    NSString *userAddress = [self getUserAddress];
    if (userAddress.length > 0) {
        
        WinWatermarkInfo *info = [[WinWatermarkInfo alloc] init];
        info.tilteInfo = userAddress;
        info.tilteFontSize = 12.0f;
        info.iconImage = [UIImage imageInBundleNamed:@"LocationWatermarkCamera"];
        
        [infoArray addObject:info];
    }
    
    NSArray *luaWaterInfos = [self getLuaWaterInfos];
    for (int i = 0; i < luaWaterInfos.count; i++) {
        
        id infoObj = [luaWaterInfos objectAtIndex:i];
        if ([infoObj isKindOfClass:[NSString class]]) {

            NSString *infoStr = (NSString *)infoObj;
            if (infoStr.length > 0) {
                
                WinWatermarkInfo *info = [[WinWatermarkInfo alloc] init];
                info.tilteInfo = infoStr;
                info.tilteFontSize = 12.0f;
                
                [infoArray addObject:info];
            }
        }
    }
    
    return infoArray;
}

#pragma mark - 获取问题名称方法
- (NSString *)getQstName {
    
    return (self.currentFuncs.opt.isQstName ? self.qstItem.qstName : @"");
}

#pragma mark - 获取菜单名称方法
- (NSString *)getFuncName {
    
    id model = [WSDataSourceManager sharedInstance].currentActiveModel;
    
    if ([model isKindOfClass:[WSEnterStoreAcvtModel class]]) {
        
        WSEnterStoreAcvtModel *enterStoreAcvtModel = (WSEnterStoreAcvtModel *)model;
        return enterStoreAcvtModel.currentFuncs.name;
    }
    
    if ([model isKindOfClass:[WSAcvtModel class]]) {
        
        WSAcvtModel *acvtModel = (WSAcvtModel *)model;
        return acvtModel.currentAcvtBean.acvtName;
    }
    
    return nil;
}

#pragma mark - 获取用户名称方法
- (NSString *)getEmpName {
    
    NSString *empName = [WSAppData getObjectbyKey:EMPNAME];
    NSString *serverRequireStr = [WSAppData getObjectbyKey:SERVERREQUIRE];
    
    NSData *serverRequireData = [serverRequireStr dataUsingEncoding:NSUTF8StringEncoding];
    id serverRequireObject = [NSJSONSerialization JSONObjectWithData:serverRequireData options:NSJSONReadingMutableContainers error:nil];
    if ([serverRequireObject isKindOfClass:[NSArray class]]) {
        
        id serverRequireDic = [(NSArray *)serverRequireObject firstObject];
        if ([serverRequireDic isKindOfClass:[NSDictionary class]]) {
            
            id empOrgCodesArray = [(NSDictionary *)serverRequireDic objectForKey:@"empOrgCodes"];
            if ([empOrgCodesArray isKindOfClass:[NSArray class]]) {
                
                id orgCodeDic = [(NSArray *)empOrgCodesArray firstObject];
                if ([orgCodeDic isKindOfClass:[NSDictionary class]]) {
                    
                    NSString *orgCode = [(NSDictionary *)orgCodeDic objectForKey:@"orgCode"];
                    if (orgCode.length > 0) {
                        empName = [NSString stringWithFormat:@"%@ %@", empName, orgCode];
                    }
                }
            }
        }
    }
    
    return empName;
}

#pragma mark - 获取门店名称方法
- (NSString *)getStoreCodeNameWithStoreBean:(WSStoreBean *)storeBean {
    
    NSString *storeCode = nil;
    NSString *storeName = nil;
    NSString *storeCodeName = nil;
    
    if (!self.currentStore.isFakeStore && self.currentStore.name && self.currentStore.name.length > 0) {
        storeCode = self.currentStore.code;
        storeName = self.currentStore.name;
    }
    else if (storeBean) {
        storeCode = storeBean.code;
        storeName = storeBean.name;
    }
    
    if (storeCode.length > 0 && storeName.length > 0) {
        storeCodeName = [NSString stringWithFormat:@"%@ %@", storeCode, storeName];
    }
    else {
        storeCodeName = storeName;
    }
    
    return storeCodeName;
}

#pragma mark - 获取门店位置方法
- (NSString *)getStoreLocation {
    
    NSString *storeLocation = nil;
    if ([self.qstItem.locationType isEqualToString:@"3"]) {
        
        WSLocationDescribe *locationDesrible = [WSLocationManager getInstance].lastLocation;
        CLLocationCoordinate2D coordinate = locationDesrible.location.coordinate;
        storeLocation = [NSString stringWithFormat:@"%f %f", coordinate.latitude, coordinate.longitude];
    }
    else if ([self.qstItem.locationType isEqualToString:@"5"]) {
        
        WSLocationDescribe *locationDesrible = [WSLocationManager getInstance].lastLocation;
        storeLocation = locationDesrible.detailAddress;
    }
    
    return storeLocation;
}

#pragma mark - 获取门店地址方法
- (NSString *)getStoreAddressWithStoreBean:(WSStoreBean *)storeBean {
    
    NSString *storeAddress = nil;
    if (!self.currentStore.isFakeStore && self.currentStore.name && self.currentStore.name.length > 0) {
        storeAddress = self.currentStore.addr;
    }
    else if (storeBean) {
        storeAddress = storeBean.addr;
    }
    
    id model = [WSDataSourceManager sharedInstance].currentActiveModel;
    if ([model isKindOfClass:[WSAcvtModel class]]) {
        
        WSAcvtModel *acvtModel = (WSAcvtModel *)model;
        storeAddress = acvtModel.currentStore.currentAddress;
    }
    
    if ([self.qstItem.locationType isEqualToString:@"1"]) {
        
        WSLocationDescribe *locationDesrible = [WSLocationManager getInstance].lastLocation;
        storeAddress = locationDesrible.detailAddress;
    }
    
    return storeAddress;
}

#pragma mark - 获取用户地址方法
- (NSString *)getUserAddress {
    
    WSLocationDescribe *locationDesrible = [WSLocationManager getInstance].lastLocation;
    return locationDesrible.detailAddress;
}

#pragma mark - 获取lua脚本信息方法
- (NSArray *)getLuaWaterInfos {
    
    NSString *luaWaterMark = [self.luaWaterMark stringByReplacingOccurrencesOfString:@"@&@" withString:@"\n"];
    return [luaWaterMark componentsSeparatedByString:@"\n"];
}

#pragma mark - 获取配置图片宽度方法
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

#pragma mark - 获取照片最大宽度方法
- (CGFloat)getPhotoMaxWidth {
        
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat configurationWidth = [self getImageShootWidth].floatValue;
    CGFloat finalWidth = ((configurationWidth >= screenWidth) ? configurationWidth : screenWidth);
    
    return finalWidth;
}

#pragma mark - 查询父级别滚动视图方法
- (UIScrollView *)getSuperViewWithView:(UIView *)view {
    
    UIView *superView = view.superview;
    while (superView) {
        
        if (superView && [superView isKindOfClass:[UIScrollView class]] && ![superView isKindOfClass:[WSAcvtScrollView class]]) {
            return (UIScrollView *)superView;
        }
        superView = superView.superview;
    }
    
    return nil;
}

#pragma mark - 添加图片方法(.h方法 暂时无业务逻辑操作)
- (void)addImageID:(NSString *)imageID withImage:(UIImage *)image {
    
}

#pragma mark - 删除全部图片方法(.h方法)
- (void)deleteAllImage {
    
    for (WSPhotoView *imgItem in self.photoViewArray) {
        
        if ([self.delegate respondsToSelector:@selector(photoBrowseView:didDeletedImageForID:)]) {
            [self.delegate photoBrowseView:self didDeletedImageForID:imgItem.imageID];
        }
    }
    
    [self.imageIDArray removeAllObjects];
    [self.photoViewArray removeAllObjects];
    
    if ([self isPPZTakePhotoType]) {
        [[WSPaiPaiManager sharedInstance] deleteTraxAllImageList];
    }
    
    [self reloadData];
}

@end
//=============================================================================================================================
