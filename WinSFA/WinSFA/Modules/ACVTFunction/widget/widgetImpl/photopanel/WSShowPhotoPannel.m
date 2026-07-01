//
//  WSShowPhotoPannel.m
//  WinSFA
//
//  Created by heju on 15/11/12.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSShowPhotoPannel.h"
#import "I_W_BuildInfo.h"

#import "WSServerIPList.h"
#import "I_W_DisplayValue.h"
#import "WSPhotoBrowseView.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "WSInterAction.h"
#import "WCDownLoadingAndShowingImageView.h"
#import "WSPhotoView.h"
#import "WSEmptyView.h"


#define K_TIP_LABEL_WIDTH 80

#define K_TIP_LABEL_HEIGHT 30


@interface WSShowPhotoPannel ()<WSPhotoBrowseViewDelegate,WCDownLoadingAndShowingImageViewDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) UIViewController *bowserImageVC;
@property (nonatomic,strong) UIScrollView *iScrollView;
@property (nonatomic,strong) WSPhotoBrowseView *photoBrowseView;
@property (nonatomic,strong) UILabel *tiplabel;
@property (nonatomic , strong) WSEmptyView *emptyView;


@end


@implementation WSShowPhotoPannel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        return self;
    }
    return  nil;
}


- (void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo {
    [super loadBuildInfo:buildInfo];
}

- (void)buildDisplayContent {
    
    [super buildDisplayContent];
    
//    BOOL orientation = NO;
//
//    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
//        orientation = YES;
//    }
    
    
    NSArray *imagePathArray = nil;
    
    NSString *imagePathStr = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    
    if ([imagePathStr length] > 0) {
        imagePathArray = [imagePathStr componentsSeparatedByString:@","];
        _originalValue = imagePathStr;
    }
    CGFloat y = self.titleLabel.frame.size.height;

    if ([imagePathArray count] < 1) {
        imagePathArray = [[xbuildInfo getDefaultValue] componentsSeparatedByString:@","];
        _originalValue = [xbuildInfo getDefaultValue];
       
        
    }
    
    CGFloat photoViewH = PHOTO_PANEL_HEIGHT;
    if ([[xbuildInfo getDisplayMode] isEqualToString:@"newStyle"]) {
        photoViewH = (self.width - 20)*9/16 +15;
    }
    
    _photoView = [[WSPhotoBrowseView alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.bounds), photoViewH)
                                                     funs:[self getAcvtModel].currentFuncs
                                         withImageIDArray:imagePathArray
                                       withSupperLocalPic:NO
                                        withSupperHttpPic:YES
                                          withMaxPhotoNum:[xbuildInfo getMaxPhoto] > 0 ? [xbuildInfo getMaxPhoto] : [[xbuildInfo getMlen] integerValue]
                                                 delegate:nil
                                                    align:nil
                                          withDisPlayMode:[xbuildInfo getDisplayMode]];
    _photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _photoView.delegate = self;
    _photoView.currentStore = [self getAcvtModel].currentStore;
    [self addSubview:_photoView];
  
    //SFA-24115 2018-10-09
    if (imagePathArray.count > 0) {
        [self addSubview:_photoView];
        [self setFrame:CGRectMake(MAIN_CELL_PADDING, CGRectGetMinY(self.frame), CGRectGetWidth(self.bounds) - 2 * MAIN_CELL_PADDING, photoViewH + y)];
    }
    else {
        if (self.titleLabel && self.titleLabel.text.length > 0) {
            [self setFrame:CGRectMake(MAIN_CELL_PADDING, CGRectGetMinY(self.frame), CGRectGetWidth(self.bounds) - 2 * MAIN_CELL_PADDING, y)];
        }
        else {
            [self setFrame:CGRectMake(MAIN_CELL_PADDING, CGRectGetMinY(self.frame), CGRectGetWidth(self.bounds) - 2 * MAIN_CELL_PADDING, PHOTO_PANEL_HEIGHT + y)];
            [self emptyViewIsShowWithImagePath:imagePathArray];
        }
    }
}

- (void)emptyViewIsShowWithImagePath:(id)imagePath
{
    //     MMSH-4596 - 【IOS】完美门店成功图像查看小图时，没有维护图片的类别需要显示暂无数据字样
    BOOL isHidden = NO;
    NSArray *imagePathArray = nil;
    if ([imagePath isKindOfClass:[NSString class]]) {
        imagePathArray = [(NSString *)imagePath componentsSeparatedByString:@","];
    } else if ([imagePath isKindOfClass:[NSArray class]]) {
        imagePathArray = (NSArray *)imagePath;
    }
    if (imagePathArray.count > 0) {
        isHidden = YES;
//       MMSH-5223 SFA玛氏中国iOS手机端门店拜访完美成功图像打开无照片
//        return;
    }
    if (!self.emptyView) {
        self.emptyView = [[WSEmptyView alloc] initWithFrame:self.bounds];
        [self addSubview:self.emptyView];
    }
    self.emptyView.hidden =isHidden;
}

