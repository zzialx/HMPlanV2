//
//  ParentViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCBaseViewController.h"

@class WSFuncsBean;

@interface ParentViewController : WCBaseViewController <UITableViewDataSource, UITableViewDelegate>{}
@property (nonatomic, strong) UITableView       *subFuncsTableView;
@property (nonatomic, strong) NSMutableArray    *subFuncsArray;
@property (nonatomic, strong) WSFuncsBean         *currentFuncs;

- (id)initWithFuncs:(WSFuncsBean *)funcs;
- (void)dealWithselect:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)decorateCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)valueChange:(id)sender;

@end
