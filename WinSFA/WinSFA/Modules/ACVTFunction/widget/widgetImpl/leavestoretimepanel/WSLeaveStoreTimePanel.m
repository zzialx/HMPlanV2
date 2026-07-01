//
//  WSLeaveStoreTimePanel.m
//  WinSFA
//
//  Created by Alicia on 2017/8/1.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSLeaveStoreTimePanel.h"
#import "WSInoutStoreTable.h"
#import "WSDataSourceManager.h"
#import "WSAcvtModel.h"



#define kScreenDisplayScale (SCREEN_WIDTH / SCREEN_HEIGHT)
#define kCurrentVC_ViewHeight kCurrentVC_ViewWidth * kScreenDisplayScale
#define kCurrentVC_ViewWidth self.frame.size.width

#define kViewPadding     (kCurrentVC_ViewHeight * 0.0529)
#define kImageWH        (kCurrentVC_ViewWidth * 0.325)
#define kViewHeight     (kViewPadding * 2 + kImageWH)
#define kTextColorAlpha 0.8
#define kImgColorAlpha  0.2

#define Font_Size_Time ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 12.0f : 14.0f)
#define Font_Size_duration ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 11.0f : 13.0f)

@interface WSLeaveStoreTimePanel ()

@property (nonatomic, strong) UILabel *enterStoreLabel;
@property (nonatomic, strong) UILabel *leaveStoreLabel;
@property (nonatomic, strong) UILabel *durationTimeLabel;

@end

@implementation WSLeaveStoreTimePanel

#pragma mark - 重写widgetWillAppear方法 2018-04-20
- (void)widgetWillAppear
{
    double enterTime = [self getEnterStoreTime];
    double leaveTime = [self getLeaveStoreTime];
    NSString *durationTimeString = [self getDurationStoreTimeByEnterTime:enterTime leaveTime:leaveTime];
    
    [self setLeaveStoreTime:leaveTime];
    [self setDurationTime:durationTimeString];
}
- (void)buildDisplayContent
{
    [super buildDisplayContent];
    
    UIView *circleImageView = [self getBgCircleView];
    CGRect circleFrame = CGRectMake(self.frame.size.width / 2 - kImageWH - MAIN_CELL_PADDING, (kViewHeight - kImageWH) / 2, kImageWH, kImageWH);
    circleImageView.frame = circleFrame;
    circleImageView.tintColor = MAIN_TINT_COLOR;
    [self addSubview:circleImageView];
    
    UIView *bgView = [[UIView alloc] initWithFrame:circleFrame];
    [bgView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:bgView];
    
    CGFloat labelHeight = 18;
    UILabel *enterStoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, kViewHeight / 2 - labelHeight, self.frame.size.width / 2, labelHeight)];
    [enterStoreLabel setFont:FONT_SIZE_PINGFANG_MEDIUM(Font_Size_Time)];
    [self addSubview:enterStoreLabel];
    self.enterStoreLabel = enterStoreLabel;
    
    
    UILabel *leaveStoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, kViewHeight / 2, self.frame.size.width / 2, labelHeight)];
    [leaveStoreLabel setFont:FONT_SIZE_PINGFANG_MEDIUM(Font_Size_Time)];
    [self addSubview:leaveStoreLabel];
    self.leaveStoreLabel = leaveStoreLabel;

    CGFloat durationTimeHeight = 21;
    UILabel *durationTimeLabel = [[UILabel alloc] init];
    [durationTimeLabel setFrame:CGRectMake(0, circleImageView.size.height / 2 - durationTimeHeight, circleImageView.size.width, durationTimeHeight)];
    [durationTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [bgView addSubview:durationTimeLabel];
    self.durationTimeLabel = durationTimeLabel;
  
    UILabel *durationLabel = [[UILabel alloc] init];
    [durationLabel setText:NSLocalizedString(@"txt_duration", nil)];
    [durationLabel setFont:FONT_SIZE_PINGFANG_MEDIUM(Font_Size_duration)];
    [durationLabel setTextColor:GRAY_TEXT_COLOR];
    [durationLabel setFrame:CGRectMake(0, circleImageView.size.height / 2, circleImageView.size.width, 21)];
    [durationLabel setTextAlignment:NSTextAlignmentCenter];
    [bgView addSubview:durationLabel];

    // Set Text Value
    double enterTime = [self getEnterStoreTime];
    double leaveTime = [self getLeaveStoreTime];
    [self setEnterStoreTime:enterTime];
    [self setLeaveStoreTime:leaveTime];
    NSString *durationTimeString = [self getDurationStoreTimeByEnterTime:enterTime leaveTime:leaveTime];
    [self setDurationTime:durationTimeString];
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, kViewHeight)];
    
    
    NSInteger durationAngle = ([durationTimeString integerValue] % 60) * 6; // 6 = 360 / 60
    CGFloat durationRadian = durationAngle * M_PI / 180 - M_PI_4 - M_PI_2;
    [circleImageView setTransform:CGAffineTransformMakeRotation(durationRadian)];
}

- (void)setEnterStoreTime:(double)enterTime {
    NSString *enterTimeString = [WSCurrentTime getTimeStringbyMills:enterTime];
    if (enterTimeString) {
        NSString *enterString = NSLocalizedString(@"txt_enter_store_time", nil);
        NSString *enterLabelString = [NSString stringWithFormat:@"%@ %@", enterString, enterTimeString];
        NSMutableAttributedString *enterAttr = [[NSMutableAttributedString alloc] initWithString:enterLabelString];
        [enterAttr addAttribute:NSForegroundColorAttributeName value:DETAIL_TEXT_COLOR range:NSMakeRange(0, enterString.length)];
        [enterAttr addAttribute:NSForegroundColorAttributeName value:GRAY_TEXT_COLOR range:NSMakeRange(enterString.length + 1, enterTimeString.length)];
        [self.enterStoreLabel setAttributedText:enterAttr];
    }
}

