//
//  WSCircleInfoView.m
//  WinSFA
//
//  Created by mac on 2018/11/8.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSCircleInfoView.h"
#import "MarqueeLabel.h"
#import "WSChartConst.h"
#import "WSPrograssView.h"
#import "DACircularProgressView.h"
#import "ZZCircleProgress.h"

static const CGFloat kSalesInfoStartY = 10.0f;          //销售起始Y坐标
static const CGFloat kSalesInfoStandardSpace = 12.0f;   //销售信息标准间距
static const CGFloat kSalesInfoSmallSpace = 5.0f;       //销售信息小间距

static const CGFloat kSalesInfoIconSize = 25.0f;        //销售信息图标尺寸
static const CGFloat kSalesInfoElementHeight = 64.0f;   //销售信息元素高度

static const CGFloat kSalesInfoSuperBigFont = 28.0f;    //销售信息超大字体
static const CGFloat kSalesInfoBigFont = 18.0f;         //销售信息大字体
static const CGFloat kSalesInfoStandardFont = 14.0f;    //销售信息标准字体
static const CGFloat kSalesInfoSmallFont = 12.0f;       //销售信息小字体
static const CGFloat kSalesInfoSuperSmallFont = 10.0f;  //销售信息超小字体

#ifndef WSSalesInfoView_m
#define WSSalesInfoView_m

#define kSalesInfoTitleBlue [UIColor colorWithRed:48.0f / 255.0f green:127.0f / 255.0f blue:240.0f / 255.0f alpha:1.0f]
#define kSalesInfoTitleGray [UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f]
#define kSalesInfoTitleRed  [UIColor colorWithRed:245.0f / 255.0f green:78.0f / 255.0f blue:74.0f / 255.0f alpha:1.0f]

#define kSalesInfoTitleWhite  [UIColor colorWithRed:255.0f / 255.0f green:255.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f]
#define CircleButtonColor       ([UIColor colorForKey:@"CircleButton"] ?  : MAIN_TEXT_COLOR)
#define CircleButtonFont         ([UIFont fontForKey:@"CircleButton"] ?  : [UIFont systemFontOfSize:UI_Font])

//SalesMoneyLabel
#define SalesMoneyLabelColor       ([UIColor colorForKey:@"SalesMoneyLabel"] ?  : kSalesInfoTitleBlue)
#define SalesMoneyLabelFont         ([UIFont fontForKey:@"SalesMoneyLabel"])

#define CircleLabelColor       ([UIColor colorForKey:@"CircleLabel"] ?  : MAIN_TEXT_COLOR)
#define CircleLabelFont         ([UIFont fontForKey:@"CircleLabel"] ?  : [UIFont systemFontOfSize:UI_Font])

//iphone 6 圆的宽度 和 屏幕的宽度、边距
#define scale_Width 375
#define scale (SCREEN_WIDTH/scale_Width)
#define circleWidth 170
#define bottomPadding 50*scale

#define KPROGRESSVIEWBACKIMAGEHEIGHT 272
#define KPROGRESSVIEW_WIDTH 180
#define KTOPBACKIMAGESPACE 15
#define KNAMEWIDTH 200





// 中间视图宏
//#define KLABELTOPSPACE 22*scale
//#define KLABELRIGHRSPACE 10*scale
//#define KTOPABELSPACE 15
//#define KBUTTONWIDTH 93*scale
//#define KBUTTONHEIGHT 20*scale
//#define KBUTTONSPACE 10
//#define KBUTTONLEFTSPACE 129
//#define KBUTTONTOPSPACE 20
//#define KTOPCIRCLELINEWIDTH 8
//#define KLEFTSPACE 25
//#define BOTTOMOUTSIDEPROGRESSVIEW_WIDTH 80
//#define BOTTOMMIDDLEPROGRESSVIEW_WIDTH 60
//#define BOTTOMINSIDEPROGRESSVIEW_WIDTH 40
//#define KBOTTOMCIRCLELINEWIDTH 4
//#define CIRCLESPACE 10
//#define KLABELLEFTSPACE 223
//#define KLABELWIDTH 70

#endif

@interface WSCircleInfoView()

@property (nonatomic, copy, readwrite) NSString *noticeCount;   //通知数量

@property (nonatomic, strong) UIImageView *headImageView;       //头像图片视图
@property (nonatomic, strong) UIImageView *hornImageView;       //喇叭图片视图
@property (nonatomic, strong) MarqueeLabel *contentLabel;       //内容标签
@property (nonatomic, strong) UIButton *notifyButton;           //通知按键
@property (nonatomic, strong) UILabel *countLabel;              //计数标签

@property (nonatomic, strong) UILabel *salesTitleLabel;         //销售标题标签
@property (nonatomic, strong) UILabel *salesMoneyLabel;         //销售金额标签
@property (nonatomic, strong) UILabel *progressTitleLabel;      //进度标题标签
@property (nonatomic, strong) UILabel *progressCountLabel;      //进度计数标签

@property (nonatomic, strong) ZZCircleProgress *zzPrgressView;    //立白环形进度条

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

@property (nonatomic,strong) UILabel *nameTitle;

#pragma mark - 通知按键响应方法 sender:发射器
- (void)touchUpNotifyButtonEnevt:(id)sender;

@end

#pragma mark - 销售信息视图 延展(工具)
@interface WSCircleInfoView (Tools)

