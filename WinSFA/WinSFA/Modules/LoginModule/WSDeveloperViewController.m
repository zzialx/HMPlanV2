//
//  WSDeveloperViewController.m
//  WinSFA
//
//  Created by zhangke on 14/10/16.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSDeveloperViewController.h"

@interface WSDeveloperViewController ()<UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView* scrollView;
@property (nonatomic,strong) UIPageControl* pageControl;

@end

@implementation WSDeveloperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, MAIN_BUTTON_WH, 44)];
    [backBtn setBackgroundColor:[UIColor clearColor]];
    [backBtn setImage:[UIImage scaledImageForName:@"icon_back" ofType:@"png"] forState:UIControlStateNormal];
//    [backBtn setImage:[UIImage imageForName:@"icon_back_press.png"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    
    self.navigationItem.leftBarButtonItem=homeButtonItem;
    

    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    
    self.title=NSLocalizedString(@"about_our",  nil);
    self.scrollView=[[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.pagingEnabled=YES;
    [self.view addSubview:self.scrollView];
    //self.scrollView.contentSize=CGSizeMake(self.view.width, self.view.height);
    self.scrollView.delegate=self;
    self.scrollView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    for(int i=1;i<2;i++){
        NSString* name=nil;
        if(IS_IPHONE5 && !INTERFACE_IS_PAD){
            name=[NSString stringWithFormat:@"developer%d-5",i];
        }else{
            name=[NSString stringWithFormat:@"developer%d",i];
        }

        UIImage* image=[UIImage scaledImageForName:name ofType:@"jpg"];
        UIImageView* imageview=[[UIImageView alloc] initWithFrame:CGRectMake(self.view.width*(i-1), 0, self.view.width, self.view.height - 64)];
        imageview.image=image;
        [self.scrollView addSubview:imageview];
    }
//    
//    self.pageControl=[[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.width, 30)];
//    self.pageControl.numberOfPages=5;
//    self.pageControl.pageIndicatorTintColor=[UIColor lightGrayColor];
//    self.pageControl.currentPageIndicatorTintColor= MAIN_TINT_COLOT;
//    self.pageControl.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;

    //[self.view addSubview:self.pageControl];

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page=scrollView.contentOffset.x/self.view.width;
    self.pageControl.currentPage=page;
}

- (void)backAction{
    
     [self.navigationController popViewControllerAnimated:YES];
}
@end
