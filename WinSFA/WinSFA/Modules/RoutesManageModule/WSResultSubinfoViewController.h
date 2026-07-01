//
//  resultSubinfoViewController.h
//  WinChannelFrameWork
//
//  Created by wdy on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFuncsBean.h"
#import "WSStoreBean.h"
#import "WSStoreInfoBeanArray.h"
#import "WSAppData.h"
#import "WSStoreInfoBean.h"

@interface WSResultSubinfoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray  *storeArray;
    WSFuncsBean       *currentFuncs;

    NSMutableArray *col1DataArray;

    NSMutableArray  *titles;
//    UITableView     *myTableView;
    NSArray         *filtedData;
}

@property (nonatomic, strong) NSMutableArray    *storeArray;
@property (nonatomic, strong) WSFuncsBean         *currentFuncs;
@property (nonatomic, strong) NSMutableArray    *col1DataArray;
@property (nonatomic, strong) NSMutableArray    *titles;
@property (nonatomic, strong) UITableView       *myTableView;
@property (nonatomic, strong) NSArray           *filtedData;

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store;

@end
