//
//  WSSuggestView.h
//  WinSFA
//
//  Created by huzepei on 16/7/5.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSSuggest;
@class WSSuggestWholesale;
@class WSSuggestView;
@class WSSuggestHome;

@protocol WSSuggestViewDelegate <NSObject>

-(void)WSSuggestViewDidClickCloseBtn:(WSSuggestView *)suggestView WithIndex:(NSInteger)index;

-(void)WSSuggestViewDidClickPlusBtn:(WSSuggestView *)suggestView WithIndex:(NSInteger)index;

-(void)WSSuggestViewDidClickContainerView:(WSSuggestView *)suggestView WithIndex:(NSInteger)index;

@end

@interface WSSuggestView : UIView

@property (nonatomic,strong) WSSuggest *suggest;

@property (nonatomic,strong) WSSuggestWholesale *suggestWholesale;

@property (nonatomic,strong) WSSuggestHome *suggestHome;

@property (nonatomic,assign) BOOL showPlus;

@property (nonatomic,assign) NSInteger suggestIndex;

@property (nonatomic,weak) id<WSSuggestViewDelegate>delegate;

-(void)removeContainerViewAndPlusBtn;

-(void)setupViews;

-(void)setUpPlusBtn;

@end
