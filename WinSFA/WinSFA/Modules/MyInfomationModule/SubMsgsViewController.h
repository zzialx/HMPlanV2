//
//  SubMsgsViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSMsgsBean;

@interface SubMsgsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *titlesTableView;
    WSMsgsBean    *msgs;
}
@property (nonatomic, strong) UITableView   *titlesTableView;
@property (nonatomic, strong) WSMsgsBean      *msgs;

@end
