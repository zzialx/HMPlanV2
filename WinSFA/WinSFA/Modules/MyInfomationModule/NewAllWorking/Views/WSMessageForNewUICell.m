//
//  WSMessageForNewUICell.m
//  WinSFA
//
//  Created by zhiqing on 16/6/3.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSMessageForNewUICell.h"
#import "WSServerIPList.h"
#import "NSString+Additions.h"
#import "WSRequestHelper.h"

#define view_pre_space (13)
#define view_top_space (15)
#define k_ThemeLableFontSize ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 16 : 16)
#define k_ThemeSynopsisFontSize ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 12 : 14)
#define k_MsgLableFontSize ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10 : 12)
#define k_IsReadFontSize ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 12 : 14)

#define k_MsgLableWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10 : 12)

#define k_Content_H   30.0f

@interface WSMessageForNewUICell ()
{
    UIView * _backGroundView;
    UILabel * _titleLabel;
    UILabel * _detailLable;
    UIImageView * _imageView;
    UILabel * _lineLable;
    UILabel * _workTypeLable;
    UILabel * _timeLable;
    UILabel * _isReadLabel;
    UIImageView * _rightArrow;
    UIImageView * _backgroundImage;
    CGFloat width;
    UIView * _bottomView;
}

@end

@implementation WSMessageForNewUICell

+(instancetype)cellWithTableView:(UITableView *)tableView{
    
    static NSString * reuserID = @"resuerID";
    WSMessageForNewUICell * cell = [tableView dequeueReusableCellWithIdentifier:reuserID];
    if (cell == nil) {
        cell = [[WSMessageForNewUICell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserID];
    }
    
    return cell;
    
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpSubViews];
    }
    
    return self;
}

-(void)setUpSubViews{
    _backGroundView  = [[UIView alloc]init];
//    _backGroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    _backgroundImage = [[UIImageView alloc]init];
    _backgroundImage.image = [UIImage imageNamed:@"message_bg"];
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.font = [UIFont systemFontOfSize:k_ThemeLableFontSize];
    [_titleLabel setTextColorWithHexStr:@"#282828"];
    _titleLabel.numberOfLines = 0;
    
    _detailLable = [[UILabel alloc]init];
    [_detailLable setTextColorWithHexStr:@"#757575"];
    _detailLable.font = [UIFont systemFontOfSize:k_ThemeSynopsisFontSize];
    _detailLable.numberOfLines = 2;
    
    _imageView = [[UIImageView alloc]init];
//    _imageView.backgroundColor = [UIColor redColor];
    _imageView.contentMode = UIViewContentModeScaleToFill;
    
    _lineLable = [[UILabel alloc]init];
    _lineLable.backgroundColor = [UIColor colorWithHexString:@"#a8a8a8"];
    _workTypeLable = [[UILabel alloc]init];
    _workTypeLable.font = [UIFont systemFontOfSize:k_MsgLableFontSize + 2];
    _workTypeLable.textColor = MAIN_TINT_COLOR;
    [_workTypeLable setTextColorWithHexStr:@"#3983f8"];
//    _workTypeLable.textColor = [UIColor colorWithRed:42/255.0 green:83/255.0 blue:254/255.0 alpha:1];
    _workTypeLable.textAlignment = NSTextAlignmentLeft;
    
    _timeLable = [[UILabel alloc]init];
    _timeLable.font = [UIFont systemFontOfSize:k_MsgLableFontSize + 2];
    [_timeLable setTextColorWithHexStr:@"#a8a8a8"];
    _timeLable.textAlignment = NSTextAlignmentLeft;
    
    _isReadLabel = [[UILabel alloc]init];
    
    _isReadLabel.font = [UIFont systemFontOfSize:k_IsReadFontSize];
    _isReadLabel.textAlignment = NSTextAlignmentLeft;
    [_isReadLabel setTextColorWithHexStr:@"#a8a8a8"];
    
    
    _rightArrow = [[UIImageView alloc]init];
    _rightArrow.image = [UIImage imageNamed:@"arrow_right"];
    _rightArrow.contentMode = UIViewContentModeScaleAspectFit;
    
    _bottomView = [[UIView alloc]init];
    _bottomView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:236/255.0 alpha:1];
    [_backGroundView addSubview:_backgroundImage];
    [_backGroundView addSubview:_titleLabel];
    [_backGroundView addSubview:_detailLable];
    [_backGroundView addSubview:_lineLable];
    [_backGroundView addSubview:_workTypeLable];
    [_backGroundView addSubview:_timeLable];
    [_backGroundView addSubview:_isReadLabel];
    [_backGroundView addSubview:_rightArrow];
    [_backGroundView addSubview:_imageView];
    [self.contentView addSubview:_bottomView];

    [self.contentView addSubview:_backGroundView];
