//
//  LTViewControllerName.m
//  LTDebug
//
//  Created by Alicia on 17/3/1.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "LTDebugView.h"
#import "LTDebugMacro.h"
#import "LTDebugViewController.h"


#define kIsIPhone           (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kWindowWidth        (kIsIPhone ? (UIScreen.mainScreen.bounds.size.width / 2) : (UIScreen.mainScreen.bounds.size.width / 4))
#define kWindowHeight       30
#define kWindowTop          80
#define kTextPadding        0
#define kViewPadding        8
#define kTextLeftPadding    (kTextPadding + kWindowHeight)
#define kTextWidth          (kWindowWidth - kTextLeftPadding - kViewPadding)

#define kTextFont           [UIFont fontWithName:@"Helvetica-Bold" size:10]

#define kDebugTextColor     [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]

#define kShowWindowTime     5

@interface LTDebugView ()


@property (nonatomic, strong) UIWindow *overlayWindow;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, assign) BOOL isExpand;

@end

@implementation LTDebugView

+ (instancetype)sharedInstance {
    static LTDebugView *viewName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        viewName = [[LTDebugView alloc] init];
    });
    return viewName;
}

#pragma mark - Public Method
- (void)showThenHideWindow {
    if (!self.isExpand) {
        self.isExpand = YES;
        [self expandWindow];
        
        dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, kShowWindowTime * NSEC_PER_SEC);
        dispatch_after(timer, dispatch_get_main_queue(), ^{
            if (!self.overlayView.isHidden && self.isExpand) {
                self.isExpand = NO;
                [self expandWindow];
            }
        });
    }
}

- (void)resetWindowAndViewByIsHidden:(BOOL)isHidden {
    if (isHidden) {
        self.overlayWindow.frame = UIScreen.mainScreen.bounds;
        [self.overlayView setHidden:YES];
    } else {
        self.isExpand = NO;
        self.overlayWindow.frame = [self getWindowRect];
        [self.overlayView setHidden:NO];
    }
}

#pragma mark - Actions

- (void)tapOverlayView:(UITapGestureRecognizer *)tapRecognizer {
    if (self.isExpand) {
        [self resetWindowAndViewByIsHidden:YES];
        
        LTDebugViewController *debugController = [[LTDebugViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:debugController];
        [self.overlayWindow.rootViewController presentViewController:navController animated:YES completion:nil];
    } else {
        self.isExpand = NO;
        [self showThenHideWindow];
    }
}

#pragma mark - Private Method
- (CGRect)getWindowRect {
    CGFloat offsetY = self.overlayWindow.origin.y > 0 ? self.overlayWindow.origin.y : kWindowTop;
    CGRect newFrame;
    if (self.isExpand) {
        newFrame = CGRectMake(CGRectGetWidth(UIScreen.mainScreen.bounds) - kWindowWidth, offsetY, kWindowWidth, kWindowHeight);
    } else {
        newFrame = CGRectMake(CGRectGetWidth(UIScreen.mainScreen.bounds) - kWindowHeight, offsetY, kWindowWidth, kWindowHeight);
    }
    return newFrame;
}

- (void)expandWindow {
    CGRect newFrame = [self getWindowRect];
    [UIView animateWithDuration:0.5 animations:^{
        self.overlayWindow.frame = newFrame;
    }];
}

- (UIBezierPath *)viewPath {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat radius = kWindowHeight / 2;
    [path moveToPoint:CGPointMake(radius, 0)];
    [path addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:3 * M_PI_2 endAngle:M_PI_2 clockwise:NO];
    [path addLineToPoint:CGPointMake(kWindowWidth, kWindowHeight)];
    [path addLineToPoint:CGPointMake(kWindowWidth, 0)];
    [path addLineToPoint:CGPointMake(radius, 0)];
    return path;
}

#pragma mark - Gestures 

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint center = recognizer.view.center;
    CGPoint translation = [recognizer translationInView:self.overlayWindow];
    recognizer.view.center = CGPointMake(self.overlayWindow.center.x, center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.overlayWindow];
}

