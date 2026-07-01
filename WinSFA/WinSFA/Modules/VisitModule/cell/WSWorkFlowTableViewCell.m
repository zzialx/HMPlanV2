//
//  WSWorkFlowCell.m
//  WinSFA
//
//  Created by yang on 15/11/10.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSWorkFlowTableViewCell.h"
#import "WSServerIPList.h"
#import "WSRequestHelper.h"
#import "JSBadgeView.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseStoreOtherDataDBService.h"


#define CELL_LEFT_SPACE (INTERFACE_IS_PHONE ? 15.0f : 20.0f)
#define ICON_TITLE_GAP 12.0f
#define TITLE_REQUIRE_GAP 7.0f
#define VISIT_ACTION_RIGHT_GAP 13.0f

#define FUNCS_ICON_WIDTH 20.0f
//#define IS_REQUIRE_ICON_WIDTH 18.0f
//#define VISIT_ACTION_ICON_WIDTH 36.0f



@interface WSWorkFlowTableViewCell ()

@property (nonatomic, strong) UIImageView  *funcsIconImageView;
@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UIImageView  *isRequireImageView;
@property (nonatomic, strong) UIImageView  *visitActionImageView;
@property (nonatomic, strong) UIImageView *warningImageView;
@property (nonatomic, strong) JSBadgeView *badgeView;
@property (nonatomic, strong) JSBadgeView *badgeNumberView;


@end

@implementation WSWorkFlowTableViewCell

- (UIColor *)getNormalCellBackgroundColor
{
    UIColor *color = [UIColor colorForKey:@"WorkFlowCellNormalBackgroudColor"];
    if (!color) {
        color = [UIColor whiteColor];
    }
    return color;
}

- (UIColor *)getSelectedCellBackgroundColor
{
    UIColor *color = [UIColor colorForKey:@"WorkFlowCellSelectedBackgroudColor"];
    if (!color) {
        color = [UIColor colorWithHexString:@"#f3f3f3"];
    }
    return color;
}

- (UIColor *)getNormalCellTitleColor
{
    UIColor *color = [UIColor colorForKey:@"WorkFlowCellTitleColor"];
    if (!color) {
        color = MAIN_TEXT_COLOR;
    }
    return color;
}

- (UIColor *)getSelectedCellTitleColor
{
    UIColor *color = [UIColor colorForKey:@"WorkFlowCellSelectedTitleColor"];
    if (!color) {
        color = MAIN_TEXT_COLOR;
    }
    return color;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.contentView.backgroundColor = [self getSelectedCellBackgroundColor];
        self.titleLabel.textColor = [self getSelectedCellTitleColor];
    }else {
        self.contentView.backgroundColor = [self getNormalCellBackgroundColor];
        self.titleLabel.textColor = [self getNormalCellTitleColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.contentView.backgroundColor = [self getSelectedCellBackgroundColor];
        self.titleLabel.textColor = [self getSelectedCellTitleColor];
    }else {
        self.contentView.backgroundColor = [self getNormalCellBackgroundColor];
        self.titleLabel.textColor = [self getNormalCellTitleColor];
    }
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.funcsIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_LEFT_SPACE, (WORKFLOW_CELL_DEFAULT_HEIGHT - FUNCS_ICON_WIDTH)/2, FUNCS_ICON_WIDTH, FUNCS_ICON_WIDTH)];
        self.funcsIconImageView.backgroundColor = [UIColor clearColor];
        self.funcsIconImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:self.funcsIconImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [self getNormalCellTitleColor];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font =[UIFont fontWithName:@"PingFangSC-Medium" size:INTERFACE_IS_PHONE ? 15 : 16];
        self.titleLabel.numberOfLines = 0;
        [self.contentView addSubview:self.titleLabel];
        
        UIImage *mustImage = [UIImage imageForName:@"star_must"];
        self.isRequireImageView = [[UIImageView alloc] initWithImage:mustImage];
        self.isRequireImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview: self.isRequireImageView];
        
        UIImage *doneImage = [UIImage imageForName:@"visit_action_done"];
        self.visitActionImageView = [[UIImageView alloc] initWithImage:doneImage];
        self.visitActionImageView.frame = CGRectMake(self.indicatorImageView.left - VISIT_ACTION_RIGHT_GAP - doneImage.size.width, (WORKFLOW_CELL_DEFAULT_HEIGHT - doneImage.size.height)/2, doneImage.size.width, doneImage.size.height);
        self.visitActionImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.visitActionImageView.backgroundColor = [UIColor clearColor];
        self.visitActionImageView.hidden = YES;
        /*Jira - SFA-14667 create by sunhongfu*/
        self.visitActionImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.contentView addSubview: self.visitActionImageView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        UIColor *lineColor = [UIColor colorForKey:@"WorkFlowCellSeparatorLineColor"];
        if (lineColor) {
            self.separatorLineColor = lineColor;
        }
        
        
        UIImage *warningImage = [UIImage imageNamed:@"icon_tips"];
        self.warningImageView = [[UIImageView alloc] initWithImage:warningImage];
        self.warningImageView.frame = CGRectMake(self.right - warningImage.size.width - MAIN_CELL_HEIGHT, (self.height - warningImage.size.height) / 2, warningImage.size.width, warningImage.size.height);
        self.warningImageView.hidden = YES;
        [self.contentView addSubview: self.warningImageView];
        
        self.badgeView = [[JSBadgeView alloc] initWithParentView:self alignment:JSBadgeViewAlignmentCenterRight];
        [self.badgeView setBadgePositionAdjustment:CGPointMake(-60, 0)];
        [self.badgeView setBounds:CGRectMake(0, 0, 8, 8)];
        [self.badgeView setHidden:YES];
        
        self.badgeNumberView = [[JSBadgeView alloc] initWithParentView:self alignment:JSBadgeViewAlignmentCenterRight];
        [self.badgeNumberView setBadgePositionAdjustment:CGPointMake(-40, 0)];
        [self.badgeNumberView setBounds:CGRectMake(0, 0, 8, 8)];
        [self.badgeNumberView setHidden:YES];
        
        return self;
    }
    
    return nil;
    
}

