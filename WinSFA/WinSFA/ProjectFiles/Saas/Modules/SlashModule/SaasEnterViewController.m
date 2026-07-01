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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NSLog(@"SaasEnterViewController been touched");
    self.view.hidden = YES;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    myScrollView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGuestrue = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollviewTouch:)] autorelease];
    tapGuestrue.numberOfTapsRequired = 1;
    tapGuestrue.numberOfTouchesRequired = 1;
    [myScrollView addGestureRecognizer:tapGuestrue];
    
    
    float pageControlHeight = 18.0;
    int pageCount = 3;
    CGRect scrollViewRect = [self.view bounds];
    scrollViewRect.size.height -= pageControlHeight;
    myScrollView.pagingEnabled = YES;
    myScrollView.contentSize = CGSizeMake(scrollViewRect.size.width * pageCount, 1);
    myScrollView.showsHorizontalScrollIndicator = NO;
    myScrollView.showsVerticalScrollIndicator = NO;
    
    [myScrollView setUserInteractionEnabled:YES];
    [myScrollView setScrollEnabled:YES];
    [myScrollView setCanCancelContentTouches:YES];
    [myScrollView setBounces:NO];
    myScrollView.delegate = self;
    
    
    myPageControl.backgroundColor = [UIColor clearColor];
    myPageControl.numberOfPages = pageCount;
    myPageControl.currentPage = 0;
    
    [myPageControl addTarget:self action:@selector(changePage) forControlEvents:UIControlEventValueChanged];
    [self.view bringSubviewToFront:myPageControl];
    
    [self creatPages];
}

- (id)scrollviewTouch:(id *)sender
{
    NSLog(@"touch");
    
    if (myPageControl.currentPage == 2)
    {
        NSLog(@"page 2");
        self.view.hidden = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"saasenter" object:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"firstTimeUser"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return nil;
}

- (void)loadScrollViewWithPage:(UIView *)page
{
    NSLog(@"load");
    int pageCount = [[myScrollView subviews] count];
    CGRect bounds = myScrollView.bounds;
    bounds.origin.x = bounds.size.width * pageCount;
    bounds.origin.y = 0;
    page.frame = bounds;
    [myScrollView addSubview:page];
}

- (void)creatPages
{
    NSLog(@"creat");
    CGRect pageRect = myScrollView.frame;
    
    UIImageView *imageView1 = [[[UIImageView alloc] initWithFrame:pageRect] autorelease];
    imageView1.image = [UIImage imageNamed:@"page1"];
    
    UIImageView *imageView2 = [[[UIImageView alloc] initWithFrame:pageRect] autorelease];
    imageView2.image = [UIImage imageNamed:@"page2"];
    
    UIImageView *imageView3 = [[[UIImageView alloc] initWithFrame:pageRect] autorelease];
    imageView3.image = [UIImage imageNamed:@"page3"];
    
    [self loadScrollViewWithPage:imageView1];
    [self loadScrollViewWithPage:imageView2];
    [self loadScrollViewWithPage:imageView3];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scroll");
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    myPageControl.currentPage = page;
}

@end
