//
//  WSAcvtGridTableViewCell.m
//  WinSFA
//
//  Created by Stephanie on 16/8/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSAcvtGridTableViewCell.h"
#import "PureLayout.h"

#define kSelectImage [UIImage imageNamed:@"icn_check"]
#define kUnSelectImage [UIImage imageNamed:@"icn_nocheck"]
#define kLeftButtonWidth 60.0f
#define kLeftTitleTotalWidth 80.0f

CGFloat const AcvtGridTableViewCellHeight = 55.0f;
CGFloat const AcvtGridTableViewCellLeftTitleTotalWidth = 80.0f;
CGFloat const AcvtGridTableViewCellLabelMinWidth = 180.0f;

@interface WSAcvtGridTableViewCell ()
{
    NSMutableArray *labelArray;
    
    UIButton *leftButton;
    
    NSInteger lastWidth;
    
    BOOL isShowLeftButton;
}

@property (nonatomic, strong) UIView  *TopLineView;
@property (nonatomic, strong) UIView  *separatorLineView;


@end

@implementation WSAcvtGridTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        labelArray = [NSMutableArray array];
        
    }
    
    return self;
}

- (void)setDataArray:(NSArray *)dataArray leftTitleQst:(WSAcvtBean_qst *)leftTitleQst leftTitleValue:(NSString *)value indexPath:(NSIndexPath *)indexPath totalCount:(NSInteger)totalCount
{
    _leftTitleQst = leftTitleQst;
    
    if (!dataArray || [dataArray count] == 0) {
        return;
    }
    
    if (leftTitleQst) {
        
        isShowLeftButton = YES;
        
        if (!leftButton) {
            UIButton *button = [UIButton newAutoLayoutView];
            [self.contentView addSubview:button];
            [button setImage:kUnSelectImage forState:UIControlStateNormal];
            [button setImage:kSelectImage forState:UIControlStateSelected];
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [button autoSetDimension:ALDimensionHeight toSize:kLeftButtonWidth];
            [button autoSetDimension:ALDimensionWidth toSize:kLeftButtonWidth];
            [button autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:(kLeftTitleTotalWidth - kLeftButtonWidth)/2];
            [button autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:(AcvtGridTableViewCellHeight - kLeftButtonWidth)/2];
            leftButton = button;
        }
        
        if ([value length] > 0 && [value isEqualToString:[(WSAcvtBean_qst_opt *)[leftTitleQst.opt firstObject] optId]]) {
            leftButton.selected = YES;
        }else {
            leftButton.selected = NO;
        }
    }
    
    UIView *contentWidthView = [UIView newAutoLayoutView];
    contentWidthView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:contentWidthView];
    
    CGFloat leftSapce = 0;
    [contentWidthView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.contentView];
    if (leftTitleQst) {
        leftSapce = kLeftTitleTotalWidth;
    }
    
    [contentWidthView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withOffset:-leftSapce];
    [contentWidthView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:leftSapce];
    
    if ([labelArray count] == [dataArray count]) {
        for (NSInteger i = 0; i < [labelArray count]; i++) {
            UILabel *label = (UILabel *)labelArray[i];
            label.text = dataArray[i];
        }
    }else {
        
        UIView *lastLabel = nil;
        for (NSInteger i = 0; i < [dataArray count]; i++) {
            NSString *data = dataArray[i];
            UIView * view;
            if ([data rangeOfString:@".png"].location != NSNotFound) {
                UIImageView * imageView = [UIImageView newAutoLayoutView];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                NSURL * url = [NSURL URLWithString:[WSHttpURLHelper getImageCompleteURL:data]];
                [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@""]];
                view = imageView;
            }else{
                UILabel *label = [UILabel newAutoLayoutView];
                [label setTextAlignment:NSTextAlignmentCenter];
                [label setTextColor:[UIColor grayColor]];
                [label setFont:[UIFont systemFontOfSize:UI_Font]];
                [label setBackgroundColor:[UIColor clearColor]];
                //            label.backgroundColor = [UIColor yellowColor];
                //            label.layer.borderColor = [UIColor grayColor].CGColor;
                //            label.layer.borderWidth = 1.0;
                
                label.text = data;
                view = label;

            }
            [self.contentView addSubview:view];
            [labelArray addObject:view];
            
            [view autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:contentWidthView withMultiplier:1./[dataArray count]];
            if ([view isKindOfClass:[UILabel class]]) {
                
                [view autoPinEdgeToSuperviewEdge:ALEdgeTop];
                [view autoSetDimension:ALDimensionHeight toSize:AcvtGridTableViewCellHeight];
                
            }else{
                
                [view autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
                [view autoSetDimension:ALDimensionHeight toSize:20];

            }
            if (lastLabel) {
                [view autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lastLabel];
            }else {
                [view autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:leftSapce];
            }
            
            lastLabel = view;
        }
    }
    
    [self setStyleWithIndexPath:indexPath totalCount:totalCount];
}

- (void)buttonAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(acvtGridTableViewCell:leftTitleButtonSelected:)]) {
        [self.delegate acvtGridTableViewCell:self leftTitleButtonSelected:sender.selected];
    }
}

- (void)setStyleWithIndexPath:(NSIndexPath *)indexPath totalCount:(NSInteger)totalCount
{
//    if (indexPath.row == 0) {
//        if (!self.TopLineView) {
//            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 1)];
//            line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//            line.backgroundColor = self.separatorLineColor;
//            self.TopLineView = line;
//        }
//        
//        self.TopLineView.frame = CGRectMake(0, 0, self.contentView.width, 1);
//        [self.contentView addSubview:self.TopLineView];
//    }else {
//        [self.TopLineView removeFromSuperview];
//    }
    
//    if (!self.separatorLineView) {
//        UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
//        line.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//        line.backgroundColor = [UIColor colorWithHexString:@"#d2d2d2"];
//        [self.contentView addSubview:line];
//        self.separatorLineView = line;
//    }
//    
//    self.separatorLineView.frame = CGRectMake(0, self.contentView.height - 1, self.contentView.width, 1);
    
    
//    if (totalCount > 2) {
        if (indexPath.row % 2 == 0) {
            self.contentView.backgroundColor = RGBCOLOR(246, 246, 246);
        }else {
            self.contentView.backgroundColor = [UIColor whiteColor];
        }
//    }
}

+ (CGFloat)getCellRealWidthWithDataCount:(NSInteger)count displayWidth:(CGFloat)width hasLeftTitle:(BOOL)hasLeftTitle
{
    CGFloat contentWidth = hasLeftTitle ? width - kLeftTitleTotalWidth : width;
    CGFloat cellWidth = 0;
    if (count > 0) {
        cellWidth = contentWidth / count;
    }
    if (cellWidth < AcvtGridTableViewCellLabelMinWidth) {
        cellWidth = AcvtGridTableViewCellLabelMinWidth;
    }
    
    CGFloat realWidth = (cellWidth * count) + (hasLeftTitle ? kLeftTitleTotalWidth : 0);
    
    return realWidth;
}

@end
