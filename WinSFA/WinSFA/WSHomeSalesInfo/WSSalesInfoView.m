//
//  WSSalesInfoView.m
//  WinSFA
//
//  Created by yuanji on 2018/4/12.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSSalesInfoView.h"
#import "MarqueeLabel.h"
#import "WSChartConst.h"
#import "WSPrograssView.h"

static const CGFloat kSalesInfoStartY = 20.0f;          //销售起始Y坐标
static const CGFloat kSalesInfoStandardSpace = 12.0f;   //销售信息标准间距
static const CGFloat kSalesInfoSmallSpace = 5.0f;       //销售信息小间距

static const CGFloat kSalesInfoIconSize = 25.0f;        //销售信息图标尺寸
static const CGFloat kSalesInfoElementHeight = 64.0f;   //销售信息元素高度
static const CGFloat kSalesInfoLineWidth = 1.0f;        //销售信息线宽度

static const CGFloat kSalesInfoSuperBigFont = 28.0f;    //销售信息超大字体
static const CGFloat kSalesInfoBigFont = 18.0f;         //销售信息大字体
static const CGFloat kSalesInfoStandardFont = 15.0f;    //销售信息标准字体
static const CGFloat kSalesInfoSmallFont = 12.0f;       //销售信息小字体
static const CGFloat kSalesInfoSuperSmallFont = 10.0f;  //销售信息超小字体

#ifndef WSSalesInfoView_m
#define WSSalesInfoView_m

#define kSalesInfoTitleBlue [UIColor colorWithRed:48.0f / 255.0f green:127.0f / 255.0f blue:240.0f / 255.0f alpha:1.0f]
#define kSalesInfoTitleGray [UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f]
#define kSalesInfoTitleRed  [UIColor colorWithRed:245.0f / 255.0f green:78.0f / 255.0f blue:74.0f / 255.0f alpha:1.0f]
//iphone 6 圆的宽度 和 屏幕的宽度、边距
#define scale_Width 375
#define scale (SCREEN_WIDTH/scale_Width)
#define circleWidth 168
#define bottomPadding 30
#endif
//===================================================================================================================================================================

#pragma mark - 销售信息视图 延展(内部)
@interface WSSalesInfoView ()

@property (nonatomic, copy, readwrite) NSString *noticeCount;   //通知数量

@property (nonatomic, strong) UIImageView *topBgUpImageView;    //顶部背景图片视图
@property (nonatomic, strong) UIImageView *topBgDownImageView;  //底部背景图片视图

@property (nonatomic, strong) UIImageView *headImageView;       //头像图片视图
@property (nonatomic, strong) UIImageView *hornImageView;       //喇叭图片视图
@property (nonatomic, strong) MarqueeLabel *contentLabel;       //内容标签
@property (nonatomic, strong) UIButton *notifyButton;           //通知按键
@property (nonatomic, strong) UILabel *countLabel;              //计数标签

@property (nonatomic, strong) UILabel *salesTitleLabel;         //销售标题标签
@property (nonatomic, strong) UILabel *salesMoneyLabel;         //销售金额标签
@property (nonatomic, strong) UILabel *progressTitleLabel;      //进度标题标签
@property (nonatomic, strong) UILabel *progressCountLabel;      //进度计数标签

@property (nonatomic, strong) UILabel *tilteLabel1;             //标题标签1
@property (nonatomic, strong) UILabel *contentLabel1;           //内容标签1
@property (nonatomic, strong) UIView *lineView1;                //线1
@property (nonatomic, strong) UILabel *tilteLabel2;             //标题标签2
@property (nonatomic, strong) UILabel *contentLabel2;           //内容标签2
@property (nonatomic, strong) UILabel *tilteLabel3;             //标题标签3
@property (nonatomic, strong) UILabel *contentLabel3;           //内容标签3
@property (nonatomic, strong) UIView *lineView2;                //线2
@property (nonatomic, strong) UILabel *tilteLabel4;             //标题标签4
@property (nonatomic, strong) UILabel *contentLabel4;           //内容标签4
@property (nonatomic, strong) WSPrograssView *prograssView;     // 环形进度条

