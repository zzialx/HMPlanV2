//
//  WSSubMenuViewController.m
//  WinSFA
//
//  Created by Alicia on 2018/1/11.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

// WARNING - 这是个临时类，为了在需求允许时间内完成功能，稍后重构出下级菜单处理方式后去掉该类

#import "WSSubMenuViewController.h"

@interface WSSubMenuViewController ()

@end

@implementation WSSubMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)gotoFuncsBean:(WSFuncsBean *)funcBean {
    BOOL isInStore = self.currentStore ? YES : NO;
    [self showFuncBean:funcBean isInStore:isInStore];
}

@end
