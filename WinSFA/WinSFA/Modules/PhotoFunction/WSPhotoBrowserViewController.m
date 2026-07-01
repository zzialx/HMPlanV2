//
//  PhotoBrowserViewController.m
//  PhotoBrowserTest
//
//  Created by Jiepeng Zheng on 12-8-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSPhotoBrowserViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WSEditImageView.h"
#import "WSViewForWebImage.h"
#import "WSPhotoLogicService.h"
#import "WSShareItem.h"
#import "WSBottomPopView.h"
#import "WWKApi.h"
#import "WSEnvrionment.h"
@interface WSPhotoBrowserViewController ()
{
    NSInteger currentPage;
    BOOL barHidden;
    CGRect viewBounds;
    UITapGestureRecognizer *tapGesture;
}

@property (nonatomic,strong) UIButton* editButton;
@property (nonatomic,strong) UIView* statusView;


@end

@implementation WSPhotoBrowserViewController
-(void)loadShareView{
    
    NSMutableArray *items = [NSMutableArray array];
    //获取微信appid
    NSDictionary * infoDic = [[NSBundle mainBundle]infoDictionary];
    NSArray *CFBundleURLTypes = [infoDic objectForKey:@"CFBundleURLTypes"];
    
    for (NSDictionary *obj in CFBundleURLTypes) {
        NSString *bundleURLName = obj[@"CFBundleURLName"];
        if ([bundleURLName isEqualToString:@"weixin"]) {
            
            NSArray *urlSchemes = obj[@"CFBundleURLSchemes"];
            NSString *appId = [urlSchemes firstObject];
            if (appId && appId.length > 0 ) {
                WSShareItem * item = [[WSShareItem alloc]initWithTitle:NSLocalizedString(@"wechat", nil)  Icon:@"icon_wechat"];
                [items addObject:item];
                
                WSShareItem * item2 = [[WSShareItem alloc]initWithTitle:NSLocalizedString(@"朋友圈", nil)  Icon:@"icon_moments"];
                [items addObject:item2];
            }
        } else if ([bundleURLName isEqualToString:@"qyweixin"]) {
            
            WSShareItem * itemSms = [[WSShareItem alloc]initWithTitle:NSLocalizedString(@"wxworkwechat", nil) Icon:@"WechatIMG"];
            [items addObject:itemSms];
        }
       
    }
    //添加popview
    [WSBottomPopView showToView:self.view.window withItems:(NSArray *)items andSelectBlock:^(WSShareItem *item) {
    
          
        }];
    
}
- (void)deleteButtonClick:(id)sender
{
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"confirm_delete_dialog_title", nil)];
    
    [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
    
    [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowserDeletePhoto:)]) {
            if (_imageIDs) {
                if (currentPage < [_imageIDs count]) {
                    NSString *deleteImageId = [_imageIDs objectAtIndex:currentPage];
                    [self.delegate photoBrowserDeletePhoto:deleteImageId];
                    // SFA-22788
                    //SFA-立白 ios经销商拜访-门店检查-常规陈列，删除照片app闪退
                    //    SFA-22361  donghong 修改换位 顺手改正预览
                    // SFA-22790 (防止移除多次)
                    if ([_imageIDs containsObject:deleteImageId]) {
                        [_imageIDs removeObjectAtIndex:currentPage];
                    }
                }
            }
        }
        
        if ([self getImageCount] == 0)
        {
            [self doneButtonClick:nil];
            return;
        }
        
        for (UIView *subView in [_myScrollView subviews])
        {
            [subView removeFromSuperview];
        }
        
        [self setUpViews];
        [self creatPages];
        _myScrollView.contentSize = CGSizeMake(viewBounds.size.width * [self getImageCount], viewBounds.size.height);
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self.navigationBar setHidden:NO];
        [self.statusView setHidden:NO];

        //[self.toolBar setHidden:NO];
        barHidden = NO;

    }];
    
    [alert show];
    

}

- (id)initWithImages:(NSMutableArray *)images
{
    self = [super init];
    if (self)
    {
        _images = images;
        barHidden = NO;
        _isAllowDeletePhoto = YES;
    
       
    }
    return self;
}

