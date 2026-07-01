//
//  WSAcvtGridTableViewHeaderView.h
//  WinSFA
//
//  Created by Stephanie on 16/8/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const AcvtGridTableViewHeaderHeight;

@class WSAcvtGridTableViewHeaderView;

@protocol WSAcvtGridTableViewHeaderViewDelegate <NSObject>

- (void)headerViewAddButtonClicked:(WSAcvtGridTableViewHeaderView *)headerView;

@end

@interface WSAcvtGridTableViewHeaderView : UIView

@property (nonatomic, weak) id<WSAcvtGridTableViewHeaderViewDelegate> delegate;

@property (nonatomic, assign) BOOL readonly;


- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray leftSpace:(CGFloat)leftSpace;

@end
