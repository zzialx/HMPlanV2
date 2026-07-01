//
//  WSWorkFlowCollectionViewCell.m
//  WinSFA
//
//  Created by Alicia on 17/2/14.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSWorkFlowCollectionViewCell.h"
#import "JSBadgeView.h"
#define WORK_FOLLOW_FONT        [UIFont fontForKey:@"WorkFlowCellTitle"] ? : [UIFont systemFontOfSize:FONT_SIZE_DESC]

#define kWorkFlowCellTitleColor        ([UIColor colorForKey:@"WorkFlowCellTitle"] ? [UIColor colorForKey:@"WorkFlowCellTitle"] : [UIColor colorWithHexString:@"333333"])
@interface WSWorkFlowCollectionViewCell()

@property (nonatomic, strong) JSBadgeView *badgeView;

@end

@implementation WSWorkFlowCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.titleLabel.font = WORK_FOLLOW_FONT;
        self.titleLabel.textColor = kWorkFlowCellTitleColor;
        [self.titleLabel setHighlighted:NO];
        
        self.funcsIconImageView.frame = CGRectMake((self.width - FUNCS_ICON_WIDTH ) / 2, MAIN_PADDING, FUNCS_ICON_WIDTH, FUNCS_ICON_WIDTH);
        
        self.titleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.funcsIconImageView.frame) + MAIN_TEXT_IMG_PADDING, self.width, kTitleHeight);
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.numberOfLines = 2;
        
        self.visitActionImageView.image = [UIImage imageNamed:@"icon_finish"];
//        self.visitActionImageView.frame = CGRectMake(self.funcsIconImageView.right - kStatusImageViewWidth + kStatusImageViewWidth/3, self.funcsIconImageView.bottom -  kStatusImageViewWidth/3, kStatusImageViewWidth, kStatusImageViewWidth);
        self.visitActionImageView.frame = CGRectMake(self.funcsIconImageView.right - kStatusImageViewWidth, self.funcsIconImageView.bottom -  kStatusImageViewWidth, kStatusImageViewWidth, kStatusImageViewWidth);
        self.visitActionImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        
        self.badgeView = [[JSBadgeView alloc] initWithParentView:self.funcsIconImageView alignment:JSBadgeViewAlignmentTopRight];
        [self.badgeView setBadgePositionAdjustment:CGPointMake(5, 0)];
        [self.badgeView setHidden:YES];
   
    }
    
    return self;    
}

- (void)setSelected:(BOOL)selected {
    // Overrid super class method, don't call super
}

- (void)setHighlighted:(BOOL)highlighted {
    //  Overrid super class method, don't call super
}

- (void)setDataWithFuncsBean:(WSFuncsBean *)funcsBean
                       store:(WSStoreBean *)store
           visitActionStatus:(VisitActionStatus)visitActionStatus
                      action:(WSVisitStoreActionObject *)action
                     hasTips:(BOOL)hasTips
                  badgeCount:(NSInteger)badgeCount
                   indexPath:(NSIndexPath *)indexPath
                  totalCount:(NSInteger)totalCount {
    
    [super setDataWithFuncsBean:funcsBean store:store visitActionStatus:visitActionStatus action:action hasTips:hasTips badgeCount:badgeCount indexPath:indexPath totalCount:totalCount];
    
    NSString *titleContent = funcsBean.name;
    if ([action.is_required isEqualToString:@"R"]) {
        titleContent = [NSString stringWithFormat:@"%@*", titleContent];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:titleContent];
        NSRange range = NSMakeRange(titleContent.length - 1, 1);
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
        self.titleLabel.attributedText = string;
    } else {
        self.titleLabel.text = titleContent;
    }
    
    CGFloat titleContentHeight = [titleContent ws_sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE_DESC] constrainedToWidth:self.width].height;
    
    self.titleLabel.height = titleContentHeight + 2;
  
  

    if (badgeCount > 0) {
        [self.badgeView setBadgeText:[NSString stringWithFormat:@"%ld", badgeCount]];
        [self.badgeView setHidden:NO];
    } else {
        [self.badgeView setHidden:YES];
    }
}

@end
