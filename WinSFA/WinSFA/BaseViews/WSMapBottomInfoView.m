//
//  WSMapBottomInfoView.m
//  WinSFA
//
//  Created by yang on 16/11/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSMapBottomInfoView.h"
#import "PureLayout.h"

#define kTopOffset 10
#define kBottomOffset 10
#define kLeftOffset 15

#define KBigGap 10
#define KLittleGap 8
#define KImageWidth 3


#define kDetailFontSize  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 13.0f : 15.0f)

@interface WSMapBottomInfoView ()

@property (nonatomic, strong) UILabel *storeNameLabel;

@property (nonatomic, strong) UILabel *storeCodeLabel;

@property (nonatomic, strong) UILabel *storeAddressLabel;

@property (nonatomic, strong) UILabel * separateLabel;

@property (nonatomic, strong) UIImageView * leftImageView;

@property (nonatomic , strong) UILabel * visitContant; // 拜访内容


@end

@implementation WSMapBottomInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.storeNameLabel = [UILabel newAutoLayoutView];
        self.storeNameLabel.font = [UIFont systemFontOfSize:UI_Font];
        self.storeNameLabel.textColor = [UIColor blackColor];
        [self addSubview:self.storeNameLabel];
        [self.storeNameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kTopOffset];
        [self.storeNameLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLeftOffset];
        [self.storeNameLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withOffset:-2*kLeftOffset];
        
        self.storeCodeLabel = [UILabel newAutoLayoutView];
        self.storeCodeLabel.font = [UIFont systemFontOfSize:kDetailFontSize];
        self.storeCodeLabel.textColor = CELL_DETAIL_TEXTCOLOR;
        [self addSubview:self.storeCodeLabel];
        [self.storeCodeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.storeNameLabel withOffset:KBigGap];
        [self.storeCodeLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLeftOffset];
        [self.storeCodeLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withOffset:-2*kLeftOffset];
        
        self.storeAddressLabel = [UILabel newAutoLayoutView];
        self.storeAddressLabel.font = [UIFont systemFontOfSize:kDetailFontSize];
        self.storeAddressLabel.numberOfLines = 0;
        self.storeAddressLabel.textColor = CELL_DETAIL_TEXTCOLOR;
        [self addSubview:self.storeAddressLabel];
        [self.storeAddressLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.storeCodeLabel withOffset:KLittleGap];
        [self.storeAddressLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLeftOffset];
        [self.storeAddressLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withOffset:-2*kLeftOffset];
        
        self.separateLabel = [UILabel newAutoLayoutView];
        UIColor *lineColor = [UIColor colorForKey:@"WorkFlowCellSeparatorLineColor"];
        if (!lineColor) {
            lineColor = DETAIL_SEPERATE_LINE_COLOR;
        }
        self.separateLabel.backgroundColor = lineColor;
        [self addSubview:self.separateLabel];
        
        [self.separateLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.storeAddressLabel withOffset:KLittleGap * 0.5];
        [self.separateLabel autoSetDimension:ALDimensionHeight toSize:0.5];
        [self.separateLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLeftOffset];
        [self.separateLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withOffset:-2*kLeftOffset];
        
        self.leftImageView = [UIImageView newAutoLayoutView];
        [self.leftImageView setImage:[UIImage imageNamed:@"icon_bar_blue"]];
        [self addSubview:self.leftImageView];
        [self.leftImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.separateLabel withOffset:KLittleGap + 2];
        [self.leftImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLeftOffset];
        [self.leftImageView autoSetDimension:ALDimensionWidth toSize:KImageWidth];
        [self.leftImageView autoSetDimension:ALDimensionHeight toSize:12];
        
        self.visitContant = [UILabel newAutoLayoutView];
        self.visitContant.font = [UIFont systemFontOfSize:kDetailFontSize];
        self.visitContant.numberOfLines = 0;
        self.visitContant.textColor = CELL_DETAIL_TEXTCOLOR;
        [self addSubview:self.visitContant];
        [self.visitContant autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.separateLabel withOffset:KLittleGap];
        [self.visitContant autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.leftImageView withOffset:kLeftOffset * 0.5];
        [self.visitContant  autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withOffset:-2.5*kLeftOffset - KImageWidth];
        
    }
    return self;
}


- (void)setStore:(WSStoreBean *)storeBean
{
    self.storeNameLabel.text = storeBean.name;
    self.storeCodeLabel.text = storeBean.code;
    self.storeAddressLabel.text = storeBean.addr;
    if (storeBean.visitcontent.length > 0) {
        self.separateLabel.hidden = NO;
        self.leftImageView.hidden = NO;
        self.visitContant.hidden = NO;
        self.visitContant.text = storeBean.visitcontent;
    }else{
        self.separateLabel.hidden = YES;
        self.leftImageView.hidden = YES;
        self.visitContant.hidden = YES;
    }
}

+ (CGFloat)heightForStore:(WSStoreBean *)store width:(CGFloat)width
{
    CGFloat contentWidth = width - 2*kLeftOffset;
    CGFloat height = kTopOffset * 2;
    
    if ([store.name length] > 0) {
        CGSize size = [store.name stringSizeWithFont:[UIFont systemFontOfSize:UI_Font] width:contentWidth];
        height += size.height + KBigGap;
    }
    
    if ([store.code length] > 0) {
        CGSize size = [store.code stringSizeWithFont:[UIFont systemFontOfSize:kDetailFontSize] width:contentWidth];
        height += size.height + KLittleGap;
    }
    
    if ([store.addr length] > 0) {
        CGSize size = [store.addr stringSizeWithFont:[UIFont systemFontOfSize:kDetailFontSize] width:contentWidth];
        height += size.height;
    }
    
    if ([store.visitcontent length] > 0) {
        CGSize size = [store.visitcontent stringSizeWithFont:[UIFont systemFontOfSize:kDetailFontSize] width: width - 2.5*kLeftOffset - KImageWidth];
        height += size.height + 2 *KLittleGap;

    }
    return height;
    
}

@end
