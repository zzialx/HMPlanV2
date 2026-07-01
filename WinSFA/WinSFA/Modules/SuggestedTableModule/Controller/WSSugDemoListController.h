//
//  WSSugDemoListController.h
//  WinSFA
//
//  Created by huzepei on 16/9/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSSuggestWholesale.h"
#import "WSSuggestHome.h"

@interface WSSugDemoListController : UIViewController

@property (nonatomic,strong) NSMutableArray *dmeoListArray;

@property (nonatomic,copy) NSString *stype;

@property(nonatomic,copy) void (^sugClick)(WSSuggestWholesale *);

@property (nonatomic,copy) void (^sugHomeClick)(WSSuggestHome *);

@property(nonatomic,copy) void (^delegateSuc)();

@end