- (id)initWithImageIDs:(NSMutableArray *)imageIDs
{
    if (!imageIDs) {
        return nil;
    }
    self = [super init];
    if (self)
    {
        _imageIDs = imageIDs;
        barHidden = NO;
        _isAllowDeletePhoto = YES;
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    float navWidth = self.view.width;
    if (INTERFACE_IS_PAD) {
        if (self.view.width < self.view.height) {
            navWidth = self.view.height;
        }
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, navWidth, IPHONE_X ? 44 : 20)];
    [view setBackgroundColor:MAIN_TINT_COLOR];
    [self.view addSubview:view];
    self.statusView = view;
    
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, IPHONE_X ? 44 : 20, navWidth, 44)];
    self.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    NSInteger imageCount = [self getImageCount];
    NSString *title = nil;
    if (imageCount > 1) {
        title = [NSString stringWithFormat:@"%ld/%ld", (long)currentPage + 1, (long)imageCount];
    }else{
        title = NSLocalizedString(@"photo_preview", nil);
    }
    self.myNavigationItem = [[UINavigationItem alloc] initWithTitle:title];
    /*SFA-15629 SFA 默沙东：ipad 门店拜访->今日经销商，拍照里面的照片放大没法删除。*/
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneBtn setFrame:CGRectMake(MAIN_BUTTON_WH, 0 , MAIN_BUTTON_WH, 44)];
    [doneBtn addTarget:self action:@selector(doneButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setTintColor:[UIColor whiteColor]];
    [doneBtn setImage:[[UIImage scaledImageForName:@"icon_back" ofType:@"png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
    self.myNavigationItem.leftBarButtonItem = leftItem;
    
   [self.navigationBar setItems:@[self.myNavigationItem]];
    [self.view addSubview:self.navigationBar];
    
    
   self.navigationBar.barTintColor = [UIColor redColor];
   [self.navigationBar setBackgroundImage:[UIImage imageFromColor:MAIN_TINT_COLOR with:self.navigationBar.bounds] forBarMetrics:UIBarMetricsDefault];
//
//    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - 44, navWidth, 44)];
//    if (IOS7_OR_LATER) {
//        self.toolBar.barTintColor = [UIColor colorForKey:@"NavigationBarBackgroundColor"];
//        self.toolBar.tintColor = [UIColor colorForKey:@"NavigationBarButtonTitleColor"];
//    }else {
//        self.toolBar.tintColor = self.navigationBar.tintColor;
//    }
//    
//    self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    if (self.isAllowDeletePhoto) {
//        UIBarButtonItem *blankItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//        UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButtonClick:)];
//        deleteItem.tintColor = [UIColor colorForKey:@"NavigationBarButtonTitleColor"];
//       [self.toolBar setItems:@[blankItem,deleteItem]];
//    }
//    [self.view addSubview:self.toolBar];
    
}

- (void)addRightBar{
    
    self.myNavigationItem.rightBarButtonItems= nil;
    NSMutableArray *rightItemArray = [NSMutableArray array];
    if (self.isAllowDeletePhoto) {
        UIButton *deletBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deletBtn setFrame:CGRectMake(0, 0, 22, 22)];
        [deletBtn addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [deletBtn setImage:[UIImage scaledImageForName:@"icon_delete" ofType:@"png"] forState:UIControlStateNormal];
        UIBarButtonItem *deletItem = [[UIBarButtonItem alloc]initWithCustomView:deletBtn];
        [rightItemArray addObject:deletItem];
    }
    
    if(self.enableEdit){
        self.editButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0 , 22, 22)];
        [self.editButton setImage:[UIImage scaledImageForName:@"icon_edit" ofType:@"png"] forState:UIControlStateNormal];
        [self.editButton setImage:[UIImage scaledImageForName:@"icon_done" ofType:@"png"] forState:UIControlStateSelected];
        [self.editButton addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *editItem=[[UIBarButtonItem alloc] initWithCustomView:self.editButton];
        [rightItemArray addObject:editItem];
    }
    
    NSArray *shareIDs = [WSEnvrionment getWWCHAT_SHARE_ID];
    if (shareIDs.count > 1) {
//        YIHAIKERRY-2298
//        SFA益海嘉里【照片分享】分享的图标修改 （别的地方用可以修改）
        UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareBtn setFrame:CGRectMake(0, 0, 24, 24)];
        [shareBtn setBackgroundColor:[UIColor clearColor]];
        [shareBtn setImage:[UIImage scaledImageForName:@"btn_share_white" ofType:@"png"] forState:UIControlStateNormal];
        [shareBtn addTarget:self action:@selector(loadShareView) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc]initWithCustomView:shareBtn];
        [rightItemArray addObject:shareItem];
    }

    self.myNavigationItem.rightBarButtonItems = rightItemArray;

}
- (void)doneButtonClick:(id)sender
{
    if (IOS7_OR_LATER) {
        NSString *statusBarStyle = [[WSSkinStyleManager sharedInstance].skinStyleResourceCahche objectForKey:[NSString stringWithFormat:@"%@%@", kStatusBarStyle, INTERFACE_IS_PAD ? kiPadSuffix : @""]];
        if (statusBarStyle == nil || ![statusBarStyle isEqualToString:@"1"]) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)getImageCount {
    return self.imageIDs ? self.imageIDs.count : self.images.count;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if ([_imageIDs[0] isKindOfClass:[NSURL class]]) {
//        [self.toolBar setHidden:YES];
//    }
    
    [self setUpViews];
}

- (void)setUpViews
{
    viewBounds = self.view.bounds;
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTouch)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    
    
    if (_myScrollView == nil)
    {
        _myScrollView = [[UIScrollView alloc] initWithFrame:viewBounds];
    }
    
    [_myScrollView addGestureRecognizer:tapGesture];
    
    NSInteger imageCount = [self getImageCount];
    
    _myScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _myScrollView.pagingEnabled = YES;
    _myScrollView.contentSize = CGSizeMake(viewBounds.size.width * imageCount, viewBounds.size.height);
    _myScrollView.contentOffset = CGPointMake(viewBounds.size.width * currentPage, 0);
    _myScrollView.showsHorizontalScrollIndicator = NO;
    _myScrollView.showsVerticalScrollIndicator = NO;
    _myScrollView.scrollEnabled=YES;
    _myScrollView.delegate = self;
    id object = _imageIDs.count > 0 ? _imageIDs[0] :_images[0];
    [self loadImageAccordingDataType:object withIndex:0];
    
    NSString *title = nil;
    if (imageCount > 1) {
        title = [NSString stringWithFormat:@"%ld/%ld", (long)currentPage + 1, (long)imageCount];
    }else{
        title = NSLocalizedString(@"photo_preview", nil);
    }
    self.myNavigationItem.title = title;
    
    [self.view addSubview:_myScrollView];
    [self.view sendSubviewToBack:_myScrollView];
    
    if ([[UIDevice currentDevice]systemVersionByFloat] < 7.0) {
        CGRect navigationBarRect = self.navigationBar.frame;
        if (navigationBarRect.origin.y != 0 ) {
            navigationBarRect.origin.y = 0;
            self.navigationBar.frame = navigationBarRect;
        }
    }
    [self addRightBar];
    
//    if(self.enableEdit){
//        self.editButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//        [self.editButton setTitle:NSLocalizedString(@"edit",nil) forState:UIControlStateNormal];
//        [self.editButton setTitle:NSLocalizedString(@"complete",nil) forState:UIControlStateSelected];
//        UIBarButtonItem* barButton=[[UIBarButtonItem alloc] initWithCustomView:self.editButton];
//        NSMutableArray* array=[NSMutableArray arrayWithArray:self.toolBar.items];
//        [array insertObject:barButton atIndex:0];
//        self.toolBar.items=array;
//        
//        [self.editButton addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
//    }
}

- (void)changeBarStatus
{
    barHidden = barHidden ? NO : YES;
    [[UIApplication sharedApplication] setStatusBarHidden:barHidden];
    [self.navigationBar setHidden:barHidden];
    [self.statusView setHidden:barHidden];
    
//    if ([_imageIDs[0] isKindOfClass:[NSURL class]]) {
//        [self.toolBar setHidden:YES];
//    }
//    else{
//        [self.toolBar setHidden:barHidden];
//
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self creatPages];
}

