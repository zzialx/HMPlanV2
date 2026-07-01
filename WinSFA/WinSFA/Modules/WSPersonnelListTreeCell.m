//
//  WSPersonnelListTreeCell.m
//  WinSFA
//
//  Created by winchannel on 15/7/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSPersonnelListTreeCell.h"

#define kCellPadding    30

@interface WSPersonnelListTreeCell ()

@property (nonatomic, assign) WSPersonnelListStyle listStyle;
@property (nonatomic ,strong) UIButton *button;
@property (nonatomic ,strong) UIButton *selectButton;
@property (nonatomic ,strong) UILabel *nameLabel;

@end

@implementation WSPersonnelListTreeCell

#pragma mark - Init
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                    listStyle:(WSPersonnelListStyle )listStyle {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.listStyle = listStyle;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - 40)/2.0, 40, 40)];
    [self.button addTarget:self action:@selector(foldAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.button ];
    
    self.selectButton = [[UIButton alloc] init];
    [self.selectButton addTarget:self action:@selector(checkClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.selectButton setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateSelected];
    [self.contentView addSubview:self.selectButton];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.button.frame.size.width, 0, self.frame.size.width - self.button.frame.size.width - MAIN_TEXT_IMG_PADDING, self.frame.size.height)];
    [self.nameLabel setFont:[UIFont systemFontOfSize:UI_Font]];
    [self.contentView addSubview:self.nameLabel];
}

#pragma mark - Public method
- (void)assignedWithWSSubempStoreBean:(NSObject<I_W_Cell> *)bean withIsReadOnly:(BOOL)isReadOnly {
    self.dataItem = bean;
    
    [self tableviewCellWithSubViewsFrame];

    if ([bean getName]) {
        self.nameLabel.text = [bean getName];
        
    } else if ([bean getOrgName]){
        self.nameLabel.text = [bean getOrgName];
        
    } else if ([bean getOrgCode]){
        self.nameLabel.text = [bean getOrgCode];
    } else {
        self.nameLabel.text = nil;
    }
    
    //SFA 项目SFA-20952 SFA葵花药业--IOS端群发功能页面中图标显示有误
    UIImage *image = nil;
    if ([[bean getLeafNode] boolValue] == NO) {
        if ([bean getIsExpland] || [bean getIsAllExpand]) {
            image = [UIImage imageNamed:@"unfold_button"];
        } else {
            image = [UIImage imageNamed:@"fold_button"];
        }
    }
    
    [self.button setImage:image forState:UIControlStateNormal];
    
    if ([bean getOptioned]) {
        self.selectButton.selected  = YES;
    } else {
        self.selectButton.selected = NO;
    }
    if (isReadOnly) {
        self.selectButton.userInteractionEnabled = NO;
    } else {
        self.selectButton.userInteractionEnabled = YES;
    }
    
    
}

// 用于层级缩进
- (void)tableviewCellWithSubViewsFrame {
    NSInteger subLevelCode = [[self.dataItem getSub_Level_Code] integerValue];
    if (subLevelCode >= 0) {
        CGRect rectbutton = self.button.frame;
        
        CGFloat kPadding = kCellPadding * (subLevelCode - 1);
        
        self.button.frame = CGRectMake(kPadding, rectbutton.origin.y, rectbutton.size.width, rectbutton.size.height);
        
        if (!(self.listStyle & WSPersonnelListStyleOption)) {
            [self.selectButton setHidden:YES];
        } else {
            if (self.listStyle & WSPersonnelListStyleParentOption) {
                [self.selectButton setHidden:NO];
            } else {
                if ([[self.dataItem getSonBean] count] > 0) {
                    [self.selectButton setHidden:YES];
                } else {
                    [self.selectButton setHidden:NO];
                }
            }
        }
        
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat buttonWH = 20;
    CGFloat imagePadding = MAIN_TEXT_IMG_PADDING;
 
    CGFloat paddingX = CGRectGetMaxX(self.button.frame) + imagePadding;
    if (self.listStyle & WSPersonnelListStyleLeftOption) {
        // selectButton 在 nameLabel 左侧
        self.selectButton.frame = CGRectMake(paddingX, (self.frame.size.height - buttonWH) / 2, buttonWH, buttonWH);
        
        CGFloat namePaddingX = CGRectGetMaxX(self.selectButton.frame) + imagePadding;
        CGFloat nameWidth = self.width - namePaddingX - MAIN_CELL_PADDING;
        self.nameLabel.frame = CGRectMake(namePaddingX, self.nameLabel.origin.y, nameWidth, self.nameLabel.size.height);
    } else {
         // selectButton 在最右侧
        self.selectButton.frame = CGRectMake(self.frame.size.width - MAIN_PADDING - buttonWH, (self.frame.size.height - buttonWH) / 2, buttonWH, buttonWH);
        
        CGFloat nameWidth = self.width - paddingX - CGRectGetMinX(self.nameLabel.frame) - imagePadding;
        self.nameLabel.frame = CGRectMake(paddingX, self.nameLabel.origin.y, nameWidth, self.nameLabel.size.height);
    }
}

#pragma mark - Action

-(void)foldAction:(UIButton *)sender {
    [self.delegate listTreeCell:self reloadDataItem:self.dataItem];
}

- (void)checkClickAction:(id)sender{
    
    [self.dataItem setOptioned:![self.dataItem getOptioned]];
    
    UIButton *button = (UIButton *)sender;
    
    [self.selectButton setSelected:!button.selected];
    
    [self.delegate listTreeCell:self didClickItem:self.dataItem];
}

@end
