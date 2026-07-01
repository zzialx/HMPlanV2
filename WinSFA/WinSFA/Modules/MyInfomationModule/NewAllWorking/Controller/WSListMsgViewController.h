//
//  WSListMsgViewController.h
//  WinSFA
//
//  Created by mac on 2018/11/9.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WCBaseViewController.h"

@interface WSListMsgViewController : WCBaseViewController
@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, strong) NSMutableArray *msgArray;
@property (nonatomic, strong) NSString *storeId;
@end