- (void)gotoPage:(NSInteger)aPage
{
    currentPage = aPage;
}

- (void)creatPages
{
    [_myScrollView removeAllSubviews];
    for (NSInteger i = 0; i < [_imageIDs count]; i++) {
        id obj = [_imageIDs objectAtIndex:i];
        [self loadImageAccordingDataType:obj withIndex:i];
    }

}

- (void)loadImageAccordingDataType:(id)object withIndex:(NSInteger)index{
    if ([object isKindOfClass:[NSURL class]]) {
        [self loadScrollViewWithImageUrl:[_imageIDs objectAtIndex:index] Index:index];
    }else if ([object isKindOfClass:[NSString class]]){
        // MSTD-5926 照片点击显示大图需区分本地和服务器回显，服务器回显的处理方式参照WSPhotoBrowseView的缩略图
        NSURL *url = nil;
        
        if ([WSPhotoLogicService isServerRedisPhoto:object]) {
            url = [NSURL URLWithString:[WSHttpURLHelper getImageCompleteURL:[WSPhotoLogicService getPhotoURLFromServerRedisValue:object]]];
        }else{
            url = [[NSURL alloc] initWithString:object];
        }
        
        if (url) {
            [self loadScrollViewWithImageUrl:url Index:index];
        }else{
            NSString *tempStr = (NSString *)object;
            if ([tempStr rangeOfString:@"data:image/png;base64"].location != NSNotFound) {
                [self loadScrollViewWithImageBase64Str:tempStr withIndex:index];
            }else{
                
                [self loadScrollViewWithImageID:tempStr Index:index];
            }
        }
        
    }else if ([object isKindOfClass:[UIImage class]]){
        [self loadScrollViewWithImage:object withIndex:index];
    }

}

