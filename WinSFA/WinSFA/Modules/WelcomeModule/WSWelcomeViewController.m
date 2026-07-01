//
//  WSWelcomeViewController.m
//  WinSFA
//
//  Created by Alicia on 2017/10/30.
//  Copyright © 2017年 WinChannel. All rights reserved.
//
// MSTD-6659 登录后进入的欢迎页/广告页

#import "WSWelcomeViewController.h"
#import "WSWelcomeDataService.h"

#define kSkipTime           3

@interface WSWelcomeViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation WSWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setTimer];
}

#pragma mark - Init

- (instancetype)initWithFuncs:(WSFuncsBean *)funcs {
    if(!funcs || !funcs.filter || [funcs.filter length] == 0) {
        LogError(@"WSWelcomeViewController funcs is nil");
        return nil;
    }
    BOOL hasCacheFile = [[WSWelcomeDataService sharedInstance] hasCacheFileWithUrl:funcs.filter];
    if (!hasCacheFile) {
        LogError(@"WSWelcomeViewController no cache file: %@", funcs.filter);
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.currentFuncs = funcs;
        self.title = funcs.name;
        return self;
    }
    return nil;
}


- (void)setupViews {
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.imageView];
    
    
    NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:self.currentFuncs.filter];
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:imageData];
    [self.imageView setImage:image];
    
    
    UIImage *buttonImage = [UIImage imageNamed:@"btn_skip"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeImage) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(self.view.width - buttonImage.size.width - MAIN_PADDING, UI_STATUS_BAR_HEIGHT + MAIN_PADDING, buttonImage.size.width, buttonImage.size.height);
    [self.view addSubview:button];

}

- (void)setTimer {
    NSInteger skipTime = kSkipTime;
    NSString *skipTimeStr = [[NSUserDefaults standardUserDefaults] objectForKey:APPDATA_WELCOME_SKIP_TIME];
    if ([skipTimeStr length] > 0) {
        NSInteger kTempTime = [skipTimeStr integerValue];
        // MSTD-6731 负数仍然使用默认值，只有非负数时候才赋值
        if (kTempTime >= 0 ) {
            skipTime = kTempTime;
        }
    }
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, skipTime * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self closeImage];
    });

}

#pragma mark - Actions

- (void)closeImage {
    [self.navigationController popViewControllerAnimated:YES];
}



@end
