//
//  WSOutlinkCell.m
//  WinSFA
//
//  Created by huzepei on 16/7/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSOutlinkCell.h"
#import "PureLayout.h"
#import "WSRequestHelper.h"

@interface WSOutlinkCell()

@property (nonatomic,strong) UIImageView *ocimageView;
@property (nonatomic,strong) UILabel *ocLabel;

@end

@implementation WSOutlinkCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        
        [self initViews];
    }
    return self;
}
-(void)initViews
{
    _ocimageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_ocimageView];
    
    _ocLabel = [[UILabel alloc] init];
    _ocLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:_ocLabel];
    
    ALEdgeInsets defInsets = ALEdgeInsetsMake(10.0,26.0,10.0,0.0);
    [_ocimageView autoPinEdgesToSuperviewEdgesWithInsets:defInsets excludingEdge:ALEdgeRight];
    
    [_ocimageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView  withMultiplier:0.3 relation:NSLayoutRelationEqual];
    
    [_ocLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [_ocLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_ocimageView withOffset:20.0];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

-(void)setOm:(WSOutlinkModel *)om
{
    _om = om;
    [[WSRequestHelper shareInstance] downloadImageWithUrl:_om.imageStr imageView:_ocimageView];
     _ocLabel.text = _om.titleName;
}

@end
