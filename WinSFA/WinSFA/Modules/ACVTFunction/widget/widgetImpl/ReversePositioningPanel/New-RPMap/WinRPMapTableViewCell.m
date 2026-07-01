//
//  WinRPMapTableViewCell.m
//  WinSFA
//
//  Created by yuanji on 2019/7/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WinRPMapTableViewCell.h"
#import "WinRPMapPOI.h"
//=================================================================================================================================

#pragma mark - RP地图表视图单元格 延展(内部)
@interface WinRPMapTableViewCell ()

@property (nonatomic, assign) BOOL isSelectState; //是否选中状态

@end
//=================================================================================================================================

#pragma mark - RP地图表视图单元格 延展(工具)
@interface WinRPMapTableViewCell (Tools)

- (void)layoutCell; //布局单元格方法

@end
//=================================================================================================================================

#pragma mark - RP地图表视图单元格
@implementation WinRPMapTableViewCell

#pragma mark - 获取mainTitleLabel方法
- (UILabel *)mainTitleLabel {
    
    if (!_mainTitleLabel) {
        _mainTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _mainTitleLabel.backgroundColor = [UIColor clearColor];
        _mainTitleLabel.textAlignment = NSTextAlignmentLeft;
        _mainTitleLabel.font = [UIFont systemFontOfSize:16.0f];
        _mainTitleLabel.textColor = [UIColor colorWithHexString:@"009cff"];
        _mainTitleLabel.numberOfLines = 0;
    }
    return _mainTitleLabel;
}

#pragma mark - 获取subTitleLabel方法
- (UILabel *)subTitleLabel {
    
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subTitleLabel.backgroundColor = [UIColor clearColor];
        _subTitleLabel.textAlignment = NSTextAlignmentLeft;
        _subTitleLabel.font = [UIFont systemFontOfSize:12.0f];
        _subTitleLabel.textColor = [UIColor colorWithHexString:@"969696"];
        _subTitleLabel.numberOfLines = 0;
    }
    return _subTitleLabel;
}

#pragma mark - 获取distanceTitleLabel方法
- (UILabel *)distanceTitleLabel {
    
    if (!_distanceTitleLabel) {
        _distanceTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _distanceTitleLabel.backgroundColor = [UIColor clearColor];
        _distanceTitleLabel.textAlignment = NSTextAlignmentCenter;
        _distanceTitleLabel.font = [UIFont systemFontOfSize:12.0f];
        _distanceTitleLabel.textColor = [UIColor grayColor];
        _distanceTitleLabel.numberOfLines = 0;
    }
    return _distanceTitleLabel;
}

#pragma mark - 获取distanceImgView方法
- (UIImageView *)distanceImgView {
    
    if (!_distanceImgView) {
        _distanceImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _distanceImgView.backgroundColor = [UIColor clearColor];
        _distanceImgView.contentMode = UIViewContentModeScaleAspectFit;
        _distanceImgView.clipsToBounds = YES;
        _distanceImgView.image = [UIImage imageNamed:@"distance_img"];
    }
    return _distanceImgView;
}

#pragma mark - 获取selectImgView方法
- (UIImageView *)selectImgView {
    
    if (!_selectImgView) {
        _selectImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _selectImgView.backgroundColor = [UIColor clearColor];
        _selectImgView.contentMode = UIViewContentModeScaleAspectFit;
        _selectImgView.clipsToBounds = YES;
        _selectImgView.image = [UIImage imageNamed:@"icon_yibaifang"];
        _selectImgView.hidden = YES;
    }
    return _selectImgView;
}

#pragma mark - 重写initWithStyle:reuseIdentifier:方法
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.mainTitleLabel];
        [self.contentView addSubview:self.subTitleLabel];
        [self.contentView addSubview:self.distanceTitleLabel];
        [self.contentView addSubview:self.distanceImgView];
        [self.contentView addSubview:self.selectImgView];
    }
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self layoutCell];
}

#pragma mark - 获取单元格高度方法
+ (CGFloat)getCellHeightWithTableView:(UITableView *)tableView data:(WinRPMapPOI *)data {
    
    CGFloat space = 10.0f;
    CGFloat rightMaxWidth = 80.0f;
    CGFloat textMaxWidth = CGRectGetWidth(tableView.frame) - (space * 3) - rightMaxWidth;
    
    NSString *mainTitle = (data.name.length > 0 ? data.name : @" ");
    NSString *subTitle = (data.address.length > 0 ? data.address : @" ");
    CGSize mainTitleSize = [mainTitle ws_sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToWidth:textMaxWidth];
    CGSize subTitleSize = [subTitle ws_sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToWidth:textMaxWidth];
    
    CGFloat textHeight = mainTitleSize.height + (space / 2) + subTitleSize.height;
    CGFloat allHeight = textHeight + (space * 2);
    return allHeight;
}

