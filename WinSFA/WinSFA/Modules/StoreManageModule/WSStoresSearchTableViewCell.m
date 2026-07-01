//
//  WSStoresSearchTableViewCell.m
//  WinSFA
//
//  Created by 董宏 on 2019/12/14.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSStoresSearchTableViewCell.h"
#import "WSStoresSearchDataModel.h"

static CGFloat const kStoresSearchViewCellX      = 10;
static CGFloat const kStoresSearchViewCellY      = 10;
static CGFloat const kStoresSearchViewCellLabelH    = 15;




@interface WSStoresSearchTableViewCell ()
@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *addLabel;
@property (nonatomic, strong) UILabel *levelLabel;//等级
@property (nonatomic, strong) UILabel *empNameLabel;
@property (nonatomic, strong) UIView *linLableView;
@property (nonatomic, strong) UIImageView *imageBlack;


@end

@implementation WSStoresSearchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addControls];
    }
    return self;
}

- (void)addControls {
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *codeLabel = [[UILabel alloc] init];
    codeLabel.font = [UIFont systemFontOfSize:15];
    codeLabel.textColor = [UIColor blackColor];
    codeLabel.text =  @"6666666";
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.text =  @"路线：15";
    
    UILabel *addLabel = [[UILabel alloc] init];
    addLabel.font =  [UIFont systemFontOfSize:15];
    addLabel.textColor = [UIColor colorWithHexString:@"c4c4c4"];
    [addLabel setText:@"地址：12"];
    
    UILabel *levelLabel = [[UILabel alloc] init];
    levelLabel.font =  [UIFont systemFontOfSize:15];
    levelLabel.textColor = [UIColor colorWithHexString:@"c4c4c4"];
    [levelLabel setText:@"申请时间：2019-13-09"];
    
    UILabel *empNameLabel = [[UILabel alloc] init];
    empNameLabel.font =  [UIFont systemFontOfSize:15];
    empNameLabel.textColor = [UIColor colorWithHexString:@"c4c4c4"];
    [empNameLabel setText:@"变更类型：合并"];
    
    UIImageView *img = [[UIImageView alloc] init];
    [img setImage:[UIImage imageNamed:@"right_arrow"]];//  forward_black_check
    
    
    
    UIView *linLableView = [[UIView alloc] init];
    linLableView.backgroundColor = [UIColor colorWithHexString:@"c4c4c4"];
    
    [self.contentView addSubview:codeLabel];
    [self.contentView addSubview:nameLabel];
    [self.contentView addSubview:addLabel];
    [self.contentView addSubview:levelLabel];
    [self.contentView addSubview:empNameLabel];
    [self.contentView addSubview:img];
    [self.contentView addSubview:linLableView];
    
    self.nameLabel = nameLabel;
    self.addLabel = addLabel;
    self.codeLabel = codeLabel;
    self.levelLabel = levelLabel;
    self.empNameLabel = empNameLabel;
    self.imageBlack = img;
    self.linLableView = linLableView;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutControls];
}

- (void)layoutControls {
    
    CGFloat paddingX = kStoresSearchViewCellX;
    CGFloat paddingY = kStoresSearchViewCellY;
    CGFloat viewWidth = self.frame.size.width;
    CGFloat viewHeight = self.frame.size.height;
    
    self.codeLabel.frame = CGRectMake(paddingX, paddingY, viewWidth/4*3, kStoresSearchViewCellLabelH);

    self.nameLabel.frame = CGRectMake(paddingX, CGRectGetMaxY(self.codeLabel.frame) + paddingY, viewWidth - 2*paddingX, kStoresSearchViewCellLabelH);
    
    self.addLabel.frame = CGRectMake(paddingX, CGRectGetMaxY(self.nameLabel.frame) + paddingY, viewWidth - 2*paddingX, kStoresSearchViewCellLabelH);
    
    self.levelLabel.frame = CGRectMake(paddingX, CGRectGetMaxY(self.addLabel.frame)  + paddingY, viewWidth - 2*paddingX, kStoresSearchViewCellLabelH);
    
    self.empNameLabel.frame = CGRectMake(paddingX, CGRectGetMaxY(self.levelLabel.frame)  + paddingY, viewWidth - 2*paddingX, kStoresSearchViewCellLabelH);
    
    self.imageBlack.frame = CGRectMake(viewWidth - paddingX -  kStoresSearchViewCellLabelH, (viewHeight -  kStoresSearchViewCellLabelH)/2, kStoresSearchViewCellLabelH, kStoresSearchViewCellLabelH);
    
    self.linLableView.frame = CGRectMake(0,   viewHeight - 1 , viewWidth - paddingX, 1);
 
}

- (void)setModel:(WSStoresSearchDataInfoModel *)model
{
    _model = model;
    self.codeLabel.text = _model.code;
    self.nameLabel.text = _model.name;
    self.addLabel.text = [NSString stringWithFormat:@"地址:%@",_model.addr];
    self.levelLabel.text = [NSString stringWithFormat:@"等级:%@",[NSString stringNotNilWithValue:_model.lvlcode]];
    self.empNameLabel.text = [NSString stringWithFormat:@"业代:%@",[NSString stringNotNilWithValue:_model.empName]];
    if ([_model.cpyCode isEqualToString:@"0"]) {
        self.imageBlack.hidden = YES;
    }else{
        self.imageBlack.hidden = NO;
    }
}

@end