//    self.contentView.backgroundColor = [UIColor colorWithRed:237/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    self.contentView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:236/255.0 alpha:1];
 
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _backGroundViewHeight = 0;
    width = self.contentView.width - 2* view_pre_space;
    CGSize titleSize = [self.MsgsBean_msg.title ws_sizeWithFont:[UIFont systemFontOfSize:k_ThemeLableFontSize] constrainedToWidth:width];
    _titleLabel.frame = CGRectMake(view_pre_space, view_top_space, width - view_pre_space, titleSize.height);
    NSString * urlStr = nil;
    urlStr = self.MsgsBean_msg.url ? : self.MsgsBean_msg.fileUrl;
    if(urlStr){

        _detailLable.frame = CGRectMake(view_pre_space, _titleLabel.bottom + view_top_space, width - 90, 40);
        
        _imageView.frame = CGRectMake(INTERFACE_IS_PHONE? width - 60 -view_pre_space : width - 60 -view_pre_space, _detailLable.centerY - 30, 60, 60);
        
    }else{
        
//      CGSize  detailSize = [[self convertString:self.MsgsBean_msg.cont] ws_sizeWithFont:[UIFont systemFontOfSize:k_ThemeSynopsisFontSize] constrainedToWidth:width ];
//        SFA-25341董宏
//        if (detailSize.height > 24) {
//            detailSize.height = 36;
//        }
        _detailLable.frame = CGRectMake(view_pre_space, _titleLabel.bottom + view_top_space, width - 2*view_pre_space, k_Content_H);
        
        _imageView.frame = CGRectZero;
    }

//    _lineLable.frame = CGRectMake(view_pre_space, _detailLable.bottom + view_top_space,INTERFACE_IS_PHONE?( width - 2*view_pre_space):( width - 2*view_pre_space) - 166, 0.5);
     _lineLable.frame = CGRectMake(view_pre_space, _detailLable.bottom + view_top_space,INTERFACE_IS_PHONE?( width - 2*view_pre_space):( width - 2*view_pre_space) , 0.5);
   
    CGFloat workTypeWidth = [_workTypeLable.text ws_sizeWithFont:[UIFont systemFontOfSize:k_MsgLableFontSize + 2] constrainedToHeight:11].width;
   
    if (workTypeWidth > width * 0.5) {
            workTypeWidth = width * 0.5;
    }
   
    _workTypeLable.frame = CGRectMake(view_pre_space, _lineLable.bottom + view_top_space, workTypeWidth, 11);
    
    _timeLable.frame = CGRectMake(_workTypeLable.right + view_pre_space , _lineLable.bottom + view_top_space, 120, INTERFACE_IS_PHONE? 11 :13);
    [_timeLable sizeToFit];
    _timeLable.centerY = _workTypeLable.centerY;
    _isReadLabel.frame = CGRectMake(_timeLable.right + view_pre_space, _lineLable.bottom + view_top_space, 50, 11);
    
    _rightArrow.frame = CGRectMake(width - 40, _lineLable.bottom + view_top_space, 40, 11);
    _backGroundViewHeight = _rightArrow.bottom + view_pre_space;
//    _backGroundView.frame = CGRectMake(view_pre_space, 0, INTERFACE_IS_PHONE?width :width -166 , _backGroundViewHeight);
//    MSTD-6692 xuhan
    _backGroundView.frame = CGRectMake(view_pre_space, 10, INTERFACE_IS_PHONE?width :width , _backGroundViewHeight);
    _bottomView.frame = CGRectMake(0, _backGroundView.bottom, self.contentView.width, 12);

    _backgroundImage.frame = _backGroundView.bounds;
    self.height = _backGroundViewHeight;
}

-(void)setMsgsBean_msg:(WSMsgsBean_msg *)MsgsBean_msg{
    _MsgsBean_msg = MsgsBean_msg;
    
    _titleLabel.text = MsgsBean_msg.title;
    _detailLable.text = [self convertString:MsgsBean_msg.cont];
    
    for (WSMsgsBean * bean in self.msgBean) {
        if ([self.MsgsBean_msg.pid isEqualToString:bean.Id]) {
            _workTypeLable.text = bean.name;
            break;
        }else{
            _workTypeLable.text = @"";
        }
        
    }
   
    _timeLable.text = self.MsgsBean_msg.pubdate;
    // 标记 是否已读的lable
    NSString *key = [NSString stringWithFormat:@"%@#%@#%@", self.MsgsBean_msg.s, self.MsgsBean_msg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID]];
    if (self.storeId && self.storeId.length>0) {
        key = [NSString stringWithFormat:@"%@#%@",key,self.storeId];
    }
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
    NSNumber *number = [dic objectForKey:key];
    if ([self.MsgsBean_msg.isread isEqualToString:@"1"]|| (number && [number boolValue]))
    {
        _isReadLabel.hidden = YES;

    }
    else
    {
        _isReadLabel.hidden = NO;
        _isReadLabel.text = NSLocalizedString(@"unread", nil);
        [_isReadLabel setTextColorWithHexStr:@"#c90000"];
    }
