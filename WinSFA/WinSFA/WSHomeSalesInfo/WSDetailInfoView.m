//
//  WSDetailInfoView.m
//  WinSFA
//
//  Created by mac on 2018/11/9.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSDetailInfoView.h"
#import "DACircularProgressView.h"
#import "DACircularProgressView.h"

#define CircleButtonColor       ([UIColor colorForKey:@"CircleButton"] ?  : MAIN_TEXT_COLOR)
#define CircleButtonFont         ([UIFont fontForKey:@"CircleButton"] ?  : [UIFont systemFontOfSize:UI_Font])

#define CircleLabelColor       ([UIColor colorForKey:@"CircleLabel"] ?  : MAIN_TEXT_COLOR)
#define CircleLabelFont         ([UIFont fontForKey:@"CircleLabel"] ?  : [UIFont systemFontOfSize:UI_Font])

// 中间视图宏
//iphone 6 圆的宽度 和 屏幕的宽度、边距
#define scale_Width 375
#define scale (SCREEN_WIDTH/scale_Width)
#define circleWidth 190

#define KLABELTOPSPACE 15*scale
#define KLABELRIGHRSPACE 10*scale

#define kSalesInfoElementHeight 120*scale

#define KTOPABELSPACE 15
#define KPROGRESSVIEWTOPSPACE 10
#define KBUTTONWIDTH 93*scale
#define KBUTTONHEIGHT 20*scale
#define KBUTTONSPACE 10
#define KBUTTONLEFTSPACE 129
#define KBUTTONTOPSPACE 20
#define KTOPCIRCLELINEWIDTH 8
#define KLEFTSPACE 25
#define BOTTOMOUTSIDEPROGRESSVIEW_WIDTH 80
#define BOTTOMMIDDLEPROGRESSVIEW_WIDTH 60
#define BOTTOMINSIDEPROGRESSVIEW_WIDTH 40
#define KBOTTOMCIRCLELINEWIDTH 4
#define CIRCLESPACE 10
#define KLABELLEFTSPACE 223
#define KLABELWIDTH 70
#define KNAMEWIDTH 200

@interface WSDetailInfoView()

@property (nonatomic, strong) DACircularProgressView *bottomOutsideProgressView;
@property (nonatomic, strong) DACircularProgressView *bottomMiddleProgressView;
@property (nonatomic, strong) DACircularProgressView *bottomInsideProgressView;
@property (nonatomic, strong) UIImageView *progressViewbackImageView;

@property (nonatomic, strong) UIButton *bottomOutsidButton;
@property (nonatomic, strong) UIButton *bottomMiddleButton;
@property (nonatomic, strong) UIButton *bottomIntsidButton;

@property (nonatomic, strong) UILabel *bottomOutsideLeftLabel;
@property (nonatomic, strong) UILabel *bottomOutsideRightLabel;

@property (nonatomic, strong) UILabel *bottomMiddleLeftLabel;
@property (nonatomic, strong) UILabel *bottomMiddleRightLabel;

@property (nonatomic, strong) UILabel *bottomInsideLeftLabel;
@property (nonatomic, strong) UILabel *bottomInsideRightLabel;

@end

#pragma mark - 销售信息视图 延展(工具)
@interface WSDetailInfoView (Tools)

#pragma mark - 设置销售信息视图方法
- (void)setupDetailInfoView;

#pragma mark - 布局核心信息方法
- (void)layoutDetailInfo;

#pragma mark - 测量图片尺寸方法(缩放计算) imageSize:图片尺寸 drawWidth:绘制宽度
//- (CGSize)measureImageSizeWithImageSize:(CGSize)imageSize drawWidth:(CGFloat)drawWidth;

@end
@implementation WSDetailInfoView

#pragma mark - 重写initWithFrame:方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupDetailInfoView];
    }
    return self;
}

