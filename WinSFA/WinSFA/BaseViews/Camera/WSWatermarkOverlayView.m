//
//  WSWatermarkOverlayView.m
//  WinSFA
//
//  Created by Alicia on 2017/8/7.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#define kFontColor      [UIColor whiteColor]
//#define kFontSize       11
#define kFontSizeRatio  (INTERFACE_IS_PHONE ? 0.0344 : 0.012)    // 0.0344 = 11/320, 320 像素下需要显示字号大小为 11
#define kBgAlpha        0.4
#define kBgWidthRatio   (INTERFACE_IS_PHONE ? 1.0 : 0.15)
#define KIconSpace 4

#import "WSWatermarkOverlayView.h"

@interface WSWatermarkOverlayView ()

@property (nonatomic, assign) CGFloat offsetY;
// MSTD-7860
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) CGPoint bottomPoint;
@property (nonatomic, assign) CGFloat totalHeight;//上半部分水印的高度
@property (nonatomic, copy)  NSString *locationType;

@end

@implementation WSWatermarkOverlayView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame locationType:nil];
}

- (instancetype)initWithFrame:(CGRect)frame locationType:(NSString *)locationType
{
    self = [super initWithFrame:frame];
    if (self) {
        self.locationType = locationType;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.totalHeight= 0;
   //SFA-23422
    BOOL isCenterDisplay = NO;
    BOOL isHiddenline = NO;
    NSInteger textAttachment = NSTextAlignmentLeft;
    NSString *image_watermark = [NSString stringWithValue:[[NSUserDefaults standardUserDefaults] objectForKey:IMAGE_WATERMARK]];
    if ([image_watermark isEqualToString:@"3"] && self.locationType && [self.locationType isEqualToString:@"1"]) {
        //水印居中显示
        isCenterDisplay = YES;
        isHiddenline = YES;
        textAttachment = NSTextAlignmentCenter;
        
    }
    
    CGFloat waterBackViewY = 0;
    CGRect waterBackViewRect = CGRectMake(0, waterBackViewY, self.width, self.totalHeight);
    UIView *waterBackView = [[UIView alloc] initWithFrame:waterBackViewRect];
    waterBackView.backgroundColor = [UIColor clearColor];
    [self addSubview:waterBackView];
    
    CGFloat paddingX = 26;
    CGFloat upWidth = self.width - (paddingX * 2);
    CGFloat displayNameFontSize = self.width * kFontSizeRatio;
    CGRect displayNameRect = CGRectMake(paddingX, MAIN_CELL_PADDING, upWidth, displayNameFontSize);
    UILabel *displayNameLabel = [[UILabel alloc] initWithFrame:displayNameRect];
    [displayNameLabel setFont:FONT_SIZE_PINGFANG_REGULAR(displayNameFontSize)];
    [displayNameLabel setTextColor:kFontColor];
    [displayNameLabel setText:APP_DISPLAY_NAME];
    displayNameLabel.textAlignment = textAttachment;
    [waterBackView addSubview:displayNameLabel];
    self.totalHeight += displayNameFontSize;
    
    CGFloat timeFontSize = self.width * kFontSizeRatio * 3;
    CGRect timeRect = CGRectMake(paddingX, CGRectGetMaxY(displayNameRect), upWidth, timeFontSize);
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeRect];
    [timeLabel setTextColor:kFontColor];
    [timeLabel setFont:FONT_SIZE_PINGFANG_REGULAR(timeFontSize)];
    [timeLabel setText:[WSCurrentTime getShortTimeString]];
    timeLabel.textAlignment = textAttachment;
    [waterBackView addSubview:timeLabel];
    self.totalHeight += timeFontSize;
    
    CGFloat dateFontSize = self.width * kFontSizeRatio;
    CGRect dateRect = CGRectMake(paddingX, CGRectGetMaxY(timeRect), upWidth, dateFontSize);
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:dateRect];
    [dateLabel setTextColor:kFontColor];
    [dateLabel setFont:FONT_SIZE_PINGFANG_REGULAR(dateFontSize)];
    [dateLabel setText:[WSCurrentTime getLocalizedWeekAndDateStringFormatDot]];
    dateLabel.textAlignment = textAttachment;
    [waterBackView addSubview:dateLabel];
    self.totalHeight += dateFontSize;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(MAIN_CELL_PADDING, MAIN_CELL_PADDING, 2, self.totalHeight)];
    [lineView setBackgroundColor:[UIColor whiteColor]];
    lineView.hidden = isHiddenline;
    [waterBackView addSubview:lineView];
    // MSTD-7860
    self.point = CGPointMake(MAIN_CELL_PADDING + self.frame.origin.x, MAIN_CELL_PADDING + self.totalHeight + self.frame.origin.y);
    self.offsetY = MAIN_TEXT_IMG_PADDING;
    
    if (isCenterDisplay) {
        waterBackViewY = (self.height - self.totalHeight) / 2;
        waterBackView.frame = CGRectMake(0, waterBackViewY, self.width, self.totalHeight);
    }
    
}

// MSTD-7860
- (CGPoint)getLineBottomPoint {
    return self.point;
}

- (void)setFuncName:(NSString *)funcName empName:(NSString *)empName lua:(NSString *)lua {
    [self setFuncName:funcName empName:empName storeCode:nil storeName:nil storeAddress:nil storeLocation:nil lua:lua];
}


