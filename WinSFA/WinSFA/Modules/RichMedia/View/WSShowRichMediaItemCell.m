//
//  WSShowRichMediaItemCell.m
//  WinSFA
//
//  Created by mac on 16/9/27.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSShowRichMediaItemCell.h"
#import "PureLayout.h"
#import "WSRequestHelper.h"

#define CACHE_DIR [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface WSShowRichMediaItemCell ()
{
    UIImageView * _iconImageView;
    UILabel * _detailLable;
    UIImageView * _jiaobiaoImageView;
}

@end


@implementation WSShowRichMediaItemCell
-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        [self setupSubViews];
    }
    
    return self;
}

-(void)setupSubViews{
    
    _iconImageView = [[UIImageView alloc]init];
    _jiaobiaoImageView = [[UIImageView alloc]init];
    _detailLable = [[UILabel alloc]init];
    _detailLable.numberOfLines = 2;
    _detailLable.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_iconImageView];
    [self addSubview:_jiaobiaoImageView];
    [self addSubview:_detailLable];
    _detailLable.backgroundColor = [UIColor whiteColor];
    [_iconImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
    [_iconImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self withMultiplier:0.8];
    [_detailLable autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeTop];
    [_detailLable autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self withMultiplier:0.2];
    
    [_jiaobiaoImageView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [_jiaobiaoImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [_jiaobiaoImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:_iconImageView withMultiplier:0.3];
    [_jiaobiaoImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:_iconImageView withMultiplier:0.3];
    _jiaobiaoImageView.image = [UIImage imageNamed:@"zx@2X.png"];

    [self bringSubviewToFront:_jiaobiaoImageView];
}

-(void)setModel:(WSRichItemModel *)model{
    _model = model;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSURL *url = [[manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *imgStr2 = [NSString stringWithFormat:@"richMedia/%@/sort-0.png",model.img_add];
    
    NSURL *path = [url URLByAppendingPathComponent:imgStr2];
    
    [[WSRequestHelper shareInstance] downloadImageWithUrl:[path absoluteString] imageView:_iconImageView placeholderImage:[UIImage imageNamed:@"sort-0"]];
    
    _detailLable.text = model.name;
    if ([model.isread isEqualToString:@"1"] || model.h5_add.length ==0 ) {
        
        _jiaobiaoImageView.hidden = YES;
    }else{
        _jiaobiaoImageView.hidden = NO;
        
    }
    
}
@end
