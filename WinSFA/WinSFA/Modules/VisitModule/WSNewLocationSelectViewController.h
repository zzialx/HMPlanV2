//
//  WSNewLocationSelectViewController.h
//  WinSFA
//
//  Created by heju on 16/8/24.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WSLocationArray.h"
#import "WSSearchBar.h"

@protocol WSLocationNewSelectViewControllerDelegate;

@interface WSNewLocationSelectViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (nonatomic, assign) id<WSLocationNewSelectViewControllerDelegate> selectDelegate;

@property (nonatomic, strong) WSSearchBar *ownSearchBar;

@property (nonatomic, strong) NSMutableArray *filterArray;

- (id)initWithCurrentLocation:(NSString *)cityName  selectedItem:(WSDictBean *)selectedItem dicts:(NSArray *)dicts  ;

- (id)initWithCurrentLocationItem:(WSDictBean *)currentItem selectedItem:(WSDictBean *)selectedItem dicts:(NSArray *)dicts;

@end


@protocol WSLocationNewSelectViewControllerDelegate <NSObject>

- (void)viewController:(WSNewLocationSelectViewController *)viewController didselectedItem:(WSDictBean *)item;

@end
