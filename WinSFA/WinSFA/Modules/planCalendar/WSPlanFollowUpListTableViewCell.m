//
//  WSPlanFollowUpListTableViewCell.m
//  WinSFA
//
//  Created by 董宏 on 2020/5/7.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSPlanFollowUpListTableViewCell.h"

static CGFloat const kStoreRouteViewCellX      = 10;


@interface WSPlanFollowUpListTableViewCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *planLabel;
@property (nonatomic, strong) UIView *linView;

@end

@implementation WSPlanFollowUpListTableViewCell

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
    planLabel.textAlignment = NSTextAlignmentRight;
    
   
    
    
    
    UIImageView *setImg = [[UIImageView alloc] init];
    [setImg setImage:[UIImage imageNamed:@"arrow_right"]];
//    arrow_right@3x
//    visit_action_done
//    setImg.hidden = YES;
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:@"c4c4c4"];
    [self.contentView addSubview:nameLabel];
    [self.contentView addSubview:planLabel];
    [self.contentView addSubview:setImg];
    [self.contentView addSubview:view];
    
    self.nameLabel = nameLabel;
    self.planLabel = planLabel;
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
    self.nameLabel.frame = CGRectMake(paddingX, offsetY , viewWidth - 2*paddingX - 30  , viewHeight);
    self.planLabel.frame = CGRectMake(viewWidth - 80 -  5, offsetY , 50 , viewHeight);
    self.setImg.frame = CGRectMake(viewWidth - 5 - 30, 5, 30, 30);
    self.linView.frame = CGRectMake(0, viewHeight - 1 , viewWidth,1);
    
    
}
- (void)setTitle:(NSString *)title
{
    _title = title;
    self.nameLabel.text = title;


}
- (void)setNumer:(NSString *)numer
{
    _numer = numer;
    self.planLabel.text = numer;

}

@end

