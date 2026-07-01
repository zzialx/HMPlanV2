//
//  WSHOrderRelationViewController.h
//  WinSFA
//
//  Created by HZH on 2017/7/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "BaseViewController.h"

@interface WSHOrderRelationViewController : BaseViewController

@property (nonatomic, strong) NSDictionary *dataCacheDic;
@property (nonatomic, copy) NSString *totalCountStr;
@property (nonatomic, strong) UIViewController *navPreViewController;
@property (nonatomic, strong) NSArray *prodFirstLevelTypesArray;

- (void)doOrderAction;
- (void)reloadAllSubviews;

@end
