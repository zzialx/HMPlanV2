//
//  WSGenerateSuggestController.h
//  WinSFA
//
//  Created by huzepei on 16/7/6.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCBaseViewController.h"
@class WSSuggest;
@class WSSuggestWholesale;

@interface WSGenerateSuggestController : UIViewController

@property(nonatomic,copy) void (^sug)(WSSuggestWholesale *);

@property (nonatomic,copy) NSString *suggestName;

@property (nonatomic,copy) NSString *storeID;
//准备日期
@property (nonatomic, copy) NSString *prepareDate;
/**
 *  此数据是外面传递进来的数据模型
 */
@property (nonatomic,strong) WSSuggestWholesale *suggestWho;

@end
