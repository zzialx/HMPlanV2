//
//  WSSMSDetailCell.m
//  WinSFA
//
//  Created by mac on 16/12/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSMSDetailCell.h"
#import "WSMappingObject.h"
#import "WSSMSManagerModel.h"

#define top_margin  15
#define right_margin 10
#define CONTENT_TITLE_FONTSIZE  FONT_SIZE_PINGFANG_MEDIUM(13)
#define CONTENT_TITLE_TEXTCOLOR  [UIColor colorWithHexString:@"#333333"]
@interface WSSMSDetailCell ()

@property (nonatomic,strong)UIButton * selectButton;
@property (nonatomic,strong)UILabel * phoneNumOrTimeLabel;
@property (nonatomic,strong)UILabel * detailabel;
@property (nonatomic,strong)UILabel * timeLabel;
@property (nonatomic,assign)WSSMSDetailCellType celltype;

@end

@implementation WSSMSDetailCell

-initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier type:(WSSMSDetailCellType)type{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _celltype = type;
        [self setupSubViews];
    }
    
    return self;
}


-(void)setupSubViews{
    
    _selectButton = [[UIButton alloc]init];
    [_selectButton addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];
    [_selectButton setImage:[UIImage scaledImageForName:@"icn_nocheck" ofType:@"png"] forState:UIControlStateNormal];
     [_selectButton setImage:[UIImage scaledImageForName:@"icn_check" ofType:@"png"] forState:UIControlStateSelected];
    _phoneNumOrTimeLabel = [[UILabel alloc]init];
    _phoneNumOrTimeLabel.textColor = [UIColor blackColor];
     _phoneNumOrTimeLabel.textAlignment = NSTextAlignmentLeft;
    _detailabel =[[UILabel alloc]init];
    _detailabel.numberOfLines = 0;
    _detailabel.lineBreakMode = NSLineBreakByCharWrapping;
    _detailabel.font = FONT_SIZE_PINGFANG_MEDIUM(13);
    _detailabel.textColor = CONTENT_TITLE_TEXTCOLOR;
     _detailabel.textAlignment = NSTextAlignmentLeft;
    _timeLabel = [[UILabel alloc]init];
    _timeLabel.font = FONT_SIZE_PINGFANG_MEDIUM(13);
    _timeLabel.textColor = CONTENT_TITLE_TEXTCOLOR;
    _timeLabel.textAlignment = NSTextAlignmentRight;
    _timeLabel.contentMode = UIViewContentModeTop;
    [self.contentView addSubview:_selectButton];
    [self.contentView addSubview:_phoneNumOrTimeLabel];
    [self.contentView addSubview:_detailabel];
    [self.contentView addSubview:_timeLabel];

}

-(void)layoutSubviews{
    [super layoutSubviews];
    _selectButton.frame = CGRectMake(top_margin, top_margin, 30, 30);
    _phoneNumOrTimeLabel.frame = CGRectMake(_selectButton.right + right_margin, top_margin, self.width - 50, 30);


    if (_celltype == WSSMSDetailCellTypeGroup) {
        
        _detailabel.frame = CGRectMake(_selectButton.right +  right_margin, _phoneNumOrTimeLabel.bottom, SCREEN_WIDTH * 0.7 - 30 - 4 *top_margin, [WSSMSDetailCell detailLableSize:_model]);
        CGFloat timeLabelWidth = SCREEN_WIDTH * 0.3 - top_margin;
        
        _timeLabel.frame = CGRectMake(self.width -  top_margin - timeLabelWidth , _phoneNumOrTimeLabel.bottom, SCREEN_WIDTH * 0.3 - top_margin , 20);
    }else{
        _detailabel.frame = CGRectMake(_selectButton.right +  top_margin, _phoneNumOrTimeLabel.bottom, SCREEN_WIDTH - 3* top_margin - 30, [WSSMSDetailCell detailLableSize:_model]);
        _timeLabel.frame = CGRectZero;
    }
    
}

- (void)setModel:(id)model{
    _model = model;
    if ([model isKindOfClass:[WSSMSManagerModel class]]) {
        WSSMSManagerModel * data = (WSSMSManagerModel *)model;
        _phoneNumOrTimeLabel.text = [NSString stringWithFormat:@"%@ (%lu)",data.lastObject.receiver_num,(unsigned long)data.array.count];
        _detailabel.text = data.lastObject.content;
        _timeLabel.text = [data.lastObject.result_time substringToIndex:10];
        _selectButton.selected  = data.lastObject.isSelect;
    }else{
    
        WSBaseSmsDataObject * data = (WSBaseSmsDataObject *)model;
        _phoneNumOrTimeLabel.text = data.result_time;
        _detailabel.text = data.content;
        _selectButton.selected  = data.isSelect;

    }

}

+(CGFloat)cellHeightWith:(id)model{
    
    return [WSSMSDetailCell detailLableSize:model] + 50;

}

+(CGFloat)detailLableSize:(id)model{
    
    NSString * content;
    CGFloat width = 0;
    if ([model isKindOfClass:[WSSMSManagerModel class]]) {
        WSSMSManagerModel * data = (WSSMSManagerModel *)model;
        content = data.lastObject.content;
        width = SCREEN_WIDTH * 0.7 - 3* top_margin - 30;
    }else{
        
        WSBaseSmsDataObject * data = (WSBaseSmsDataObject *)model;
        content = data.content;
        width = SCREEN_WIDTH  - 3* top_margin - 30;

    }
    
    CGSize size=[content sizeWithAttributes:@{NSFontAttributeName: CONTENT_TITLE_FONTSIZE}];
    
#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    size =  [content boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName: CONTENT_TITLE_FONTSIZE} context:nil].size;
#else
      size=[content sizeWithFont:CONTENT_TITLE_FONTSIZE] constrainedToSize:CGSizeMake(width, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        
#endif
    
    if (size.height < 20) {  // 小于一行的时候 计算不准确
        return 20;
    }
    
    return size.height + 5;


}
-(void)Click:(UIButton *)sender{
    sender.selected = !sender.selected;
    
    if (self.buttonClick) {
        self.buttonClick();
    }

}

@end