- (DACircularProgressView *)bottomOutsideProgressView{
    if (_bottomOutsideProgressView == nil) {
        _bottomOutsideProgressView = [[DACircularProgressView alloc] initWithFrame:CGRectZero];
        _bottomOutsideProgressView.roundedCorners = YES;
        
        //背景环颜色
        _bottomOutsideProgressView.trackTintColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:252.0/255.0 alpha:1.0];
        // 填充色
        _bottomOutsideProgressView.progressTintColor = [UIColor colorWithRed:131.0/255.0 green:148.0/255.0 blue:251.0/255.0 alpha:1.0];
        
    }
    return _bottomOutsideProgressView;
}

- (DACircularProgressView *)bottomMiddleProgressView{
    if (_bottomMiddleProgressView == nil) {
        _bottomMiddleProgressView = [[DACircularProgressView alloc] initWithFrame:CGRectZero];
        _bottomMiddleProgressView.roundedCorners = YES;
        //        _bottomMiddleProgressView.lineWidth = 4;
        //        _bottomMiddleProgressView.thicknessRatio = 0.1;
        //背景环颜色
        [_bottomMiddleProgressView setTrackTintColor:[UIColor colorWithRed:247.0/255.0 green:241.0/255.0 blue:251.0/255.0 alpha:1.0]];
        // 填充色
        self.bottomMiddleProgressView.progressTintColor = [UIColor colorWithRed:188.0/255.0 green:141.0/255.0 blue:238.0/255.0 alpha:1.0];
    }
    return _bottomMiddleProgressView;
}

- (DACircularProgressView *)bottomInsideProgressView{
    if (_bottomInsideProgressView == nil) {
        _bottomInsideProgressView = [[DACircularProgressView alloc] initWithFrame:CGRectZero];
//        _bottomInsideProgressView.roundedCorners = NO;
        
        //背景环颜色
        [self.bottomInsideProgressView setTrackTintColor:[UIColor colorWithRed:254.0/255.0 green:243.0/255.0 blue:242.0/255.0 alpha:1.0] ];
        // 填充色
        self.bottomInsideProgressView.progressTintColor = [UIColor colorWithRed:255.0/255.0 green:168.0/255.0 blue:151.0/255.0 alpha:1.0];
    }
    return _bottomInsideProgressView;
}

- (UIButton *)bottomOutsidButton{
    if (_bottomOutsidButton == nil) {
        _bottomOutsidButton = [[UIButton alloc] initWithFrame:CGRectMake(KBUTTONLEFTSPACE, self.progressViewbackImageView.height + KBUTTONTOPSPACE,  KBUTTONWIDTH, KBUTTONHEIGHT)];
        [_bottomOutsidButton setImage:[UIImage imageNamed:@"jinggengmendian"] forState:UIControlStateNormal];
        [_bottomOutsidButton setTitle:@"精耕门店" forState:UIControlStateNormal];
        [_bottomOutsidButton setTitleColor:CircleButtonColor forState:UIControlStateNormal];
        _bottomOutsidButton.imageEdgeInsets = UIEdgeInsetsMake(5 ,0 , 5, 10);  _bottomOutsidButton.titleLabel.font = CircleButtonFont;
        _bottomOutsidButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;// 水平左对齐
        _bottomOutsidButton.contentVerticalAlignment = UIControlContentHorizontalAlignmentLeft;// 垂直居中对齐
    }
    return _bottomOutsidButton;
}

- (UIButton *)bottomMiddleButton{
    if (_bottomMiddleButton == nil) {
        _bottomMiddleButton = [[UIButton alloc] initWithFrame:CGRectMake(KBUTTONLEFTSPACE, CGRectGetMaxY(self.bottomOutsidButton.frame) + KBUTTONSPACE,  KBUTTONWIDTH, KBUTTONHEIGHT)];
        [_bottomMiddleButton setImage:[UIImage imageNamed:@"yudazao"] forState:UIControlStateNormal];
        [_bottomMiddleButton setTitle:@"预打造门店" forState:UIControlStateNormal];
        [_bottomMiddleButton  setTitleColor:CircleButtonColor forState:UIControlStateNormal];
        _bottomMiddleButton.titleLabel.font = CircleButtonFont;
        _bottomMiddleButton.imageEdgeInsets = UIEdgeInsetsMake(5 ,0 , 5, 10);
        
        _bottomMiddleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;// 水平左对齐
        _bottomMiddleButton.contentVerticalAlignment = UIControlContentHorizontalAlignmentLeft;// 垂直居中对齐
    }
    return _bottomMiddleButton;
}

