//
//  BaseListViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFuncsBean.h"

@interface BaseListViewController : UITableViewController
{}
@property (nonatomic, strong) NSMutableArray    *dataArray;
@property (nonatomic, strong) WSFuncsBean         *currentFuncs;
- (id)initWithArray:(NSArray *)array;

@end
