//
//  WSDropListCollectionViewCell.h
//  WinSFA
//
//  Created by Alicia on 17/1/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kDropListFontSize   (UI_Font - 3)



@protocol I_W_OptionDataItem;

@interface WSDropListCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIButton *contentButton;


- (void)setDataItem:(NSObject<I_W_OptionDataItem> *)dataItem isSelected:(BOOL)isSelected;
- (void)setItemSelected:(BOOL)isSelected;
- (BOOL)getItemSelected;

@end
