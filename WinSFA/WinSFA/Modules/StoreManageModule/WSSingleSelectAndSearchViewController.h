//
//  WSSingleSelectAndSearchViewController.h
//  WinSFA
//
//  Created by xiajl on 15/3/4.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WCBaseViewController.h"
#import "I_W_OptionDataItem.h"

@class WSSingleSelectAndSearchViewController;

@protocol singleSelectAndSearchDelegate <NSObject>

@optional
-(void)singleSelectAndSearchView:(WSSingleSelectAndSearchViewController *)singleSelectAndSearchView selectedItem:(NSString *)item;

-(void)singleSelectAndSearchView:(WSSingleSelectAndSearchViewController *)singleSelectAndSearchView didSelectedItem:(id <I_W_OptionDataItem>)item;

@end

@interface WSSingleSelectAndSearchViewController : WCBaseViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)NSArray *itemArray;
@property (nonatomic, strong)NSArray *itemIds;
@property (nonatomic, weak)id<singleSelectAndSearchDelegate> selectedDelegate;

@property (nonatomic, assign)BOOL isForAcvtGrid;

@end