#pragma mark - 通知按键响应方法 sender:发射器
- (void)touchUpNotifyButtonEnevt:(id)sender;

@end
//===================================================================================================================================================================

#pragma mark - 销售信息视图 延展(工具)
@interface WSSalesInfoView (Tools)

#pragma mark - 设置销售信息视图方法
- (void)setupSalesInfoView;

#pragma mark - 布局销售信息视图方法
- (void)layoutSalesInfoView;

#pragma mark - 布局顶部信息方法
- (void)layoutTopInfo;

#pragma mark - 布局核心信息方法
- (void)layoutCoreInfo;

#pragma mark - 布局底部信息方法
- (void)layoutBottomInfo;

#pragma mark - 测量图片尺寸方法(缩放计算) imageSize:图片尺寸 drawWidth:绘制宽度
- (CGSize)measureImageSizeWithImageSize:(CGSize)imageSize drawWidth:(CGFloat)drawWidth;

@end
//===================================================================================================================================================================

#pragma mark - 销售信息视图
@implementation WSSalesInfoView

#pragma mark - 获取topBgUpImageView方法
- (UIImageView *)topBgUpImageView
{
    if(_topBgUpImageView == nil)
    {
        _topBgUpImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _topBgUpImageView.backgroundColor = [UIColor clearColor];
        _topBgUpImageView.contentMode = UIViewContentModeScaleAspectFit;
        _topBgUpImageView.image = [UIImage scaledImageForName:@"salesInfoBgUp" ofType:@"png"];
    }
    return _topBgUpImageView;
}

#pragma mark - 获取topBgDownImageView方法
- (UIImageView *)topBgDownImageView
{
    if(_topBgDownImageView == nil)
    {
        _topBgDownImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _topBgDownImageView.backgroundColor = [UIColor clearColor];
        _topBgDownImageView.contentMode = UIViewContentModeScaleAspectFit;
        _topBgDownImageView.image = [UIImage scaledImageForName:@"salesInfoBgDown" ofType:@"png"];
    }
    return _topBgDownImageView;
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
        _salesTitleLabel.textColor = kSalesInfoTitleGray;
    }
    
    return _salesTitleLabel;
}
- (WSPrograssView *)prograssView{
    
    if (_prograssView == nil) {
        
        CGFloat circelW = scale*circleWidth;
        _prograssView = [WSPrograssView sharedProgressViewManagerInitwithframe:CGRectMake(0,0,circelW,circelW) imageName:nil progressRate:0 isNeedshowRate:NO];
    }
    return _prograssView;
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
        _salesMoneyLabel.textColor = kSalesInfoTitleBlue;
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
        _progressTitleLabel.font = [UIFont systemFontOfSize:kSalesInfoStandardFont];
        _progressTitleLabel.textColor = kSalesInfoTitleGray;
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
        _progressCountLabel.font = [UIFont boldSystemFontOfSize:kSalesInfoBigFont];
        _progressCountLabel.textColor = kSalesInfoTitleBlue;
    }
    
    return _progressCountLabel;
}

#pragma mark - 获取tilteLabel1方法
- (UILabel *)tilteLabel1
{
    if (_tilteLabel1 == nil)
    {
        _tilteLabel1 = [[UILabel alloc] initWithFrame:CGRectZero];
        _tilteLabel1.backgroundColor = [UIColor clearColor];
        _tilteLabel1.textAlignment = NSTextAlignmentCenter;
        _tilteLabel1.font = [UIFont systemFontOfSize:kSalesInfoStandardFont];
        _tilteLabel1.textColor = kSalesInfoTitleGray;
    }
    
    return _tilteLabel1;
}

#pragma mark - 获取contentLabel1方法
- (UILabel *)contentLabel1
{
    if (_contentLabel1 == nil)
    {
        _contentLabel1 = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel1.backgroundColor = [UIColor clearColor];
        _contentLabel1.textAlignment = NSTextAlignmentCenter;
        _contentLabel1.font = [UIFont systemFontOfSize:kSalesInfoBigFont];
        _contentLabel1.textColor = kSalesInfoTitleRed;
    }
    
    return _contentLabel1;
}

