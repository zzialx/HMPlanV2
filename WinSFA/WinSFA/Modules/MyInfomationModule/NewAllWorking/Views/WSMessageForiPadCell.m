//
//  WSMessageForiPadCell.m
//  WinSFA
//
//  Created by winchannel on 2018/3/21.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSMessageForiPadCell.h"

#define k_PointView_Width 6
#define k_TitleFontSize ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 18 : 18)
#define k_pointView_X  18
#define k_TitleView_X  (k_pointView_X + k_PointView_Width + 5)
#define k_TitleView_Width (self.width - k_TitleView_X - 20)

@interface WSMessageForiPadCell(){
    
}
@property (nonatomic, strong) UIView *pointView;
//@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation WSMessageForiPadCell

+(instancetype)cellWithTableView:(UITableView *)tableView{
    
    static NSString * reuserID = @"WSMessageForiPadCellID";
    WSMessageForiPadCell * cell = [tableView dequeueReusableCellWithIdentifier:reuserID];
    if (cell == nil) {
        cell = [[WSMessageForiPadCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserID];
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
    
    _pointView = [[UIView alloc]initWithFrame:CGRectMake(k_pointView_X, (self.height - k_PointView_Width)/2.0, k_PointView_Width, k_PointView_Width)];
    _pointView.backgroundColor = [UIColor colorWithHexString:@"#3983f9"];
    _pointView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _pointView.layer.cornerRadius = k_PointView_Width/2.0;
    [self.contentView addSubview:_pointView];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(k_TitleView_X , 0, k_TitleView_Width, self.height)];
    self.titleLabel.textColor =  [UIColor colorWithHexString:@"#333333"] ;
    self.titleLabel.font = FONT_SIZE_PINGFANG_Light(18);
    self.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.titleLabel.numberOfLines = 0 ;
    //_titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    self.titleLabel.textAlignment = NSTextAlignmentLeft ;
    self.titleLabel.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.titleLabel];
}

+ (float)cellHeightForRow:(WSMsgsBean_msg *)msg with:(CGFloat)width{
    
    width = width - k_TitleView_X - 20 ;
    CGSize titleSize = [msg.title ws_sizeWithFont:FONT_SIZE_PINGFANG_Light(18) constrainedToWidth:width lineBreakMode:NSLineBreakByCharWrapping];
    if (titleSize.height <= 30) {
        return 35.0f;
    }
   return  titleSize.height + 10.0f;
}
-(void)setMsgsBean_msg:(WSMsgsBean_msg *)MsgsBean_msg{
    
    _MsgsBean_msg = MsgsBean_msg;
    _titleLabel.text = MsgsBean_msg.title;
    //      SFA-23516  donghong
    NSString *key = [NSString stringWithFormat:@"%@#%@#%@", self.MsgsBean_msg.s, self.MsgsBean_msg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
    NSNumber *number = [dic objectForKey:key];
    if ([self.MsgsBean_msg.isread isEqualToString:@"1"]|| (number && [number boolValue]))
    {
        _pointView.hidden = YES;
        
    }
    else
    {
        _pointView.hidden = NO;
    }
    

    
}
- (void)layoutSubviews{
    
    [super layoutSubviews];
    _pointView.frame = CGRectMake(k_pointView_X, (self.height - k_PointView_Width)/2.0, k_PointView_Width, k_PointView_Width);
    self.titleLabel.frame = CGRectMake(k_TitleView_X , 0, k_TitleView_Width, self.height);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
