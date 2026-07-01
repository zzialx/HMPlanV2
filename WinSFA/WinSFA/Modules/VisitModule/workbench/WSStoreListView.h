//
//  WSStoreListView.h
//  WinSFA
//
//  Created by yang on 16/12/15.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSStoreListViewDelegate <NSObject>

- (void)didSelectStore:(WSStoreBean *)store;

@end

@interface WSStoreListView : UIView

@property (nonatomic, weak) id<WSStoreListViewDelegate> delegate;

- (instancetype)initWithStoreList:(NSArray *)storeList;

- (void)setStoreList:(NSArray *)storeList;

- (void)setSelectedStore:(WSStoreBean *)selectedStore;

- (void)showOnView:(UIView *)view;

@end