#pragma mark - 获取lineView1方法
- (UIView *)lineView1
{
    if(_lineView1 == nil)
    {
        _lineView1 = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView1.backgroundColor = kSalesInfoTitleGray;
    }
    return _lineView1;
}

#pragma mark - 获取tilteLabel2方法
- (UILabel *)tilteLabel2
{
    if (_tilteLabel2 == nil)
    {
        _tilteLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
        _tilteLabel2.backgroundColor = [UIColor clearColor];
        _tilteLabel2.textAlignment = NSTextAlignmentCenter;
        _tilteLabel2.font = [UIFont systemFontOfSize:kSalesInfoStandardFont];
        _tilteLabel2.textColor = kSalesInfoTitleGray;
    }
    
    return _tilteLabel2;
}

#pragma mark - 获取contentLabel2方法
- (UILabel *)contentLabel2
{
    if (_contentLabel2 == nil)
    {
        _contentLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel2.backgroundColor = [UIColor clearColor];
        _contentLabel2.textAlignment = NSTextAlignmentCenter;
        _contentLabel2.font = [UIFont systemFontOfSize:kSalesInfoBigFont];
        _contentLabel2.textColor = kSalesInfoTitleRed;
    }
    
    return _contentLabel2;
}

#pragma mark - 获取tilteLabel3方法
- (UILabel *)tilteLabel3
{
    if (_tilteLabel3 == nil)
    {
        _tilteLabel3 = [[UILabel alloc] initWithFrame:CGRectZero];
        _tilteLabel3.backgroundColor = [UIColor clearColor];
        _tilteLabel3.textAlignment = NSTextAlignmentCenter;
        _tilteLabel3.font = [UIFont systemFontOfSize:kSalesInfoStandardFont];
        _tilteLabel3.textColor = kSalesInfoTitleGray;
    }
    
    return _tilteLabel3;
}

#pragma mark - 获取contentLabel3方法
- (UILabel *)contentLabel3
{
    if (_contentLabel3 == nil)
    {
        _contentLabel3 = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel3.backgroundColor = [UIColor clearColor];
        _contentLabel3.textAlignment = NSTextAlignmentCenter;
        _contentLabel3.font = [UIFont systemFontOfSize:kSalesInfoBigFont];
        _contentLabel3.textColor = kSalesInfoTitleRed;
    }
    
    return _contentLabel3;
}

#pragma mark - 获取lineView2方法
- (UIView *)lineView2
{
    if(_lineView2 == nil)
    {
        _lineView2 = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView2.backgroundColor = kSalesInfoTitleGray;
    }
    return _lineView2;
}

#pragma mark - 获取tilteLabel4方法
- (UILabel *)tilteLabel4
{
    if (_tilteLabel4 == nil)
    {
        _tilteLabel4 = [[UILabel alloc] initWithFrame:CGRectZero];
        _tilteLabel4.backgroundColor = [UIColor clearColor];
        _tilteLabel4.textAlignment = NSTextAlignmentCenter;
        _tilteLabel4.font = [UIFont systemFontOfSize:kSalesInfoStandardFont];
        _tilteLabel4.textColor = kSalesInfoTitleGray;
    }
    
    return _tilteLabel4;
}

#pragma mark - 获取contentLabel4方法
- (UILabel *)contentLabel4
{
    if (_contentLabel4 == nil)
    {
        _contentLabel4 = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel4.backgroundColor = [UIColor clearColor];
        _contentLabel4.textAlignment = NSTextAlignmentCenter;
        _contentLabel4.font = [UIFont systemFontOfSize:kSalesInfoBigFont];
        _contentLabel4.textColor = kSalesInfoTitleRed;
    }
    
    return _contentLabel4;
}

#pragma mark - 重写initWithFrame:方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupSalesInfoView];
    }
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutSalesInfoView];
}

#pragma mark - 计算销售信息视图高度方法 width:宽度
- (CGFloat)calculationSalesInfoViewHeightWithWidth:(CGFloat)width
{
    if(width <= 0.0f)
        return width;
    
    CGFloat maxHeight = 0.0f;
    
    UIImage *image = [UIImage scaledImageForName:@"salesInfoBgUp" ofType:@"png"];
    CGSize size = [self measureImageSizeWithImageSize:image.size drawWidth:width];
    maxHeight += size.height;
    
    image = [UIImage scaledImageForName:@"salesInfoBgDown" ofType:@"png"];
    size = [self measureImageSizeWithImageSize:image.size drawWidth:width];
    maxHeight += size.height;
    
    maxHeight += (kSalesInfoElementHeight * 2);
    return maxHeight;
}

