//
//  WSCenterView.h
//  WinSFA
//
//  Created by winchannel on 2017/7/3.
//  Copyright © 2017年 WinChannel. All rights reserved.
//


#import <UIKit/UIKit.h>

@class WSCenterView,WSShareItem;

@protocol ZYCenterViewDataSource <NSObject>
@required
- (NSInteger)numberOfItemsWithCenterView:(WSCenterView *)centerView;
- (WSShareItem *)itemWithCenterView:(WSCenterView *)centerView item:(NSInteger)item;

@end

@protocol ZYCenterViewDelegate <NSObject,UIScrollViewDelegate>

@optional
- (void)didSelectItemWithCenterView:(WSCenterView *)centerView andItem:(WSShareItem *)item;
@end


@interface WSCenterView : UIScrollView

@property (nonatomic,weak) id<ZYCenterViewDataSource> dataSource;
@property (nonatomic,weak) id<ZYCenterViewDelegate> centerViewDelegate;

- (void)reloadData;

- (void)dismis;
@end

#define KBHBRemoveAnimationComplete @"removeAnimation"
