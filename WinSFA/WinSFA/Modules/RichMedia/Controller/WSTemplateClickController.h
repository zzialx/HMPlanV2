//
//  WSTemplateClickController.h
//  WinSFA
//
//  Created by huzepei on 16/8/23.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSTemplateClickController : UIViewController

@property (nonatomic,strong) NSArray *dataArray;

@property (nonatomic,strong) NSString *name;

@property (nonatomic,copy) void (^changeTitle) (NSString *);

@end
