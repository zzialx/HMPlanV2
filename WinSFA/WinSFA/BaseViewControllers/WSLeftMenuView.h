//
//  WSLeftMenuView.h
//  WinSFA
//
//  Created by winchannel on 16/8/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSLeftMenuViewDelegate <NSObject>

- (BOOL)leftMenusViewShouldSelectItemAtIndex:(NSInteger)index;

- (void)leftMenusViewDidSelectItemAtIndex:(NSInteger)index;

@end

@interface WSLeftMenuView : UIView

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, weak) id<WSLeftMenuViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame withFuncs:(NSArray *)aFuncs;

@end
