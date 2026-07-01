//
//  RoadsResultViewController.h
//  WinChannelFrameWork
//
//  Created by wdy on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSAppData.h"
#import "WSFuncsBean.h"
#import "WSResultSubinfoViewController.h"

@interface WSRoadsResultViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    NSArray     *myResultArray;
    UITableView *myTabView;
    WSFuncsBean   *currentFuncs;
}
@property (nonatomic, strong) NSArray       *myResultArray;
@property (nonatomic, strong) UITableView   *myTabView;
@property (nonatomic, strong) WSFuncsBean     *currentFuncs;

- (id)initWithFuncs:(WSFuncsBean *)funcs Result:(NSArray *)resultArray;

@end