- (void)setLeaveStoreTime:(double)leaveTime {
    NSString *leaveTimeString = [WSCurrentTime getTimeStringbyMills:leaveTime];
    NSString *leaveString = NSLocalizedString(@"txt_leave_store_time", nil);
    NSString *leaveLabelString = [NSString stringWithFormat:@"%@ %@", leaveString, leaveTimeString];
    NSMutableAttributedString *leaveAttr = [[NSMutableAttributedString alloc] initWithString:leaveLabelString];
    [leaveAttr addAttribute:NSForegroundColorAttributeName value:DETAIL_TEXT_COLOR range:NSMakeRange(0, leaveString.length)];
    [leaveAttr addAttribute:NSForegroundColorAttributeName value:GRAY_TEXT_COLOR range:NSMakeRange(leaveString.length + 1, leaveTimeString.length)];
    [self.leaveStoreLabel setAttributedText:leaveAttr];
}

- (void)setDurationTime:(NSString *)durationTimeString {
    NSString *durationString = NSLocalizedString(@"txt_point", nil);
    NSString *durationLabelString = [NSString stringWithFormat:@"%@ %@", durationTimeString, durationString];
    NSMutableAttributedString *durationAttr = [[NSMutableAttributedString alloc] initWithString:durationLabelString];
    NSRange durationRange = NSMakeRange(0, durationTimeString.length);
    NSRange durationLabelRange = NSMakeRange(durationTimeString.length + 1, durationString.length);
    [durationAttr addAttribute:NSForegroundColorAttributeName value:[MAIN_TINT_COLOR colorWithAlphaComponent:kTextColorAlpha] range:durationRange];
    [durationAttr addAttribute:NSForegroundColorAttributeName value:GRAY_TEXT_COLOR range:durationLabelRange];
    [durationAttr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:durationRange];
    [durationAttr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:FONT_SIZE_MAIN] range:durationLabelRange];
    [self.durationTimeLabel setAttributedText:durationAttr];
}

- (double)getEnterStoreTime {
    WSAcvtModel *acvtModel = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    if (!acvtModel) {
        LogError(@"Can not find activeModel");
        return [[WSCurrentTime getServerTime] doubleValue];
    }
    
    NSString* enterTime = [NSString stringWithValue:[[WSInoutStoreTable sharedTable] getEnterStoreTime:acvtModel.currentStore andOtherParam:acvtModel.md5 andParamType:EParameterType_VisitId]] ;
    if (enterTime != nil && ![enterTime isEqualToString:@""]) {
        return [enterTime doubleValue];
    } else {
        return [[WSCurrentTime getServerTime] doubleValue];
    }
}

- (double)getLeaveStoreTime {
    return [[WSCurrentTime getServerTime] doubleValue];
}

- (NSString *)getDurationStoreTimeByEnterTime:(double)enterTime leaveTime:(double)leaveTime {
    double minDiff = ceil((leaveTime - enterTime) / 60);
    NSString *durationTime = [NSString stringWithFormat:@"%.0lf",minDiff];
    return durationTime;
}

- (UIView *)getBgCircleView {
    CGFloat diameter = kImageWH;
    CGRect rect = CGRectMake(0, 0, diameter, diameter);
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    [circleLayer setFrame:rect];
    [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    [circleLayer setStrokeColor:[[MAIN_TINT_COLOR colorWithAlphaComponent:kTextColorAlpha] CGColor]];
    CGFloat radius = diameter / 2;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, nil, radius, radius, radius, M_PI * 35 / 180, M_PI * 55 / 180, YES);
    [circleLayer setPath:path];
    CGPathRelease(path);
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    [gradientLayer setFrame:CGRectInset(rect, -2, -2)];
    [gradientLayer setColors:@[(id)[[MAIN_TINT_COLOR colorWithAlphaComponent:kTextColorAlpha] CGColor], (id)[[MAIN_TINT_COLOR colorWithAlphaComponent:kImgColorAlpha] CGColor]]];
    [gradientLayer setStartPoint:CGPointMake(0, 0)];
    [gradientLayer setEndPoint:CGPointMake(1, 1)];
    
    CALayer *circleGradientLayer = [CALayer layer];
    [circleGradientLayer setFrame:rect];
    [circleGradientLayer addSublayer:gradientLayer];
    [circleGradientLayer setMask:circleLayer];
    
    CAShapeLayer *dotLayer = [CAShapeLayer layer];
    [dotLayer setFrame:rect];
    [dotLayer setFillColor:[[MAIN_TINT_COLOR colorWithAlphaComponent:kImgColorAlpha] CGColor]];
    CGMutablePathRef dotPath = CGPathCreateMutable();
    CGPathAddEllipseInRect(dotPath, nil, CGRectMake(diameter * 0.82, diameter * 0.82, 5, 5));
    [dotLayer setPath:dotPath];
    CGPathRelease(dotPath);

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kImageWH, kImageWH)];
    [view.layer addSublayer:circleGradientLayer];
    [view.layer addSublayer:dotLayer];
    
    return view;
}
- (UIViewController*)getResponderViewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController
                                          class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
    
}

@end
