//
//  WSClearstoreListTableViewCell.m
//  WinSFA
//
//  Created by mac on 2018/7/18.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSClearstoreListTableViewCell.h"
#import "GlobalUtil.h"

@implementation WSClearstoreListTableViewCell



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    CGFloat titleWidth = FRAME_WIDTH/2-MAIN_BIG_PADDING;
    CGRect  titleFrame = CGRectMake(MAIN_BIG_PADDING, 0, titleWidth, self.contentView.height);
    self.labName = [[UILabel alloc] initWithFrame:titleFrame];
    [self.labName setTextColor:[UIColor blackColor]];
    [self.labName setFont:[UIFont systemFontOfSize:UI_Font]];
    [self.contentView addSubview:self.labName];
    
    self.btnSelect = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnSelect.frame = CGRectMake(FRAME_WIDTH-2*MAIN_BIG_PADDING, MAIN_BIG_PADDING, MAIN_BIG_PADDING, MAIN_BIG_PADDING);
    [self.contentView addSubview:self.btnSelect];

}
- (void)setStoreOther:(WSBaseStoreOtherDataObject *)storeOther
{
    self.labName.text =(storeOther.item3 && storeOther.item3.length > 0) ? [NSString stringWithFormat:@"%@(%@ 家)",storeOther.item1,storeOther.item3] :storeOther.item1;
    if ([storeOther.item20 isEqualToString:@"1"]) {
        [self.btnSelect setBackgroundImage:[UIImage imageNamed:@"city_selectbtn"] forState:UIControlStateNormal];
    }
    else
    {
        [self.btnSelect setBackgroundImage:[UIImage imageNamed:@"city_unselectbtn"] forState:UIControlStateNormal];
    }
    
}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.contentView.frame = frame;
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
