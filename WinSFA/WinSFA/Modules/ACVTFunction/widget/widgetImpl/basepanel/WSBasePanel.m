//
//  WSBasePanel.m
//  WinSFA
//
//  Created by winchannel on 15/3/19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSBasePanel.h"
#import "I_W_BuildInfo.h"
#import "WidgetConstant.h"
//#import "WSHttpURLHelper.h"
#import "WSRequestHelper.h"
@implementation WSBasePanel
@synthesize titleLabel;

-(id)initWithFrame:(CGRect)frame{
    
    self =[super initWithFrame:frame];
    
    if (self) {
        
        return self;
    }
    
    return nil;
}

- (void)setTitleContent:(NSString *)titleContent{
    if (titleContent.length>0) {
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:titleContent];
        //YIHAIKERRY-2864 多个*情况下 必填项应显示在问题最后位置
        if ([[xbuildInfo getISRequire] isEqualToString:@"1"] && [[titleContent substringFromIndex:titleContent.length - 1] isEqualToString:@"*"]) {
            
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(string.length - 1, 1)];
        }
        titleLabel.attributedText = string;
    }
    else{
        titleLabel.attributedText = nil;
    }
    
}

- (void)setTitleLabelAlignment:(NSTextAlignment)align{
    
    
    titleLabel.textAlignment = align;
    
}

- (void)setTitleLabelFrame:(CGRect)frame{
    
    [titleLabel setFrame:frame];
    
}

-(void)buildDisplayContent{
  
    
    [super buildDisplayContent];
    
    //    MMSH-3487
    //    SFA玛氏中国MWC- 【手机端：拜访】调查编号wj_cxcpmt01中的问题设置了"问题背景颜色（16进制）"，但在手机端没有生效
    NSString *bgColor = [xbuildInfo getBgColor];
    if (bgColor.length > 0) {
        self.backgroundColor = [UIColor colorWithHexString:bgColor];
    }
    
    if ([xbuildInfo getQuestIconURL].length > 0) {
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        __weak typeof (self) weakSelf = self;
        
        
        [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:[xbuildInfo getQuestIconURL]] imageView:self.iconImageView placeholderImage:[UIImage imageNamed:@"place_holder"] completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
            // 原来为除去 [[UIScreen mainScreen] scale] 屏幕scale 但是后台只能放一张图片，放2X图片 三倍屏不对，放3X图片二倍屏幕不对固需要指定后台放@2x图片
            CGFloat imageWidth = image.size.width / 2;
            CGFloat imageHeight = image.size.height  / 2;
            weakSelf.iconImageView.frame = CGRectMake(MAIN_CELL_PADDING, 0, imageWidth, imageHeight);
            [weakSelf.superview layoutSubviews];
        }];
        [self addSubview:self.iconImageView];
    }
    
    
    NSString *title = DEFAULT_VALUE;
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0, 0.0,0.0)];
    
    titleLabel.backgroundColor = kCLEAR_COLOR_value;
    
    titleLabel.text = title;
    
    UIFont *font;
    if (![[xbuildInfo getDisplayMode] isEqualToString:QST_DISPLAYMODE_SMALL]) {
        font = PanelTextFieldFont;
    } else {
        font = [UIFont systemFontOfSize:(UI_Font - 1)];
    }
    
    titleLabel.font = [UIFont fontForKey:@"BasePannelTitle"] ? [UIFont fontForKey:@"BasePannelTitle"] : font;
    
    
    NSString *qstType  = [xbuildInfo getWidgetId];
    if ((qstType && [qstType isEqualToString:@"SE"])) {
        self.isShowTitleLabel = NO;
        return;
    }
    [self addSubview:titleLabel];
    
    NSString *hideBottomLine = [xbuildInfo getHideBottomLine];
    if (![hideBottomLine isEqualToString:@"1"]) {
        /*Jira - MSTD-6842 分割线要求顶到头 create by sunhongfu 2017-11-8*/
        self.bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(SEPERATE_PADDING_Left, self.frame.size.height - 1, self.frame.size.width - 0, MAIN_CELL_SEPERATOR_HEIGHT)];
        self.bottomLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.bottomLineView.backgroundColor = DETAIL_SEPERATE_LINE_COLOR;
        [self addSubview:self.bottomLineView];
    }
    
 }

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    

    
}

