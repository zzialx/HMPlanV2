//
//  ProdListViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSProdListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{}

@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, strong) NSMutableArray    *dataArray;
@property (nonatomic, strong) UIViewController  *ownParenetViewController;
@property (nonatomic, copy) NSString *prodPicUrl;

- (id)initWithArray:(NSArray *)array;

@end
