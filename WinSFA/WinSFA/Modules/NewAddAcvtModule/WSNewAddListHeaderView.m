//
//  WSNewAddListHeaderView.m
//  WinSFA
//
//  Created by zhaodanyang on 2018/5/14.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSNewAddListHeaderView.h"
#import "WSNewAddAcvtModel.h"
@interface WSNewAddListHeaderView()

@property (nonatomic,strong) UILabel *nameTitleLabel;
@property (nonatomic,strong) UILabel *summaryLabel;
@property (nonatomic,strong) UIButton *unfoldBtn;

@end

@implementation WSNewAddListHeaderView

#pragma mark - 获取nameTitleLabel方法
- (UILabel *)nameTitleLabel{
    if (_nameTitleLabel == nil) {
        _nameTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0 , 0.0, SCREEN_WIDTH/2, self.height)];
        _nameTitleLabel.font = [UIFont systemFontOfSize:14.0f];
        _nameTitleLabel.textColor = [UIColor blackColor];
    }
    return _nameTitleLabel;
}

#pragma mark - 获取summaryLabel方法
- (UILabel *)summaryLabel{
    if (_summaryLabel == nil) {
        _summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameTitleLabel.right , 0.0, SCREEN_WIDTH-self.nameTitleLabel.right-40, self.height)];
        _summaryLabel.font = [UIFont systemFontOfSize:14.0];
        _summaryLabel.textAlignment = NSTextAlignmentRight;
        _summaryLabel.textColor = [UIColor blackColor];
    }
    return _summaryLabel;
}

#pragma mark - 获取unfoldBtn方法
- (UIButton *)unfoldBtn{
    if (_unfoldBtn == nil) {
        _unfoldBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _unfoldBtn.frame = CGRectMake(SCREEN_WIDTH - 40, 0, 40, self.height);
        [_unfoldBtn setImage:[UIImage imageNamed:@"icon_arrow_up"] forState:UIControlStateNormal];
        [_unfoldBtn setImage:[UIImage imageNamed:@"icon_arrow_down"] forState:UIControlStateSelected];
        _unfoldBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_unfoldBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
        [_unfoldBtn addTarget:self action:@selector(unfoldBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _unfoldBtn;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"0xf1f1f1"];
        [self.contentView addSubview:self.nameTitleLabel];
        [self.contentView addSubview:self.summaryLabel];
        [self.contentView addSubview:self.unfoldBtn];
    }
    return self;
}

- (void)setModel:(WSNewAddAcvtModel *)model{
    
//    self.model = model;
    
    self.nameTitleLabel.text = [NSString stringWithFormat:@"%@ (%lu)",self.model.titleStr,(unsigned long)self.model.subModelArray.count];
    //        YIHAIKERRY-1818 董宏
//    CGSize size = [self.nameTitleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(SCREEN_WIDTH/2, self.height) lineBreakMode:NSLineBreakByWordWrapping];
    
    //  YIHAIKERRY-2708    ios7之后sizeWithFont已被废弃
    CGSize size = [self.nameTitleLabel.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH/2, self.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]} context:nil].size;
    
    
    self.nameTitleLabel.frame = CGRectMake(self.nameTitleLabel.frame.origin.x, (self.height-size.height)/2,size.width,size.height);
    
    self.summaryLabel.text = self.model.rightStr;
}

- (void)unfoldBtnDidClick:(UIButton *)unfoldBtn{
    
    WSNewAddAcvtModel *model = self.model;
    WSNewAddAcvtModel *cacheModel = self.model;
    
    UIButton *button = unfoldBtn;
    
    if (!button.selected)
    {
        button.selected = YES;
        [model.subModelArray removeAllObjects];
    }
    else
    {
        unfoldBtn.selected = NO;
        if (model.subModelArray.count)
        {
            [model.subModelArray addObjectsFromArray:cacheModel.subModelArray];
        }
    }
    
    self.model = model;
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(newAddListHeaderView:newAddAcvtModel:)])
    {
        [self.delegate newAddListHeaderView:self newAddAcvtModel:self.model];
    }
}

@end
