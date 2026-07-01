//
//  WSCalloutAnnotationView.m
//  WinSFA
//
//  Created by heju on 16/5/12.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSCalloutAnnotationView.h"

#define K_LEFT_SPACE  10
#define K_Button_Width  10
#define K_TitleLabel_Height  20
#define K_TitleLabel_Max_Width  250

#define K_VIEW_MARGIN 5

#define K_OFFSET_HEIGHT 54

@interface WSCalloutAnnotationView()

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong)UILabel *subTitleLabel;

@property (nonatomic,strong) UIImageView *backgroundView;

@property (nonatomic , strong) UIButton * leftImageButton;


@end

@implementation WSCalloutAnnotationView


-(instancetype)init{
    if(self=[super init]){
        [self layoutUI];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self layoutUI];
    }
    return self;
}

-(void)layoutUI{
    
    //背景
    _backgroundView = [[UIImageView alloc]init];
    [_backgroundView setImage:[UIImage imageNamed:@"site_bj"]];
    
//    _backgroundView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.backgroundView];
    
    _leftImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftImageButton.titleLabel.font = [UIFont systemFontOfSize:10];
    _leftImageButton.titleEdgeInsets = UIEdgeInsetsMake(-3, 0, 0, 0);
    [_leftImageButton setBackgroundImage:[UIImage imageNamed:@"map_blue"] forState:UIControlStateNormal];
    [self addSubview:self.leftImageButton];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = RGBCOLOR(51, 51, 51);
    _titleLabel.numberOfLines = 0;
    _titleLabel.font = [UIFont systemFontOfSize:13];
    _titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self addSubview:self.titleLabel];
    
    _subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel.textColor = RGBCOLOR(153, 153, 153);
    _subTitleLabel.font = [UIFont systemFontOfSize:10];

    _subTitleLabel.textAlignment = NSTextAlignmentRight;
    _subTitleLabel.numberOfLines = 0;
    _subTitleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self addSubview:self.subTitleLabel];
    
    
}

#pragma mark 当给大头针视图设置大头针模型时可以在此处根据模型设置视图内容
-(void)setAnnotation:(WSStoreAnnotation *)annotation{
    
    [super setAnnotation:annotation];
    

    if (annotation.store.styp.length > 0 && annotation.store.isShowMapCallout) {
        // 蒙牛只需要门店拜访顺序，门店类型
        [self showVisitNum:annotation.store.row_number styp:annotation.store.styp];
        return;
    }
    
    _leftImageButton.frame = CGRectMake(K_LEFT_SPACE, K_LEFT_SPACE, 1.5 *K_Button_Width, 2 *K_Button_Width);
    [_leftImageButton setTitle:annotation.store.row_number forState:UIControlStateNormal];
   
    CGFloat width = K_TitleLabel_Max_Width;

    NSString *titleName = annotation.storeName;
    _titleLabel.text = titleName;

    CGSize titleSize = [titleName ws_sizeWithFont:[UIFont systemFontOfSize:13] constrainedToWidth:(K_TitleLabel_Max_Width - 3 *K_LEFT_SPACE - K_Button_Width) lineBreakMode:NSLineBreakByCharWrapping];
    if (titleSize.height > K_TitleLabel_Height) {
        width = K_TitleLabel_Max_Width;
    }else{
        width = titleSize.width + 3 *K_LEFT_SPACE + K_Button_Width;
    }
    _titleLabel.frame = CGRectMake(_leftImageButton.right  + 0.5 * K_LEFT_SPACE, K_LEFT_SPACE, titleSize.width, titleSize.height);
    
    NSString *subTitle = [self compareCurrentTime:annotation.store.code] ;
    
    CGSize subTileSize = [subTitle ws_sizeWithFont:[UIFont systemFontOfSize:10] constrainedToWidth:(K_TitleLabel_Max_Width - 3 *K_LEFT_SPACE - K_Button_Width) lineBreakMode:NSLineBreakByCharWrapping];
    
    CGFloat subTitleWidth = subTileSize.width;
    if (subTitleWidth < titleSize.width) {
        subTitleWidth = titleSize.width;
    }
    _subTitleLabel.frame = CGRectMake(_leftImageButton.right  + 0.5 *K_LEFT_SPACE,_titleLabel.size.height + 3*K_VIEW_MARGIN, subTitleWidth, subTileSize.height);
    _subTitleLabel.text = subTitle;
    
    if (titleSize.width < subTileSize.width) {
        width = subTileSize.width + 3 *K_LEFT_SPACE + K_Button_Width;
    }
    
    CGFloat selfHeight = K_OFFSET_HEIGHT;
    CGFloat contantHeight = titleSize.height + subTileSize.height + K_LEFT_SPACE + 3*K_VIEW_MARGIN;
    if (contantHeight > K_OFFSET_HEIGHT ) {
        selfHeight = contantHeight;
    }
    self.frame = CGRectMake(0, 0, width, selfHeight);
    self.layer.anchorPoint = CGPointMake(0.5, 1.0);
    self.backgroundView.frame = CGRectMake(0, 0, width, selfHeight);
}

-(void)showVisitNum:(NSString *)visitNum styp:(NSString *)styp{
    NSString * title = [NSString stringWithFormat:@"%@ %@",visitNum,styp];
    _titleLabel.text = title;

    CGSize titleSize = [title ws_sizeWithFont:[UIFont systemFontOfSize:13] constrainedToWidth:(K_TitleLabel_Max_Width - K_LEFT_SPACE) lineBreakMode:NSLineBreakByCharWrapping];
    _titleLabel.frame = CGRectMake(K_LEFT_SPACE, K_LEFT_SPACE, titleSize.width, titleSize.height);

    CGFloat width = titleSize.width + 2*K_LEFT_SPACE;
    self.frame = CGRectMake(0, 0, width, 44);
    self.layer.anchorPoint = CGPointMake(0.5, 1.0);
    self.backgroundView.frame = CGRectMake(0, 0, width, 44);
}

-(NSString *)compareCurrentTime:(NSString *)str
{
    
    //把字符串转为NSdate
    NSDateFormatter * dateFormatter = [NSDateFormatter standardDateFormatter];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * timeDate = [dateFormatter dateFromString:str];
    //八小时时区
    NSTimeZone * zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: timeDate];
    NSDate* mydate = [timeDate dateByAddingTimeInterval: interval];
    NSDate *nowDate =[[NSDate date] dateByAddingTimeInterval: interval];
    // 两个时间间隔
    NSTimeInterval timeInterval= [mydate timeIntervalSinceDate:nowDate];
    timeInterval = -timeInterval;
    
    NSLog(@"时间是%f",timeInterval);
    
    long temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        
        result = [NSString stringWithFormat:@"刚刚"];
    }
    else if((temp = timeInterval/60) <60){
        
        result = [NSString stringWithFormat:@"%ld分钟前",temp];
    }
    
    else if((temp = timeInterval/(60*60)) <24){
        
        result = [NSString stringWithFormat:@"%ld小时前",temp];
    }
    
    else {
        result = str;
    }
    return result;
}

@end

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