#pragma mark - 更新销售信息视图方法 showData:显示数据
- (void)updateSalesInfoViewWithShowData:(WSSalesInfoViewShowData *)showData
{
    self.noticeCount = (showData.noticeCount.length > 0) ? showData.noticeCount : @"";
    
    NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:WS_CHARTMODULE_USERHEADIMAGE];
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage scaledImageForName:@"headportrait_normal" ofType:@"png"]];
    
    self.contentLabel.text = (showData.slogan.length > 0) ? showData.slogan : @"";
    self.countLabel.text = (showData.noticeCount.length > 0) ? showData.noticeCount : @"";
    
    self.salesTitleLabel.text = (showData.tilte1.length > 0) ? showData.tilte1 : @"";
    self.salesMoneyLabel.text = (showData.content1.length > 0) ? showData.content1 : @"";
    
    self.progressTitleLabel.text = (showData.tilte7.length > 0) ? showData.tilte7 : @"";
    self.progressCountLabel.text = (showData.content7.length > 0) ? showData.content7 : @"";
    //MN-3645
    self.prograssView.rate = [((showData.content2.length > 0) ? showData.content2 : @"0") integerValue];
    
    self.tilteLabel1.text = (showData.tilte3.length > 0) ? showData.tilte3 : @"";
    self.contentLabel1.text = (showData.content3.length > 0) ? showData.content3 : @"";
    
    self.tilteLabel2.text = (showData.tilte4.length > 0) ? showData.tilte4 : @"";
    self.contentLabel2.text = (showData.content4.length > 0) ? showData.content4 : @"";
    
    self.tilteLabel3.text = (showData.tilte5.length > 0) ? showData.tilte5 : @"";
    self.contentLabel3.text = (showData.content5.length > 0) ? showData.content5 : @"";
    
    self.tilteLabel4.text = (showData.tilte6.length > 0) ? showData.tilte6 : @"";
    self.contentLabel4.text = (showData.content6.length > 0) ? showData.content6 : @"";
    
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

@end
//===================================================================================================================================================================

#pragma mark - 销售信息视图 延展(工具)
@implementation WSSalesInfoView (Tools)

#pragma mark - 设置销售信息视图方法
- (void)setupSalesInfoView
{
    [self addSubview:self.topBgUpImageView];
    [self addSubview:self.topBgDownImageView];
    
    [self addSubview:self.headImageView];
    [self addSubview:self.hornImageView];
    [self addSubview:self.contentLabel];
    [self addSubview:self.notifyButton];
    [self addSubview:self.countLabel];
    
    [self addSubview:self.salesTitleLabel];
    [self addSubview:self.salesMoneyLabel];
    [self addSubview:self.progressTitleLabel];
    [self addSubview:self.progressCountLabel];
    
    [self addSubview:self.tilteLabel1];
    [self addSubview:self.contentLabel1];
    [self addSubview:self.lineView1];
    [self addSubview:self.tilteLabel2];
    [self addSubview:self.contentLabel2];
    [self addSubview:self.tilteLabel3];
    [self addSubview:self.contentLabel3];
    [self addSubview:self.lineView2];
    [self addSubview:self.tilteLabel4];
    [self addSubview:self.contentLabel4];
    [self addSubview:self.prograssView];

}

