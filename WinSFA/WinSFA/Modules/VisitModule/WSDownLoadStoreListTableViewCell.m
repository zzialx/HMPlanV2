//
//  WSDownLoadStoreListTableViewCell.m
//  WinSFA
//
//  Created by mac on 2018/7/17.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSDownLoadStoreListTableViewCell.h"
#import "GlobalUtil.h"
@implementation WSDownLoadStoreListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    self.contentView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    CGFloat titleWidth = FRAME_WIDTH/2-MAIN_BIG_PADDING;
    CGRect  titleFrame = CGRectMake(MAIN_BIG_PADDING, 0, titleWidth, self.contentView.height);
    self.labName = [[UILabel alloc] initWithFrame:titleFrame];
    [self.labName setTextColor:GRAY_TEXT_COLOR];
    [self.labName setFont:[UIFont systemFontOfSize:UI_Font]];
    [self.contentView addSubview:self.labName];
    
    
    titleFrame = CGRectMake( FRAME_WIDTH/2, 0, titleWidth, self.contentView.height);
    self.labTime = [[UILabel alloc] initWithFrame:titleFrame];
    [self.labTime setTextColor:GRAY_TEXT_COLOR];
    [self.labTime setFont:[UIFont systemFontOfSize:UI_Font]];
    self.labTime.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.labTime];
}
- (void)setStoreOther:(WSBaseStoreOtherDataObject *)storeOther
{
    self.labName.text =(storeOther.item3 && storeOther.item3.length > 0) ? [NSString stringWithFormat:@"%@(%@ 家)",storeOther.item1,storeOther.item3] :storeOther.item1;
    self.labTime.text = [GlobalUtil timeOfTimestamp:@([storeOther.biz_date integerValue]) withType:timeWithYearAndDay];

}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.contentView.frame = frame;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
