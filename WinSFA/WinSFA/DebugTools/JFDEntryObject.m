//
//  JFDEntryObject.m
//  WinSFA
//
//  Created by dujinfeng481 on 14/12/1.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "JFDEntryObject.h"
#import "JFDRootViewController.h"
#import  <objc/runtime.h>
#import "WSPlistHelper.h"

#define TAP_HIT_NUMBER      (5)
#define TAP_TOUCH_NUMBER    (1)

@interface JFDEntryObject()
@property (nonatomic, assign) UIViewController  *enterViewController;
@property (nonatomic, retain) UIView            *enterView;
@end

@implementation JFDEntryObject


static JFDEntryObject *instance = nil;
+ (JFDEntryObject*) getInstance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        if (instance == nil) {
            instance = [[JFDEntryObject alloc] init];
        }
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self) {
        if (nil == instance) {
            instance = [super allocWithZone:zone];
        }
        return instance;
    }
    
    return nil;
}

-(id)copy
{
    return self;
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;    //如果未MRC，个人感觉应该使用 [self retain]
}

#if __has_feature(objc_arc)
#else
- (id) retain
{
    return self;
}

- (unsigned) retainCount
{
    return 1;
}

- (oneway void) release
{
    // Do nothing
}

- (id) autorelease
{
    return self;
}
#endif

#pragma mark - public method
- (void) addDebugToolsToViewController:(UIViewController*)vc
                             withFrame:(CGRect)rect
{
    if (!self.enterView || !vc) {
        self.enterViewController = vc;
        if (CGRectIsEmpty(rect) || CGRectIsNull(rect)) {
            if ([UIDevice isiPad] || [UIDevice isiPadSimulator]) {
                rect = CGRectMake(800, 10, 200, 200);
            }else {
                rect = CGRectMake(160, 10, 150, 150);
            }
        }
        self.enterView = [[UIView alloc] initWithFrame:rect];
        [self.enterView setBackgroundColor:[UIColor clearColor]];
        [vc.view addSubview:self.enterView];
        
        UITapGestureRecognizer *topGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
        [topGesture setNumberOfTapsRequired: TAP_HIT_NUMBER];
        [topGesture setNumberOfTouchesRequired: TAP_TOUCH_NUMBER];
        [self.enterView addGestureRecognizer:topGesture];
        
    }else {
        LogError(@"不能将debutTools添加到多个页面");
    }
}

- (void) removeDebutTools
{
    if (self.enterView) {
        [self.enterView removeFromSuperview];
        self.enterView = nil;
        self.enterViewController = nil;
    }
}

#pragma mark - private method
- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)sender
{
    if (sender.numberOfTapsRequired == TAP_HIT_NUMBER && sender.numberOfTouchesRequired == TAP_TOUCH_NUMBER) {
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"DebugRootStoryboard" bundle:nil];
        JFDRootViewController *debugController = [mainStoryboard instantiateViewControllerWithIdentifier:@"DebugRootID"];
        [self.enterViewController presentViewController:debugController animated:YES completion:^{
            LogInfo(@"show debug tools page");
        }];
    }
}

#pragma mark - overwrite method
-(void)exchangeAndsetDebugServerIp:(NSString *)pathStr
{
    BOOL needExchange = NO;
    if (self.debugServerIp != pathStr) {
        if (pathStr == nil || self.debugServerIp == nil) {
            needExchange = YES;
        }
        
        self.debugServerIp = pathStr;
    }
    
    if (needExchange) {
        LogInfo(@"adu dymanic exchange server ip method");
        Method addobject = class_getClassMethod([WSPlistHelper class], @selector(getCompleteURL:));
        Method logAddobject = class_getClassMethod([JFDEntryObject class], @selector(debugCompleteURL:));
        method_exchangeImplementations(addobject, logAddobject);
    }
}

+ (NSString *)debugCompleteURL:(NSString *)partOfURL
{
    NSString *resultString=[[[JFDEntryObject getInstance] debugServerIp] stringByAppendingString:partOfURL];
    LogInfo(@"adu dymanic 手动设置的debug server ip:%@", resultString);
    return resultString;
}

@end
