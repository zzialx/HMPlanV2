//
//  WSLocationSelectViewController.h
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-16.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSLocationArray.h"
#import "WSSearchBar.h"

@protocol WSLocationSelectViewControllerDelegate <NSObject>

@optional
- (void)locationSelectedAtIndex:(NSNumber *)index andArrat:(NSArray*)array;

@end

@interface WSLocationSelectViewController : UIViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, assign) id<WSLocationSelectViewControllerDelegate> selectDelegate;


@property (nonatomic, strong) WSSearchBar   *ownSearchBar;

@property (nonatomic, strong) NSMutableArray *filterArray;

- (id)initWithCurrentLocation:(NSString *)aCurrentLocation dicts:(NSArray *)dicts  selectIndex:(NSInteger)aLocationSelectIndex;

- (id)initWithCurrentLocation:(NSString *)aCurrentLocation locationArray:(WSLocationArray *)aLocationArray selectIndex:(NSInteger)aLocationSelectIndex;

@end
