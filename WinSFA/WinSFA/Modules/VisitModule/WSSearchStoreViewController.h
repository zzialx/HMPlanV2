//
//  WSSearchStoreViewController.h
//  WinSFA
//
//  Created by heju on 16/8/27.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSSearchStoreViewControllerDelegate;

@interface WSSearchStoreViewController : UIViewController <UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) id<WSSearchStoreViewControllerDelegate> delegate;


- (instancetype)initWithCityName:(NSString *)selectedCityName searchContent:(NSString *)content;

@end

@protocol WSSearchStoreViewControllerDelegate <NSObject>

- (void)viewController:(WSSearchStoreViewController *)viewController didSelectContent:(NSString *)content;

@end

