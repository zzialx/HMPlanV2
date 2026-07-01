//
//  LeaveStoreViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"
#import "WSAlertpolicy.h"


@interface WSLeaveStoreViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,WSAlertpolicyDelegate>{
//    NSString    *unfinishedString;
//    UIAlertView *alert;
    
    BOOL    isCustomTime;       //是否为自定义时间
    
    WSStoreBean * temp_storebean;
}
@property (nonatomic, strong) UITableView   *tableView;
@property (nonatomic, strong) NSArray       *dataArray;
@property (nonatomic, assign) BOOL          allowUpload;

//@property (nonatomic, retain) NSString      *unfinishedString;
//@property (nonatomic, retain) UIAlertView   *alert;
@end
