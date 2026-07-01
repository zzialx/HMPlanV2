//
//  WSHotLineViewController.h
//  WinSFA
//
//  Created by huzepei on 16/6/21.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSHotLineViewController : UIViewController

@property(nonatomic,strong) void(^checkChangePwd)();
@property(nonatomic,strong) void(^findBackPwd)();

@end
