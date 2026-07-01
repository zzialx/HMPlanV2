//
//  MoreProductViewController.h
//  WinChannelIPhone
//
//  Created by winchannel on 11-10-3.
//  Copyright 2011年 Winchannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCBaseViewController.h"
#import "WSSearchBar.h"

#define RECEIVEMORE             @"receiveMoreProducts"

@interface MoreProductViewController : WCBaseViewController<UITableViewDataSource,UITableViewDelegate>

//@property (nonatomic, strong) NSMutableDictionary   *stateDictionary;
//@property (nonatomic, strong) NSMutableArray        *moreProducts;
//@property (nonatomic, strong) NSMutableArray        *selectProducts;
//@property (nonatomic, strong) NSMutableArray        *originData;
//// modity by yanguoshuai at 2012-02-27
//@property (nonatomic, strong) NSMutableArray *tmpMorePs;
//add by xiajl 2014-07-03 
@property (nonatomic, strong) WSSearchBar       *ownSearchBar;
@property (nonatomic, strong) NSMutableDictionary *filterIBranProducts;
@property (nonatomic,copy)NSString *titleName;
- (instancetype)initWithProductArray:(NSArray *)productArray title:(NSString *)titleName;
- (void)postReceiveMoreNotificationAndSendSelectedProducts;

@end
