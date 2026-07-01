//
//  WSPopStoreDetailMessageView.m
//  WinSFA
//
//  Created by zhiqing on 16/8/24.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSPopStoreDetailMessageView.h"
#import "PureLayout.h"
#import "WSRadioOptView.h"
#import "WSBaseStoreDBService.h"
#define k_View_Width ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 150 : 300)
#define k_View_height ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 60 : 200)
#define k_TitleLable_Height ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 40 : 60)

#define k_BodayView_Space_Margin ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 10 : 15)

@interface WSPopStoreDetailMessageView ()
{
    
    UIView * _bgView;
    UIView * _popView;
    UILabel * _titleLable;
    UIView * _bodayView;
    
    UILabel * _nameLable;
    UILabel * _state;
    UIButton * _stateButton;
    UILabel * _visitType;
    UILabel * _visitTypeImgView;
    UILabel * _visitState;
    UILabel * _exceptionDesc;
    UIButton * _closeButton;
    NSLayoutConstraint  *popViewConstraint;

}
@end

@implementation WSPopStoreDetailMessageView



-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUpSubViews];
    }
    return self;
}


-(void)setUpSubViews{
    _bgView = [UIView newAutoLayoutView];
    _bgView.backgroundColor = [UIColor blackColor];
    _bgView.alpha = 0.6;
    [self addSubview:_bgView];
    [_bgView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
   
     _popView = [UIView newAutoLayoutView];
     _popView.layer.cornerRadius = 8;
     _popView.clipsToBounds = YES;
    [self addSubview:_popView];
   
    [_popView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:k_View_height];
    [_popView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [_popView autoSetDimension:ALDimensionWidth toSize:k_View_Width];

    _titleLable = [UILabel newAutoLayoutView];
    _titleLable.text = @"PJP详细信息";
    _titleLable.textAlignment = NSTextAlignmentCenter;
    _titleLable.backgroundColor = MAIN_TINT_COLOT;
    [_popView addSubview:_titleLable];
    [_titleLable autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [_titleLable autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [_titleLable autoSetDimension:ALDimensionWidth toSize:k_View_Width];
    [_titleLable autoSetDimension:ALDimensionHeight toSize:k_TitleLable_Height];
    
    _bodayView = [UIView newAutoLayoutView];
    _bodayView.backgroundColor = [UIColor whiteColor];

    [_popView addSubview:_bodayView];
    [_bodayView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [_bodayView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_titleLable];
    [_bodayView autoSetDimension:ALDimensionWidth toSize:k_View_Width];
    [_bodayView autoSetDimension:ALDimensionHeight toSize:k_TitleLable_Height * 6];
    _nameLable = [UILabel newAutoLayoutView];
    _state = [UILabel newAutoLayoutView];
    _stateButton = [UIButton newAutoLayoutView];
    [_stateButton addTarget:self action:@selector(prepareStore) forControlEvents:UIControlEventTouchUpInside];
    [_stateButton setTitleColor:MAIN_TINT_COLOT forState:UIControlStateNormal];
    _visitType = [UILabel newAutoLayoutView];
    _visitTypeImgView = [UILabel newAutoLayoutView];
//    _visitTypeImgView.contentMode = UIViewContentModeScaleAspectFit;

    _visitType.text = @"拜访类型:";
    _visitState = [UILabel newAutoLayoutView];
    
    _exceptionDesc = [UILabel newAutoLayoutView];
    _exceptionDesc.text = @"异常描述:";
    _exceptionDesc.numberOfLines = 0;
    _closeButton = [UIButton newAutoLayoutView];
    [_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    _closeButton.backgroundColor = MAIN_TINT_COLOT;
    [_closeButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    
    [_bodayView addSubview:_nameLable];
    [_bodayView addSubview:_state];
    [_bodayView addSubview:_stateButton];
    [_bodayView addSubview:_visitType];
    [_bodayView addSubview:_visitTypeImgView];

    [_bodayView addSubview:_visitState];
    [_bodayView addSubview:_exceptionDesc];
    [_bodayView addSubview:_closeButton];
    
    [_nameLable autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:k_BodayView_Space_Margin];
    [_nameLable autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [_nameLable autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:k_BodayView_Space_Margin];
    [_nameLable autoSetDimension:ALDimensionHeight toSize:k_TitleLable_Height];
    
    [_state autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_nameLable];
    [_state autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:k_BodayView_Space_Margin];
    [_state autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:_bodayView withMultiplier:1 relation:NSLayoutRelationLessThanOrEqual];
    [_state autoSetDimension:ALDimensionHeight toSize:k_TitleLable_Height];
    
    [_stateButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_nameLable];
    [_stateButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_state withOffset:k_BodayView_Space_Margin];
    [_stateButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:_bodayView withMultiplier:0.5 relation:NSLayoutRelationLessThanOrEqual];
    [_stateButton autoSetDimension:ALDimensionHeight toSize:k_TitleLable_Height];

    
    [_visitType autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_state];
    [_visitType autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:k_BodayView_Space_Margin];
    [_visitType autoSetDimensionsToSize:CGSizeMake(80, k_TitleLable_Height)];

    [_visitTypeImgView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_visitType];
    [_visitTypeImgView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_visitType];
    [_visitTypeImgView autoSetDimensionsToSize:CGSizeMake(80, 20)];

    [_visitState autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_visitType];
    [_visitState autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:k_BodayView_Space_Margin];
    [_visitState autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:k_BodayView_Space_Margin];
    [_visitState autoSetDimension:ALDimensionHeight toSize:k_TitleLable_Height];
 

}


-(void)setStore:(NSDictionary *)store{
    _store = store;
    _nameLable.text = [NSString stringWithFormat:@"客户名称: %@",store[@"name"]];
    
    if ([(NSString *)store[@"memo4"] length] >0) {
        _state.text = @"准备状态: 已准备";
        [_stateButton setTitle:@"查看准备" forState:UIControlStateNormal];
    }else if ([store[@"memo3"] isEqualToString:@"115119"]){
        _state.text = @"准备状态: 已准备";
        [_stateButton setTitle:@"修改准备" forState:UIControlStateNormal];
    }else{
        _state.text = @"准备状态: 未准备";
        [_stateButton setTitle:@"开始准备" forState:UIControlStateNormal];
    }
    
    if ([store[@"memo1"] isEqualToString:@"116117"]) {
        _visitTypeImgView.text = @"电话拜访" ;

    }else if ([store[@"memo1"] isEqualToString:@"116116"]){
        
        _visitTypeImgView.text = @"现场拜访" ;
    }else{
        if ([(NSString *)store[@"memo4"] length]) {
            _visitTypeImgView.text = @"现场拜访";

        }else{
            _visitTypeImgView.text = @"";
        }
    }
    
    if ([(NSString *)store[@"memo4"] length]) {
        _visitState.text = [NSString stringWithFormat:@"拜访状态: %@",store[@"memo4"]];
        if ([store[@"memo4"] isEqualToString:@"异"]) {
            
            [_popView autoSetDimension:ALDimensionHeight toSize:k_TitleLable_Height * 7];

            [_exceptionDesc autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_visitState];
            [_exceptionDesc autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:k_BodayView_Space_Margin];
            [_exceptionDesc autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:k_BodayView_Space_Margin];
            [_exceptionDesc autoSetDimension:ALDimensionHeight toSize:k_TitleLable_Height];
            _exceptionDesc.text = [_exceptionDesc.text stringByAppendingString:store[@"exceptionDesc"]] ;
            [_closeButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_exceptionDesc];
            [_closeButton autoPinEdgeToSuperviewEdge:ALEdgeLeft];
            [_closeButton autoPinEdgeToSuperviewEdge:ALEdgeRight];
            [_closeButton autoSetDimension:ALDimensionHeight toSize:k_TitleLable_Height];
      
        }else{
            [_popView autoSetDimension:ALDimensionHeight toSize:k_TitleLable_Height * 6];

            [_closeButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_visitState];
            [_closeButton autoPinEdgeToSuperviewEdge:ALEdgeLeft];
            [_closeButton autoPinEdgeToSuperviewEdge:ALEdgeRight];
            [_closeButton autoSetDimension:ALDimensionHeight toSize:k_TitleLable_Height];
        }
    }else{
        [_popView autoSetDimension:ALDimensionHeight toSize:k_TitleLable_Height * 6];

        _visitState.text = [NSString stringWithFormat:@"拜访状态: 未拜访"];
        [_closeButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_visitState];
        [_closeButton autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [_closeButton autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [_closeButton autoSetDimension:ALDimensionHeight toSize:k_TitleLable_Height];
    }
   
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter * formatter = [NSDateFormatter standardDateFormatter];
    
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString * string = [formatter stringFromDate:date];
    
    if ([string compare:self.dateString] != NSOrderedDescending) {
        _stateButton.hidden = NO;
    }else{
        _stateButton.hidden = YES;
    }
     _popView.top = 1000;
    [UIView animateWithDuration:0.5 animations:^{
        _popView.top = k_View_height;
    } completion:^(BOOL finished) {
        
    }];
}


-(void)prepareStore{
    
    
    WSBaseStoreDBService *service = [[WSBaseStoreDBService alloc] init];
    // 如果是准备明天或明天以后的门店，如果此门店属于 今日拜访的门店，那么该门店也是计划内门店
    NSArray * storeArray =  [service queryStoreByStoreId:_store[@"id"]];
    if (storeArray.count > 0) {
        
        if ([self.delegate respondsToSelector:@selector(storePrepareWith:withDate:)]) {
            [self.delegate storePrepareWith:storeArray[0] withDate:self.dateString];
        }
    }
 
    [self removeFromSuperview];
}


-(void)closeSelf{
    
    [self removeFromSuperview];

}
@end
