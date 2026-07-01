//
//  WSDetailHeadView.m
//  WinSFA
//
//  Created by admin on 15/11/11.
//  Copyright © 2015年 WinChannel. All rights reserved.
//


// 自定义headView  后面再优化
#import "WSDetailHeadView.h"
#import "WSMsgsBean.h"
#import "NSString+Additions.h"

#define k_ThemeLableFontSize ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 16 : 16)
#define k_Margin ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 15 : 15)
#define WCPADDING 20.0f
#define FONT_NAME @"Heiti SC"
#define THEME_FONT_NAME @"MicrosoftYaHei"

#define k_TimeLableFontSize ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 12 : 12)
#define IS_IPAD_NARGIN 166
@interface WSDetailHeadView()

@property(nonatomic,strong) UILabel * themeLable;
@property(nonatomic,strong) UIButton * msgButtom;
@property(nonatomic,strong) UILabel * timeLable;
@property(nonatomic,strong) UILabel * partitionLine;


@end

@implementation WSDetailHeadView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.themeLable = [[UILabel alloc]init];
//        self.themeLable.font = [UIFont fontWithName:THEME_FONT_NAME size:k_ThemeLableFontSize];
        self.themeLable.font = [UIFont systemFontOfSize:k_ThemeLableFontSize];
        self.themeLable.textColor = [UIColor colorWithHexString:@"#3c3c3c"];
        self.themeLable.numberOfLines = 0 ;
        self.msgButtom = [[UIButton alloc]init];
        self.msgButtom.titleLabel.font = [UIFont fontWithName:FONT_NAME size:k_TimeLableFontSize];
//        [self.msgButtom setBackgroundImage:[UIImage imageNamed:@"bulletinboard_type_bg"] forState:UIControlStateNormal];
        [self.msgButtom setTitleColor:MAIN_TINT_COLOT forState:UIControlStateNormal];
        
        self.timeLable = [[UILabel alloc]init];
        self.timeLable.textAlignment = NSTextAlignmentLeft;
        self.timeLable.font = [UIFont fontWithName:FONT_NAME size:k_TimeLableFontSize + 2];
        self.timeLable.textColor = [UIColor colorWithHexString:@"#cbcbcb"];
        self.partitionLine = [[UILabel alloc]init];
        self.partitionLine.backgroundColor = [UIColor colorWithRed:212/255.0 green:212/255.0 blue:212/255.0 alpha:1];
        
        [self addSubview:self.themeLable];
        [self addSubview:self.msgButtom];
        [self addSubview:self.timeLable];
        [self addSubview:self.partitionLine];
    }
    
    return self;
    
}

-(void)layoutSubviews{
//    CGSize size = [self.model.title sizeWithFont:[UIFont systemFontOfSize:k_ThemeLableFontSize]];
     CGSize size = [self.model.title ws_sizeWithFont:[UIFont systemFontOfSize:k_ThemeLableFontSize] constrainedToWidth:self.width lineBreakMode:NSLineBreakByWordWrapping];
    self.themeLable.frame = CGRectMake(0 , k_Margin , self.width, size.height);
    
    CGFloat workTypeWidth = [self.msgButtom.titleLabel.text ws_sizeWithFont:[UIFont fontWithName:FONT_NAME size:k_TimeLableFontSize] constrainedToHeight:11].width;
    if (workTypeWidth > self.width * 0.5) {
        workTypeWidth = self.width * 0.5;
    }
    self.msgButtom.frame = CGRectMake(0, CGRectGetMaxY(self.themeLable.frame) + 10 , workTypeWidth, 16);
    
    self.timeLable.frame = CGRectMake(CGRectGetMaxX(self.msgButtom.frame) + 11 ,  self.msgButtom.frame.origin.y -2 , 130, 20);
    [self.timeLable sizeToFit];

    self.partitionLine.frame = CGRectMake(0, CGRectGetMaxY(self.msgButtom.frame) + 11, self.width  , 0.6);
}

-(void)setModel:(WSMsgsBean_msg *)model{
    _model = model;
    
    self.themeLable.text = self.model.title;
    self.timeLable.text = self.model.pubdate;
    
}
-(void)setMsgBean:(NSMutableArray *)msgBean{
    _msgBean = msgBean;
    // IPAD 项目 信息分类的边框 只需要显示一种背景图片
    for (WSMsgsBean * bean in self.msgBean) {
        if ([self.model.pid isEqualToString:bean.Id]) {
            [self.msgButtom setTitle:bean.name forState:UIControlStateNormal];
            
        }
        
    }
    
}
@end
