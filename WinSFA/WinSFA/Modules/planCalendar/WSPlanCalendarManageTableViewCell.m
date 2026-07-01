//
//  WSPlanCalendarManageTableViewCell.m
//  WinSFA
//
//  Created by 董宏 on 2020/4/29.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSPlanCalendarManageTableViewCell.h"
#import "WSPlanCalendarManageDataModel.h"

static CGFloat const kCalendarManageTableViewCellX      = 10;
static CGFloat const kCalendarManageTableViewCellY      = 10;
static CGFloat const kCalendarManageTableViewCellH     = 15;




@interface WSPlanCalendarManageTableViewCell ()

@property (nonatomic, strong) UILabel *leaderNameLabel;
@property (nonatomic, strong) UILabel *salesNameLabel;
@property (nonatomic, strong) UILabel *storeNameLabel;
@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, strong) UIView *linView;

@end

@implementation WSPlanCalendarManageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addControls];
    }
    return self;
}

- (void)addControls {
    
    [self setBackgroundColor:[UIColor whiteColor]];
    UILabel *leaderNameLabel = [[UILabel alloc] init];
    leaderNameLabel.font = [UIFont systemFontOfSize:15];
    leaderNameLabel.textColor = [UIColor blackColor];
    leaderNameLabel.text =  @"主管";
    
    UILabel *salesNameLabel = [[UILabel alloc] init];
    salesNameLabel.font = [UIFont systemFontOfSize:15];
    salesNameLabel.textColor = [UIColor blackColor];
    salesNameLabel.text =  @"代表";
    
    UILabel *storeNameLabel = [[UILabel alloc] init];
    storeNameLabel.font = [UIFont systemFontOfSize:15];
    storeNameLabel.textColor = [UIColor blackColor];
    storeNameLabel.text =  @"河南美瑞大药房";
    
    UILabel *stateLabel = [[UILabel alloc] init];
    stateLabel.font = [UIFont boldSystemFontOfSize:15];
    stateLabel.textAlignment = NSTextAlignmentRight;
    stateLabel.text =  @"(已随访)";
    
    
    
    
    
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:@"c4c4c4"];
    [self.contentView addSubview:leaderNameLabel];
    [self.contentView addSubview:salesNameLabel];
    [self.contentView addSubview:storeNameLabel];
    [self.contentView addSubview:stateLabel];
    [self.contentView addSubview:view];
    
    self.leaderNameLabel = leaderNameLabel;
    self.salesNameLabel = salesNameLabel;
    self.storeNameLabel = storeNameLabel;
    self.stateLabel = stateLabel;

    self.linView = view;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutControls];
}

- (void)layoutControls {
    
    CGFloat paddingX = kCalendarManageTableViewCellX;
    CGFloat paddingY = kCalendarManageTableViewCellY;

    CGFloat viewWidth = self.frame.size.width;
    CGFloat viewHeight = self.frame.size.height;
    
    CGFloat y = 0;
    self.leaderNameLabel.frame = CGRectMake(paddingX, paddingY , viewWidth , kCalendarManageTableViewCellH);
    if (!self.leaderNameLabel.hidden) {
        y = CGRectGetMaxY(self.leaderNameLabel.frame);
    }
    
    self.salesNameLabel.frame = CGRectMake(paddingX,   y + paddingY , viewWidth  , kCalendarManageTableViewCellH);
    
    self.stateLabel.frame = CGRectMake(paddingX,(viewHeight - kCalendarManageTableViewCellH)/2 , viewWidth - 2 * paddingX  , kCalendarManageTableViewCellH);

    self.storeNameLabel.frame = CGRectMake(paddingX, CGRectGetMaxY(self.salesNameLabel.frame)  + paddingY , viewWidth  , kCalendarManageTableViewCellH);
    

    self.linView.frame = CGRectMake(0, viewHeight - 1 , viewWidth,1);
}
- (void)setModel:(WSPlanCalendarRouteManageDataInfoModel *)model
{
    _model = model;
    if( _model.leaderId && _model.leaderId.length > 0)
    {
        self.leaderNameLabel.text = _model.leaderName;
        self.leaderNameLabel.hidden = NO;
    }else{
        self.leaderNameLabel.hidden = YES;
    }
    
    self.salesNameLabel.text = _model.salesName;
    self.storeNameLabel.text = _model.storeName;
    
    if([model.flag isEqualToString:@"1"]){
        self.stateLabel.text = @"(已随访)";
        self.stateLabel.textColor = [UIColor greenColor];
    }else{
        self.stateLabel.text = @"(未随访)";
        self.stateLabel.textColor = [UIColor redColor];
    }
}

@end