#pragma mark - Property

- (UILabel *)errorLabel {
    if (!_errorLabel) {
        CGFloat errorWH = kWindowHeight - kViewPadding;
        CGRect frame = CGRectMake(kViewPadding / 2, kViewPadding / 2, errorWH, errorWH);
        _errorLabel = [[UILabel alloc] initWithFrame:frame];
        _errorLabel.textColor = kDebugTextColor;
        _errorLabel.font = kTextFont;
        _errorLabel.textAlignment = NSTextAlignmentCenter;
        _errorLabel.backgroundColor = [UIColor redColor];
        _errorLabel.layer.cornerRadius = errorWH / 2;
        _errorLabel.layer.masksToBounds = YES;
        _errorLabel.text = @"0";
    }
    return _errorLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextLeftPadding, 0, kTextWidth, kWindowHeight / 2)];
        _nameLabel.textColor = kDebugTextColor;
        _nameLabel.font = kTextFont;
//        _nameLabel.adjustsFontSizeToFitWidth = YES;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.overlayView addSubview:_nameLabel];
    }
  
    return _nameLabel;
}

- (UILabel *)otherLabel {
    if (!_otherLabel) {
        CGFloat topPadding = kWindowHeight / 2;
        CGFloat height = kWindowHeight / 2;
        CGRect frame = CGRectMake(kTextLeftPadding, topPadding, kTextWidth, height);
        _otherLabel = [[UILabel alloc] initWithFrame:frame];
        _otherLabel.font = kTextFont;
        _otherLabel.textColor = kDebugTextColor;
        _otherLabel.textAlignment = NSTextAlignmentCenter;
        _otherLabel.text = @"...";
    }
    return _otherLabel;
}


- (UIView *)overlayView {
    if (!_overlayView) {
        CGRect viewFrame = self.overlayWindow.bounds;
        _overlayView = [[UIView alloc] initWithFrame:viewFrame];
    
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.fillColor = [UIColor colorWithWhite:0.2 alpha:0.5].CGColor;
        layer.path = [self viewPath].CGPath;
        [_overlayView.layer addSublayer:layer];
        [self.overlayWindow addSubview:_overlayView];
        
        [_overlayView addSubview:self.otherLabel];
        [_overlayView addSubview:self.errorLabel];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
        [tapRecognizer addTarget:self action:@selector(tapOverlayView:)];
        [_overlayView addGestureRecognizer:tapRecognizer];
    }
    return _overlayView;
}

- (UIWindow *)overlayWindow; {
    if(!_overlayWindow) {
//        CGRect frame = CGRectMake(CGRectGetWidth(UIScreen.mainScreen.bounds) - kWindowHeight, kWindowTop, kWindowWidth, kWindowHeight);
         CGRect frame = CGRectMake(CGRectGetWidth(UIScreen.mainScreen.bounds), kWindowTop, kWindowWidth, kWindowHeight);
        _overlayWindow = [[UIWindow alloc] initWithFrame:frame];
        _overlayWindow.backgroundColor = [UIColor clearColor];
        _overlayWindow.windowLevel = UIWindowLevelAlert;
         LTDebugRootViewController *rootViewController = [[LTDebugRootViewController alloc] init];
        _overlayWindow.rootViewController = rootViewController;
        _overlayWindow.rootViewController.view.backgroundColor = [UIColor clearColor];
        [_overlayWindow makeKeyAndVisible];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_overlayWindow addGestureRecognizer:panGesture];
    }
    return _overlayWindow;
}

@end



# pragma mark - LTDebugRootViewController


@implementation LTDebugRootViewController

- (BOOL)shouldAutorotate {
    if (INTERFACE_IS_PHONE) {
        return NO;
    } else {
        return YES;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end
