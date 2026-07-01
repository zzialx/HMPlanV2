//
//  WSMyMessageCell.m
//  demo
//
//  Created by admin on 15/10/21.
//  Copyright (c) 2015年 zhiqingPC. All rights reserved.
//

#import "WSMyMessageCell.h"
#import "WSServerIPList.h"
#import "WSServerIPController.h"
#import "SDWebImageManager.h"
#import "NSString+ServerUrl.h"

// 字体大小
#define k_ThemeLableFontSize ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 16 : 16)
#define k_ThemeSynopsisFontSize ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 12 : 14)
#define k_MsgLableFontSize ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10 : 12)
#define k_IsReadFontSize ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 12 : 14)

#define k_MsgLableWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10 : 12)
#define MARGIN ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10 : 15)
#define FONTSPACE 15
#define FONT_NAME @"Heiti SC"
#define FONT_SIZE 14
#define IMAGE_SPACE ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10 : 15)
@interface WSMyMessageCell()

// 主题lable
@property(nonatomic,strong) UILabel * themeLable;

// 主题简介
@property(nonatomic,strong) UILabel * themeSynopsis;

// 添加图片

@property(nonatomic,strong) UIButton * imgView;

// 工作重点
@property(nonatomic,strong) UIButton * msgLable;

// 时间标签
@property(nonatomic,strong) UILabel * timeLable;

// 是否已读
@property(nonatomic,strong)UILabel * isRead;

// 添加分割线
@property(nonatomic,strong)UILabel * separatorline;

@property (nonatomic, strong)NSURLConnection *iURLConnection;

@end

@implementation WSMyMessageCell

-(void)setMsgBean:(NSMutableArray *)msgBean{


    _msgBean = msgBean;

}

- (NSMutableData *)imageData
{
    if (!_imageData) {
        _imageData = [[NSMutableData alloc] init];
    }
    return _imageData;
}

// cell 重用
+(instancetype)cellWithTableView:(UITableView *)tableView{
    
    static NSString * reuserID = @"resuerID";
    WSMyMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:reuserID];
    if (cell == nil) {
        cell = [[WSMyMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserID];
    }
    
    return cell;
    
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        UILabel * themeLable = [[UILabel alloc]init];
        self.themeLable = themeLable;
        themeLable.font = [UIFont fontWithName:FONT_NAME size:k_ThemeLableFontSize];
        [themeLable setTextColorWithHexStr:@"#282828"];
        [self.contentView addSubview:themeLable];
        
        // 添加 主题简介
        UILabel * themeSynopsis = [[UILabel alloc]init];
        self.themeSynopsis = themeSynopsis;
        [themeSynopsis setTextColorWithHexStr:@"#757575"];
        themeSynopsis.font = [UIFont fontWithName:FONT_NAME size:k_ThemeSynopsisFontSize];
        themeSynopsis.numberOfLines = 2;
        [self.contentView addSubview:themeSynopsis];
        
        // 添加图片
      
        UIButton * imgView = [[UIButton alloc]init];
        imgView.contentMode = UIViewContentModeCenter;
       // [imgView addTarget:self action:@selector(didSelectIndex) forControlEvents:UIControlEventTouchUpInside];
        [imgView setBackgroundImage:[UIImage imageNamed:@"fujian_bj"] forState:UIControlStateNormal];
        imgView.userInteractionEnabled = NO;
        self.imgView = imgView;
        [self.contentView addSubview:imgView];
        
        
        // 添加工作重点的UIButton
        UIButton * msgLable = [[UIButton alloc]init];
        msgLable.titleLabel.font = [UIFont fontWithName:FONT_NAME size:k_MsgLableFontSize];
        [msgLable setBackgroundImage:[UIImage imageNamed:@"bulletinboard_type_bg"] forState:UIControlStateNormal];
        [msgLable sizeToFit];
        self.msgLable = msgLable;
//        [self.msgLable setTitleColor:[UIColor colorWithRed:65/255.0 green:157/255.0 blue:238/255.0 alpha:1] forState:UIControlStateNormal];
        [self.msgLable setTitleColor:MAIN_TINT_COLOT forState:UIControlStateNormal];
        [self.contentView addSubview:msgLable];
        
        
        // 添加时间lable
        UILabel * timeLable = [[UILabel alloc]init];
        timeLable.font = [UIFont fontWithName:FONT_NAME size:k_MsgLableFontSize + 2];
        [timeLable setTextColorWithHexStr:@"#a8a8a8"];
        timeLable.textAlignment = NSTextAlignmentLeft;
        self.timeLable = timeLable;
        [self.contentView addSubview:timeLable];
        
        // 标记 是否已读的lable
        UILabel * isRead = [[UILabel alloc]init];
        isRead.font = [UIFont fontWithName:FONT_NAME size:k_IsReadFontSize];
        isRead.textAlignment = NSTextAlignmentLeft;
        self.isRead  = isRead;
        [isRead setTextColorWithHexStr:@"#a8a8a8"];
        [self.contentView addSubview:isRead];
        
        self.separatorline = [[UILabel alloc]init];
        self.separatorline.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1];
        [self.contentView addSubview:self.separatorline];
    }
    
    
    return self;
}