- (UIButton *)bottomIntsidButton{
    if (_bottomIntsidButton == nil) {
        _bottomIntsidButton = [[UIButton alloc] initWithFrame:CGRectMake(KBUTTONLEFTSPACE, CGRectGetMaxY(self.bottomMiddleButton.frame) + KBUTTONSPACE  ,  KBUTTONWIDTH, KBUTTONHEIGHT)];
        [_bottomIntsidButton setImage:[UIImage imageNamed:@"saomangmendian"] forState:UIControlStateNormal];
        [_bottomIntsidButton setTitle:@"扫盲门店" forState:UIControlStateNormal];
        [_bottomIntsidButton setTitleColor:CircleButtonColor forState:UIControlStateNormal];
        _bottomIntsidButton.titleLabel.font = CircleButtonFont;
        _bottomIntsidButton.imageEdgeInsets = UIEdgeInsetsMake(5 ,0 , 5, 10);
        
        _bottomIntsidButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;// 水平左对齐
        _bottomIntsidButton.contentVerticalAlignment = UIControlContentHorizontalAlignmentLeft;// 垂直居中对齐
    }
    return _bottomIntsidButton;
}

- (UILabel *)bottomOutsideLeftLabel{
    if (_bottomOutsideLeftLabel == nil) {
        _bottomOutsideLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(KLABELLEFTSPACE, self.bottomOutsidButton.frame.origin.y, KLABELWIDTH, KBUTTONHEIGHT)];
        _bottomOutsideLeftLabel.font = CircleLabelFont;
        [_bottomOutsideLeftLabel setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
        
    }
    return _bottomOutsideLeftLabel;
}

- (UILabel *)bottomOutsideRightLabel{
    if (_bottomOutsideRightLabel == nil) {
        _bottomOutsideRightLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bottomOutsideLeftLabel.frame) + 3, self.bottomOutsidButton.frame.origin.y, KLABELWIDTH, KBUTTONHEIGHT)];
        _bottomOutsideRightLabel.font = CircleLabelFont;
        [_bottomOutsideRightLabel setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
    }
    return _bottomOutsideRightLabel;
}

- (UILabel *)bottomMiddleLeftLabel{
    if (_bottomMiddleLeftLabel == nil) {
        _bottomMiddleLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(KLABELLEFTSPACE, self.bottomMiddleButton.frame.origin.y, KLABELWIDTH, KBUTTONHEIGHT)];
        _bottomMiddleLeftLabel.font = CircleLabelFont;
        [_bottomMiddleLeftLabel setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
    }
    return _bottomMiddleLeftLabel;
}
- (UILabel *) bottomMiddleRightLabel{
    if (_bottomMiddleRightLabel == nil) {
        _bottomMiddleRightLabel =  [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bottomMiddleLeftLabel.frame) + 5, self.bottomMiddleLeftLabel.frame.origin.y, KLABELWIDTH, KBUTTONHEIGHT)];
        _bottomMiddleRightLabel.font = CircleLabelFont;
        [_bottomMiddleRightLabel setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
    }
    return _bottomMiddleRightLabel;
}

- (UILabel *)bottomInsideLeftLabel{
    if (_bottomInsideLeftLabel == nil) {
        _bottomInsideLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(KLABELLEFTSPACE, self.bottomIntsidButton.frame.origin.y, KLABELWIDTH, KBUTTONHEIGHT)];
        _bottomInsideLeftLabel.font = CircleLabelFont;
        //        _bottomInsideLabel.textColor = CircleLabelColor;
        [_bottomInsideLeftLabel setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
        
    }
    return _bottomInsideLeftLabel;
}

