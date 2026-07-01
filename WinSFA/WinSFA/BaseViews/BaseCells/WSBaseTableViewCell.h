//
//  WSBaseTableViewCell.h
//  WinSFA
//
//  Created by Stephanie on 16/8/17.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSBaseTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView  *indicatorImageView;
@property (nonatomic, assign) BOOL showIndicatorImage;

@property (nonatomic, strong) UIView  *TopLineView;
@property (nonatomic, strong) UIView  *separatorLineView;

@property (nonatomic, strong) UIColor  *separatorLineColor;

//- (void)setStyleWithIndexPath:(NSIndexPath *)indexPath totalCount:(NSInteger)totalCount;

@end
