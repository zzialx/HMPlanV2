//
//  WSWorkFlowViewCell.m
//  WinSFA
//
//  Created by Alicia on 2018/1/22.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSWorkFlowViewCell.h"
#import "NSString+Additions.h"
#import "WSRequestHelper.h"

#define WORK_FOLLOW_FONT        [UIFont fontForKey:@"WorkFlowCellTitle"] ? : FONT_SIZE_PINGFANG_MEDIUM(INTERFACE_IS_PHONE ? 15 : 16)

@implementation WSWorkFlowViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.contentView.backgroundColor = [self getNormalCellBackgroundColor];
        
        self.funcsIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(MAIN_CELL_PADDING, (WORKFLOW_CELL_DEFAULT_HEIGHT - FUNCS_ICON_WIDTH)/2, FUNCS_ICON_WIDTH, FUNCS_ICON_WIDTH)];
        [self.contentView addSubview:self.funcsIconImageView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = [self getNormalCellTitleColor];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = WORK_FOLLOW_FONT;
        self.titleLabel.numberOfLines = 0;
        [self.contentView addSubview:self.titleLabel];
        
       
        UIImage *doneImage = [UIImage imageForName:@"visit_action_done"];
        self.visitActionImageView = [[UIImageView alloc] initWithImage:doneImage];
        self.visitActionImageView.frame = CGRectMake(self.indicatorImageView.left - MAIN_PADDING - doneImage.size.width, (WORKFLOW_CELL_DEFAULT_HEIGHT - doneImage.size.height)/2, doneImage.size.width, doneImage.size.height);
        self.visitActionImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.visitActionImageView.backgroundColor = [UIColor clearColor];
        self.visitActionImageView.hidden = YES;
        [self.contentView addSubview: self.visitActionImageView];

        UIImage *warningImage = [UIImage imageNamed:@"icon_tips"];
        self.warningImageView = [[UIImageView alloc] initWithImage:warningImage];
        CGFloat warningWH = warningImage.size.width;
        self.warningImageView.frame = CGRectMake(self.funcsIconImageView.right + MAIN_TEXT_IMG_PADDING, self.top + MAIN_TEXT_IMG_PADDING, warningWH, warningWH);
        self.warningImageView.hidden = YES;
        [self.contentView addSubview: self.warningImageView];
        
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
    if ([funcsBean.icon length] > 0) {
        self.funcsIconImageView.hidden = NO;
        [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:funcsBean.icon] imageView:self.funcsIconImageView];
    }else {
        self.funcsIconImageView.hidden = YES;
    }
   
    
    if ([visitActionStatus isEqualToString:ActionDone]) {
        self.visitActionImageView.hidden = NO;
    } else {
        self.visitActionImageView.hidden = YES;
    }
    
    
    if (hasTips || badgeCount < 0) {
        self.warningImageView.hidden = NO;
    } else {
        self.warningImageView.hidden = YES;
    }
    
}


#pragma mark - Style
- (UIColor *)getNormalCellBackgroundColor {
    UIColor *color = [UIColor colorForKey:@"WorkFlowCellNormalBackgroudColor"];
    if (!color) {
        color = [UIColor whiteColor];
    }
    return color;
}

- (UIColor *)getSelectedCellBackgroundColor {
    UIColor *color = [UIColor colorForKey:@"WorkFlowCellSelectedBackgroudColor"];
    if (!color) {
        color = [UIColor colorWithHexString:@"#f3f3f3"];
    }
    return color;
}

- (UIColor *)getNormalCellTitleColor {
    UIColor *color = [UIColor colorForKey:@"WorkFlowCellTitle"] ? : [UIColor colorForKey:@"WorkFlowCellTitleColor"];

    if (!color) {
        color = MAIN_TEXT_COLOR;
    }
    return color;
}

- (UIColor *)getSelectedCellTitleColor {
    UIColor *color = [UIColor colorForKey:@"WorkFlowCellSelectedTitleColor"];
    if (!color) {
        color = MAIN_TEXT_COLOR;
    }
    return color;
}

#pragma mark - Property Setting

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    [self setBackgroundBySelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [self setBackgroundBySelected:highlighted];
}

- (void)setBackgroundBySelected:(BOOL)selected {
    if (selected) {
        self.contentView.backgroundColor = [self getSelectedCellBackgroundColor];
        self.titleLabel.textColor = [self getSelectedCellTitleColor];
    } else {
        self.contentView.backgroundColor = [self getNormalCellBackgroundColor];
        self.titleLabel.textColor = [self getNormalCellTitleColor];
    }
}

@end