- (void)loadScrollViewWithPage:(UIView *)aPageView
{
//    NSLog(@"load");
    NSInteger pageCount = [[_myScrollView subviews] count];
    CGRect bounds = _myScrollView.bounds;
    bounds.origin.x = bounds.size.width * pageCount;
    bounds.origin.y = 0;
    aPageView.frame = bounds;
    [_myScrollView addSubview:aPageView];
}


- (void)loadScrollViewWithImageID:(NSString *)aImageID Index:(NSInteger)aPage
{
//    NSLog(@"load");
//    CGRect bounds = _myScrollView.frame;
//    bounds.origin.x = viewBounds.size.width * aPage;
//    bounds.origin.y = 0;
//    
//    if(INTERFACE_IS_PHONE){
//        if([UIScreen mainScreen].bounds.size.height>480){
//            bounds.origin.y=64.0f;
//            bounds.size.height=[UIScreen mainScreen].bounds.size.height-64.0f-44.0f;
//        }
//    }
    
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:bounds];
//    imageView.tag=aPage+100;
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    imageView.clipsToBounds = YES;
    WSViewForWebImage * scaleImageView = [self createScaleImageViewWithPage:aPage];
//    scaleImageView =  [scaleImageView initWithFrame:bounds andImage:nil andUrl:aImagePathUrl];
    scaleImageView.tag = aPage + 100;
    NSArray *imageKeyArray = [aImageID componentsSeparatedByString:@"@"];
    
    UIImage *image = nil;
    
    if ([imageKeyArray count] > 1) {
        image = [[SDImageCache sharedImageCache] imageFromKey:[imageKeyArray firstObject] fromDisk:YES];
        if (image) {
//            imageView.image = image;
            scaleImageView = [scaleImageView initWithFrame:scaleImageView.bounds andImage:image andUrl:nil];
            
        }else {
//            [imageView sd_setImageWithURL:[NSURL URLWithString:[WSHttpURLHelper getImageCompleteURL:[imageKeyArray lastObject]]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            }];
            scaleImageView = [scaleImageView initWithFrame:scaleImageView.bounds andImage:nil andUrl:[NSURL URLWithString:[WSHttpURLHelper getImageCompleteURL:[imageKeyArray lastObject]]]];
        }
        
    }else {
        image = [[SDImageCache sharedImageCache] imageFromKey:aImageID fromDisk:YES];
//        imageView.image = image;
        scaleImageView = [scaleImageView initWithFrame:scaleImageView.bounds andImage:image andUrl:nil];

    }
    
    
//    [_myScrollView addSubview:imageView];
    [_myScrollView addSubview:scaleImageView];

}

