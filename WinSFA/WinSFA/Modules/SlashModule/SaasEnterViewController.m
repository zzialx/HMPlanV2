//
//  SaasEnterViewController.m
//  WinChannelFrameWork
//
//  Created by Jiepeng Zheng on 12-7-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SaasEnterViewController.h"

@interface SaasEnterViewController ()

@end

@implementation SaasEnterViewController

@synthesize myScrollView = _myScrollView;
@synthesize myPageControl = _myPageControl;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NSLog(@"SaasEnterViewController been touched");
    self.view.hidden = YES;
    
}

- (void)loadView
{
    [super loadView];
    self.myScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.myScrollView];
    
    self.myPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 30, self.view.frame.size.width, 10)];
    [self.view addSubview:self.myPageControl];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _myScrollView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGuestrue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollviewTouch:)];
    tapGuestrue.numberOfTapsRequired = 1;
    tapGuestrue.numberOfTouchesRequired = 1;
    [_myScrollView addGestureRecognizer:tapGuestrue];
    
    
    float pageControlHeight = 18.0;
    int pageCount = 3;
    CGRect scrollViewRect = [self.view bounds];
    scrollViewRect.size.height -= pageControlHeight;
    _myScrollView.pagingEnabled = YES;
    _myScrollView.contentSize = CGSizeMake(scrollViewRect.size.width * pageCount, 1);
    _myScrollView.showsHorizontalScrollIndicator = NO;
    _myScrollView.showsVerticalScrollIndicator = NO;
    
    [_myScrollView setUserInteractionEnabled:YES];
    [_myScrollView setScrollEnabled:YES];
    [_myScrollView setCanCancelContentTouches:YES];
    [_myScrollView setBounces:NO];
    _myScrollView.delegate = self;
    
    
    _myPageControl.backgroundColor = [UIColor clearColor];
    _myPageControl.numberOfPages = pageCount;
    _myPageControl.currentPage = 0;
    
    [_myPageControl addTarget:self action:@selector(changePage) forControlEvents:UIControlEventValueChanged];
    [self.view bringSubviewToFront:_myPageControl];
    
    [self creatPages];
}

- (id)scrollviewTouch:(id *)sender
{
    NSLog(@"touch");
    
    if (_myPageControl.currentPage == 2)
    {
        NSLog(@"page 2");
        [UIView animateWithDuration:0.5 animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"saasenter" object:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"firstTimeUser"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return nil;
}

- (void)loadScrollViewWithPage:(UIView *)page
{

    NSInteger pageCount = [[_myScrollView subviews] count];
    CGRect bounds = _myScrollView.bounds;
    bounds.origin.x = bounds.size.width * pageCount;
    bounds.origin.y = 0;
    page.frame = bounds;
    [_myScrollView addSubview:page];
}

- (void)creatPages
{
    NSLog(@"creat");
    CGRect pageRect = _myScrollView.frame;
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:pageRect];
    imageView1.image = [UIImage imageNamed:@"page1"];
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:pageRect];
    imageView2.image = [UIImage imageNamed:@"page2"];
    
    UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:pageRect];
    imageView3.image = [UIImage imageNamed:@"page3"];
    
    [self loadScrollViewWithPage:imageView1];
    [self loadScrollViewWithPage:imageView2];
    [self loadScrollViewWithPage:imageView3];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"scroll");
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _myPageControl.currentPage = page;
}

- (void)viewDidUnload {
    [self setMyScrollView:nil];
    [super viewDidUnload];
}
@end
