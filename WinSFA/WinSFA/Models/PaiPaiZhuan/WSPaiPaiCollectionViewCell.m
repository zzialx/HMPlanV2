//
//  WSPaiPaiCollectionViewCell.m
//  WinSFA
//
//  Created by zhangmin on 2019/12/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSPaiPaiCollectionViewCell.h"
//=====================================================================================================================

@interface WSPaiPaiCollectionViewCell()

@property (nonatomic, strong) UILabel *titleLabel;          //名称
@property (nonatomic, strong) UILabel *photoCountLabel;     //数量
@property (nonatomic, strong) UILabel *photoLog;            //图片单位 张
@property (nonatomic, strong) UILabel *fillLog;             //必填标示
@property (nonatomic, strong) UIImageView *coverImageView;  //遮盖视图

@end
//=====================================================================================================================

@implementation WSPaiPaiCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    
    self.bgIcon = [[UIImageView alloc] init];
    self.coverImageView = [[UIImageView alloc] init];
    self.titleLabel = [[UILabel alloc] init];
    self.photoCountLabel = [[UILabel alloc] init];
    self.photoLog = [[UILabel alloc] init];
    self.fillLog = [[UILabel alloc] init];
    
    [self.contentView addSubview:self.bgIcon];
    [self.contentView addSubview:self.coverImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.photoCountLabel];
    [self.contentView addSubview:self.photoLog];
    [self.contentView addSubview:self.fillLog];
    
    [self.bgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5);
        make.left.equalTo(self).offset(5);
        make.right.equalTo(self.mas_right).offset(-5);
    }];
    
    [self.photoCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(5);
        make.bottom.equalTo(self.mas_bottom).offset(-5);
    }];
    
    [self.photoLog mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.photoCountLabel.mas_right).offset(1);
        make.bottom.equalTo(self.photoCountLabel.mas_bottom).offset(-3);
    }];
    
    [self.fillLog mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-15);
        make.centerY.equalTo(self.photoCountLabel.mas_centerY);
    }];
    
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont systemFontOfSize:11];
    self.photoCountLabel.font = [UIFont systemFontOfSize:22];
    self.photoLog.font = [UIFont systemFontOfSize:10];
    self.fillLog.font = [UIFont systemFontOfSize:13];
    self.fillLog.textColor = [UIColor redColor];
}

- (void)setModel:(WSAcvtListDataItem *)model {
    
    _model = model;
    self.titleLabel.text = model.mainTitle;
    if (model.rightTitle) {
        NSInteger count = model.rightTitle.integerValue;
        if (count < 0) {
            self.photoCountLabel.text = @"00";
        } else if (count < 10) {
            self.photoCountLabel.text = [NSString stringWithFormat:@"0%@", model.rightTitle];
        } else {
            self.photoCountLabel.text = model.rightTitle;
        }
    } else {
        self.photoCountLabel.text = @"00";
    }
    
    self.photoLog.text = @"张";
    self.fillLog.text = model.requiredLogo;
}

- (void)setViewColorWithIndex:(NSInteger)index {
    
    NSString *colorString = nil;
    switch (index) {
        case 1:
            colorString = @"#BDA275";
            break;
        case 2:
            colorString = @"#FF9144";
            break;
        case 3:
            colorString = @"#489EFF";
            break;
        case 4:
            colorString = @"#E78FBB";
            break;
        case 5:
            colorString = @"#73AD36";
            break;
        default:
            break;
    }
    
    NSString *imageName = [NSString stringWithFormat:@"infobg%ld", (long)index];
    self.bgIcon.image = [UIImage imageNamed:imageName];
    
    self.coverImageView.image = [UIImage imageNamed:@"infoCoverbg"];
    NSInteger count = [self.model.rightTitle integerValue];
    self.coverImageView.hidden = (count > 0) ? NO : YES;
    if (count==-99) {
        self.coverImageView.hidden = NO;
    }
    self.titleLabel.textColor = [UIColor colorWithHexString:colorString];
    self.photoCountLabel.textColor = [UIColor colorWithHexString:colorString];
    self.photoLog.textColor = [UIColor colorWithHexString:colorString];
}

@end
//=====================================================================================================================
