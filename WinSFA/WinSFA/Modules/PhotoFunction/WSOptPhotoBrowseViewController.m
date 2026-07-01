//
//  WSOptPhotoBrowseViewController.m
//  WinSFA
//
//  Created by winchannel on 2017/9/11.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSOptPhotoBrowseViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WSEditImageView.h"
#import "WSViewForWebImage.h"
#import "WSPhotoLogicService.h"

@interface WSOptPhotoBrowseViewController (){
        NSInteger currentPage;
        BOOL barHidden;
        CGRect viewBounds;
        UITapGestureRecognizer *tapGesture;
        NSMutableArray *imageDescriptionArray;
        UIPageControl *_pageControl;
}

@end

@implementation WSOptPhotoBrowseViewController

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

- (id)initWithImageIDs:(NSMutableArray *)imageIDs withImageDescription:(NSMutableArray *)descriptions{
    
    self = [self initWithImageIDs:imageIDs];
    if (self) {
        imageDescriptionArray = descriptions ;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (NSInteger)getImageCount {
    return self.imageIDs ? self.imageIDs.count : self.images.count;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUpViews];
}

- (void)setUpViews
{
    viewBounds = self.view.bounds;
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDown)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    
    
    if (_myScrollView == nil)
    {
        _myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(viewBounds.origin.x, 20, viewBounds.size.width, viewBounds.size.height - 20)];
    }
    
    [_myScrollView addGestureRecognizer:tapGesture];
    
    NSInteger imageCount = [self getImageCount];
    
    _myScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _myScrollView.pagingEnabled = YES;
    _myScrollView.contentSize = CGSizeMake(viewBounds.size.width * imageCount, viewBounds.size.height - 20);
    _myScrollView.contentOffset = CGPointMake(viewBounds.size.width * currentPage, 0);
    _myScrollView.showsHorizontalScrollIndicator = NO;
    _myScrollView.showsVerticalScrollIndicator = NO;
    _myScrollView.scrollEnabled=YES;
    _myScrollView.delegate = self;
    _myScrollView.bounces = NO;
    id object = _imageIDs.count > 0 ? _imageIDs[0] :_images[0];
    [self loadImageAccordingDataType:object withIndex:0];
    
    if (_imageIDs.count > 1) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, viewBounds.size.height - 30, viewBounds.size.width, 30)];  //创建uipagecontrol，位置在屏幕最下方。
        _pageControl.numberOfPages = _imageIDs.count; //总的图片页数
        _pageControl.currentPage = currentPage;//当前页
        [_pageControl addTarget:self action:@selector(pageturn:) forControlEvents:UIControlEventValueChanged];//用户点击uipagecontrol的响应函数
        [self.view addSubview:_pageControl];  //将uipagecontrol添加到主界面上。
    }
    [self.view addSubview:_myScrollView];
    [self.view sendSubviewToBack:_myScrollView];
    
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
    WSViewForWebImage * scaleImageView = [self createScaleImageViewWithPage:aPage];
    scaleImageView.tag = aPage + 100;
    NSArray *imageKeyArray = [aImageID componentsSeparatedByString:@"@"];
    
    UIImage *image = nil;
    
    if ([imageKeyArray count] > 1) {
        image = [[SDImageCache sharedImageCache] imageFromKey:[imageKeyArray firstObject] fromDisk:YES];
        if (image) {
            scaleImageView = [scaleImageView initWithFrame:scaleImageView.bounds andImage:image andUrl:nil];
            
        }else {

            scaleImageView = [scaleImageView initWithFrame:scaleImageView.bounds andImage:nil andUrl:[NSURL URLWithString:[WSHttpURLHelper getImageCompleteURL:[imageKeyArray lastObject]]]];
        }
        
    }else {
        image = [[SDImageCache sharedImageCache] imageFromKey:aImageID fromDisk:YES];

        scaleImageView = [scaleImageView initWithFrame:scaleImageView.bounds andImage:image andUrl:nil];
        
    }
    [_myScrollView addSubview:scaleImageView];
    
}

- (void)loadScrollViewWithImageUrl:(NSURL *)aImagePathUrl Index:(NSInteger)aPage
{
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
    
    NSString *optName = [imageDescriptionArray objectAtIndex:aPage];
    if (optName && optName.length > 0) {
        UILabel *contentLabel = [[UILabel alloc]init];
        contentLabel.font = FONT_SIZE_PINGFANG_MEDIUM(14);
        contentLabel.frame = CGRectMake(scaleImageView.left + 20, scaleImageView.bottom + 16, scaleImageView.width - 40, 40);
        contentLabel.textColor = [UIColor whiteColor];
        contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        contentLabel.numberOfLines = 2;
        contentLabel.backgroundColor = [UIColor blackColor];
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.text = optName;
        [_myScrollView addSubview:contentLabel];
    }

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
            bounds.origin.y=100.0f;
            bounds.size.height=_myScrollView.height - 220.0f;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

    [self.navigationBar setHidden:YES];

    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    currentPage = page;
    [_pageControl setCurrentPage:page];
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

- (void)viewDown{
    
    if (IOS7_OR_LATER) {
        NSString *statusBarStyle = [[WSSkinStyleManager sharedInstance].skinStyleResourceCahche objectForKey:[NSString stringWithFormat:@"%@%@", kStatusBarStyle, INTERFACE_IS_PAD ? kiPadSuffix : @""]];
        if (statusBarStyle == nil || ![statusBarStyle isEqualToString:@"1"]) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