//    _imageView.image = [UIImage imageNamed:@"arrow_right"];
    
    NSString * urlStr = nil;
    urlStr = self.MsgsBean_msg.url ? : self.MsgsBean_msg.fileUrl;
    if (urlStr.length > 3 ) {
        
        NSRange range = NSRangeFromString(urlStr);
        range.length = range.length - 3;
        
        NSString * message = [urlStr substringFromIndex:(urlStr.length - 3)];
        if ([message isEqualToString:@"ocx"] || [message isEqualToString:@"doc"]) {
            
            _imageView.image = [UIImage imageNamed:@"icon_file_doc"];
        }
        else if ([message isEqualToString:@"pdf"]){
             _imageView.image = [UIImage imageNamed:@"icon_file_pdf"];
        }
        else if ([message isEqualToString:@"ppt"] || [message isEqualToString:@"ptx"]){
            _imageView.image = [UIImage imageNamed:@"icon_file_ppt"];
        }
        else if ([message isEqualToString:@"lsx"] || [message isEqualToString:@"xls"]){
             _imageView.image = [UIImage imageNamed:@"icon_file_xls"];
        }
        else{
            NSArray * medieArray = [urlStr componentsSeparatedByString:@","];
            
            NSString * url = [WSHttpURLHelper getImageCompleteURL:[medieArray firstObject]];

//            _imageView.image = [UIImage imageNamed:@"place_holder"];
            [[WSRequestHelper shareInstance] downloadImageWithUrl:url imageView:_imageView placeholderImage:[UIImage imageNamed:@"place_holder"]];
        }
 
    }
    else{
        
        _imageView.image = nil;
    }

}


+(float)cellHeightForRow:(WSMsgsBean_msg *)msg with:(CGFloat)width{
    
    width = width - 2* view_pre_space;
    
    CGSize titleSize = [msg.title ws_sizeWithFont:[UIFont systemFontOfSize:k_ThemeLableFontSize] constrainedToWidth:width];
    CGSize detailSize = CGSizeZero;
    NSString * urlStr = nil;
    urlStr = msg.url ? : msg.fileUrl;
    if(urlStr){
        detailSize.height = 40;
    }else{
        detailSize.height = k_Content_H;
//        NSString * contString = msg.cont;
//        contString = [contString stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
//        contString = [contString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
//         detailSize = [contString ws_sizeWithFont:[UIFont systemFontOfSize:k_ThemeSynopsisFontSize] constrainedToWidth:width ];
        //        SFA-25341董宏
//        if (detailSize.height > 24.0) {
//            detailSize.height = 36;
//        }
    }
    
    return   ( 2 * view_pre_space + 3 * view_top_space + titleSize.height + detailSize.height + 11 + 12);

}

-(NSString *)convertString:(NSString *)string{
    NSString * contString = string;
    contString = [contString stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    contString = [contString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    //判断是不是html内容
    if ([self isHTMLContent:contString]) {
        contString = @"";
    }
    return contString;
}
- (BOOL)isHTMLContent:(NSString *)string {
    if (!string || string.length == 0) {
        return NO;
    }
    NSString *lowercaseStr = [string lowercaseString];
    if ([lowercaseStr rangeOfString:@"<!doctype html"].location != NSNotFound) {
        return YES;
    }
    if ([self hasTag:lowercaseStr tag:@"html"]) {
        return YES;
    }
    if ([self hasTag:lowercaseStr tag:@"head"] || [self hasTag:lowercaseStr tag:@"body"]) {
        return YES;
    }
    NSArray *commonTags = @[@"div", @"p", @"span", @"a", @"img", @"ul", @"li", @"h1", @"h2", @"h3", @"table", @"tr", @"td"];
    NSUInteger tagCount = 0;
    for (NSString *tag in commonTags) {
        if ([self hasTag:lowercaseStr tag:tag]) {
            tagCount++;
            if (tagCount >= 2) { // 出现至少2种不同标签，判定为HTML
                return YES;
            }
        }
    }
    // 特征5: 检测自闭合标签（如<img>、<br>等）
    if ([lowercaseStr rangeOfString:@"<img "].location != NSNotFound ||
        [lowercaseStr rangeOfString:@"<br>"].location != NSNotFound ||
        [lowercaseStr rangeOfString:@"<hr>"].location != NSNotFound) {
        return YES;
    }
    // 特征6: 检测HTML实体（如&nbsp; &lt; &gt;等）
    if ([lowercaseStr rangeOfString:@"&amp;"].location != NSNotFound ||
        [lowercaseStr rangeOfString:@"&nbsp;"].location != NSNotFound ||
        [lowercaseStr rangeOfString:@"&lt;"].location != NSNotFound ||
        [lowercaseStr rangeOfString:@"&gt;"].location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

/// 辅助方法：检测字符串中是否包含指定标签（支持开始标签和闭合标签）
- (BOOL)hasTag:(NSString *)string tag:(NSString *)tag {
    // 匹配开始标签（如<div> 或 <div class="test">）
    NSString *startTagPattern = [NSString stringWithFormat:@"<%@[ >]", tag];
    // 匹配闭合标签（如</div>）
    NSString *endTagPattern = [NSString stringWithFormat:@"</%@>", tag];
    
    NSRange startRange = [string rangeOfString:startTagPattern options:NSCaseInsensitiveSearch];
    NSRange endRange = [string rangeOfString:endTagPattern options:NSCaseInsensitiveSearch];
    
    return startRange.location != NSNotFound || endRange.location != NSNotFound;
}

@end
