//
//  WSTabBarController.m
//  demo
//
//  Created by admin on 15/10/26.
//  Copyright (c) 2015年 zhiqingPC. All rights reserved.
//

#import "WSTabBarController.h"
#import "WSNavViewController.h"
#import "WSMyMsgViewController.h"
#import "ViewController.h"
#import "WSDetalViewController.h"
#import "WSRevertViewController.h"
@interface WSTabBarController ()

@end

@implementation WSTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.title = @"all";
    
    ViewController * view =[ViewController new];
    WSNavViewController * navView =[[WSNavViewController alloc]initWithRootViewController:view];
    view.title = @"焦点拜访";
    [self addChildViewController:navView];
    
    WSDetalViewController * detal = [WSDetalViewController new];
    detal.title = @"detal";
    [self addChildViewController:detal];
    
    WSMyMsgViewController * PopViewCtrl = [WSMyMsgViewController new];
    WSNavViewController * nav =[[WSNavViewController alloc]initWithRootViewController:PopViewCtrl];
    PopViewCtrl.title = @"my_info";

   // [self.navigationController pushViewController:PopViewCtrl animated:YES];
     [self addChildViewController:nav];
    
     WSDetalViewController * detal1 = [WSDetalViewController new];
    detal1.title = @"detal1";
    [self addChildViewController:detal1];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