- (UILabel *) bottomInsideRightLabel{
    if (_bottomInsideRightLabel == nil) {
        _bottomInsideRightLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bottomInsideLeftLabel.frame) + 3, self.bottomInsideLeftLabel.frame.origin.y, KLABELWIDTH, KBUTTONHEIGHT)];
        _bottomInsideRightLabel.font = CircleLabelFont;
        [_bottomInsideRightLabel setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
    }
    return _bottomInsideRightLabel;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutDetailInfo];

}

#pragma mark - 计算销售信息视图高度方法 width:宽度
- (CGFloat)calculationCircleInfoViewHeightWithWidth:(CGFloat)width
{
    if(width <= 0.0f)
        return width;

    CGFloat maxHeight = 0.0f;

    maxHeight += kSalesInfoElementHeight ;
    return maxHeight;
}

#pragma mark - 更新销售信息视图方法 showData:显示数据
- (void)updateDetailInfoViewWithShowData:(WSCircleDetailInfoViewShowData *)showData
{
    
    CGFloat outSideProgress = (showData.tilte4.length > 0) ? [showData.tilte4 floatValue] /100.0 : 0.0;
    [self.bottomOutsideProgressView setProgress:outSideProgress animated:YES];

    CGFloat middleSideProgress = (showData.content5.length > 0) ? [showData.content5 floatValue] /100.0 : 0.0;
    [self.bottomMiddleProgressView setProgress:middleSideProgress animated:YES];

    CGFloat inSideProgress = (showData.tilte7.length > 0) ? [showData.tilte7 floatValue] /100.0 : 0.0;
    [self.bottomInsideProgressView setProgress:inSideProgress animated:YES];
    
    NSString *outsideGoalStr = (showData.content3.length > 0) ? [NSString stringWithFormat:@"%@",showData.content3] :@"0";
    NSString *outsideRateStr = (showData.tilte4.length > 0) ? [NSString stringWithFormat:@"%@%%",showData.tilte4]: @"0";
    self.bottomOutsideLeftLabel.attributedText = [self changeTextColorWithString:[NSString stringWithFormat:@"目标%@家",outsideGoalStr] isLeftLabel:YES];
    self.bottomOutsideRightLabel.attributedText = [self changeTextColorWithString:[NSString stringWithFormat:@"完成%@",outsideRateStr] isLeftLabel:NO] ;
    
    NSString *middleGoalStr = (showData.tilte5.length > 0) ? [NSString stringWithFormat:@"%@",showData.tilte5] :@"0";
    NSString *middleRateStr = (showData.content5.length > 0) ? [NSString stringWithFormat:@"%@%%",showData.content5]: @"0";
    self.bottomMiddleLeftLabel.attributedText = [self changeTextColorWithString:[NSString stringWithFormat:@"目标%@家",middleGoalStr] isLeftLabel:YES];
    self.bottomMiddleRightLabel.attributedText = [self changeTextColorWithString:[NSString stringWithFormat:@"完成%@",middleRateStr] isLeftLabel:NO];
    
    NSString *insideGoalStr = (showData.content5.length > 0) ? [NSString stringWithFormat:@"%@",showData.content6]  :@"0";
    NSString *insideRateStr = (showData.tilte7.length > 0) ?  [NSString stringWithFormat:@"%@%%",showData.tilte7]: @"0";
    
    self.bottomInsideLeftLabel.attributedText = [self changeTextColorWithString:[NSString stringWithFormat:@"目标%@家",insideGoalStr] isLeftLabel:YES];
    self.bottomInsideRightLabel.attributedText = [self changeTextColorWithString:[NSString stringWithFormat:@"完成%@",insideRateStr] isLeftLabel:NO];
    
    [self setNeedsLayout];
}


