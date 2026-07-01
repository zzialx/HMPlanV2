//
//  WSStoreFollowUpTableViewCell.m
//  WinSFA
//
//  Created by 董宏 on 2020/4/22.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSStoreFollowUpTableViewCell.h"

static CGFloat const kStoreFollowUpViewCellX      = 10;
static CGFloat const kStoreFollowUpViewCellY      = 10;
static CGFloat const kStoreFollowUpViewCellLabelH  = 15;
static CGFloat const kStoreFollowUpViewCellBtnH   = 25;



@interface WSStoreFollowUpTableViewCell ()

@property (nonatomic, strong) UILabel *superiorEmpNameLabel;
@property (nonatomic, strong) UILabel *empNameLabel;
@property (nonatomic, strong) UILabel *storeNameLabel;
@property (nonatomic, strong) UILabel *storeAddrLabel;
@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) UILabel *endTimeLabel;
@property (nonatomic, strong) UIButton *modifyBtn;
@property (nonatomic, strong) UIButton *undoBtn;
@property (nonatomic, strong) UIView *linView;

@end

@implementation WSStoreFollowUpTableViewCell

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
    superiorEmpNameLabel.text =  @"随访主管：主管1";
    
    UILabel *empNameLabel = [[UILabel alloc] init];
    empNameLabel.font =  [UIFont systemFontOfSize:15];
    empNameLabel.textColor = [UIColor colorWithHexString:@"c4c4c4"];
    [empNameLabel setText:@"随访下属：代表1"];
    
    UILabel *storeNameLabel = [[UILabel alloc] init];
    storeNameLabel.font =  [UIFont systemFontOfSize:15];
    storeNameLabel.textColor = [UIColor blackColor];
    [storeNameLabel setText:@"随访客户：阳光大药房"];
    
    UILabel *storeAddrLabel = [[UILabel alloc] init];
    storeAddrLabel.font =  [UIFont systemFontOfSize:15];
    storeAddrLabel.textColor = [UIColor colorWithHexString:@"c4c4c4"];
    [storeAddrLabel setText:@"地址"];
 
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.image = [UIImage imageNamed:@"detailAddr"];
    
    
    UILabel *endTimeLabel = [[UILabel alloc] init];
    endTimeLabel.font =  [UIFont systemFontOfSize:15];
    endTimeLabel.textColor = [UIColor blackColor];
    [endTimeLabel setText:@"已随访 结束时间：14:05"];
    endTimeLabel.textAlignment = NSTextAlignmentRight;
    
    UIButton *modifyBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [modifyBtn setTitle:@"开始随访" forState:UIControlStateNormal];
    
    [modifyBtn setTintColor:[UIColor orangeColor]];
    
    modifyBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    [modifyBtn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchUpInside];
    
    modifyBtn.layer.cornerRadius = 4.0;
    modifyBtn.layer.borderColor = [UIColor orangeColor].CGColor;
    modifyBtn.layer.borderWidth = 1.0f;
    modifyBtn.hidden = YES;

    
    UIButton *undoBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [undoBtn setTitle:@"取消随访" forState:UIControlStateNormal];
    
    [undoBtn setTintColor:[UIColor colorWithHexString:@"c4c4c4"]];
    
    undoBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    [undoBtn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchUpInside];
    
    undoBtn.layer.cornerRadius = 4.0;
    undoBtn.layer.borderColor = [UIColor colorWithHexString:@"c4c4c4"].CGColor;
    undoBtn.layer.borderWidth = 1.0f;
    undoBtn.hidden = YES;
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:@"c4c4c4"];
    
    [self.contentView addSubview:superiorEmpNameLabel];
    [self.contentView addSubview:empNameLabel];
    [self.contentView addSubview:storeNameLabel];
    [self.contentView addSubview:storeAddrLabel];
    [self.contentView addSubview:imgView];
    [self.contentView addSubview:endTimeLabel];
    [self.contentView addSubview:modifyBtn];
    [self.contentView addSubview:undoBtn];
    [self.contentView addSubview:view];
    
    
    
    self.superiorEmpNameLabel = superiorEmpNameLabel;
    self.empNameLabel = empNameLabel;
    self.storeNameLabel = storeNameLabel;
    self.storeAddrLabel = storeAddrLabel;
    self.imgView = imgView;
    self.endTimeLabel = endTimeLabel;
    self.modifyBtn = modifyBtn;
    self.undoBtn = undoBtn;
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
    self.imgView.frame = CGRectMake(paddingX, CGRectGetMaxY(self.storeNameLabel.frame)  + paddingY, kStoreFollowUpViewCellLabelH, kStoreFollowUpViewCellLabelH);
    
    self.storeAddrLabel.frame = CGRectMake(CGRectGetMaxX(self.imgView.frame) + 5 , CGRectGetMaxY(self.storeNameLabel.frame)  + paddingY, viewWidth, kStoreFollowUpViewCellLabelH);
    
    self.endTimeLabel.frame = CGRectMake(viewWidth - paddingX - viewWidth/5*4, CGRectGetMaxY(self.storeAddrLabel.frame)  + 2 * paddingY, viewWidth/5*4, kStoreFollowUpViewCellLabelH);
    
    self.undoBtn.frame = CGRectMake(viewWidth - paddingX - 70, CGRectGetMaxY(self.storeAddrLabel.frame) + paddingY, 70, kStoreFollowUpViewCellBtnH);
    
    self.modifyBtn.frame = CGRectMake(self.undoBtn.frame.origin.x - paddingX - 70, CGRectGetMaxY(self.storeAddrLabel.frame) + paddingY, 70, kStoreFollowUpViewCellBtnH);
    
    self.linView.frame = CGRectMake(0, CGRectGetMaxY(self.endTimeLabel.frame) - 1 + paddingY, viewWidth - paddingX, 1);
    
    
}