#pragma mark - 设置销售信息视图方法
- (void)setupCircleInfoView;

#pragma mark - 布局销售信息视图方法
- (void)layoutCircleInfoView;

#pragma mark - 布局顶部信息方法
- (void)layoutTopInfo;

#pragma mark - 布局核心信息方法
- (void)layoutCoreInfo;

#pragma mark - 测量图片尺寸方法(缩放计算) imageSize:图片尺寸 drawWidth:绘制宽度
- (CGSize)measureImageSizeWithImageSize:(CGSize)imageSize drawWidth:(CGFloat)drawWidth;

@end
@implementation WSCircleInfoView

#pragma mark - 重写initWithFrame:方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupCircleInfoView];
    }
    return self;
}


#pragma mark - 获取headImageView方法
- (UIImageView *)headImageView
{
    if(_headImageView == nil)
    {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _headImageView.backgroundColor = [UIColor clearColor];
        _headImageView.contentMode = UIViewContentModeScaleAspectFit;
        _headImageView.layer.masksToBounds = YES;
    }
    return _headImageView;
}

#pragma mark - 获取hornImageView方法
- (UIImageView *)hornImageView
{
    if(_hornImageView == nil)
    {
        _hornImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _hornImageView.backgroundColor = [UIColor clearColor];
        _hornImageView.contentMode = UIViewContentModeScaleAspectFit;
        _hornImageView.image = [UIImage scaledImageForName:@"salesInfoHorn" ofType:@"png"];
    }
    return _hornImageView;
}

#pragma mark - 获取contentLabel方法
- (MarqueeLabel *)contentLabel
{
    if(_contentLabel == nil)
    {
        // MN-3135  zhaodanyang
        _contentLabel = [[MarqueeLabel alloc] initWithFrame:CGRectZero duration:14.0 andFadeLength:0.0];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.font = [UIFont systemFontOfSize:kSalesInfoSmallFont];
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.marqueeType = MLContinuous;
        _contentLabel.fadeLength = 10.0f;
        _contentLabel.trailingBuffer = 30.0f;
        _contentLabel.animationDelay = 2.0f;
    }
    return _contentLabel;
}

