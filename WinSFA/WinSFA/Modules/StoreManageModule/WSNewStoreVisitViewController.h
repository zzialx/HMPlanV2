//
//  WSNewStoreVisitViewController.h
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-22.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSAllStoresViewController.h"

@class WSAcvtListDataItem;

@interface WSNewStoreVisitViewController : WSAllStoresViewController

- (id)initWithFuncs:(WSFuncsBean*)funcs acvtListItem:(WSAcvtListDataItem *)item;

@end
