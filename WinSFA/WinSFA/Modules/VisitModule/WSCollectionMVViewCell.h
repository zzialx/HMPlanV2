//
//  WSCollectionMVViewCell.h
//  WinSFA
//
//  Created by Alicia on 17/2/10.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

// TAB_MVListViewStyleVertical 时显示的 Cell
@interface WSCollectionMVViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *mainTitleLabel;
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *statusImageView;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) CALayer *separatorLayer;

@property (nonatomic, strong) WSFuncsBean *funcsBean;
@property (nonatomic, assign) VisitActionStatus actionStatus;

- (void)setTitle:(NSString *)title;

@end
