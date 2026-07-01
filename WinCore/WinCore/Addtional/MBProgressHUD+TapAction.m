//
//  MBProgressHUD+TapAction.m
//  HudDemo
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "MBProgressHUD+TapAction.h"
#import "WSLoadingImageView.h"

@interface MBDotActivityIndicatorView : UIView

@property (nonatomic, strong) UIImageView *circleImageView;

@end

@implementation MBDotActivityIndicatorView
+ (MBDotActivityIndicatorView *)activityIndicatorView {
    CGFloat WH = 30;
    MBDotActivityIndicatorView *indicator = [[MBDotActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, WH,WH)];
    return indicator;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin;
        _circleImageView = [[WSLoadingImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_circleImageView];
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if ([view pointInside:[self convertPoint:point toView:view] withEvent:event])
            return YES;
    }
    return NO;
}

- (void)startAnimating {
    [_circleImageView startAnimating];
}

- (void)stopAnimating {
    [_circleImageView stopAnimating];
}


@end



@implementation MBProgressHUD (TapAction)

+(MB_INSTANCETYPE)showHUDAddedTo:(UIView *)aView withText:(NSString *)text tips:(NSString *)tips tapTarget:(id)target action:(SEL)action {
    return [MBProgressHUD showHUDAddedTo:aView withText:text tips:tips tapTarget:target action:action type:MBProgressHUDMessageTypeWaiting];
}

+ (MB_INSTANCETYPE)showHUDAddedTo:(UIView *)aView withText:(NSString *)text tips:(NSString *)tips tapTarget:(id)target action:(SEL)action type:(MBProgressHUDMessageType)type
{
    NSTimeInterval hideTime = 1.0;
    
    if ([text length] > 10 || [tips length] > 10) {
        
        hideTime = 2.0;
        //SFA-23760 zhaodanyang
        if ([text length] > 30 || [tips length] > 30) {
            hideTime = 3.0;
            
            if ([text length] > 50 || [tips length] > 50) {
                hideTime = 5.0;
            }
        }
    }
    
    return [MBProgressHUD showHUDAddedTo:aView withText:text tips:tips tapTarget:target action:action type:type autoHideTime:hideTime];
}

+ (MB_INSTANCETYPE)showHUDAddedTo:(UIView *)aView withText:(NSString *)text tips:(NSString *)tips tapTarget:(id)target action:(SEL)action type:(MBProgressHUDMessageType)type autoHideTime:(NSTimeInterval)autoHideTime
{
    LogInfo(@"Toast msg:%@", text);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:aView animated:YES];
    hud.label.text = text;
    hud.detailsLabel.text = tips;
    hud.removeFromSuperViewOnHide = YES;
    
    
//    if (INTERFACE_IS_PAD) {
//        hud.edgeMargin = 300;
//    }
    
    switch (type) {
        case MBProgressHUDMessageTypeWaiting:
        {
//            hud.mode = MBProgressHUDModeIndeterminate;
//            hud.mode = MBProgressHUDModeCustomView;
//            MBDotActivityIndicatorView *indicatorView = [MBDotActivityIndicatorView activityIndicatorView];
//            hud.customView = indicatorView;
//            [indicatorView startAnimating];
        }
            break;
        case MBProgressHUDMessageTypeDone:
        {
            hud.mode = MBProgressHUDModeCustomView;
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"hud_done"]];
            [hud hideAnimated:YES afterDelay:autoHideTime];
        }
            break;
        case MBProgressHUDMessageTypeFailed:
        {
            hud.mode = MBProgressHUDModeCustomView;
//            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"hud_failed"]];
            [hud hideAnimated:YES afterDelay:autoHideTime];

        }
            break;
        case  MBProgressHUDMessageTypeText:
        {
            hud.mode = MBProgressHUDModeText;
            [hud hideAnimated:YES afterDelay:autoHideTime];
            break;
        }
        default:
            hud.mode = MBProgressHUDModeIndeterminate;
            break;
    }
    
    
    UITapGestureRecognizer *HUDSingleTap = [[UITapGestureRecognizer alloc]initWithTarget:target action:action];
    [hud addGestureRecognizer:HUDSingleTap];
    return hud;
}

@end
