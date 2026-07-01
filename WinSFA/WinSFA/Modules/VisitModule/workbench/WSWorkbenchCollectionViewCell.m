//
//  WSWorkbenchCollectionViewCell.m
//  WinSFA
//
//  Created by yang on 16/12/15.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSWorkbenchCollectionViewCell.h"
#import "PureLayout.h"
#import "WSRequestHelper.h"
#import "JSBadgeView.h"

#define kImageViewWidth     (INTERFACE_IS_PHONE ? SCREEN_WIDTH * 0.075 : 24)
#define kImageViewHeight    (INTERFACE_IS_PHONE ? SCREEN_WIDTH * 0.075 : 24)

#define kImageViewLabelGap 6

#define kStatusImageViewWidth 13.0f

#define WORK_FOLLOW_FONT        [UIFont fontForKey:@"WorkBenchCellTitle"] ? : [UIFont systemFontOfSize:FONT_SIZE_DESC]

#define kWorkFlowCellTitleColor        ([UIColor colorForKey:@"WorkBenchCellTitle"] ? [UIColor colorForKey:@"WorkFlowCellTitle"] : [UIColor colorWithHexString:@"333333"])

@interface WSWorkbenchCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *statusImageView;
@property (nonatomic , strong) NSLayoutConstraint * titleLabelConstraint;
@property (nonatomic , strong) NSLayoutConstraint * imageHConstraint;
@property (nonatomic , strong) NSLayoutConstraint * imageWConstraint;
@property (nonatomic, strong) JSBadgeView *badgeView;

@end

@implementation WSWorkbenchCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _imageView = [UIImageView newAutoLayoutView];
        [self.contentView addSubview:_imageView];
        _imageWConstraint = [_imageView autoSetDimension:ALDimensionWidth toSize:kImageViewWidth];
        _imageHConstraint = [_imageView autoSetDimension:ALDimensionHeight toSize:kImageViewHeight];
        [_imageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:7];
        [_imageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        
        _titleLabel = [UILabel newAutoLayoutView];
        [self.contentView addSubview:_titleLabel];
        
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = WORK_FOLLOW_FONT ;
        _titleLabel.textColor = kWorkFlowCellTitleColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView];
        [_titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_imageView withOffset:kImageViewLabelGap];
        [_titleLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:_imageView];
        
        self.badgeView = [[JSBadgeView alloc] initWithParentView:_imageView alignment:JSBadgeViewAlignmentTopRight];
        [self.badgeView setBadgePositionAdjustment:CGPointMake(5, 0)];
        [self.badgeView setHidden:YES];
    }
    
    return self;
}

- (void)setDataWithFuncsBean:(WSFuncsBean *)funcsBean visitActionStatus:(VisitActionStatus)visitActionStatus badgeCount:(NSInteger)badgeCount
{
    _funcsBean = funcsBean;
    NSString *imageUrl = [WSHttpURLHelper getImageCompleteURL:funcsBean.icon];
    [[WSRequestHelper shareInstance] downloadImageWithUrl:imageUrl imageView:self.imageView];
    self.titleLabel.text = funcsBean.name;
    
    CGFloat titleContentHeight = [funcsBean.name ws_sizeWithFont:WORK_FOLLOW_FONT constrainedToWidth:self.width].height;
    CGFloat kTitleLabelMaxH =  [@"字体" ws_sizeWithFont:WORK_FOLLOW_FONT constrainedToWidth:self.width].height *2; //标题的最大高度 2行的高度 SFA-30666
    
    //SHOUQIAN-54 --2018-7-1
    if (titleContentHeight > kTitleLabelMaxH) {
        titleContentHeight = kTitleLabelMaxH;
    }
    
    [_titleLabelConstraint autoRemove];
    _titleLabelConstraint = [_titleLabel autoSetDimension:ALDimensionHeight toSize:titleContentHeight];
//    _titleLabelConstraint = [_titleLabel autoSetDimension:ALDimensionWidth toSize:self.width];
    if (_isGrid) {
        [_imageWConstraint autoRemove];
        [_imageHConstraint autoRemove];
        [_imageView autoSetDimensionsToSize:CGSizeMake((55), (55))];
        _titleLabel.textColor = DETAIL_TEXT_COLOR;
        _titleLabel.font = WORK_FOLLOW_FONT;
    }

    [self.statusImageView removeFromSuperview];
    if ([visitActionStatus isEqualToString:ActionDone]) {
        self.statusImageView.image = [UIImage scaledImageForName:@"icon_finish" ofType:@"png"];
        [self.contentView addSubview:self.statusImageView];
        [self.statusImageView autoSetDimension:ALDimensionWidth toSize:kStatusImageViewWidth];
        [self.statusImageView autoSetDimension:ALDimensionHeight toSize:kStatusImageViewWidth];
//        [self.statusImageView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.imageView withOffset:kStatusImageViewWidth/3];
//        [self.statusImageView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.imageView withOffset:kStatusImageViewWidth/3];
        
        [self.statusImageView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.imageView];
        [self.statusImageView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.imageView];
    }
    
    if (badgeCount > 0) {
        [self.badgeView setBadgeText:[NSString stringWithFormat:@"%ld", badgeCount]];
        [self.badgeView setHidden:NO];
    } else {
        [self.badgeView setHidden:YES];
    }
    
}

- (UIImageView *)statusImageView
{
    if (!_statusImageView) {
        _statusImageView = [[UIImageView alloc] init];
    }
    return _statusImageView;
}

@end