-(NSMutableAttributedString *) changeTextColorWithString :(NSString *)str isLeftLabel :(BOOL) isLeft
{
    
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSRange range1 = NSMakeRange(0, 0);
    NSRange range2 = NSMakeRange(0, 0);
    if (isLeft) {
        if ([str rangeOfString:@"标"].location != NSNotFound) {
            range1 = [str rangeOfString:@"标"];
        }
        range2 = NSMakeRange(range1.location+1, str.length-3);
    }
    else{
        if ([str rangeOfString:@"成"].location != NSNotFound) {
            range1 = [str rangeOfString:@"成"];
        }
        range2 = NSMakeRange(range1.location + 1, str.length -2);
    }
    
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:24.0/255.0 green:128.0/255.0 blue:249.0/255.0 alpha:1.0] range:range2];
    
    return attributeStr;
}

@end
//===================================================================================================================================================================

#pragma mark - 销售信息视图 延展(工具)
@implementation WSDetailInfoView (Tools)

#pragma mark - 设置销售信息视图方法
- (void)setupDetailInfoView
{
    [self addSubview:self.bottomOutsideProgressView];
    [self addSubview:self.bottomMiddleProgressView];
    [self addSubview:self.bottomInsideProgressView];
    
    [self addSubview:self.bottomOutsidButton];
    [self addSubview:self.bottomMiddleButton];
    [self addSubview:self.bottomIntsidButton];
    
    [self addSubview:self.bottomOutsideLeftLabel];
    [self addSubview:self.bottomOutsideRightLabel];
    [self addSubview:self.bottomMiddleLeftLabel];
    [self addSubview:self.bottomMiddleRightLabel];
    [self addSubview:self.bottomInsideLeftLabel];
    [self addSubview:self.bottomInsideRightLabel];

}

