//
//  WSRichShowCollectionCell.m
//  WinSFA
//
//  Created by zhiqing on 16/8/28.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRichShowCollectionCell.h"
#import "PureLayout.h"
#import "WSRequestHelper.h"

#define CACHE_DIR [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface WSRichShowCollectionCell ()
{
    UIImageView * _bgImageView;
    UIImageView * _iconImageView;
    UILabel * _detailLable;
    UIImageView * _jiaobiaoImageView;
}

@end

@implementation WSRichShowCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        
        [self setupSubViews];
    }
    
    return self;
}


-(void)setupSubViews{
    
    _bgImageView = [UIImageView newAutoLayoutView];
    _bgImageView.image = [UIImage imageNamed:@"zhantai"];
//    _bgImageView.contentMode = UIViewContentModeScaleAspectFit;

    _iconImageView = [UIImageView newAutoLayoutView];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    _detailLable = [UILabel newAutoLayoutView];
    _detailLable.text = @"及方式方法及附加";
    _detailLable.numberOfLines = 2;
    _detailLable.font = [UIFont systemFontOfSize:13];
    _detailLable.textAlignment = NSTextAlignmentCenter;
    
    _jiaobiaoImageView = [[UIImageView alloc]init];
    _jiaobiaoImageView.contentMode = UIViewContentModeScaleAspectFit;
    _jiaobiaoImageView.image = [UIImage imageNamed:@"zx@2X.png"];
    [self addSubview:_bgImageView];
    [self addSubview:_iconImageView];
    [self addSubview:_detailLable];
    [self addSubview:_jiaobiaoImageView];
    
//    [_bgImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [_bgImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft ];
    [_bgImageView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [_bgImageView autoPinEdgeToSuperviewEdge:ALEdgeTop ];
    [_bgImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [_iconImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 0, 0, 10) excludingEdge:ALEdgeBottom];
    [_iconImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self withMultiplier:0.5];
    
    [_detailLable autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_iconImageView withOffset:20];
    [_detailLable autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [_detailLable autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];

    [_detailLable autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self withMultiplier:0.3];
    
    
    [_jiaobiaoImageView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [_jiaobiaoImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [_jiaobiaoImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:_iconImageView withMultiplier:0.4];
    [_jiaobiaoImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:_iconImageView withMultiplier:0.4];
    [self bringSubviewToFront:_jiaobiaoImageView];
}

-(void)setModel:(WSRichItemModel *)model{
    _model = model;
    
    NSString *imgStr2 = [NSString stringWithFormat:@"richMedia/%@/sort-0.png",model.img_add];
  
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSURL *url = [[manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    
    NSURL *path = [url URLByAppendingPathComponent:imgStr2];
    
    [[WSRequestHelper shareInstance] downloadImageWithUrl:[path absoluteString] imageView:_iconImageView placeholderImage:[UIImage imageNamed:@"sort-0"]];
   
    _detailLable.text = model.name;
    if ([model.isread isEqualToString:@"1"] || model.h5_add.length ==0 ) {
        
        _jiaobiaoImageView.hidden = YES;
    }else{
        _jiaobiaoImageView.hidden = NO;

    }
    
}

-(void)setFontSize:(NSInteger)fontSize{
    
    _detailLable.font = [UIFont systemFontOfSize:fontSize];


}
@end