#pragma mark - 获取notifyButton方法
- (UIButton *)notifyButton
{
    if(_notifyButton == nil)
    {
        _notifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _notifyButton.backgroundColor = [UIColor clearColor];
        [_notifyButton setImage:[UIImage scaledImageForName:@"salesInfoMessageTip" ofType:@"png"] forState:UIControlStateNormal];
        [_notifyButton setImage:[UIImage scaledImageForName:@"salesInfoMessageTip" ofType:@"png"] forState:UIControlStateSelected];
        [_notifyButton addTarget:self action:@selector(touchUpNotifyButtonEnevt:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _notifyButton;
}

- (UILabel *)nameTitle{
    if (_nameTitle == nil) {
        _nameTitle = [[UILabel alloc] init];
        _nameTitle.frame = CGRectMake((SCREEN_WIDTH - KNAMEWIDTH) * 0.5, kSalesInfoStartY, KNAMEWIDTH, 20);
        _nameTitle.font = [UIFont systemFontOfSize:15];
        [_nameTitle setTextColor:[UIColor whiteColor]];
        _nameTitle.textAlignment = NSTextAlignmentCenter;
        _nameTitle.text = [WSAppData getObjectbyKey:APPDATA_EMPNAME];
    }
    return _nameTitle;
}

#pragma mark - 获取countLabel方法
- (UILabel *)countLabel
{
    if (_countLabel == nil)
    {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.backgroundColor = [UIColor redColor];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.font = [UIFont boldSystemFontOfSize:kSalesInfoSuperSmallFont];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.layer.masksToBounds = YES;
    }
    
    return _countLabel;
}

#pragma mark - 获取salesTitleLabel方法
- (UILabel *)salesTitleLabel
{
    if (_salesTitleLabel == nil)
    {
        _salesTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _salesTitleLabel.backgroundColor = [UIColor clearColor];
        _salesTitleLabel.textAlignment = NSTextAlignmentCenter;
        _salesTitleLabel.font = [UIFont systemFontOfSize:kSalesInfoStandardFont];
        _salesTitleLabel.textColor = kSalesInfoTitleWhite;
    }
    
    return _salesTitleLabel;
}

- (ZZCircleProgress *)zzPrgressView{
    if (_zzPrgressView == nil) {
        
//        CGFloat circelW = scale*circleWidth;
//        CGFloat circelX = (SCREEN_WIDTH - circelW) * 0.5;
//        CGFloat circelY = CGRectGetMaxY(self.progressViewbackImageView.frame)- circelW - bottomPadding*scale;
        
        _zzPrgressView = [[ZZCircleProgress alloc] initWithFrame:CGRectZero pathBackColor:[UIColor whiteColor] pathFillColor:[UIColor colorWithRed:251.0/255.0 green:207.0/255.0 blue:108.0/255.0 alpha:1.0] startAngle:-90 strokeWidth:8 * scale];
        _zzPrgressView.showProgressText = NO;
    }
    return _zzPrgressView;
}
#pragma mark - 获取salesMoneyLabel方法
- (UILabel *)salesMoneyLabel
{
    if (_salesMoneyLabel == nil)
    {
        _salesMoneyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _salesMoneyLabel.backgroundColor = [UIColor clearColor];
        _salesMoneyLabel.textAlignment = NSTextAlignmentCenter;
        _salesMoneyLabel.font = [UIFont boldSystemFontOfSize:kSalesInfoSuperBigFont];
        _salesMoneyLabel.textColor = kSalesInfoTitleWhite;
    }
    
    return _salesMoneyLabel;
}

#pragma mark - 获取progressTitleLabel方法
- (UILabel *)progressTitleLabel
{
    if (_progressTitleLabel == nil)
    {
        _progressTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _progressTitleLabel.backgroundColor = [UIColor clearColor];
        _progressTitleLabel.textAlignment = NSTextAlignmentCenter;
        _progressTitleLabel.font = SalesMoneyLabelFont ? : [UIFont systemFontOfSize:kSalesInfoStandardFont];
        _progressTitleLabel.textColor = kSalesInfoTitleWhite;
    }
    
    return _progressTitleLabel;
}

#pragma mark - 获取progressCountLabel方法
- (UILabel *)progressCountLabel
{
    if (_progressCountLabel == nil)
    {
        _progressCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _progressCountLabel.backgroundColor = [UIColor clearColor];
        _progressCountLabel.textAlignment = NSTextAlignmentCenter;
        _progressCountLabel.font = SalesMoneyLabelFont;
        _progressCountLabel.textColor = kSalesInfoTitleWhite;
    }
    
    return _progressCountLabel;
}


- (UIImageView *)progressViewbackImageView{
    if (_progressViewbackImageView == nil) {
        _progressViewbackImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _progressViewbackImageView.image = [UIImage imageNamed:@"bg_circel_index_top"];
    }
    return _progressViewbackImageView;
}
//- (DACircularProgressView *)bottomOutsideProgressView{
//    if (_bottomOutsideProgressView == nil) {
//        _bottomOutsideProgressView = [[DACircularProgressView alloc] initWithFrame:CGRectZero];
//        _bottomOutsideProgressView.roundedCorners = YES;
//
//        //背景环颜色
//        _bottomOutsideProgressView.trackTintColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:252.0/255.0 alpha:1.0];
//        // 填充色
//        _bottomOutsideProgressView.progressTintColor = [UIColor colorWithRed:131.0/255.0 green:148.0/255.0 blue:251.0/255.0 alpha:1.0];
//
//    }
//    return _bottomOutsideProgressView;
//}
//
//- (DACircularProgressView *)bottomMiddleProgressView{
//    if (_bottomMiddleProgressView == nil) {
//        _bottomMiddleProgressView = [[DACircularProgressView alloc] initWithFrame:CGRectZero];
//        _bottomMiddleProgressView.roundedCorners = YES;
////        _bottomMiddleProgressView.lineWidth = 4;
//        //        _bottomMiddleProgressView.thicknessRatio = 0.1;
//        //背景环颜色
//        [_bottomMiddleProgressView setTrackTintColor:[UIColor colorWithRed:247.0/255.0 green:241.0/255.0 blue:251.0/255.0 alpha:1.0]];
//        // 填充色
//        self.bottomMiddleProgressView.progressTintColor = [UIColor colorWithRed:188.0/255.0 green:141.0/255.0 blue:238.0/255.0 alpha:1.0];
//    }
//    return _bottomMiddleProgressView;
//}
//
//- (DACircularProgressView *)bottomInsideProgressView{
//    if (_bottomInsideProgressView == nil) {
//        _bottomInsideProgressView = [[DACircularProgressView alloc] initWithFrame:CGRectZero];
//        _bottomInsideProgressView.roundedCorners = YES;
//
//        //背景环颜色
//        [self.bottomInsideProgressView setTrackTintColor:[UIColor colorWithRed:254.0/255.0 green:243.0/255.0 blue:242.0/255.0 alpha:1.0] ];
//        // 填充色
//        self.bottomInsideProgressView.progressTintColor = [UIColor colorWithRed:255.0/255.0 green:168.0/255.0 blue:151.0/255.0 alpha:1.0];
//    }
//    return _bottomInsideProgressView;
//}
//
//- (UIButton *)bottomOutsidButton{
//    if (_bottomOutsidButton == nil) {
//        _bottomOutsidButton = [[UIButton alloc] initWithFrame:CGRectMake(KBUTTONLEFTSPACE, self.progressViewbackImageView.height + KBUTTONTOPSPACE,  KBUTTONWIDTH, KBUTTONHEIGHT)];
//        [_bottomOutsidButton setImage:[UIImage imageNamed:@"jinggengmendian"] forState:UIControlStateNormal];
//        [_bottomOutsidButton setTitle:@"精耕门店" forState:UIControlStateNormal];
//        [_bottomOutsidButton setTitleColor:CircleButtonColor forState:UIControlStateNormal];
//        _bottomOutsidButton.imageEdgeInsets = UIEdgeInsetsMake(5 ,0 , 5, 10);  _bottomOutsidButton.titleLabel.font = CircleButtonFont;
//        _bottomOutsidButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;// 水平左对齐
//        _bottomOutsidButton.contentVerticalAlignment = UIControlContentHorizontalAlignmentLeft;// 垂直居中对齐
//    }
//    return _bottomOutsidButton;
//}
//
//- (UIButton *)bottomMiddleButton{
//    if (_bottomMiddleButton == nil) {
//        _bottomMiddleButton = [[UIButton alloc] initWithFrame:CGRectMake(KBUTTONLEFTSPACE, CGRectGetMaxY(self.bottomOutsidButton.frame) + KBUTTONSPACE,  KBUTTONWIDTH, KBUTTONHEIGHT)];
//        [_bottomMiddleButton setImage:[UIImage imageNamed:@"yudazao"] forState:UIControlStateNormal];
//        [_bottomMiddleButton setTitle:@"预打造门店" forState:UIControlStateNormal];
//        [_bottomMiddleButton  setTitleColor:CircleButtonColor forState:UIControlStateNormal];
//        _bottomMiddleButton.titleLabel.font = CircleButtonFont;
//        _bottomMiddleButton.imageEdgeInsets = UIEdgeInsetsMake(5 ,0 , 5, 10);
//
//        _bottomMiddleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;// 水平左对齐
//        _bottomMiddleButton.contentVerticalAlignment = UIControlContentHorizontalAlignmentLeft;// 垂直居中对齐
//    }
//    return _bottomMiddleButton;
//}
//
//- (UIButton *)bottomIntsidButton{
//    if (_bottomIntsidButton == nil) {
//        _bottomIntsidButton = [[UIButton alloc] initWithFrame:CGRectMake(KBUTTONLEFTSPACE, CGRectGetMaxY(self.bottomMiddleButton.frame) + KBUTTONSPACE  ,  KBUTTONWIDTH, KBUTTONHEIGHT)];
//        [_bottomIntsidButton setImage:[UIImage imageNamed:@"saomangmendian"] forState:UIControlStateNormal];
//        [_bottomIntsidButton setTitle:@"扫盲门店" forState:UIControlStateNormal];
//        [_bottomIntsidButton setTitleColor:CircleButtonColor forState:UIControlStateNormal];
//        _bottomIntsidButton.titleLabel.font = CircleButtonFont;
//        _bottomIntsidButton.imageEdgeInsets = UIEdgeInsetsMake(5 ,0 , 5, 10);
//
//        _bottomIntsidButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;// 水平左对齐
//        _bottomIntsidButton.contentVerticalAlignment = UIControlContentHorizontalAlignmentLeft;// 垂直居中对齐
//    }
//    return _bottomIntsidButton;
//}
//
//- (UILabel *)bottomOutsideLeftLabel{
//    if (_bottomOutsideLeftLabel == nil) {
//        _bottomOutsideLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(KLABELLEFTSPACE, self.bottomOutsidButton.frame.origin.y, KLABELWIDTH, KBUTTONHEIGHT)];
//        _bottomOutsideLeftLabel.font = CircleLabelFont;
//        [_bottomOutsideLeftLabel setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
//
//    }
//    return _bottomOutsideLeftLabel;
//}
//
//- (UILabel *)bottomOutsideRightLabel{
//    if (_bottomOutsideRightLabel == nil) {
//        _bottomOutsideRightLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bottomOutsideLeftLabel.frame) + 3, self.bottomOutsidButton.frame.origin.y, KLABELWIDTH, KBUTTONHEIGHT)];
//        _bottomOutsideRightLabel.font = CircleLabelFont;
//        [_bottomOutsideRightLabel setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
//    }
//    return _bottomOutsideRightLabel;
//}
//
//- (UILabel *)bottomMiddleLeftLabel{
//    if (_bottomMiddleLeftLabel == nil) {
//        _bottomMiddleLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(KLABELLEFTSPACE, self.bottomMiddleButton.frame.origin.y, KLABELWIDTH, KBUTTONHEIGHT)];
//        _bottomMiddleLeftLabel.font = CircleLabelFont;
//        [_bottomMiddleLeftLabel setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
//    }
//    return _bottomMiddleLeftLabel;
//}
//- (UILabel *) bottomMiddleRightLabel{
//    if (_bottomMiddleRightLabel == nil) {
//        _bottomMiddleRightLabel =  [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bottomMiddleLeftLabel.frame) + 5, self.bottomMiddleLeftLabel.frame.origin.y, KLABELWIDTH, KBUTTONHEIGHT)];
//        _bottomMiddleRightLabel.font = CircleLabelFont;
//        [_bottomMiddleRightLabel setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
//    }
//    return _bottomMiddleRightLabel;
//}
//
//- (UILabel *)bottomInsideLeftLabel{
//    if (_bottomInsideLeftLabel == nil) {
//        _bottomInsideLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(KLABELLEFTSPACE, self.bottomIntsidButton.frame.origin.y, KLABELWIDTH, KBUTTONHEIGHT)];
//        _bottomInsideLeftLabel.font = CircleLabelFont;
//        //        _bottomInsideLabel.textColor = CircleLabelColor;
//        [_bottomInsideLeftLabel setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
//
//    }
//    return _bottomInsideLeftLabel;
//}
//
//- (UILabel *) bottomInsideRightLabel{
//    if (_bottomInsideRightLabel == nil) {
//        _bottomInsideRightLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bottomInsideLeftLabel.frame) + 3, self.bottomInsideLeftLabel.frame.origin.y, KLABELWIDTH, KBUTTONHEIGHT)];
//        _bottomInsideRightLabel.font = CircleLabelFont;
//        [_bottomInsideRightLabel setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
//    }
//    return _bottomInsideRightLabel;
//}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutCircleInfoView];
}

#pragma mark - 计算销售信息视图高度方法 width:宽度
- (CGFloat)calculationCircleInfoViewHeightWithWidth:(CGFloat)width
{
    if(width <= 0.0f)
        return width;
    
    CGFloat maxHeight = 0.0f;
    
    UIImage *image = [UIImage scaledImageForName:@"bg_circel_index_top" ofType:@"png"];
    CGSize size = [self measureImageSizeWithImageSize:image.size drawWidth:width];
    maxHeight += size.height;
    
    return maxHeight;
}

#pragma mark - 更新销售信息视图方法 showData:显示数据
- (void)updateCircleInfoViewWithShowData:(WSCircleInfoViewShowData *)showData
{
    self.noticeCount = (showData.noticeCount.length > 0) ? showData.noticeCount : @"";
    
    self.contentLabel.text = (showData.slogan.length > 0) ? showData.slogan : @"";
    self.countLabel.text = (showData.noticeCount.length > 0) ? showData.noticeCount : @"";
    
    self.salesTitleLabel.text = (showData.tilte1.length > 0) ? showData.tilte1 : @"";
    self.salesMoneyLabel.text = (showData.content1.length > 0) ? showData.content1 : @"";
    self.progressTitleLabel.text = (showData.tilte2.length > 0 && showData.content2.length > 0) ? [NSString stringWithFormat:@"%@%@%%",showData.tilte2,showData.content2]: @"";
    self.zzPrgressView.progress = [((showData.content2.length > 0) ? showData.content2 : @"0") floatValue]/100;
        
//    CGFloat outSideProgress = (showData.tilte4.length > 0) ? [showData.tilte4 floatValue] /100.0 : 0.0;
//    [self.bottomOutsideProgressView setProgress:outSideProgress animated:YES initialDelay:2.0];
//
//    CGFloat middleSideProgress = (showData.content5.length > 0) ? [showData.content5 floatValue] /100.0 : 0.0;
//    [self.bottomMiddleProgressView setProgress:middleSideProgress animated:YES initialDelay:2.0];
//
//    CGFloat inSideProgress = (showData.tilte7.length > 0) ? [showData.tilte7 floatValue] /100.0 : 0.0;
//    [self.bottomInsideProgressView setProgress:inSideProgress animated:YES initialDelay:2.0];
//
//    NSString *outsideGoalStr = (showData.content3.length > 0) ? [NSString stringWithFormat:@"%@",showData.content3] :@"0";
//    NSString *outsideRateStr = (showData.tilte4.length > 0) ? [NSString stringWithFormat:@"%@%%",showData.tilte4]: @"0";
//    self.bottomOutsideLeftLabel.attributedText = [self changeTextColorWithString:[NSString stringWithFormat:@"目标%@家",outsideGoalStr] isLeftLabel:YES];
//    self.bottomOutsideRightLabel.attributedText = [self changeTextColorWithString:[NSString stringWithFormat:@"完成%@家",outsideRateStr] isLeftLabel:NO] ;
//
//    NSString *middleGoalStr = (showData.tilte5.length > 0) ? [NSString stringWithFormat:@"%@",showData.tilte5] :@"0";
//    NSString *middleRateStr = (showData.content5.length > 0) ? [NSString stringWithFormat:@"%@%%",showData.content5]: @"0";
//    self.bottomMiddleLeftLabel.attributedText = [self changeTextColorWithString:[NSString stringWithFormat:@"目标%@家",middleGoalStr] isLeftLabel:YES];
//    self.bottomMiddleRightLabel.attributedText = [self changeTextColorWithString:[NSString stringWithFormat:@"完成%@家",middleRateStr] isLeftLabel:NO];
//
//    NSString *insideGoalStr = (showData.content5.length > 0) ? [NSString stringWithFormat:@"%@",showData.content6]  :@"0";
//    NSString *insideRateStr = (showData.tilte7.length > 0) ?  [NSString stringWithFormat:@"%@%%",showData.tilte7]: @"0";
//
//    self.bottomInsideLeftLabel.attributedText = [self changeTextColorWithString:[NSString stringWithFormat:@"目标%@家",insideGoalStr] isLeftLabel:YES];
//    self.bottomInsideRightLabel.attributedText = [self changeTextColorWithString:[NSString stringWithFormat:@"完成%@家",insideRateStr] isLeftLabel:NO];
    
    [self setNeedsLayout];
}

#pragma mark - 更新通知数量方法 countData:数量数据
- (void)updateNoticeCountWithCountData:(NSString *)countData
{
    self.noticeCount = (countData.length > 0) ? countData : @"";
    self.countLabel.text = (countData.length > 0) ? countData : @"";
    
    [self setNeedsLayout];
}

#pragma mark - 通知按键响应方法 sender:发射器
- (void)touchUpNotifyButtonEnevt:(id)sender
{
    if (self.notifyClickBlock)
        self.notifyClickBlock();
}

//-(NSMutableAttributedString *) changeTextColorWithString :(NSString *)str isLeftLabel :(BOOL) isLeft
//{
//
//    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:str];
//
//    NSRange range1 = NSMakeRange(0, 0);
//    NSRange range2 = NSMakeRange(0, 0);
//    if (isLeft) {
//        if ([str rangeOfString:@"标"].location != NSNotFound) {
//            range1 = [str rangeOfString:@"标"];
//        }
//        range2 = NSMakeRange(range1.location+1, str.length-3);
//    }
//    else{
//        if ([str rangeOfString:@"成"].location != NSNotFound) {
//            range1 = [str rangeOfString:@"成"];
//        }
//        range2 = NSMakeRange(range1.location + 1, str.length -3);
//    }
//
//    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:24.0/255.0 green:128.0/255.0 blue:249.0/255.0 alpha:1.0] range:range2];
//
//    return attributeStr;
//}

@end
//===================================================================================================================================================================

#pragma mark - 销售信息视图 延展(工具)
@implementation WSCircleInfoView (Tools)

#pragma mark - 设置销售信息视图方法
- (void)setupCircleInfoView
{
//    [self addSubview:self.salesTitleLabel];
//    [self addSubview:self.salesMoneyLabel];
//    [self addSubview:self.progressTitleLabel];
//    [self addSubview:self.notifyButton];
    [self addSubview:self.progressViewbackImageView];
    [self.progressViewbackImageView addSubview:self.zzPrgressView];
        
//    [self addSubview:self.bottomOutsideProgressView];
//    [self addSubview:self.bottomMiddleProgressView];
//    [self addSubview:self.bottomInsideProgressView];
//
//    [self addSubview:self.bottomOutsidButton];
//    [self addSubview:self.bottomMiddleButton];
//    [self addSubview:self.bottomIntsidButton];
//
//    [self addSubview:self.bottomOutsideLeftLabel];
//    [self addSubview:self.bottomOutsideRightLabel];
//    [self addSubview:self.bottomMiddleLeftLabel];
//    [self addSubview:self.bottomMiddleRightLabel];
//    [self addSubview:self.bottomInsideLeftLabel];
//    [self addSubview:self.bottomInsideRightLabel];
    
    [self addSubview:self.contentLabel];
    [self addSubview:self.salesTitleLabel];
    [self addSubview:self.salesMoneyLabel];
    [self addSubview:self.progressTitleLabel];
    [self addSubview:self.notifyButton];
    [self addSubview:self.nameTitle];
    
    
}

#pragma mark - 布局销售信息视图方法
- (void)layoutCircleInfoView
{
    UIImage *image = [UIImage scaledImageForName:@"bg_circel_index_top" ofType:@"png"];
    CGSize size = [self measureImageSizeWithImageSize:image.size drawWidth:CGRectGetWidth(self.frame)];
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat w = size.width;
    CGFloat h = size.height;
    self.progressViewbackImageView.frame = CGRectMake(x, y, w, h);

    
    CGFloat circelW = scale*circleWidth;
    CGFloat circelX = self.bounds.size.width * 0.5 - 0.5 * circelW;
    CGFloat circelY = CGRectGetMaxY(self.progressViewbackImageView.frame) - circelW - bottomPadding;
    self.zzPrgressView.frame = CGRectMake(circelX,circelY,circelW,circelW);
    
    [self layoutTopInfo];
    
    [self layoutCoreInfo];
    
//    [self layoutMiddleInfo];
    
}

#pragma mark - 布局顶部信息方法
- (void)layoutTopInfo
{
    CGFloat x = CGRectGetWidth(self.frame) - kSalesInfoIconSize - kSalesInfoStandardSpace;
    CGFloat y = kSalesInfoStartY;
    CGFloat w = kSalesInfoIconSize;
    CGFloat h = kSalesInfoIconSize;
    self.notifyButton.frame = CGRectMake(x, y, w, h);
    self.notifyButton.layer.cornerRadius = kSalesInfoIconSize / 2;
    if(self.contentLabel.text.length > 0)
    {
        x = kSalesInfoStandardSpace;
        y = kSalesInfoStartY;
        w = kSalesInfoIconSize;
        h = kSalesInfoIconSize;
        self.headImageView.frame = CGRectMake(x, y, w, h);
        self.headImageView.layer.cornerRadius = kSalesInfoIconSize / 2;
        self.headImageView.hidden = NO;
        
        UIImage *image = [UIImage scaledImageForName:@"icon_loudspeaker" ofType:@"png"];
        x = CGRectGetMaxX(self.headImageView.frame);
        y = kSalesInfoStartY;
        w = image.size.width;
        h = image.size.height;
        self.hornImageView.frame = CGRectMake(x, y, w, h);
        self.hornImageView.hidden = NO;
        
        x = CGRectGetMaxX(self.hornImageView.frame);
        h = kSalesInfoStartY;
        w = CGRectGetMinX(self.notifyButton.frame) - kSalesInfoStandardSpace - x;
        h = kSalesInfoIconSize;
        self.contentLabel.frame = CGRectMake(x, y, w, h);
        self.contentLabel.hidden = NO;
    }
    else
    {
        self.headImageView.frame = CGRectZero;
        self.headImageView.hidden = YES;
        
        self.hornImageView.frame = CGRectZero;
        self.hornImageView.hidden = YES;
        
        self.contentLabel.frame = CGRectZero;
        self.contentLabel.hidden = YES;
    }
    
    if(self.countLabel.text.length > 0)
    {
        self.countLabel.hidden = NO;
        CGSize titleSize = [self.countLabel.text ws_sizeWithFont:self.countLabel.font constrainedToWidth:2000.0f];
        CGFloat maxSize = (titleSize.width > titleSize.height) ? titleSize.width : titleSize.height;
        titleSize = CGSizeMake(maxSize, maxSize);
        x = CGRectGetMaxX(self.notifyButton.frame) - (titleSize.width / 2);
        y = CGRectGetMinY(self.notifyButton.frame) - (titleSize.height / 2);
        w = titleSize.width;
        h = titleSize.height;
        self.countLabel.frame = CGRectMake(x, y, w, h);
        self.countLabel.layer.cornerRadius = w / 2;
        self.countLabel.hidden = NO;
    }
    else
    {
        self.countLabel.hidden = YES;
        self.countLabel.frame = CGRectZero;
    }
}

#pragma mark - 布局核心信息方法
- (void)layoutCoreInfo
{
    CGFloat bootmY = CGRectGetMaxY(self.progressViewbackImageView.frame) - bottomPadding - 30;
    if(self.progressCountLabel.text.length > 0)
    {
        CGSize titleSize = [self.progressCountLabel.text ws_sizeWithFont:self.progressCountLabel.font constrainedToWidth:2000.0f];
        CGFloat x = (CGRectGetWidth(self.frame) - titleSize.width) / 2;
        CGFloat y = bootmY - titleSize.height;
        CGFloat w = titleSize.width;
        CGFloat h = titleSize.height;
        self.progressCountLabel.frame = CGRectMake(x, y, w, h);
        self.progressCountLabel.hidden = NO;
    }
    else
    {
        self.progressCountLabel.frame = CGRectZero;
        self.progressCountLabel.hidden = YES;
    }
    
    bootmY -= CGRectGetHeight(self.progressCountLabel.frame);
    if(self.progressTitleLabel.text.length > 0)
    {
        CGSize titleSize = [self.progressTitleLabel.text ws_sizeWithFont:self.progressTitleLabel.font constrainedToWidth:2000.0f];
        CGFloat x = (CGRectGetWidth(self.frame) - titleSize.width) / 2;
        CGFloat y = bootmY - kSalesInfoSmallSpace - titleSize.height;
        CGFloat w = titleSize.width;
        CGFloat h = titleSize.height;
        self.progressTitleLabel.frame = CGRectMake(x, y, w, h);
        self.progressTitleLabel.hidden = NO;
    }
    else
    {
        self.progressTitleLabel.frame = CGRectZero;
        self.progressTitleLabel.hidden = YES;
    }
    
    bootmY -= CGRectGetHeight(self.progressTitleLabel.frame);
    if(self.salesMoneyLabel.attributedText.length > 0)
    {
        [self.salesMoneyLabel sizeToFit];
        CGFloat x = (CGRectGetWidth(self.frame) - CGRectGetWidth(self.salesMoneyLabel.frame)) / 2;
        CGFloat y = bootmY - kSalesInfoStandardSpace - CGRectGetHeight(self.salesMoneyLabel.frame);
        CGFloat w = CGRectGetWidth(self.salesMoneyLabel.frame);
        CGFloat h = CGRectGetHeight(self.salesMoneyLabel.frame);
        self.salesMoneyLabel.frame = CGRectMake(x, y, w, h);
        self.salesMoneyLabel.hidden = NO;
    }
    else
    {
        self.salesMoneyLabel.frame = CGRectZero;
        self.salesMoneyLabel.hidden = YES;
    }
    
    bootmY -= CGRectGetHeight(self.salesMoneyLabel.frame);
    if(self.salesTitleLabel.text.length > 0)
    {
        CGSize titleSize = [self.salesTitleLabel.text ws_sizeWithFont:self.salesTitleLabel.font constrainedToWidth:2000.0f];
        CGFloat x = (CGRectGetWidth(self.frame) - titleSize.width) / 2;
        CGFloat y = bootmY - kSalesInfoStandardSpace - titleSize.height;
        CGFloat w = titleSize.width;
        CGFloat h = titleSize.height;
        self.salesTitleLabel.frame = CGRectMake(x, y, w, h);
        self.salesTitleLabel.hidden = NO;
    }
    else
    {
        self.salesTitleLabel.frame = CGRectZero;
        self.salesTitleLabel.hidden = YES;
    }
}

//- (void) layoutMiddleInfo{
//    
//    CGFloat bootmY = CGRectGetMaxY(self.progressViewbackImageView.frame) + KLABELTOPSPACE;
//
//    
//    if (self.bottomOutsideRightLabel.text.length > 0){
//        
//        CGSize titleSize = [self.bottomOutsideRightLabel.text ws_sizeWithFont:self.bottomOutsideRightLabel.font constrainedToWidth:2000.0f];
//        CGFloat x = (CGRectGetWidth(self.frame) - titleSize.width) - KLABELRIGHRSPACE;
//        CGFloat y = bootmY;
//        CGFloat w = titleSize.width;
//        CGFloat h = titleSize.height;
//        self.bottomOutsideRightLabel.frame = CGRectMake(x, y, w, h);
//    }
//    if (self.bottomOutsideLeftLabel.text.length > 0) {
//        CGSize titleSize = [self.bottomOutsideLeftLabel.text ws_sizeWithFont:self.bottomOutsideLeftLabel.font constrainedToWidth:2000.0f];
//        CGFloat x = (CGRectGetMinX(self.bottomOutsideRightLabel.frame) - titleSize.width) - KLABELRIGHRSPACE;
//        CGFloat y = bootmY;
//        CGFloat w = titleSize.width;
//        CGFloat h = titleSize.height;
//        self.bottomOutsideLeftLabel.frame = CGRectMake(x, y, w, h);
//    }
//    self.bottomOutsidButton.frame = CGRectMake(CGRectGetMinX(self.bottomOutsideLeftLabel.frame) - KBUTTONWIDTH - KLABELRIGHRSPACE, bootmY, KBUTTONWIDTH, KBUTTONHEIGHT);
//    
//    CGFloat bootmSecondY = CGRectGetMaxY(self.bottomOutsideRightLabel.frame) + KTOPABELSPACE;
//    
//    if (self.bottomMiddleRightLabel.text.length > 0){
//        
//        CGSize titleSize = [self.bottomMiddleRightLabel.text ws_sizeWithFont:self.bottomMiddleRightLabel.font constrainedToWidth:2000.0f];
//        CGFloat x = (CGRectGetWidth(self.frame) - titleSize.width) - KLABELRIGHRSPACE;
//        CGFloat y = bootmSecondY;
//        CGFloat w = titleSize.width;
//        CGFloat h = titleSize.height;
//        self.bottomMiddleRightLabel.frame = CGRectMake(x, y, w, h);
//    }
//    if (self.bottomMiddleLeftLabel.text.length > 0) {
//        CGSize titleSize = [self.bottomMiddleLeftLabel.text ws_sizeWithFont:self.bottomMiddleLeftLabel.font constrainedToWidth:2000.0f];
//        CGFloat x = (CGRectGetMinX(self.bottomMiddleRightLabel.frame) - titleSize.width) - KLABELRIGHRSPACE;
//        CGFloat y = bootmSecondY;
//        CGFloat w = titleSize.width;
//        CGFloat h = titleSize.height;
//        self.bottomMiddleLeftLabel.frame = CGRectMake(x, y, w, h);
//    }
//    self.bottomMiddleButton.frame = CGRectMake(CGRectGetMinX(self.bottomMiddleLeftLabel.frame) - KBUTTONWIDTH - KLABELRIGHRSPACE, bootmSecondY, KBUTTONWIDTH, KBUTTONHEIGHT);
//    
//    CGFloat bootmThirdY = CGRectGetMaxY(self.bottomMiddleRightLabel.frame) + KTOPABELSPACE;
//    if (self.bottomInsideRightLabel.text.length > 0){
//        
//        CGSize titleSize = [self.bottomInsideRightLabel.text ws_sizeWithFont:self.bottomInsideRightLabel.font constrainedToWidth:2000.0f];
//        CGFloat x = (CGRectGetWidth(self.frame) - titleSize.width) - KLABELRIGHRSPACE;
//        CGFloat y = bootmThirdY;
//        CGFloat w = titleSize.width;
//        CGFloat h = titleSize.height;
//        self.bottomInsideRightLabel.frame = CGRectMake(x, y, w, h);
//    }
//    if (self.bottomInsideLeftLabel.text.length > 0) {
//        CGSize titleSize = [self.bottomInsideLeftLabel.text ws_sizeWithFont:self.bottomInsideLeftLabel.font constrainedToWidth:2000.0f];
//        CGFloat x = (CGRectGetMinX(self.bottomInsideRightLabel.frame) - titleSize.width) - KLABELRIGHRSPACE;
//        CGFloat y = bootmThirdY;
//        CGFloat w = titleSize.width;
//        CGFloat h = titleSize.height;
//        self.bottomInsideLeftLabel.frame = CGRectMake(x, y, w, h);
//    }
//    self.bottomIntsidButton.frame = CGRectMake(CGRectGetMinX(self.bottomInsideLeftLabel.frame) - KBUTTONWIDTH - KLABELRIGHRSPACE, bootmThirdY, KBUTTONWIDTH, KBUTTONHEIGHT);
//    
//    CGFloat progressWidth = CGRectGetMinX(self.bottomOutsidButton.frame) - 2*KLABELRIGHRSPACE;
//    
//    if (progressWidth > self.height - bootmY) {
//        progressWidth = self.height - bootmY - KLABELRIGHRSPACE;
//    }
//    CGFloat progressX = KLABELRIGHRSPACE;
//
//    self.bottomOutsideProgressView.frame = CGRectMake(progressX,  bootmY, progressWidth, progressWidth);
//    self.bottomMiddleProgressView.frame = CGRectMake(progressX + 10, bootmY + 10, progressWidth - 20, progressWidth - 20);
//    self.bottomInsideProgressView.frame = CGRectMake(progressX + 20,  bootmY + 20, progressWidth - 40, progressWidth - 40);
//}
#pragma mark - 测量图片尺寸方法(缩放计算) imageSize:图片尺寸 drawWidth:绘制宽度
- (CGSize)measureImageSizeWithImageSize:(CGSize)imageSize drawWidth:(CGFloat)drawWidth
{
    if (imageSize.width <= 0)
        return CGSizeZero;
    
    CGFloat imageHeight = (drawWidth * imageSize.height) / imageSize.width;
    return CGSizeMake(drawWidth, imageHeight);
}

@end
//===================================================================================================================================================================

#pragma mark - 销售信息视图显示数据
@implementation WSCircleInfoViewShowData

@end

