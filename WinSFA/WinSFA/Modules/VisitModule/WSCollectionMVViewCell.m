//
//  WSCollectionMVViewCell.m
//  WinSFA
//
//  Created by Alicia on 17/2/10.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSCollectionMVViewCell.h"
#import "WSServerIPList.h"
#import "SDWebImageManager.h"
#import "WSRequestHelper.h"

#define kImageWH    30

@implementation WSCollectionMVViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.contentView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    CGFloat rightImgWidth = 30;
    self.statusImageView = [[UIImageView alloc] initWithFrame:
                           CGRectMake(MAIN_CELL_PADDING, (self.contentView.height - MAIN_CELL_BUTTON_WH) / 2, rightImgWidth, MAIN_CELL_BUTTON_WH)];
    self.statusImageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.statusImageView];
    
    self.leftImageView = [[UIImageView alloc] initWithFrame:
                          CGRectMake(MAIN_CELL_PADDING, (self.contentView.height - kImageWH) / 2, kImageWH, kImageWH)];
    self.leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.leftImageView];
    

    self.arrowImageView = [[UIImageView alloc] initWithFrame:
                          CGRectMake(self.contentView.width - MAIN_CELL_BUTTON_WH, (self.contentView.height - MAIN_CELL_BUTTON_WH) / 2, MAIN_CELL_BUTTON_WH, MAIN_CELL_BUTTON_WH)];
    self.arrowImageView.image = [UIImage imageNamed:@"arrow_right"];
    self.arrowImageView.contentMode = UIViewContentModeCenter;
    self.arrowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleLeftMargin;
    [self.contentView addSubview:self.arrowImageView];
    

    CGFloat titleWidth = self.contentView.width - kImageWH - 2 * MAIN_PADDING - MAIN_CELL_BUTTON_WH - rightImgWidth;
    CGRect titleFrame = CGRectMake(CGRectGetMaxX(self.leftImageView.frame) + MAIN_PADDING, 0, titleWidth, self.contentView.height);
    self.mainTitleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    [self.mainTitleLabel setTextColor:MAIN_TEXT_COLOR];
    [self.mainTitleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
    [self.contentView addSubview:self.mainTitleLabel];
    
    
    self.separatorLayer = [CALayer layer];
    CGFloat padding = MAIN_CELL_PADDING;
    self.separatorLayer.frame = CGRectMake(padding, self.height - 1, CGRectGetWidth(self.contentView.frame) - padding, 1);
    self.separatorLayer.backgroundColor =  DETAIL_SEPERATE_LINE_COLOR.CGColor;
    [self.contentView.layer addSublayer:self.separatorLayer];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.contentView.frame = frame;
}


- (void)setFuncsBean:(WSFuncsBean *)funcsBean {
    _funcsBean = funcsBean;
    
    // SFA-5697 调整左边图标显示，无图标icon_Url时不显示。
    if (funcsBean.icon  && funcsBean.icon.length >0) {
        NSString *stringURL =  [WSHttpURLHelper getImageCompleteURL:funcsBean.icon];
        [[WSRequestHelper shareInstance] downloadImageWithUrl:stringURL imageView:self.leftImageView placeholderImage:[UIImage imageNamed:@"place_holder"]];
        
        _statusImageView.hidden = YES;
        _leftImageView.hidden = NO;
        CGFloat titleWidth = self.contentView.width - kImageWH - 2 * MAIN_PADDING - MAIN_CELL_BUTTON_WH;
        CGRect titleFrame = CGRectMake(CGRectGetMaxX(self.leftImageView.frame) + MAIN_PADDING, 0, titleWidth, self.contentView.height);
        self.mainTitleLabel.frame = titleFrame;
    }else{
        
        _leftImageView.hidden = YES;
        CGFloat titleWidth = self.contentView.width - 2 * MAIN_PADDING - MAIN_CELL_BUTTON_WH - _statusImageView.frame.size.width;
        CGRect titleFrame = CGRectMake(CGRectGetMaxX(self.statusImageView.frame) + MAIN_PADDING, 0, titleWidth, self.contentView.height);
        self.mainTitleLabel.frame = titleFrame;
    }
 
    self.mainTitleLabel.text = funcsBean.name;
}

- (void)setTitle:(NSString *)title {
    _leftImageView.hidden = YES;
    CGFloat titleWidth = self.contentView.width - 2 * MAIN_PADDING - MAIN_CELL_BUTTON_WH - _statusImageView.frame.size.width;
     CGRect titleFrame = CGRectMake(CGRectGetMaxX(self.statusImageView.frame) + MAIN_PADDING, 0, titleWidth, self.contentView.height);
    self.mainTitleLabel.frame = titleFrame;
    self.mainTitleLabel.text = title;
}

- (void)setActionStatus:(VisitActionStatus)actionStatus {
    if ([actionStatus isEqualToString:ActionDone]) {
        self.statusImageView.image = [UIImage imageNamed:@"visit_done.png"];
    } else if ([actionStatus isEqualToString:ActionWorking]) {
       self.statusImageView.image = [UIImage imageNamed:@"visit_doing.png"];
    } else {
        self.statusImageView.image = [UIImage imageNamed:@"visit_not_start.png"];
    }
}

@end
