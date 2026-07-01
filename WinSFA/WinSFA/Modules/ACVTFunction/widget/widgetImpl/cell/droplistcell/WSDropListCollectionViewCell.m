//
//  WSDropListCollectionViewCell.m
//  WinSFA
//
//  Created by Alicia on 17/1/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDropListCollectionViewCell.h"

@interface WSDropListCollectionViewCell ()

@property (nonatomic, strong) NSObject<I_W_OptionDataItem> *dataItem;

@end

@implementation WSDropListCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.contentButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.contentButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentButton.titleLabel.font = [UIFont systemFontOfSize:kDropListFontSize];
    self.contentButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentButton setTitleColor:MAIN_TEXT_COLOR forState:UIControlStateNormal];
    [self.contentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    UIImage *normalImage = [UIImage imageFromColor:BTN_GRAY_BG_COLOR with:self.contentButton.frame];
    UIImage *selectedImage = [UIImage imageFromColor:MAIN_TINT_COLOR with:self.contentButton.frame];
    [self.contentButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self.contentButton setBackgroundImage:selectedImage forState:UIControlStateSelected];
    [self.contentButton setUserInteractionEnabled:NO];
    //SFA-23245
    [self.contentView addSubview:self.contentButton];
    
    /* Use WSDropListRoundedCell instead
    // Add cornerRadius
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                          cornerRadius:self.contentButton.height * BTN_CORNER_RADIUS_RAITO];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.contentButton.layer.mask = maskLayer;
    [self.contentView addSubview:self.contentButton];
     */
}


#pragma mark - Public Method
- (void)setDataItem:(NSObject<I_W_OptionDataItem> *)dataItem isSelected:(BOOL)isSelected {
    self.dataItem = dataItem;
    
    NSString *itemName = [dataItem getDataItemName];
    [self.contentButton setTitle:itemName forState:isSelected];
    [self.contentButton setTitle:itemName forState:!isSelected];
    [self setItemSelected:isSelected];
}

- (void)setItemSelected:(BOOL)isSelected {
    [self.contentButton setSelected:isSelected];
}

- (BOOL)getItemSelected
{
    return self.contentButton.selected;
}

@end
