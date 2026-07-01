//
//  WSAppGuidanceViewController.m
//  WinSFA
//
//  Created by heju on 14-9-28.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//




#import "WSAppGuidanceViewController.h"
#import "WSSkinStyleManager.h"
#import "WSAuthorizationViewController.h"

#define k_PageCount 5

@interface WSAppGuidanceViewController () {
    NSInteger pageCount;
    CGRect currentRect;
}

@property (nonatomic, retain)UIScrollView *guidanceScrollView;
@property (nonatomic, retain)UIPageControl *guidancePageConrol;
@end

@implementation WSAppGuidanceViewController
@synthesize guidanceScrollView = _guidanceScrollView;
@synthesize guidancePageConrol = _guidancePageConrol;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    /*
    if ([[UIDevice currentDevice]systemVersionByFloat] >=7.0) {
        UIApplication *application = [UIApplication sharedApplication];
        [application setStatusBarHidden:YES];
    }
     */
    [self creatSubViews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"vvvvvvvvvvvvvvvvvvvvvvvv");
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [super viewWillDisappear:animated];
}


- (void)creatSubViews {
    
    NSString *appPageCount = [[WSSkinStyleManager sharedInstance].skinStyleResourceCahche objectForKey:@"APPGuidPageCount"];
    if ([appPageCount length] == 0) {
        appPageCount = DEFAULT_APP_PAGE_COUNT;
    }
    pageCount = [appPageCount integerValue];
    currentRect = [self.view bounds];
    //create scrollview
    _guidanceScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, currentRect.size.width, currentRect.size.height)];
    _guidanceScrollView.contentSize = CGSizeMake(currentRect.size.width * pageCount,currentRect.size.height);
    _guidanceScrollView.pagingEnabled = YES;
    _guidanceScrollView.scrollEnabled = YES;
    _guidanceScrollView.showsHorizontalScrollIndicator = NO;
    _guidanceScrollView.showsVerticalScrollIndicator = NO;
    _guidanceScrollView.delegate = self;
    _guidanceScrollView.clipsToBounds = NO;
    _guidanceScrollView.bounces = NO;
    [self.view addSubview:_guidanceScrollView];
    
    //create pages
    [self createGuidancePages];
  
    
    // create PageControl
    _guidancePageConrol = [[UIPageControl alloc]initWithFrame:CGRectMake((currentRect.size.width - 100)/2, currentRect.size.height - 100, 100, 15)];
//    _guidancePageConrol.backgroundColor = [UIColor grayColor];
    _guidancePageConrol.numberOfPages = pageCount;
    _guidancePageConrol.currentPage = 0;
    [_guidancePageConrol addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_guidancePageConrol];
}

- (void)createGuidancePages {
    
    NSString *appPageCount = [[WSSkinStyleManager sharedInstance].skinStyleResourceCahche objectForKey:@"APPGuidPageCount"];
    if ([appPageCount length] == 0) {
        appPageCount = DEFAULT_APP_PAGE_COUNT;
    }
    
    CGFloat x = 0;
    CGFloat y = 0;
    for (NSInteger i = 0; i < [appPageCount intValue]; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(currentRect.size.width *i + x, y , currentRect.size.width - 2*x , currentRect.size.height-y*2)];
        NSString *name;
        if (IS_IPHONE5 && !INTERFACE_IS_PAD) {
            name = [NSString stringWithFormat:@"intro_%ld-568h",(long)i];
        } else {
            name = [NSString stringWithFormat:@"intro_%ld",(long)i];
        }
        imageView.image = [UIImage scaledImageForName:name ofType:@"jpg"];
        if (i == [appPageCount intValue] - 1) {
            UITapGestureRecognizer* singleRecognizer;
            singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
            singleRecognizer.numberOfTapsRequired = 1; // 单击
            imageView.tag = i;
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:singleRecognizer];
        }
        [_guidanceScrollView addSubview:imageView];
    }
}

- (void)changePage:(id)sender
{
    NSInteger page = _guidancePageConrol.currentPage;
    
    // update the scroll view to the appropriate page
    CGRect frame = _guidanceScrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_guidanceScrollView scrollRectToVisible:frame animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = sender.frame.size.width;
    int page = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _guidancePageConrol.currentPage = page;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)addTapGestureRecognizer {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(tap:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
}

- (void)singleTap:(UITapGestureRecognizer*)recognizer
{
    /*
    NSUserDefaults *currentUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL enterGuidanceFromAppSetting = [currentUserDefaults  boolForKey:@"APPSettingEnter"];
    if (enterGuidanceFromAppSetting) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [currentUserDefaults removeObjectForKey:@"APPSettingEnter"];
    } else {
        [self createAuthorizationViewController];
    }
     */
    /*
     注册协议 现在右后台控制（HUAWEI-618）参数为: @"loginRedirectFc" 其值对应FuncBean的FC字段,
     例如 loginRedirectFc = FAC_681 则FAC_681 对应的视图界面为注册协议界面
     */
    
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        [self.view setAlpha:0.0];
                    } completion:^(BOOL finished) {
                        [[UIApplication sharedApplication] setStatusBarHidden:NO];
                        [[self.view superview] setNeedsUpdateConstraints];
                        [self.view removeFromSuperview];
                        [self removeFromParentViewController];
                    }];

}

- (void)createAuthorizationViewController {
    
    NSString *termsandconditionsStr = NSLocalizedString(@"termsandconditions", nil);
    if (termsandconditionsStr.length >0){
    
        WSAuthorizationViewController *authorizationVC = [[WSAuthorizationViewController alloc]init];
        
        [self.navigationController pushViewController:authorizationVC animated:YES];

    }
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        [self.view setAlpha:0.0];
                    } completion:^(BOOL finished) {
                        [[UIApplication sharedApplication] setStatusBarHidden:NO];
                        [[self.view superview] setNeedsUpdateConstraints];
                        [self.view removeFromSuperview];
                    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