- (void)setFuncName:(NSString *)funcName empName:(NSString *)empName storeCode:(NSString *)storeCode storeName:(NSString *)storeName storeAddress:(NSString *)storeAddress storeLocation:(NSString *)storeLocation lua:(NSString *)lua
{
    [self setFuncName:funcName empName:empName storeCode:storeCode storeName:storeName storeAddress:storeAddress storeLocation:storeLocation lua:lua qstName:nil];

}

- (void)addLabelText:(NSString *)text icon:(UIImage *)iconImage toView:(UIView *)view {
    if (!text || [text length] == 0) {
        return;
    }
    
    CGFloat iconWidth = 0;
    if (iconImage && INTERFACE_IS_PHONE) {
        iconWidth = iconImage.size.width;
    }
    
    CGFloat width = self.width * kBgWidthRatio - iconWidth - MAIN_CELL_PADDING * 2;
    CGSize textSize = [text ws_sizeWithFont:FONT_SIZE_PINGFANG_REGULAR(kFontSizeRatio * self.width) constrainedToWidth:width];
    CGFloat padding;
    if (INTERFACE_IS_PHONE) {
        padding = self.width - textSize.width - MAIN_CELL_PADDING;
    } else {
        padding = MAIN_CELL_PADDING;
    }
    CGRect labelRect = CGRectMake(padding, self.offsetY, textSize.width, textSize.height);
    UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
    [label setTextColor:kFontColor];
    [label setFont:FONT_SIZE_PINGFANG_REGULAR(kFontSizeRatio * self.width)];
    [label setText:text];
    [label setNumberOfLines:-1];
    [view addSubview:label];
    
    if (iconImage && INTERFACE_IS_PHONE) {
        CGRect iconFrame = CGRectMake(padding - iconWidth - KIconSpace, self.offsetY + (textSize.height - iconWidth) * 0.5, iconWidth, iconWidth);
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:iconFrame];
        [iconImageView setImage:iconImage];
        [iconImageView setContentMode:UIViewContentModeCenter];
        [view addSubview:iconImageView];
    }
    
    self.offsetY += textSize.height;
}

- (CGFloat)getBottomViewOffsetY {
    return self.offsetY + MAIN_CELL_PADDING;
}

- (CGFloat)getMiddleContentHeight {
    return self.bottomPoint.y - self.point.y;
}

- (CGFloat)getHeaderViewHeight{
    return self.totalHeight +MAIN_CELL_PADDING + MAIN_TEXT_IMG_PADDING;//额外加MAIN_TEXT_IMG_PADDING为距离取景框的间隔
}

- (CGFloat)getBottomViewHeight{
    return self.offsetY + MAIN_TEXT_IMG_PADDING;//额外加MAIN_CELL_PADDING为距离取景框的间隔
}

#pragma mark - 终极设置水印方法
- (void)setFuncName:(NSString *)funcName empName:(NSString *)empName storeCode:(NSString *)storeCode
          storeName:(NSString *)storeName storeAddress:(NSString *)storeAddress storeLocation:(NSString *)storeLocation
                lua:(NSString *)lua qstName:(NSString *)qstName {
    
    UIView *backView = [[UIView alloc] init];
    
    if (qstName.length > 0) {
        [self addLabelText:qstName icon:nil toView:backView];
    }
    
    [self addLabelText:funcName icon:nil toView:backView];
    
    [self addLabelText:empName icon:nil toView:backView];
    
    NSString *storeCodeName = nil;
    if (storeCode && storeName) {
        storeCodeName = [NSString stringWithFormat:@"%@ %@", storeCode, storeName];
    } else if (storeName) {
        storeCodeName = storeName;
    }
    [self addLabelText:storeCodeName icon:nil toView:backView];
    
    if (storeLocation && storeLocation.length > 0) {
        [self addLabelText:storeLocation icon:nil toView:backView];
    }
    
    [self addLabelText:storeAddress icon:[UIImage imageNamed:@"icon_location"] toView:backView];
    
    WSLocationDescribe *locationDesrible = [WSLocationManager getInstance].lastLocation;
    NSString * userAddress = locationDesrible.detailAddress;
    if (userAddress.length>0) {
        [self addLabelText:userAddress icon:[UIImage imageNamed:@"icon_location"] toView:backView];
    }
    
    NSArray *luaArray = [lua componentsSeparatedByString:@"\n"];
    if ([luaArray count] > 0){
        for (NSString * str  in luaArray) {
            if (str.length > 0) {
                [self addLabelText:str icon:nil toView:backView];
            }
        }
    } else {
        [self addLabelText:lua icon:nil toView:backView];
    }
    
    CGFloat viewWidth = self.width * kBgWidthRatio;
    CGFloat viewHeight = self.offsetY + MAIN_TEXT_IMG_PADDING;
    [backView setFrame:CGRectMake(0, self.height - viewHeight + 1, viewWidth, viewHeight)];
    self.bottomPoint = CGPointMake(backView.frame.origin.x, backView.frame.origin.y);
    if (INTERFACE_IS_PHONE) {
        [backView setBackgroundColor:[UIColor colorWithWhite:0 alpha:kBgAlpha]];
        [self sendSubviewToBack:backView];
    } else {
        UIView *leftBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, self.height)];
        [leftBackView setBackgroundColor:[UIColor colorWithWhite:0 alpha:kBgAlpha]];
        [self addSubview:leftBackView];
        [self sendSubviewToBack:leftBackView];
    }
    [self addSubview:backView];
}

@end