- (void)loadScrollViewWithImageUrl:(NSURL *)aImagePathUrl Index:(NSInteger)aPage
{
    //    NSLog(@"load");
//    CGRect bounds = _myScrollView.frame;
//    bounds.origin.x = viewBounds.size.width * aPage;
//    bounds.origin.y = 0;
//    
//    if(INTERFACE_IS_PHONE){
//        if([UIScreen mainScreen].bounds.size.height>480){
//            bounds.origin.y=self.navigationController.navigationBar.height;
//            bounds.size.height=[UIScreen mainScreen].bounds.size.height-self.navigationController.navigationBar.height-self.navigationController.toolbar.height;
//        }
//    }
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:bounds];
//    imageView.tag=aPage+100;
//    [imageView sd_setImageWithURL:aImagePathUrl];
//    [_myScrollView addSubview:imageView];
    
    WSViewForWebImage * scaleImageView = [self createScaleImageViewWithPage:aPage];
    scaleImageView =  [scaleImageView initWithFrame:scaleImageView.bounds andImage:nil andUrl:aImagePathUrl];
    scaleImageView.tag = aPage + 100;
    [_myScrollView addSubview:scaleImageView];
}

- (void)loadScrollViewWithImageIndex:(NSInteger)aPage
{
    if (!self.images || aPage >= self.images.count) {
        return;
    }
//    CGRect bounds = _myScrollView.frame;
//    bounds.origin.x = viewBounds.size.width * aPage;
//    bounds.origin.y = 0;
//    
//    if(INTERFACE_IS_PHONE){
//        if([UIScreen mainScreen].bounds.size.height>480){
//            bounds.origin.y=64.0f;
//            bounds.size.height=[UIScreen mainScreen].bounds.size.height-64.0f-44.0f;
//        }
//    }
    
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:bounds];
//    imageView.tag=aPage+100;
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    imageView.clipsToBounds = YES;
//    imageView.image = self.images[aPage];
//    [_myScrollView addSubview:imageView];

    WSViewForWebImage * scaleImageView = [self createScaleImageViewWithPage:aPage];
    scaleImageView =  [scaleImageView initWithFrame:scaleImageView.bounds andImage:self.images[aPage] andUrl:nil];
    scaleImageView.tag = aPage + 100;
    [_myScrollView addSubview:scaleImageView];

}

- (void)loadScrollViewWithImage:(UIImage *)image withIndex:(NSInteger)aPage{

    WSViewForWebImage * scaleImageView = [self createScaleImageViewWithPage:aPage];
    scaleImageView =  [scaleImageView initWithFrame:scaleImageView.bounds andImage:image andUrl:nil];
    scaleImageView.tag = aPage + 100;
    [_myScrollView addSubview:scaleImageView];
    
}
- (void)loadScrollViewWithImageBase64Str:(NSString *)base64Str withIndex:(NSInteger)aPage{
    WSViewForWebImage * scaleImageView = [self createScaleImageViewWithPage:aPage];
    scaleImageView.tag = aPage + 100;
    NSRange range = [base64Str rangeOfString:@"data:image/png;base64,"]; //现获取要截取的字符串位置
    NSString *base64 = [base64Str substringFromIndex:range.length]; //截取字符串
    NSData *urlData = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
    UIImage *image = [UIImage imageWithData:urlData];
    scaleImageView = [scaleImageView initWithFrame:self.view.bounds andImage:image andUrl:nil];
    [_myScrollView addSubview:scaleImageView];
}

