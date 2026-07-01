//
//  MsgViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCBaseViewController.h"


@class  WSFuncsBean;
@class  WSMsgBeanArray;
@class  WSMsgContentController;
@class  WSManuallyUploadViewController;

@interface WSMsgViewController : WCBaseViewController <UITableViewDataSource, UITableViewDelegate>{
    UITableView         *titlesTableView;
    UISegmentedControl  *segment;
    NSMutableArray      *dataArray;
    WSFuncsBean           *funcsBean;
}

@property (nonatomic, strong) UITableView           *titlesTableView;
@property (nonatomic, strong) UISegmentedControl    *segment;
@property (nonatomic, strong) NSMutableArray        *dataArray;
@property (nonatomic, strong) UIAlertView           *alert;
//@property (nonatomic, retain) MsgContentController  *content;
@property (nonatomic, strong) WSManuallyUploadViewController* manuallyupload;

- (id)initWithFuncs:(WSFuncsBean *)funcs;

-(void)initializationBackItemAction;

@end
