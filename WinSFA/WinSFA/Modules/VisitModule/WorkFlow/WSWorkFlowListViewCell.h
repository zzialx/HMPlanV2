//
//  WSWorkFlowListViewCell.h
//  WinSFA
//
//  Created by Alicia on 17/2/14.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSWorkFlowViewCell.h"
#import "JSBadgeView.h"

@interface WSWorkFlowListViewCell : WSWorkFlowViewCell

@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UIImageView  *isRequireImageView;
@property (nonatomic, strong) JSBadgeView *badgeNumberView;



@end
