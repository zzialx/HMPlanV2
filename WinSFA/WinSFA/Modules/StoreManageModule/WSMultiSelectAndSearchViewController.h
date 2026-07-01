//
//  WSMultiSelectAndSearchViewController.h
//  WinSFA
//
//  Created by HZH on 16/12/1.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WCBaseViewController.h"
#import "I_W_OptionDataItem.h"

@class WSMultiSelectAndSearchViewController;

@protocol MultiSelectAndSearchDelegate <NSObject>

//-(void)multiSelectAndSearchView:(WSMultiSelectAndSearchViewController *)multiSelectAndSearchView selectedItem:(NSString *)item;
//
//-(void)multiSelectAndSearchView:(WSMultiSelectAndSearchViewController *)multiSelectAndSearchView didSelectedItem:(id <I_W_OptionDataItem>)item;

-(void)multiSelectAndSearchView:(WSMultiSelectAndSearchViewController *)multiSelectAndSearchView selectedItemArray:(NSArray *)itemArray;

@end

@interface WSMultiSelectAndSearchViewController : WCBaseViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)NSArray *itemArray;
@property (nonatomic, strong)NSArray *itemIds;
@property (nonatomic, weak)id <MultiSelectAndSearchDelegate> selectedDelegate;
@property (nonatomic, strong)NSArray *selectItemIDArray;
@property (nonatomic, strong) NSArray *selectedItemArray;

@property (nonatomic, assign)BOOL isForAcvtGrid;

@end
