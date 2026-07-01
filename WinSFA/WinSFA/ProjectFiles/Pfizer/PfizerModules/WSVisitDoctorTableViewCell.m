
//
//  WSVisitDoctorTableViewCell.m
//  WinSFA
//
//  Created by heju on 16/9/12.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSVisitDoctorTableViewCell.h"


#define PLAN_IMAGE_WIDTH 12

#define PLAN_IAMGE_HEIGHT 12

#define PLAN_BUTTON_RIGHT_SPACE (INTERFACE_IS_PHONE ? 10:20)

#define K_FILLED_OUT_STATUS_VIEW_WIDHT (INTERFACE_IS_PHONE ? 60 : 85)
#define K_FILLED_OUT_STATUS_VIEW_HEGIHT (INTERFACE_IS_PHONE ? 20 : 25)
#define K_FILLED_OUT_STATUS_VIEW_RIGHT_SPACE (INTERFACE_IS_PHONE ? 15 : 20)

@interface WSVisitDoctorTableViewCell ()

@property (nonatomic,strong) UIButton *planBtn;

@end

@implementation WSVisitDoctorTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    _planBtn = [[UIButton alloc] init];
    _planBtn.userInteractionEnabled = NO;
    [self addSubview:self.planBtn];
    
    _filledOutStatusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - K_FILLED_OUT_STATUS_VIEW_WIDHT - K_FILLED_OUT_STATUS_VIEW_RIGHT_SPACE, (self.frame.size.height - K_FILLED_OUT_STATUS_VIEW_HEGIHT)/2, K_FILLED_OUT_STATUS_VIEW_WIDHT, K_FILLED_OUT_STATUS_VIEW_HEGIHT)];
    [_filledOutStatusImageView setImage:[UIImage imageNamed:@"already_filled_out_icon"]];
    _filledOutStatusImageView.hidden = YES;
    
    [self addSubview:_filledOutStatusImageView];
}

- (void)setModel:(WSHosBean *)hosBean  plan:(BOOL)plan{
    
    
    NSString *imageName;
    NSString *title;
    if (plan) {
        imageName = @"tag_0";
        title = @"内";
    }else {
        imageName = @"tag_1";
        title = @"外";
    }
    self.planBtn.frame = CGRectMake(self.width - PLAN_BUTTON_RIGHT_SPACE - PLAN_IMAGE_WIDTH ,(self.height - PLAN_IAMGE_HEIGHT)/2 , PLAN_IMAGE_WIDTH, PLAN_IAMGE_HEIGHT);
    [self.planBtn setBackgroundImage:[UIImage imageForName:imageName ] forState:UIControlStateNormal];
    self.planBtn.titleEdgeInsets = UIEdgeInsetsMake(-1, 0, 0, 0);
    [self.planBtn.titleLabel setFont:[UIFont systemFontOfSize:9.0f]];
    [self.planBtn setTitle:title forState:UIControlStateNormal];
    self.planBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_filledOutStatusImageView setFrame:CGRectMake(self.frame.size.width - K_FILLED_OUT_STATUS_VIEW_WIDHT - K_FILLED_OUT_STATUS_VIEW_RIGHT_SPACE, (self.frame.size.height - K_FILLED_OUT_STATUS_VIEW_HEGIHT)/2, K_FILLED_OUT_STATUS_VIEW_WIDHT, K_FILLED_OUT_STATUS_VIEW_HEGIHT)];
}

@end