- (void) layoutDetailInfo{
    
    CGFloat bootmY = KLABELTOPSPACE;
    
    if (self.bottomOutsideRightLabel.text.length > 0){
        
        CGSize titleSize = [self.bottomOutsideRightLabel.text ws_sizeWithFont:self.bottomOutsideRightLabel.font constrainedToWidth:2000.0f];
        CGFloat x = (CGRectGetWidth(self.frame) - titleSize.width) - KLABELRIGHRSPACE;
        CGFloat y = bootmY;
        CGFloat w = titleSize.width;
        CGFloat h = titleSize.height;
        self.bottomOutsideRightLabel.frame = CGRectMake(x, y, w, h);
    }
    if (self.bottomOutsideLeftLabel.text.length > 0) {
        CGSize titleSize = [self.bottomOutsideLeftLabel.text ws_sizeWithFont:self.bottomOutsideLeftLabel.font constrainedToWidth:2000.0f];
        CGFloat x = (CGRectGetMinX(self.bottomOutsideRightLabel.frame) - titleSize.width) - KLABELRIGHRSPACE;
        CGFloat y = bootmY;
        CGFloat w = titleSize.width;
        CGFloat h = titleSize.height;
        self.bottomOutsideLeftLabel.frame = CGRectMake(x, y, w, h);
    }
    self.bottomOutsidButton.frame = CGRectMake(CGRectGetMinX(self.bottomOutsideLeftLabel.frame) - KBUTTONWIDTH - KLABELRIGHRSPACE, bootmY, KBUTTONWIDTH, KBUTTONHEIGHT);
    
    CGFloat bootmSecondY = CGRectGetMaxY(self.bottomOutsideRightLabel.frame) + KTOPABELSPACE;
    
    if (self.bottomMiddleRightLabel.text.length > 0){
        
        CGSize titleSize = [self.bottomMiddleRightLabel.text ws_sizeWithFont:self.bottomMiddleRightLabel.font constrainedToWidth:2000.0f];
        CGFloat x = (CGRectGetWidth(self.frame) - titleSize.width) - KLABELRIGHRSPACE;
        CGFloat y = bootmSecondY;
        CGFloat w = titleSize.width;
        CGFloat h = titleSize.height;
        self.bottomMiddleRightLabel.frame = CGRectMake(x, y, w, h);
    }
    if (self.bottomMiddleLeftLabel.text.length > 0) {
        CGSize titleSize = [self.bottomMiddleLeftLabel.text ws_sizeWithFont:self.bottomMiddleLeftLabel.font constrainedToWidth:2000.0f];
        CGFloat x = (CGRectGetMinX(self.bottomMiddleRightLabel.frame) - titleSize.width) - KLABELRIGHRSPACE;
        CGFloat y = bootmSecondY;
        CGFloat w = titleSize.width;
        CGFloat h = titleSize.height;
        self.bottomMiddleLeftLabel.frame = CGRectMake(x, y, w, h);
    }
    self.bottomMiddleButton.frame = CGRectMake(CGRectGetMinX(self.bottomMiddleLeftLabel.frame) - KBUTTONWIDTH - KLABELRIGHRSPACE, bootmSecondY, KBUTTONWIDTH, KBUTTONHEIGHT);
    
    CGFloat bootmThirdY = CGRectGetMaxY(self.bottomMiddleRightLabel.frame) + KTOPABELSPACE;
    if (self.bottomInsideRightLabel.text.length > 0){
        
        CGSize titleSize = [self.bottomInsideRightLabel.text ws_sizeWithFont:self.bottomInsideRightLabel.font constrainedToWidth:2000.0f];
        CGFloat x = (CGRectGetWidth(self.frame) - titleSize.width) - KLABELRIGHRSPACE;
        CGFloat y = bootmThirdY;
        CGFloat w = titleSize.width;
        CGFloat h = titleSize.height;
        self.bottomInsideRightLabel.frame = CGRectMake(x, y, w, h);
    }
    if (self.bottomInsideLeftLabel.text.length > 0) {
        CGSize titleSize = [self.bottomInsideLeftLabel.text ws_sizeWithFont:self.bottomInsideLeftLabel.font constrainedToWidth:2000.0f];
        CGFloat x = (CGRectGetMinX(self.bottomInsideRightLabel.frame) - titleSize.width) - KLABELRIGHRSPACE;
        CGFloat y = bootmThirdY;
        CGFloat w = titleSize.width;
        CGFloat h = titleSize.height;
        self.bottomInsideLeftLabel.frame = CGRectMake(x, y, w, h);
    }
    self.bottomIntsidButton.frame = CGRectMake(CGRectGetMinX(self.bottomInsideLeftLabel.frame) - KBUTTONWIDTH - KLABELRIGHRSPACE, bootmThirdY, KBUTTONWIDTH, KBUTTONHEIGHT);
    
    CGFloat progressWidth = CGRectGetMinX(self.bottomOutsidButton.frame) - 2*KLABELRIGHRSPACE;
    
    if (progressWidth > self.height - 2 * KPROGRESSVIEWTOPSPACE) {
        progressWidth = self.height - 2 * KPROGRESSVIEWTOPSPACE;
    }
    CGFloat progressX = KLABELRIGHRSPACE;
    CGFloat ProgressY = 0.0;

    ProgressY = self.centerY - progressWidth * 0.5;
    self.bottomOutsideProgressView.frame = CGRectMake(progressX,  ProgressY, progressWidth, progressWidth);
    self.bottomMiddleProgressView.frame = CGRectMake(progressX + 10, ProgressY + 10, progressWidth - 20, progressWidth - 20);
    self.bottomInsideProgressView.frame = CGRectMake(progressX + 20,  ProgressY + 20, progressWidth - 40, progressWidth - 40);
}
#pragma mark - 测量图片尺寸方法(缩放计算) imageSize:图片尺寸 drawWidth:绘制宽度
- (CGSize)measureImageSizeWithImageSize:(CGSize)imageSize drawWidth:(CGFloat)drawWidth
{
    if (imageSize.width <= 0)
        return CGSizeZero;
    
    CGFloat imageHeight = (drawWidth * imageSize.height) / imageSize.width;
    return CGSizeMake(drawWidth, imageHeight);
}

@end

#pragma mark - 销售信息视图显示数据
@implementation WSCircleDetailInfoViewShowData

@end
