//
//  WSOpenFeedbackView.m
//  WinSFA
//
//  Created by Alicia on 2017/6/22.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSOpenFeedbackView.h"
#import "WSAddNewStoreViewController.h"
#import "WSPhotoLogicService.h"
#import "WSDataSourceManager.h"

#define kFeedBackViewWidth          86
#define kFeedBackViewHeight         140
#define kFeedBackViewOffsetY        (SCREEN_HEIGHT * 0.23)
#define kBorderWidth                4
#define kCornerRadius               5
#define kShowDuration               5   // 显示时间，秒为单位
#define kOpenFeedBackImageKey       @"OpenFeedBackImage"

@interface WSOpenFeedbackView ()

@property (nonatomic, strong) WSFuncsBean *fb;
@property (nonatomic, strong) WSAcvtBean *acvtBean;
@property (nonatomic, strong) UIImageView *screenImageView;
@property (nonatomic, strong) NSTimer *timer;
@end


@implementation WSOpenFeedbackView


- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)dealloc {
    [self stopTimer];
}

- (void)setupViews {
    CGRect viewFrame = CGRectMake(SCREEN_WIDTH - MAIN_CELL_PADDING - kFeedBackViewWidth, kFeedBackViewOffsetY, kFeedBackViewWidth, kFeedBackViewHeight);
    self.frame = viewFrame;
    self.layer.cornerRadius = kCornerRadius;
    self.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGesture];
    
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
    
    CGFloat imageHeight = kFeedBackViewHeight - MAIN_TEXTFIELD_HEIGHT -  kBorderWidth;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kBorderWidth, kBorderWidth, kFeedBackViewWidth - kBorderWidth * 2, imageHeight)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self addSubview:imageView];
    self.screenImageView = imageView;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame), kFeedBackViewWidth, MAIN_TEXTFIELD_HEIGHT)];
    [label setText:NSLocalizedString(@"question_feedback", nil)];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:label];
}

#pragma mark - Actions
- (void)showWithFuncs:(WSFuncsBean *)fb acvtBean:(WSAcvtBean *)acvtBean {
    // 当前已经是问题反馈页面则无需再显示
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    if (self.fb && model && model.currentFuncs && [model.currentFuncs.fc isEqualToString:self.fb.fc]) {
        return;
    }
    
    self.fb = fb;
    self.acvtBean = acvtBean;
    
    [self setHidden:YES];
    self.screenImageView.image = [self imageWithScreenshot];
    [self setHidden:NO];
    
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kShowDuration target:self selector:@selector(hideSelf) userInfo:nil repeats:NO];
}

#pragma mark - Private Method
- (void)hideSelf {
    [self stopTimer];
    [self setHidden:YES];
}

- (void)stopTimer {
    if(self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)handleTap:(UIGestureRecognizer *)recognizer {
    [self setHidden:YES];
    
    [self saveImageToDisk];
    
    [self gotoAcvtViewController];
}

- (void)gotoAcvtViewController {
    WSAddNewStoreViewController *controller = [[WSAddNewStoreViewController alloc] initWithFuncs:self.fb acvtBean:self.acvtBean storeBean:nil];
    controller.hidesBottomBarWhenPushed = YES;

    WSAcvtModel *acvtModel = (WSAcvtModel *)controller.model;
    acvtModel.feedbackPhotoId = kOpenFeedBackImageKey;
    
    WCNavigationController* navController = [[WCNavigationController alloc] initWithRootViewController:controller];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, MAIN_BUTTON_WH, 44)];
    [backBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    controller.navigationItem.leftBarButtonItem = homeButtonItem;
    
    [self.window.rootViewController presentViewController:navController animated:YES completion:nil];

}

- (void)backAction {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveImageToDisk {
    [[SDImageCache sharedImageCache] storeImage:self.screenImageView.image
                               imageImgCompress:@1
                                         forKey:kOpenFeedBackImageKey
                                         toDisk:YES
                                     toDocument:NO
                                 isSynchronized:YES];
    
}

// 截屏
- (NSData *)dataWithScreenshotInPNGFormat {
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImagePNGRepresentation(image);
}

- (UIImage *)imageWithScreenshot {
    NSData *imageData = [self dataWithScreenshotInPNGFormat];
    return [UIImage imageWithData:imageData];
}

@end
