//
//  WSPlanRouteListTableViewCell.m
//  WinSFA
//
//  Created by 董宏 on 2020/4/28.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSPlanRouteListTableViewCell.h"
#import "WSPlanRouteListDataModel.h"

static CGFloat const kStoreRouteViewCellX      = 10;




@interface WSPlanRouteListTableViewCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *planLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *linView;

@end

@implementation WSPlanRouteListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addControls];
    }
    return self;
}

- (void)addControls {
    
    [self setBackgroundColor:[UIColor whiteColor]];
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.text =  @"路线名称";
    
    UILabel *planLabel = [[UILabel alloc] init];
    planLabel.font = [UIFont systemFontOfSize:15];
    planLabel.textColor = [UIColor blackColor];
    planLabel.text =  @"执行状态";
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.font = [UIFont systemFontOfSize:15];
    timeLabel.textColor = [UIColor blackColor];
    timeLabel.text =  @"执行日期";
    
  
    

    
    UIImageView *setImg = [[UIImageView alloc] init];
    [setImg setImage:[UIImage imageNamed:@"visit_action_done"]];
//    setImg.hidden = YES;
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:@"c4c4c4"];
    [self.contentView addSubview:nameLabel];
    [self.contentView addSubview:planLabel];
    [self.contentView addSubview:timeLabel];
    [self.contentView addSubview:setImg];
    [self.contentView addSubview:view];
    
    self.nameLabel = nameLabel;
    self.planLabel = planLabel;
    self.timeLabel = timeLabel;
    self.setImg = setImg;
    self.linView = view;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutControls];
}

- (void)layoutControls {
    
    CGFloat paddingX = kStoreRouteViewCellX;
    CGFloat viewWidth = self.frame.size.width;
    CGFloat viewHeight = self.frame.size.height;
    CGFloat offsetY = 0;
    self.nameLabel.frame = CGRectMake(paddingX, offsetY , viewWidth / 3 , viewHeight);
    self.planLabel.frame = CGRectMake(viewWidth / 3 + paddingX, offsetY , viewWidth / 5 , viewHeight);
    self.timeLabel.frame = CGRectMake(viewWidth / 3 + viewWidth / 5 + paddingX, offsetY , viewWidth / 3  , viewHeight);
    self.setImg.frame = CGRectMake(viewWidth - paddingX - 30, 5, 30, 30);
    self.linView.frame = CGRectMake(0, viewHeight - 1 , viewWidth,1);

    
}
- (void)setModel:(WSPlanRouteListDataInfoModel *)model
{
    _model = model;
    self.nameLabel.text = _model.routeName;
    self.planLabel.text = _model.routeStatus;
    self.timeLabel.text = _model.effDate;
}

@end
