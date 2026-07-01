//
//  WSFollowUpStoreListTableViewCell.m
//  WinSFA
//
//  Created by 董宏 on 2020/5/12.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSFollowUpStoreListTableViewCell.h"

static CGFloat const kStoreFollowUpViewCellX      = 10;
static CGFloat const kStoreFollowUpViewCellY      = 10;
static CGFloat const kStoreFollowUpViewCellLabelH  = 15;



@interface WSFollowUpStoreListTableViewCell ()

@property (nonatomic, strong) UILabel *superiorEmpNameLabel;
@property (nonatomic, strong) UILabel *empNameLabel;
@property (nonatomic, strong) UILabel *storeNameLabel;
@property (nonatomic, strong) UIView *linView;

@end

@implementation WSFollowUpStoreListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addControls];
    }
    return self;
}

- (void)addControls {
    
    [self setBackgroundColor:[UIColor whiteColor]];
    UILabel *superiorEmpNameLabel = [[UILabel alloc] init];
    superiorEmpNameLabel.font = [UIFont systemFontOfSize:15];
    superiorEmpNameLabel.textColor = [UIColor colorWithHexString:@"c4c4c4"];
    superiorEmpNameLabel.text =  @"主管1";
    
    UILabel *empNameLabel = [[UILabel alloc] init];
    empNameLabel.font =  [UIFont systemFontOfSize:15];
    empNameLabel.textColor = [UIColor colorWithHexString:@"c4c4c4"];
    [empNameLabel setText:@"代表1"];
    
    UILabel *storeNameLabel = [[UILabel alloc] init];
    storeNameLabel.font =  [UIFont systemFontOfSize:15];
    storeNameLabel.textColor = [UIColor blackColor];
    [storeNameLabel setText:@"拜访中客户：阳光大药房"];

    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:@"c4c4c4"];
    
    [self.contentView addSubview:superiorEmpNameLabel];
    [self.contentView addSubview:empNameLabel];
    [self.contentView addSubview:storeNameLabel];
    [self.contentView addSubview:view];
    
    
    
    self.superiorEmpNameLabel = superiorEmpNameLabel;
    self.empNameLabel = empNameLabel;
    self.storeNameLabel = storeNameLabel;
    self.linView = view;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutControls];
}

- (void)layoutControls {
    
    CGFloat paddingX = kStoreFollowUpViewCellX;
    CGFloat paddingY = kStoreFollowUpViewCellY;
    CGFloat viewWidth = self.frame.size.width;
    
    self.superiorEmpNameLabel.frame = CGRectMake(paddingX, paddingY, viewWidth/4*3, kStoreFollowUpViewCellLabelH);
    CGFloat effY = self.superiorEmpNameLabel.hidden ? + paddingY : CGRectGetMaxY(self.superiorEmpNameLabel.frame)  + paddingY;
    
    self.empNameLabel.frame = CGRectMake(paddingX, effY, viewWidth/4*3, kStoreFollowUpViewCellLabelH);
    
    self.storeNameLabel.frame = CGRectMake(paddingX, CGRectGetMaxY(self.empNameLabel.frame)  + paddingY, viewWidth/4*3, kStoreFollowUpViewCellLabelH);
    
    self.linView.frame = CGRectMake(0, CGRectGetMaxY(self.storeNameLabel.frame) - 1 + paddingY, viewWidth - paddingX, 1);
    
    
}

- (void)setModel:(WSStoreListAddFollowUpDataInfoModel *)model
{
    if(model.leaderId){
        self.superiorEmpNameLabel.text = model.leaderName;
        self.superiorEmpNameLabel.hidden = NO;
    }
    else{
        self.superiorEmpNameLabel.hidden = YES;
    }
    self.empNameLabel.text = model.empName;
    self.storeNameLabel.text = [NSString stringWithFormat:@"拜访中客户：%@",model.storeName];
   
}
@end

