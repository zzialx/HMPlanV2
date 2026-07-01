//
//  WSRichDemoListController.h
//  WinSFA
//
//  Created by huzepei on 16/8/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSRichItemModel;

@interface WSRichDemoListController : UIViewController

@property (nonatomic,strong) NSMutableArray *dmeoListArray;

@property (nonatomic,copy) void (^deleteSuc)(NSArray *demoListArray,WSRichItemModel *im);

@property (nonatomic,copy) void (^saveSuc)(NSMutableDictionary *dict);

@end
