//
//  WSStoreVisitViewController.h
//  WinSFA
//
//  Created by winchannel on 15/7/28.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WCBaseViewController.h"
#import "WSBaseService.h"
#import "WSWidget.h"
#import "WSServiceDispatcher.h"
#import "WSStoreBaseViewController.h"


@class WSBaseTableView;

@class WSStoreService;


@class WSServiceDispatcher;




@interface WSStoreVisitViewController : WSStoreBaseViewController<WSWidgetDelegate,WSServiceDispatcherDelegate>{
    
    
    WSBaseTableView  *table_view;
    
    WSServiceDispatcher  *servicedispatcher;
    
    NSArray *shortCutArray;
    
     WSFuncsBean* subMenuFB; //关联的结果列表
    
    NSMutableDictionary *processfunction_dict;// WSStoreVisitViewController 只有这个类用到了 应该抽离
    
    NSMutableDictionary  *interaction_dict; // WSStoreVisitViewController 只有这个类用到了 应该抽离
    
}
@property (nonatomic ,strong) WCBaseViewController *vc;
-(void)viewDetailInfo:(WSInterAction *)interaction;

@end
