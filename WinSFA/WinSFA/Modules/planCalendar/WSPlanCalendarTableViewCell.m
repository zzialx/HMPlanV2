//
//  WSPlanCalendarTableViewCell.m
//  WinSFA
//
//  Created by 董宏 on 2020/4/27.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSPlanCalendarTableViewCell.h"
#import "WSPlanCalendarDataModel.h"
#import <Masonry.h>

static CGFloat const kStoreRouteViewCellX      = 10;
static CGFloat const kStoreRouteViewCellY      = 12.5;
static CGFloat const kStoreRouteViewCellLabelH      = 15;



@interface WSPlanCalendarTableViewCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *setBtn;
@property (nonatomic, strong) UIView *linView;

/**
 审批状态
 */
@property (nonatomic, strong) UILabel * approveStateLab;

@end

@implementation WSPlanCalendarTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addControls];
    }
    return self;
}

- (void)addControls {
    
    [self setBackgroundColor:[UIColor whiteColor]];
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.text =  @"路线：15";
    
    UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [setBtn setTitle:@"设置" forState:UIControlStateNormal];
    [setBtn setTintColor:[UIColor blackColor]];
    setBtn.backgroundColor = [UIColor colorWithHexString:@"#31EA00"];
    setBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    setBtn.hidden = YES;
    [setBtn addTarget:self action:@selector(btnDown) forControlEvents:UIControlEventTouchUpInside];
    setBtn.layer.cornerRadius = 4.0;
    setBtn.layer.borderColor = [UIColor clearColor].CGColor;
    setBtn.layer.borderWidth = 1.0f;
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:@"c4c4c4"];
    [self.contentView addSubview:nameLabel];
    [self.contentView addSubview:setBtn];
    [self.contentView addSubview:view];
    
    self.nameLabel = nameLabel;
    self.setBtn = setBtn;
    self.linView = view;
    
    [self approveStateLab];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutControls];
}

- (void)layoutControls {
    
    CGFloat paddingX = kStoreRouteViewCellX;
    CGFloat paddingY = kStoreRouteViewCellY;
    CGFloat viewWidth = self.frame.size.width;
    CGFloat viewHeight = self.frame.size.height;
    
    self.nameLabel.frame = CGRectMake(paddingX, paddingY, viewWidth/4*3, kStoreRouteViewCellLabelH);
    
    self.linView.frame = CGRectMake(0, viewHeight - 1 , viewWidth,1);
    
    self.setBtn.frame = CGRectMake(viewWidth - paddingX - 50, 7.5, 50, 25);
    
    [self.approveStateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(130.0);
        make.height.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_right).offset(-5.0);
        make.top.equalTo(self.contentView.mas_top).offset(0.0);
    }];
    
}
#pragma mark------设置线路名称
- (void)setModel:(WSPlanCalendarRouteDataInfoModel *)model
{
    _model = model;
    self.nameLabel.text = _model.routeName;
    self.approveStateLab.hidden = YES;
}
- (void)setTitle:(NSString *)title
{
    _title = title;
    self.nameLabel.text = title;
    self.setBtn.hidden = YES;
}
#pragma mark - # Public Method 设置考勤审批状态
- (void)setAttanceStateWithApproveState:(NSString*)approveState{
    if(approveState.length>0){
        self.approveStateLab.hidden = NO;
        self.approveStateLab.text = [NSString stringWithFormat:@"审核状态:%@",approveState];
    }
}

- (void)setIsBtn:(BOOL)isBtn
{
    if (isBtn) {
        self.setBtn.hidden = NO;
    }else{
        self.setBtn.hidden = YES;

    }
}
- (void)btnDown
{
    if (self.planCalendarViewCellDelegate && [self.planCalendarViewCellDelegate respondsToSelector:@selector(btnDownViewCell:)]){
        [self.planCalendarViewCellDelegate btnDownViewCell:_model];
    }
}
#pragma mark - # load lazy UI
#pragma mark - # 审核状态
- (UILabel*)approveStateLab{
    if(_approveStateLab==nil){
        _approveStateLab = [[UILabel alloc]init];
        [self.contentView addSubview:_approveStateLab];
        _approveStateLab.font = [UIFont systemFontOfSize:13];
        _approveStateLab.textColor = [UIColor colorWithHexString:@"#31EA00"];
        _approveStateLab.textAlignment = NSTextAlignmentRight;
        _approveStateLab.hidden = YES;
        _approveStateLab.text = @"";
    }
    return _approveStateLab;
}

@end
