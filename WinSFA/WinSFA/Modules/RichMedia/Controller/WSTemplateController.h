//
//  WSTemplateController.h
//  WinSFA
//
//  Created by huzepei on 16/8/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSRMShowBaseController.h"

@interface WSTemplateController : WSRMShowBaseController

@property (nonatomic,strong) NSMutableArray *templateArr;

@property (nonatomic,copy) void (^listArr)(NSMutableArray *array);

@end
