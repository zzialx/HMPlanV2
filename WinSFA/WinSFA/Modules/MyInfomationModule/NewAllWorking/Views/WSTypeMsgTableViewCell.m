//
//  WSTypeMsgTableViewCell.m
//  WinSFA
//
//  Created by mac on 2018/11/9.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSTypeMsgTableViewCell.h"
#import "WSRequestHelper.h"
#import "WSMsgsBean_msg.h"

@implementation WSTypeMsgTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}
- (void)setupViews {
    
    
    self.iconImg = [[UIImageView alloc] init];
    
    [self.contentView addSubview:self.iconImg];
    
    CGFloat titleWidth = FRAME_WIDTH/2-MAIN_BIG_PADDING;
    CGRect  titleFrame = CGRectMake(MAIN_BIG_PADDING, 0, titleWidth, self.contentView.height);
    self.labName = [[UILabel alloc] initWithFrame:titleFrame];
    [self.labName setTextColor:[UIColor blackColor]];
    [self.labName setFont:[UIFont systemFontOfSize:UI_Font]];
    [self.contentView addSubview:self.labName];
    
}
- (void)setMsgBean:(WSMsgsBean *)msgBean
{
    if (msgBean.icon_url && msgBean.icon_url.length > 0) {
        self.iconImg.frame = CGRectMake(MAIN_BIG_PADDING, MAIN_BIG_PADDING/2, MAIN_BIG_PADDING*2, MAIN_BIG_PADDING*2);
        [[WSRequestHelper shareInstance] downloadImageWithUrl:msgBean.icon_url imageView:self.iconImg placeholderImage:[UIImage imageNamed:@"place_holder"]];
        CGFloat titleWidth = FRAME_WIDTH/2-MAIN_BIG_PADDING;
        CGRect  titleFrame = CGRectMake(MAIN_BIG_PADDING + CGRectGetMaxX(self.iconImg.frame), 0, titleWidth, self.contentView.height);
        self.labName.frame = titleFrame;
        NSInteger badgeCount = 0;
        NSInteger readCount = 0;

        for (WSMsgsBean_msg * tempMsg in msgBean.msg)
        {
            tempMsg.componentMsgs = [tempMsg generateComponentMsgsWith:tempMsg fileUrl:tempMsg.fileUrl];
            NSString *key = [NSString stringWithFormat:@"%@#%@#%@#%@", tempMsg.s, tempMsg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID],self.storeId];
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
            NSNumber *number = [dic objectForKey:key];
            if ([tempMsg.isread isEqualToString:@"1"] || (number && [number boolValue]))
                readCount++;
            else
                badgeCount++;
        }
       
        if (badgeCount>0) {
            if (!self.badgeView) {
                self.badgeView = [[XMBadgeView alloc]  initWithAttachView:self.iconImg alignment:XMBadgeViewAlignmentCenterRight];
                // 设置是否可拖动移除红点
                [self.badgeView setPanable:NO];
                [self.badgeView setBadgeMinWidth:14.0];
                [self.badgeView setBadgePositionAdjustment:CGPointMake(0, -MAIN_BIG_PADDING/2)];
                [self.badgeView setBadgeTextFont:[UIFont systemFontOfSize:6]];
            }
            NSString *badgeCntStr = [NSString stringWithFormat:@"%ld", badgeCount];
            [self.badgeView setBadgeText:badgeCntStr];
            self.badgeView.hidden = NO;
        }
        else
        {
            self.badgeView.hidden = YES;
            [self.badgeView reset];
            [self.badgeView removeAllSubviews];
        }
    }
    self.labName.text = msgBean.name;
}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.contentView.frame = frame;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
