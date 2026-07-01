//
//  ListViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFuncsBean.h"
#import "WSStoreBean.h"

@interface WSListViewController : UITableViewController
{}
@property (nonatomic, strong) NSMutableArray    *dataArray;
@property (nonatomic, strong) WSFuncsBean         *currentFuncs;
@property (nonatomic, strong) WSStoreBean         *currentStore;
- (id)initWithArray:(NSArray *)array;
@end