#pragma mark - 设置单元格数据方法
- (void)setCellData:(WinRPMapPOI *)data isSelectState:(BOOL)isSelectState {
    
    self.mainTitleLabel.text = data.name;
    self.subTitleLabel.text = data.address;
    self.distanceTitleLabel.text = data.distance;
    self.isSelectState = isSelectState;
    
    if (isSelectState) {
        self.distanceTitleLabel.hidden = YES;
        self.distanceImgView.hidden = YES;
        self.selectImgView.hidden = NO;
    } else {
        self.distanceTitleLabel.hidden = NO;
        self.distanceImgView.hidden = NO;
        self.selectImgView.hidden = YES;
    }
    
    [self setNeedsLayout];
}

@end
//=================================================================================================================================

#pragma mark - RP地图表视图单元格 延展(工具)
@implementation WinRPMapTableViewCell (Tools)

#pragma mark - 布局单元格方法
- (void)layoutCell {
    
    CGFloat space = 10.0f;
    CGFloat rightMaxWidth = 80.0f;
    CGFloat textMaxWidth = CGRectGetWidth(self.contentView.frame) - (space * 3) - rightMaxWidth;
    NSString *mainTitle = (self.mainTitleLabel.text.length > 0 ? self.mainTitleLabel.text : @" ");
    NSString *subTitle = (self.subTitleLabel.text.length > 0 ? self.subTitleLabel.text : @" ");
    CGSize mainTitleSize = [mainTitle ws_sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToWidth:textMaxWidth];
    CGSize subTitleSize = [subTitle ws_sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToWidth:textMaxWidth];
    CGFloat textHeight = mainTitleSize.height + (space / 2) + subTitleSize.height;
    CGFloat allHeight = textHeight + (space * 2);
    
    CGFloat x = space;
    CGFloat y = space;
    CGFloat w = mainTitleSize.width;
    CGFloat h = mainTitleSize.height;
    self.mainTitleLabel.frame = CGRectMake(x, y, w, h);
    
    x = space;
    y = CGRectGetMaxY(self.mainTitleLabel.frame) + (space / 2);
    w = subTitleSize.width;
    h = subTitleSize.height;
    self.subTitleLabel.frame = CGRectMake(x, y, w, h);
    
    if (self.isSelectState) {
        UIImage *selectImage = [UIImage imageNamed:@"icon_yibaifang"];
        CGFloat offsetX = (rightMaxWidth - selectImage.size.width) / 2;
        x = CGRectGetWidth(self.contentView.frame) - space - rightMaxWidth + offsetX;
        y = (allHeight - selectImage.size.height) / 2;
        w = selectImage.size.width;
        h = selectImage.size.height;
        self.selectImgView.frame = CGRectMake(x, y, w, h);
        
        self.distanceTitleLabel.frame = CGRectZero;
        self.distanceImgView.frame = CGRectZero;
    } else {
        NSString *distanceTitle = (self.distanceTitleLabel.text.length > 0 ? self.distanceTitleLabel.text : @" ");
        CGSize distanceTitleSize = [distanceTitle ws_sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToWidth:rightMaxWidth];
        UIImage *distanceImage = [UIImage imageNamed:@"distance_img"];
        CGFloat height = distanceTitleSize.height + distanceImage.size.height + (space / 2);
        
        CGFloat offsetX = (rightMaxWidth - distanceTitleSize.width) / 2;
        x = CGRectGetWidth(self.contentView.frame) - space - rightMaxWidth + offsetX;
        y = (allHeight - height) / 2;
        w = distanceTitleSize.width;
        h = distanceTitleSize.height;
        self.distanceTitleLabel.frame = CGRectMake(x, y, w, h);
        
        offsetX = (rightMaxWidth - distanceImage.size.width) / 2;
        x = CGRectGetWidth(self.contentView.frame) - space - rightMaxWidth + offsetX;
        y = CGRectGetMaxY(self.distanceTitleLabel.frame) + (space / 2);
        w = distanceImage.size.width;
        h = distanceImage.size.height;
        self.distanceImgView.frame = CGRectMake(x, y, w, h);
        
        self.selectImgView.frame = CGRectZero;
    }
}

@end
//=================================================================================================================================