- (WSAcvtModel *) getAcvtModel
{
    WSAcvtModel *acvtModel = nil;
    
    if ([[WSDataSourceManager sharedInstance].currentActiveModel isKindOfClass:[WSAcvtModel class]]) {
        
        acvtModel = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    }
    
    return acvtModel;
    
}

- (void)photoBrowseView:(WSPhotoBrowseView *)photoBrowseView didSelectImageId:(NSString *)imageId {
    if (!photoBrowseView.imageIDArray || !imageId) {
        return;
    }
    if (self.photoBrowseView == nil) {
        self.photoBrowseView = photoBrowseView;
        _bowserImageVC = [[UIViewController alloc]init];
        self.bowserImageVC.view.backgroundColor = [UIColor  blackColor];
        
        CGRect screen = [UIScreen mainScreen].bounds;
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screen.size.width , screen.size.height)];
        scrollView.delegate = self;
        scrollView.multipleTouchEnabled = YES;
        scrollView.pagingEnabled = YES;
        scrollView.contentSize = CGSizeMake([photoBrowseView.imageIDArray count] *screen.size.width, screen.size.height);
        scrollView.backgroundColor = [UIColor clearColor];
        self.iScrollView = scrollView;
        [self.bowserImageVC.view addSubview:scrollView];
        
        for (NSInteger i = 0; i < [photoBrowseView.photoViewArray count]; i++) {
            
            WSPhotoView *photoView = photoBrowseView.photoViewArray[i];
            WCDownLoadingAndShowingImageView *view = [[WCDownLoadingAndShowingImageView alloc] initWithFrame:screen
                                                                                                withImageURL:nil
                                                                                                   withImage:photoView.imageView.image
                                                                                                withDuration:0
                                                                                             withProductName:@""];
            view.frame = CGRectMake(screen.size.width * i, 0, screen.size.width, screen.size.height);
            view.closeButton.hidden = YES;
            view.delegate = self;
            [scrollView addSubview:view];
        }
        
        _tiplabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH -  K_TIP_LABEL_WIDTH)/2, SCREEN_HEIGHT - K_TIP_LABEL_HEIGHT *1.5, K_TIP_LABEL_WIDTH, K_TIP_LABEL_HEIGHT)];
        _tiplabel.textAlignment = NSTextAlignmentCenter;
        _tiplabel.textColor = [UIColor whiteColor];
        _tiplabel.font = [UIFont systemFontOfSize:UI_Font];
        [self.bowserImageVC.view addSubview:self.tiplabel];
    }
    [self selectedPage:imageId];
    self.bowserImageVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.bowserImageVC];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}


- (void)selectedPage:(NSString *)imageId {
    NSArray *imageIds = [self.photoBrowseView.photoViewArray valueForKeyPath:@"@unionOfObjects.imageID"];
    NSInteger imageIdIndex = [imageIds indexOfObject:imageId];
    self.tiplabel.text = [NSString stringWithFormat:@"(%ld/%lu)",(long)(imageIdIndex+1),(unsigned long)[imageIds count]];
    [self.iScrollView setContentOffset:CGPointMake(SCREEN_WIDTH*imageIdIndex, 0)];
}

-(void)presentViewController:(UIViewController *)controller{
    
    WSInterAction  *interaction =[[WSInterAction alloc] init];
    [interaction setAcvt_qust_id:[xbuildInfo  getAcvtQstId]];
    [interaction setExecute_controller:controller];
    [interaction setDirect_type:DIRECT_TYPE_PRESENT];
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        [delegate executeInterAction:interaction];
    }
}

- (NSObject *)getResultDirectly {
    return _originalValue;
}

//MN-3265
//ios-申请完待办不显示图标
- (NSObject *)getPrepareSaveData {
    return _originalValue;
}

#pragma mark UIScrollViewDelegate Method

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.tiplabel.text = [NSString stringWithFormat:@"(%ld/%lu)",(long)page+1,(unsigned long)[self.photoBrowseView.imageIDArray count]];
    
}


#pragma mark WCDownLoadingAndShowingImageViewDelegate Methods
- (void)touchShowImageViewEnd:(UIView *)view {
    if (self.bowserImageVC) {
        /*
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
         */
        WSInterAction  *interaction =[[WSInterAction alloc] init];
        [interaction setAcvt_qust_id:[xbuildInfo  getAcvtQstId]];
        [interaction setDirect_type:DIRECT_TYPE_DISMISS];
        if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
            [delegate executeInterAction:interaction];
        }
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}
-(void)reloadCurrentWidgetWithValue:(NSObject *)value {
    // 对self.photoView进行操作

    if (value) {
        [self.photoView fetchImagesFromNetWorkWith:value];
    }
    //    MMSH-4596
    //    【IOS】完美门店成功图像查看小图时，没有维护图片的类别需要显示暂无数据字样
    [self emptyViewIsShowWithImagePath:value];
    
}
- (void)widgetDidLoadFinish{
    
    if (self.fixedHeight) {
        [self.photoView setFrame:CGRectMake(self.photoView.origin.x, self.photoView.origin.y, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/




@end