- (void)loadDataSource:(NSObject<I_W_DataSource> *)datasource{
    
    [super loadDataSource:datasource];
}

-(void)loadValidator:(NSObject<I_W_Validate> *)validateobjin{
    
    [super loadValidator:validateobjin];
    
}

- (void)setTitleLabelFont:(UIFont *)font{
    
    [titleLabel setFont:font];
}


- (void)setTitleLabelColor:(UIColor *)color{
    [titleLabel setTextColor:color];
}

- (void)setViewAnswerColor:(UIColor *)color{
}

- (void)setTitleLabelColorStrByHex:(NSString *)colorStr{
    
    
    if (colorStr && [colorStr length] > 0 ) {
        
        [titleLabel setTextColor:[UIColor colorWithHexString:colorStr]];/*[self colorWithHexString:colorStr]];*/
        
        
    }else{
        
        [titleLabel setTextColor:[UIColor colorForKey:@"BasePannelTitle"] ? [UIColor colorForKey:@"BasePannelTitle"] : DETAIL_TEXT_COLOR ];

    }
}
- (void)setTitleLabelBgColor:(UIColor *)color{
    
    [titleLabel setBackgroundColor:color];
}


- (void)setTitleLabelBgColorStrByHex:(NSString *)colorStr{
    
    
    if (colorStr && [colorStr length] > 0 ) {
        
        [titleLabel setBackgroundColor:[UIColor colorWithHexString:colorStr]];
        
        
    }else{
        
        [titleLabel setBackgroundColor:LABEL_COLOR_DEFAULT];
        
    }
}

- (void)setRequest:(NSString *)isRequest{
    
    [super setRequest:isRequest];
    
}

- (void)setBottomLineLeftPadding:(CGFloat)padding {
    
    self.bottomLineView.frame = CGRectMake(padding, self.bottomLineView.frame.origin.y, self.frame.size.width - padding, self.bottomLineView.frame.size.height);
    
}

- (void)setBottomLineColor:(UIColor *)color {
    self.bottomLineView.backgroundColor = color;
}

- (void)setBottomLineHidden:(BOOL)hidden {
    self.bottomLineView.hidden = hidden;
}

-(void)setQstIconUrlSelected:(NSString *)selected{
    if ([selected isEqualToString:@"true"] ||[selected isEqualToString:@"1"] ) {
        NSString * qstIconUrl = [xbuildInfo getQuestIconURL];
        NSString * selectedUrl = [qstIconUrl stringByReplacingOccurrencesOfString:@"." withString:@"selected."];
        NSURL * url = [NSURL URLWithString:[WSHttpURLHelper getImageCompleteURL:selectedUrl]];
        [self.iconImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"place_holder"]];
    }
}

// MN-3167 - 蒙牛（ios）-拜访-订单管理-下单-结算方式选预收 “剩余预收金额” 值小于0 显示红字、金额等
- (void)setViewTitleAndAnswerColor:(NSString *)colorStr
{
    if (colorStr && colorStr.length > 0)
    {
        NSArray * array = [colorStr componentsSeparatedByString:LUA_SEPARATOR];
        if (array.count == 2)
        {
            NSString *titleLabelColor = (((NSString *)array[0]).length > 0) ? array[0] : @"";
            NSString *viewAnswerColor = (((NSString *)array[1]).length > 0) ? array[1] : @"";
            [self setTitleLabelColor:[UIColor colorWithHexString:titleLabelColor]];
            [self setViewAnswerColor:[UIColor colorWithHexString:viewAnswerColor]];
        }
    }
}

@end
