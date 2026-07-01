//
//  WSWorkFlowListViewCell.m
//  WinSFA
//
//  Created by Alicia on 17/2/14.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSWorkFlowListViewCell.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseMsgTypeTable.h"
#import "WSMsgsBean_msg.h"
#import "WSBaseStoreOtherDataDBService.h"

@implementation WSWorkFlowListViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        UIImage *mustImage = [UIImage imageForName:@"star_must"];
        self.isRequireImageView = [[UIImageView alloc] initWithImage:mustImage];
        self.isRequireImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview: self.isRequireImageView];
        
        self.indicatorImageView = [[UIImageView alloc] initWithImage:[UIImage scaledImageForName:@"arrow_right" ofType:@"png"]];
        self.indicatorImageView.frame = CGRectMake(self.contentView.width - MAIN_PADDING - INDICATOR_ICON_WIDTH, (self.height - INDICATOR_ICON_WIDTH)/2, INDICATOR_ICON_WIDTH, INDICATOR_ICON_WIDTH);
        self.indicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        self.indicatorImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview: self.indicatorImageView];
        
       
        UIImage *doneImage = [UIImage imageForName:@"visit_action_done"];
        self.visitActionImageView = [[UIImageView alloc] initWithImage:doneImage];
        self.visitActionImageView.frame = CGRectMake(self.indicatorImageView.left - MAIN_PADDING - doneImage.size.width, (WORKFLOW_CELL_DEFAULT_HEIGHT - doneImage.size.height)/2, doneImage.size.width, doneImage.size.height);
        self.visitActionImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.visitActionImageView.backgroundColor = [UIColor clearColor];
        self.visitActionImageView.hidden = YES;
        [self.contentView addSubview: self.visitActionImageView];
        
       
        NSString *isShowStr = [[WSSkinStyleManager sharedInstance].skinStyleResourceCahche objectForKey:[NSString stringWithFormat:@"%@%@", @"WorkFlowIsShowSeparatorLine", INTERFACE_IS_PAD ? kiPadSuffix : @""]];
        if (!isShowStr && INTERFACE_IS_PAD) {
            isShowStr = [[WSSkinStyleManager sharedInstance].skinStyleResourceCahche objectForKey:@"WorkFlowIsShowSeparatorLine"];
        }
        
        if (![isShowStr isEqualToString:@"0"]) {
           
            self.separatorView = [[UIView alloc] init];
            CGFloat padding = MAIN_CELL_PADDING;
            self.separatorView.frame = CGRectMake(padding, self.height - MAIN_CELL_SEPERATOR_HEIGHT, CGRectGetWidth(self.contentView.frame) - padding, MAIN_CELL_SEPERATOR_HEIGHT);
            
            UIColor *lineColor = [UIColor colorForKey:@"WorkFlowCellSeparatorLineColor"];
            if (!lineColor) {
                lineColor = DETAIL_SEPERATE_LINE_COLOR;
            }
            self.separatorView.backgroundColor = lineColor;
            [self.contentView addSubview:self.separatorView];
        }
        
        CGRect warningFrame = self.warningImageView.frame;
        self.warningImageView.frame = CGRectMake(self.right - warningFrame.size.width - MAIN_CELL_HEIGHT, (self.height - warningFrame.size.height) / 2, warningFrame.size.width, warningFrame.size.height);
        
        self.badgeNumberView = [[JSBadgeView alloc] initWithParentView:self alignment:JSBadgeViewAlignmentCenterRight];
        [self.badgeNumberView setBadgePositionAdjustment:CGPointMake(-40, 0)];
        [self.badgeNumberView setBounds:CGRectMake(0, 0, 8, 8)];
        [self.badgeNumberView setHidden:YES];
    }
    
    return self;
    
}
#pragma mark - Public Method
- (void)setDataWithFuncsBean:(WSFuncsBean *)funcsBean
                       store:(WSStoreBean *)store
           visitActionStatus:(VisitActionStatus)visitActionStatus
                      action:(WSVisitStoreActionObject *)action
                     hasTips:(BOOL)hasTips
                  badgeCount:(NSInteger)badgeCount
                   indexPath:(NSIndexPath *)indexPath
                  totalCount:(NSInteger)totalCount {
    
   [super setDataWithFuncsBean:funcsBean store:store visitActionStatus:visitActionStatus action:action hasTips:hasTips badgeCount:badgeCount indexPath:indexPath totalCount:totalCount];
    //特殊处理，配置不能改变
    if ([funcsBean.fv isEqualToString:@"FV_NOTICE"]){
        //店员教育
        WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
        NSInteger unReadbadgeCount = [service queryMsgReadNumberStoreId:store.Id];
        if (unReadbadgeCount > 0) {
                [self.badgeNumberView setBadgeText:[NSString stringWithFormat:@"%ld",unReadbadgeCount]];
                [self.badgeNumberView setHidden:NO];
        } else {
                [self.badgeNumberView setHidden:YES];
        }
    }else{
        if([funcsBean.opt.unreadNumFlag isEqualToString:@"1"])
        {
            NSInteger unReadbadgeCount = 0;
//            WSBaseStoreOtherDataDBService *dataService = [[WSBaseStoreOtherDataDBService alloc] init];
            WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
            for (WSFuncsBean *bean in funcsBean.funcsArray) {
                BOOL needGenId = NO;
                unReadbadgeCount += [service queryAcvtReadNumberStoreId:store.Id andQstCode:bean.fc andNeedGenId:needGenId];
                if([bean.fc isEqualToString:@"FAC_055_AT02"]||[bean.fc isEqualToString:@"FAC_055"]||[bean.fc isEqualToString:@"FAC_055_AT03"]||[bean.fc isEqualToString:@"FAC_865"]){
                    //付费陈列、非付费陈列的处理
                    if([funcsBean.fc isEqualToString:@"FAC_055_AT02"]||[funcsBean.fc isEqualToString:@"FAC_865"]||[funcsBean.fc isEqualToString:@"FAC_024_AT01"])
                    {
                        needGenId = YES;
                    }
                    unReadbadgeCount += [service queryAcvtReadNumberStoreId:store.Id andQstCode:bean.fc andNeedGenId:needGenId];
                }
                if (bean.opt.funcTipType.length>0) {
                    WSBaseStoreOtherDataDBService *dataService = [[WSBaseStoreOtherDataDBService alloc] init];
                    unReadbadgeCount += [dataService getWorkCCellFuncTipCountWithFC:bean.fc storeId:store.Id type:bean.opt.funcTipType];
                }
                if (unReadbadgeCount > 0) {
                    break;
                }
            }
            
            if (unReadbadgeCount > 0) {
                [self.badgeNumberView setBadgeText:@"!"];
                [self.badgeNumberView setHidden:NO];
            } else {
                [self.badgeNumberView setHidden:YES];
            }
        }else{
            [self.badgeNumberView setHidden:YES];
        }
    }
    
    
    CGSize titleSize = [funcsBean.name ws_sizeWithFont:self.titleLabel.font constrainedToWidth:(self.contentView.width - self.funcsIconImageView.right - MAIN_PADDING)];
    CGFloat titleX = self.funcsIconImageView.isHidden ? MAIN_CELL_PADDING : self.funcsIconImageView.right + MAIN_PADDING;
    self.titleLabel.frame = CGRectMake(titleX, (WORKFLOW_CELL_DEFAULT_HEIGHT - titleSize.height)/2, titleSize.width, titleSize.height);
    self.titleLabel.text = funcsBean.name;
    
    if ([action.is_required isEqualToString:@"R"]) {
        self.isRequireImageView.hidden = NO;
        UIImage *mustImage = [UIImage scaledImageForName:@"star_must" ofType:@"png"];
        self.isRequireImageView.frame = CGRectMake(self.titleLabel.right + MAIN_PADDING, (WORKFLOW_CELL_DEFAULT_HEIGHT - mustImage.size.height) / 2, mustImage.size.width, mustImage.size.height);
    } else {
        self.isRequireImageView.hidden = YES;
    }
}

@end