-(WSViewForWebImage *)createScaleImageViewWithPage:(NSInteger)aPage{
    CGRect bounds = _myScrollView.frame;
    bounds.origin.x = viewBounds.size.width * aPage;
    bounds.origin.y = 0;
    
    if(INTERFACE_IS_PHONE){
        if([UIScreen mainScreen].bounds.size.height>480){
            bounds.origin.y=64.0f;
            bounds.size.height=[UIScreen mainScreen].bounds.size.height-64.0f-44.0f;
        }
    }
    
    WSViewForWebImage *s = [[WSViewForWebImage alloc] initWithFrame:bounds];
    s.backgroundColor = [UIColor clearColor];
    s.contentSize = CGSizeMake(bounds.size.width, bounds.size.height);
    s.delegate = self;
    s.minimumZoomScale = 1.f;
    s.maximumZoomScale = 3.f;
    [s setZoomScale:1.f];
    s.userInteractionEnabled = YES;
    s.showsVerticalScrollIndicator = NO;
    s.showsHorizontalScrollIndicator = NO;
    return s;
}
- (void)edit:(id)sender
{
    WSViewForWebImage *imageView = (WSViewForWebImage*)[self.view viewWithTag:100+_myScrollView.contentOffset.x/_myScrollView.width];
    
    UIImage* image = imageView.imageView.image;
    
    CGFloat ratioX = image.size.width / imageView.width;
    CGFloat ratioY = image.size.height / imageView.height;
    CGFloat ratio = ratioX > ratioY ? ratioX : ratioY;
    
    if(self.editButton.selected==NO){
        
        _myScrollView.scrollEnabled=NO;
        tapGesture.enabled=NO;
        //self.navigationBar.hidden = YES;
        
        CGFloat imageWidth = image.size.width / ratio;
        CGFloat imageHeight = image.size.height / ratio;
        
        WSEditImageView* editView=[[WSEditImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageHeight)];
        CGPoint imageCenter = imageView.center;
        imageCenter.x -= _myScrollView.contentOffset.x;
        editView.center = imageCenter;
        editView.tag=999;
        [self.view addSubview:editView];
        
        
        
    }else{
        _myScrollView.scrollEnabled=YES;
        tapGesture.enabled=YES;
        //self.navigationBar.hidden = NO;
        
        WSEditImageView* editView=(WSEditImageView*)[self.view viewWithTag:999];
        
        // Build a context that's the same dimensions as the new size
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     image.size.width,
                                                     image.size.height,
                                                     CGImageGetBitsPerComponent(image.CGImage),
                                                     0,
                                                     CGImageGetColorSpace(image.CGImage),
                                                     CGImageGetBitmapInfo(image.CGImage));
        
        CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);

   
        
        for(UIView* view in editView.viewArray){
            CGContextSetLineWidth(context, 2.0* ratio);
            CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
            CGRect rectangle = CGRectMake(view.frame.origin.x* ratio,  image.size.height-   view.bottom*ratio  , view.width* ratio , view.height* ratio) ;
            CGContextAddRect(context, rectangle);
            CGContextStrokePath(context);
        }

        
        // Draw the image to the context; the clipping path will make anything outside the rounded rect transparent
        
        // Create a CGImage from the context
        CGImageRef clippedImage = CGBitmapContextCreateImage(context);
        
        // Create a UIImage from the CGImage
        UIImage *roundedImage = [UIImage imageWithCGImage:clippedImage];
        
        CGImageRelease(clippedImage);
        CGContextRelease(context);
        
        

//        CGRect rect=imageView.frame;
//        imageView.imageView.image=nil;
//        [imageView.imageView removeFromSuperview];
//        imageView.imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.imageView.image = roundedImage;
        imageView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_myScrollView addSubview:imageView];
        
        NSNumber *imgCompress = [[NSUserDefaults standardUserDefaults] objectForKey:@"ImgCompress"];
        [[SDImageCache sharedImageCache] storeImage:roundedImage imageImgCompress:imgCompress forKey:[_imageIDs objectAtIndex:currentPage] toDisk:YES toDocument:YES isSynchronized:YES];
        
        [editView removeFromSuperview];
        
        if ([self.delegate respondsToSelector:@selector(photoBrowserEditPhoto:)]) {
            [self.delegate photoBrowserEditPhoto:[_imageIDs objectAtIndex:currentPage]];
        }
        
    }
    
    self.editButton.selected=!self.editButton.selected;


}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationBar setHidden:YES];
    [self.statusView setHidden:YES];

    //[self.toolBar setHidden:YES];
    barHidden = YES;

    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    currentPage = page;
    NSString *title = nil;
    if ([self getImageCount] > 1) {
        title = [NSString stringWithFormat:@"%ld/%ld", (long)currentPage + 1, (long)[self getImageCount]];
    }else{
        title = NSLocalizedString(@"photo_preview", nil);
    }
    self.myNavigationItem.title = title;
}


/*图片的放大 缩小*/
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    for (UIView *subView in scrollView.subviews){
        NSInteger subViewTag = subView.tag;
        if ([subView isKindOfClass:[UIImageView class]] && subViewTag == 100 + currentPage) {
            
            
            
            return subView;
        }
    }
    return nil;
}

- (void)imageTouch
{
    [self changeBarStatus];
}
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

@end
