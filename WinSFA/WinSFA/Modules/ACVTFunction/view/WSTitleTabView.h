//
//  WSAcvtTabView.h
//  WinSFA
//
//  Created by Stephanie on 16/7/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTitleTabViewTag         100

typedef NS_ENUM(NSInteger,WSTitleTabViewAlignment){
    
    WSTitleTabViewAlignmentCenter,
    WSTitleTabViewAlignmentLeft
    
};

@class WSTitleTabView;

@protocol WSTitleTabViewDelegate <NSObject>

- (void)titleTabView:(WSTitleTabView *)acvtTabView didSelectTitleAtIndex:(NSInteger)index;

@optional
- (BOOL)titleTabView:(WSTitleTabView *)acvtTabView shouldSelectTitleAtIndex:(NSInteger)index;

@end

@interface WSTitleTabView : UIView

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, weak) id<WSTitleTabViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray aligment:(WSTitleTabViewAlignment)aligment;

- (void)setTitle:(NSString *)title forTabAtIndex:(NSUInteger)index;

- (void)refreshTitlesWithTitleArray:(NSArray *)titleArray;

@end
