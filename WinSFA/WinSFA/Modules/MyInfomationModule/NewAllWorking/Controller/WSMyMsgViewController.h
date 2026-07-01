//
//  PopTableViewController.h
//  demo
//
//  Created by zhiqingPC on 15/10/20.
//  Copyright (c) 2015年 zhiqingPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCBaseViewController.h"
#import "WSCustomView.h"

#define UPDATA_MSG @"updataMassage"
#define kLeftVieWidth 200.0f

@class  WSFuncsBean;
@class  WSMsgBeanArray;
@class  WSMsgContentController;
@class  WSManuallyUploadViewController;
@class WSMsgsBean_msg;

@interface WSMyMsgViewController : WCBaseViewController<WSCustomViewExecuteSelectBtn,UITableViewDataSource,UITableViewDelegate>


// 用来存放模型的数组
@property (nonatomic,strong) NSArray                  *cellModelArray;
// 存放有已读标记的数组
@property (nonatomic,strong) NSMutableArray           *isReadArray;
@property (nonatomic, strong)UITableView                *tableView;
@property (nonatomic,strong) WSFuncsBean           *subFuncsBeanNeedShow;

// 传入以前的数据模型
- (id)initWithFuncs:(WSFuncsBean *)funcs;
-(void)initializationBackItemAction;

@end