- (void)setModel:(WSStoreFollowUpInfoDataModel *)model
{
    _model = model;
   if(model.superiorEmpName){
       self.superiorEmpNameLabel.text = [NSString stringWithFormat:@"随访主管：%@",model.superiorEmpName];
       self.superiorEmpNameLabel.hidden = NO;
   }
   else{
       self.superiorEmpNameLabel.hidden = YES;
   }
    self.empNameLabel.text = [NSString stringWithFormat:@"随访下属：%@",model.empName];
    self.storeNameLabel.text = [NSString stringWithFormat:@"随访客户：%@",model.storeName];
    self.storeAddrLabel.text = model.storeAddr;

    if([model.state isEqualToString:@"2"]){
        self.endTimeLabel.text = [NSString stringWithFormat:@"已随访  结束时间 %@",model.endTime];
        self.endTimeLabel.hidden = NO;
        self.undoBtn.hidden = YES;
        self.modifyBtn.hidden = YES;

    }else{
        self.endTimeLabel.hidden = YES;
        self.undoBtn.hidden = NO;
        self.modifyBtn.hidden = NO;
        if ([model.state isEqualToString:@"1"]) {
            [self.modifyBtn setTitle:@"随访中" forState:UIControlStateNormal];
        }
    }
}
- (void)btnDown:(UIButton*)btn
{
    if(btn==self.modifyBtn)
    {
        if (self.followUpTableViewCellDelegate && [self.followUpTableViewCellDelegate respondsToSelector:@selector(btnDownFollowUpDelegate:)]) {
            [self.followUpTableViewCellDelegate btnDownFollowUpDelegate:self.indexPath];
        }
    }else{
        if ([_model.state isEqualToString:@"1"]) {
            return;
        }
        if (self.followUpTableViewCellDelegate && [self.followUpTableViewCellDelegate respondsToSelector:@selector(btnDownCancelFollowUpDelegate:)]) {
            [self.followUpTableViewCellDelegate btnDownCancelFollowUpDelegate:self.indexPath];
        }
    }
}
@end