#pragma mark - 布局销售信息视图方法
- (void)layoutSalesInfoView
{
    UIImage *image = [UIImage scaledImageForName:@"salesInfoBgUp" ofType:@"png"];
    CGSize size = [self measureImageSizeWithImageSize:image.size drawWidth:CGRectGetWidth(self.frame)];
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat w = size.width;
    CGFloat h = size.height;
    self.topBgUpImageView.frame = CGRectMake(x, y, w, h);
    
    image = [UIImage scaledImageForName:@"salesInfoBgDown" ofType:@"png"];
    size = [self measureImageSizeWithImageSize:image.size drawWidth:CGRectGetWidth(self.frame)];
    x = 0.0f;
    y = CGRectGetMaxY(self.topBgUpImageView.frame);
    w = size.width;
    h = size.height;
    self.topBgDownImageView.frame = CGRectMake(x, y, w, h);
    
    CGFloat circelW = scale*circleWidth;
    CGFloat circelX = self.bounds.size.width * 0.5 - 0.5 * circelW;
    CGFloat circelY = CGRectGetMaxY(self.topBgDownImageView.frame)- circelW - bottomPadding*scale;
    self.prograssView.frame = CGRectMake(circelX,circelY,circelW,circelW);

    [self layoutTopInfo];
    [self layoutCoreInfo];
    [self layoutBottomInfo];
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
    CGFloat bootmY = CGRectGetMaxY(self.topBgUpImageView.frame);
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

#pragma mark - 布局底部信息方法
- (void)layoutBottomInfo
{
    CGFloat maxWidth = (CGRectGetWidth(self.frame) - kSalesInfoLineWidth);
    CGFloat elementMaxWidth = maxWidth / 2;
    CGFloat elementMaxHeight = kSalesInfoElementHeight / 2;
    
    CGFloat drawOffX = 0.0f;
    CGFloat drawOffY = CGRectGetMaxY(self.topBgDownImageView.frame);
    
    CGFloat x = drawOffX;
    CGFloat y = drawOffY;
    CGFloat w = elementMaxWidth;
    CGFloat h = elementMaxHeight;
    self.tilteLabel1.frame = CGRectMake(x, y, w, h);
    
    x = drawOffX;
    y = CGRectGetMaxY(self.tilteLabel1.frame);
    w = elementMaxWidth;
    h = elementMaxHeight;
    self.contentLabel1.frame = CGRectMake(x, y, w, h);
    
    x = elementMaxWidth;
    y = drawOffY + ((kSalesInfoElementHeight - kSalesInfoStandardSpace) / 2);
    w = kSalesInfoLineWidth;
    h = kSalesInfoStandardSpace;
    self.lineView1.frame = CGRectMake(x, y, w, h);
    
    drawOffX = CGRectGetMaxX(self.lineView1.frame);
    
    x = drawOffX;
    y = drawOffY;
    w = elementMaxWidth;
    h = elementMaxHeight;
    self.tilteLabel2.frame = CGRectMake(x, y, w, h);
    
    x = drawOffX;
    y = CGRectGetMaxY(self.tilteLabel2.frame);
    w = elementMaxWidth;
    h = elementMaxHeight;
    self.contentLabel2.frame = CGRectMake(x, y, w, h);
    
    drawOffX = 0.0f;
    drawOffY += kSalesInfoElementHeight;
    
    x = drawOffX;
    y = drawOffY;
    w = elementMaxWidth;
    h = elementMaxHeight;
    self.tilteLabel3.frame = CGRectMake(x, y, w, h);
    
    x = drawOffX;
    y = CGRectGetMaxY(self.tilteLabel3.frame);
    w = elementMaxWidth;
    h = elementMaxHeight;
    self.contentLabel3.frame = CGRectMake(x, y, w, h);
    
    x = elementMaxWidth;
    y = drawOffY + ((kSalesInfoElementHeight - kSalesInfoStandardSpace) / 2);
    w = kSalesInfoLineWidth;
    h = kSalesInfoStandardSpace;
    self.lineView2.frame = CGRectMake(x, y, w, h);
    
    drawOffX = CGRectGetMaxX(self.lineView1.frame);
    
    x = drawOffX;
    y = drawOffY;
    w = elementMaxWidth;
    h = elementMaxHeight;
    self.tilteLabel4.frame = CGRectMake(x, y, w, h);
    
    x = drawOffX;
    y = CGRectGetMaxY(self.tilteLabel4.frame);
    w = elementMaxWidth;
    h = elementMaxHeight;
    self.contentLabel4.frame = CGRectMake(x, y, w, h);
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
//===================================================================================================================================================================

#pragma mark - 销售信息视图显示数据
@implementation WSSalesInfoViewShowData

@end
//===================================================================================================================================================================