// 对cell  的子视图进行布局
-(void)layoutSubviews{
    
    // 主题的frame
    self.themeLable.frame = CGRectMake(MARGIN, (INTERFACE_IS_PHONE ? 10 : FONTSPACE), (self.width - (INTERFACE_IS_PHONE ? 95 : 95 ) - MARGIN -IMAGE_SPACE) , 21);
    
    NSString *desContent = self.MsgsBean_msg.cont;
    CGSize size ;
    CGSize textSize = CGSizeMake((self.width - (INTERFACE_IS_PHONE ? 95 : 95 ) - IMAGE_SPACE), 2000) ;

#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    size =  [desContent boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE]} context:nil].size;
#else
    size = [desContent sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
    
#endif
    
    if (size.height > (INTERFACE_IS_PHONE ? 20:20)) {
        size.height = (INTERFACE_IS_PHONE ? 40:40);
    }
    // 判断是否需要加图片
    NSString * urlStr = nil;
    urlStr = self.MsgsBean_msg.url ? : self.MsgsBean_msg.fileUrl;
    if(urlStr){
        
        self.themeSynopsis.frame  = CGRectMake(MARGIN, CGRectGetMaxY(self.themeLable.frame) + (INTERFACE_IS_PHONE ? 6 : 6), (self.width - (INTERFACE_IS_PHONE ? 90 : 90 ) - 2 * MARGIN -  IMAGE_SPACE) , size.height);
        
        // 添加图片
        self.imgView.frame = CGRectMake((self.width - (INTERFACE_IS_PHONE ? 95 : 95 ) - IMAGE_SPACE) ,  IMAGE_SPACE, (INTERFACE_IS_PHONE ? 95 : 95 ), (INTERFACE_IS_PHONE ? 90 : 90 ));
        
        
    }else{
        
        self.themeSynopsis.frame = CGRectMake(MARGIN, CGRectGetMaxY(self.themeLable.frame) + (INTERFACE_IS_PHONE ? 6 : 6) , self.width - 2 * MARGIN, size.height);
        
        self.imgView.frame = CGRectZero;
    }
    // 信息分类
    
    self.msgLable.frame = CGRectMake(MARGIN, CGRectGetMaxY(self.themeSynopsis.frame) + (INTERFACE_IS_PHONE ? 7 : 8) , INTERFACE_IS_PHONE ? 55: 55, 16);
    
    // 时间标签
    self.timeLable.frame = CGRectMake(CGRectGetMaxX(self.msgLable.frame), CGRectGetMaxY(self.themeSynopsis.frame) + (INTERFACE_IS_PHONE ? 6 : 6), INTERFACE_IS_PHONE ? 110 : 130, 20);
    
    // 是否已读
    self.isRead.frame = CGRectMake(CGRectGetMaxX(self.timeLable.frame), CGRectGetMaxY(self.themeSynopsis.frame) + (INTERFACE_IS_PHONE ? 5 : 6),INTERFACE_IS_PHONE ? 40 : 50, 20);
    
    self.separatorline.frame = CGRectMake(15, self.height - 0.5, self.width, 0.5);
}
-(void)setMsgsBean_msg:(WSMsgsBean_msg *)MsgsBean_msg{
    
    _MsgsBean_msg = MsgsBean_msg;
    self.themeLable.text = self.MsgsBean_msg.title;
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing =  2 ;// 字体的行间距
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:k_ThemeSynopsisFontSize],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    self.themeSynopsis.attributedText =[[NSAttributedString alloc] initWithString:[NSString stringNotNilWithValue:self.MsgsBean_msg.cont] attributes:attributes] ;
//        self.themeSynopsis.text = self.MsgsBean_msg.cont;
    NSString *timeStr = [self.MsgsBean_msg.pubdate substringToIndex:16];
    
    self.timeLable.text = timeStr;
    self.timeLable.textAlignment = NSTextAlignmentCenter;
    
    // IPAD 项目 信息分类的边框 只需要显示一种北京图片
    for (WSMsgsBean * bean in self.msgBean) {
        if ([self.MsgsBean_msg.pid isEqualToString:bean.Id]) {
            [self.msgLable setTitle:bean.name forState:UIControlStateNormal];
            
            [self.msgLable sizeToFit];
        }
        
    }
    NSString * urlStr = nil;
    urlStr = self.MsgsBean_msg.url ? : self.MsgsBean_msg.fileUrl;
    if (urlStr ) {
        
        
        //    if (self.model.url || self.model.fileUrl ) {
        
        NSRange range = NSRangeFromString(urlStr);
        range.length = range.length - 3;
        
        NSString * message = [urlStr substringFromIndex:(urlStr.length - 3)];
        if ([message isEqualToString:@"ocx"] || [message isEqualToString:@"doc"]) {
            
            [self.imgView setImage:[UIImage imageNamed:@"icon_file_doc"] forState:UIControlStateNormal];
        }
        else if ([message isEqualToString:@"pdf"]){
            
            [self.imgView setImage:[UIImage imageNamed:@"icon_file_pdf"] forState:UIControlStateNormal];
            
            // self.imgView.image = [UIImage imageNamed:@"icon_file_pdf"];
        }
        else if ([message isEqualToString:@"ppt"] || [message isEqualToString:@"ptx"]){
            [self.imgView setImage:[UIImage imageNamed:@"icon_file_ppt"] forState:UIControlStateNormal];
            
            //  self.imgView.image = [UIImage imageNamed:@"icon_file_ppt"];
        }
        else if ([message isEqualToString:@"lsx"] || [message isEqualToString:@"xls"]){
            [self.imgView setImage:[UIImage imageNamed:@"icon_file_xls"] forState:UIControlStateNormal];
            // self.imgView.image = [UIImage imageNamed:@"icon_file_xls"];
        }
        else if ([message isEqualToString:@"png"] || [message isEqualToString:@"PNG"] || [message isEqualToString:@"JPG"] || [message isEqualToString:@"jpg"]){
            NSArray * medieArray = [urlStr componentsSeparatedByString:@","];
            NSString * url = [[medieArray firstObject] buildupUrl];
            NSURL * picURL = [NSURL URLWithString:url];
           
            [[SDWebImageManager sharedManager]downloadImageWithURL:picURL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                //
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                //
                if (finished) {
                    
                      [self.imgView setImage:image forState:UIControlStateNormal];

                }
            }];
        
     
       
        }
        else {
        
            [self.imgView setImage:[UIImage imageNamed:@"place_holder"] forState:UIControlStateNormal];
        
        }
        
    }
    else{
        
        [self.imgView setImage:nil forState:UIControlStateNormal];
    }
    // 标记 是否已读的lable
    NSString *key = [NSString stringWithFormat:@"%@#%@#%@", self.MsgsBean_msg.s, self.MsgsBean_msg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
    NSNumber *number = [dic objectForKey:key];
    if ([self.MsgsBean_msg.isread isEqualToString:@"1"]||  (number && [number boolValue]))
    {
        self.isRead.text = NSLocalizedString(@"readed", nil);
        [self.isRead setTextColorWithHexStr:@"#a8a8a8"];
    }
    else
    {
        
        self.isRead.text = NSLocalizedString(@"unread", nil);
        [self.isRead setTextColorWithHexStr:@"#c90000"];
    }
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //上分割线，
    //    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    //    CGContextStrokeRect(context, CGRectMake(5, -1, rect.size.width - 10, 1));
    //
    //下分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:212/255.0 green:212/255.0 blue:212/255.0 alpha:1].CGColor);
    CGContextStrokeRect(context, CGRectMake(15, rect.size.height, rect.size.width, 1));
}


@end
