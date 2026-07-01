//
//  WSUpdateStoreIconViewController.h
//  WinSFA
//
//  Created by mac on 2018/4/26.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WCBaseViewController.h"

@interface WSUpdateStoreIconViewController : WCBaseViewController
@property (nonatomic , strong) WSStoreBean * store;
@property (nonatomic , copy) void (^reloadStoreImage)(NSString *imageIndex);
@end
