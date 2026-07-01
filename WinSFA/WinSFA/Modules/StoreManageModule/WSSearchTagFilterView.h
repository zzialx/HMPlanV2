//
//  WSSearchTagFilterView.h
//  WinSFA
//
//  Created by yang on 16/3/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSSearchTagFilterView;

@protocol WSSearchTagFilterViewDelegate <NSObject>

- (void)searchTagView:(WSSearchTagFilterView *)searchTagView searchButtonClicked:(NSArray *)searchTagArray;

@end

@interface WSSearchTagFilterView : UIView


@property (nonatomic, weak) id<WSSearchTagFilterViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame searchTagString:(NSString *)searchTagString;

- (void)setSelectedSearchTagArray:(NSArray *)selectedSearchTagArray;

- (void)showOnView:(UIView *)superView;

@end
