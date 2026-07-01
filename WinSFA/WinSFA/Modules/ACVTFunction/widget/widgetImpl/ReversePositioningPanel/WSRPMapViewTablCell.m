//
//  WSRPMapViewTablCell.m
//  WinSFA
//
//  Created by mac on 17/4/21.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSRPMapViewTablCell.h"
#import "PureLayout.h"
#import "NSString+Additions.h"
#define MAIN_TITLE_FONT 16.0f
#define SUB_TITLE_FONT 12.0f
#define WIDTH  SCREEN_WIDTH - 80 - MAIN_CELL_PADDING - MAIN_PADDING * 0.5
@interface WSRPMapViewTablCell (){
    NSLayoutConstraint * mainTitleHeight;
    NSLayoutConstraint * subTitleHeight;
}
@property(nonatomic,strong)UILabel * mainTitleLabel;    // 主标题
@property (nonatomic , strong) UILabel * subTitleLabel; // 副标题
@property (nonatomic , strong) UIButton * distanceButton; // 选中/显示距离
@property (nonatomic , strong) UIImageView * distanceImgView; // button 下面的距离显示

@end

@implementation WSRPMapViewTablCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpSubViews];
    }
    return self;
}

-(void)setUpSubViews{
    
    _mainTitleLabel = [UILabel newAutoLayoutView];
    _mainTitleLabel.numberOfLines = 0;
    _mainTitleLabel.textColor = [UIColor colorWithHexString:@"009cff"];
    _mainTitleLabel.font = [UIFont systemFontOfSize:MAIN_TITLE_FONT];
    _subTitleLabel = [UILabel newAutoLayoutView];
    _subTitleLabel.numberOfLines = 0;
    _subTitleLabel.textColor = [UIColor colorWithHexString:@"969696"];

    _subTitleLabel.font = [UIFont systemFontOfSize:SUB_TITLE_FONT];

    _distanceButton = [UIButton newAutoLayoutView];
    _distanceButton.userInteractionEnabled = NO;
    _distanceButton.titleLabel.font = [UIFont systemFontOfSize:SUB_TITLE_FONT];
    _distanceButton.titleLabel.textColor = [UIColor colorWithHexString:@"969696"];
    [_distanceButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_distanceButton setImage:[UIImage imageNamed:@"icon_yibaifang"] forState:UIControlStateSelected];

    _distanceImgView  = [UIImageView newAutoLayoutView];
    _distanceImgView.image = [UIImage imageNamed:@"distance_img"];
    _distanceImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_mainTitleLabel];
    [self.contentView addSubview:_subTitleLabel];
    [self.contentView addSubview:_distanceButton];
    [self.contentView addSubview:_distanceImgView];

    [_mainTitleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:MAIN_CELL_PADDING];
    [_mainTitleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:MAIN_PADDING];
    [_mainTitleLabel autoSetDimension:ALDimensionWidth toSize:WIDTH];
    mainTitleHeight = [_mainTitleLabel autoSetDimension:ALDimensionHeight toSize:20];

    [_subTitleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_mainTitleLabel withOffset:6];
    [_subTitleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:_mainTitleLabel];
    [_subTitleLabel autoSetDimension:ALDimensionWidth toSize:WIDTH];
    subTitleHeight = [_subTitleLabel autoSetDimension:ALDimensionHeight toSize:20];
    [_distanceButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:-MAIN_PADDING * 0.5];
    [_distanceButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [_distanceButton autoSetDimension:ALDimensionWidth toSize:80];
    [_distanceButton autoSetDimension:ALDimensionHeight toSize:30];
    
    [_distanceImgView autoAlignAxis:ALAxisVertical toSameAxisOfView:_distanceButton];
    [_distanceImgView autoSetDimension:ALDimensionWidth toSize:30];
    [_distanceImgView autoSetDimension:ALDimensionHeight toSize:5];
    [_distanceImgView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_distanceButton];
}
- (void)setStore:(WSStoreBean *)store
{
    CGSize mainSize = [store.name ws_sizeWithFont:[UIFont systemFontOfSize:MAIN_TITLE_FONT] constrainedToWidth:WIDTH];
    [mainTitleHeight autoRemove];
    mainTitleHeight = [_mainTitleLabel autoSetDimension:ALDimensionHeight toSize:mainSize.height];
    
    CGSize subSize = [store.addr ws_sizeWithFont:[UIFont systemFontOfSize:SUB_TITLE_FONT] constrainedToWidth:WIDTH];
    [subTitleHeight autoRemove];
    subTitleHeight = [_subTitleLabel autoSetDimension:ALDimensionHeight toSize:subSize.height];
    //    donghong  YIHAIKERRY-2667 在超过1000米换公里
    NSString *distance =  [NSString stringWithFormat:@"%@米",store.distance];
    if([store.distance integerValue] > 1000)
    {
        distance = [NSString stringWithFormat:@"%ld公里",[store.distance integerValue]/1000];
    }
    [_distanceButton setTitle:distance forState:UIControlStateNormal];
    [_distanceButton setTitle:@"" forState:UIControlStateSelected];
    _mainTitleLabel.text = store.name;
    _subTitleLabel.text  = store.addr;
}
-(void)setModelPOI:(AMapPOI *)modelPOI{
    _modelPOI = modelPOI;
    
    CGSize mainSize = [modelPOI.name ws_sizeWithFont:[UIFont systemFontOfSize:MAIN_TITLE_FONT] constrainedToWidth:WIDTH];
    [mainTitleHeight autoRemove];
    mainTitleHeight = [_mainTitleLabel autoSetDimension:ALDimensionHeight toSize:mainSize.height];

    CGSize subSize = [modelPOI.address ws_sizeWithFont:[UIFont systemFontOfSize:SUB_TITLE_FONT] constrainedToWidth:WIDTH];
    [subTitleHeight autoRemove];
    subTitleHeight = [_subTitleLabel autoSetDimension:ALDimensionHeight toSize:subSize.height];
//    donghong  YIHAIKERRY-2667 在超过1000米换公里
    NSString *distance =  [NSString stringWithFormat:@"%lu米",(long)modelPOI.distance];
    if(modelPOI.distance > 1000)
    {
        distance = [NSString stringWithFormat:@"%lu公里",(long)modelPOI.distance/1000];
    }
    [_distanceButton setTitle:distance forState:UIControlStateNormal];
     [_distanceButton setTitle:@"" forState:UIControlStateSelected];
    _mainTitleLabel.text = modelPOI.name;
    _subTitleLabel.text  = modelPOI.address;
}

-(void)setIsSelect:(BOOL)isSelect{
    _distanceButton.selected = isSelect;
    _distanceImgView.hidden = isSelect;

}

+(CGFloat)heightForcell:(AMapPOI *)POI{
    
    CGSize mainSize = [POI.name ws_sizeWithFont:[UIFont systemFontOfSize:MAIN_TITLE_FONT] constrainedToWidth:WIDTH];
    CGSize subSize = [POI.address ws_sizeWithFont:[UIFont systemFontOfSize:SUB_TITLE_FONT] constrainedToWidth:WIDTH];
    return mainSize.height + subSize.height + 2 * MAIN_PADDING + 6;
}
+(CGFloat)heightForcellStore:(WSStoreBean *)store{
    
    CGSize mainSize = [store.name ws_sizeWithFont:[UIFont systemFontOfSize:MAIN_TITLE_FONT] constrainedToWidth:WIDTH];
    CGSize subSize = [store.addr ws_sizeWithFont:[UIFont systemFontOfSize:SUB_TITLE_FONT] constrainedToWidth:WIDTH];
    return mainSize.height + subSize.height + 2 * MAIN_PADDING + 6;
}
@end