- (void)prepareForReuse
{
    [self clearOldData];
}

- (void)clearOldData
{
    self.visitActionImageView.hidden = YES;
    self.isRequireImageView.hidden = YES;
    self.titleLabel.text = nil;
}


- (void)setDataWithFuncsBean:(WSFuncsBean *)funcsBean
                       store:(WSStoreBean *)store
           visitActionStatus:(VisitActionStatus)visitActionStatus
                      action:(WSVisitStoreActionObject *)action
                     hasTips:(BOOL)hasTips
                  badgeCount:(NSInteger)badgeCount
                   indexPath:(NSIndexPath *)indexPath
                  totalCount:(NSInteger)totalCount
{
    
    CGFloat cellHeight = (self.cellHeight > 0 ? self.cellHeight : WORKFLOW_CELL_DEFAULT_HEIGHT);
    
    if ([funcsBean.icon length] > 0) {
        self.funcsIconImageView.hidden = NO;
        [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:funcsBean.icon] imageView:self.funcsIconImageView];
        CGRect frame = self.funcsIconImageView.frame;
        if (self.funcImageWidth > 0) {
            frame.size = CGSizeMake(self.funcImageWidth, self.funcImageWidth);
        }
        frame.origin.y = (cellHeight - frame.size.height)/2;
        
        self.funcsIconImageView.frame = frame;
    }else {
        self.funcsIconImageView.hidden = YES;
    }
    
    CGSize titleSize = [funcsBean.name ws_sizeWithFont:self.titleLabel.font constrainedToWidth:self.contentView.width - self.funcsIconImageView.right - ICON_TITLE_GAP lineBreakMode:NSLineBreakByCharWrapping];
    
    CGFloat titleX = self.funcsIconImageView.isHidden ? CELL_LEFT_SPACE : self.funcsIconImageView.right + ICON_TITLE_GAP;
    self.titleLabel.frame = CGRectMake(titleX, (cellHeight - titleSize.height)/2, titleSize.width, titleSize.height);
    self.titleLabel.text = funcsBean.name;
    
    if ([action.is_required isEqualToString:@"R"]) {
        self.isRequireImageView.hidden = NO;
        UIImage *mustImage = [UIImage imageForName:@"star_must"];
        self.isRequireImageView.frame = CGRectMake(self.titleLabel.right + TITLE_REQUIRE_GAP, (cellHeight - mustImage.size.height)/2, mustImage.size.width, mustImage.size.height);
    }else {
        self.isRequireImageView.hidden = YES;
    }
    
    if ([visitActionStatus isEqualToString:ActionDone]) {
        self.visitActionImageView.hidden = NO;
        
        CGRect frame = self.visitActionImageView.frame;
        self.visitActionImageView.frame = CGRectMake(self.indicatorImageView.left - VISIT_ACTION_RIGHT_GAP - frame.size.width, (cellHeight - frame.size.height)/2, frame.size.width, frame.size.height);
    }
    
//    if (!isShowSeparatorLine) {
//        [self setStyleWithIndexPath:indexPath totalCount:totalCount];
//    }
    if (badgeCount > 0) {
        [self.badgeView setBadgeText:[NSString stringWithFormat:@"%ld", badgeCount]];
        [self.badgeView setHidden:NO];
    } else {
        [self.badgeView setHidden:YES];
    }
    //针对付费陈列和非付费陈列的特殊处理
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    NSInteger unReadbadgeCount = 0;
    if([funcsBean.fc isEqualToString:@"FAC_055_AT02"]||[funcsBean.fc isEqualToString:@"FAC_055"]||[funcsBean.fc isEqualToString:@"FAC_055_AT03"]||[funcsBean.fc isEqualToString:@"FAC_865"]||[funcsBean.fc isEqualToString:@"FAC_024_AT01"]||[funcsBean.fc isEqualToString:@"FAC_870"]|[funcsBean.fc isEqualToString:@"FAC_024_AT01"])
    {
        BOOL needGenId = NO;
        if([funcsBean.fc isEqualToString:@"FAC_055_AT02"]||[funcsBean.fc isEqualToString:@"FAC_865"]||[funcsBean.fc isEqualToString:@"FAC_024_AT01"])
        {
            needGenId = YES;
        }
        unReadbadgeCount = [service queryAcvtReadNumberStoreId:store.Id andQstCode:funcsBean.fc andNeedGenId:needGenId];
    }
    if (funcsBean.opt.funcTipType&&funcsBean.opt.funcTipType.length >0) {
        WSBaseStoreOtherDataDBService *dataService = [[WSBaseStoreOtherDataDBService alloc] init];
        unReadbadgeCount = [dataService getWorkCCellFuncTipCountWithFC:funcsBean.fc storeId:store.Id type:funcsBean.opt.funcTipType];
    }
    if (unReadbadgeCount > 0) {
        [self.badgeNumberView setBadgeText:[NSString stringWithFormat:@"%ld", unReadbadgeCount]];
        [self.badgeNumberView setHidden:NO];
    } else {
        [self.badgeNumberView setHidden:YES];
    }
    
    if (hasTips || badgeCount < 0) {
        self.warningImageView.hidden = NO;
    } else {
        self.warningImageView.hidden = YES;
    }
}



@end
