//
//  WSNavViewController.m
//  demo
//
//  Created by admin on 15/10/26.
//  Copyright © 2015年 zhiqingPC. All rights reserved.
//

#import "WSNavViewController.h"

@interface WSNavViewController ()

@end

@implementation WSNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    NSInteger count = self.childViewControllers.count;
    //如果执行到这个地方,判断里面有一个控制器的话,代表当前要往导航控制器里面push的是第二个控制器
    if (count>=1) {
        
        if (count == 1) {
          //  title = [[self.childViewControllers firstObject] title];
        }
        //设置在push的时候隐藏底部的tabbar
        viewController.hidesBottomBarWhenPushed = YES;
//        
//        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"navigationbar_back_withtext" title:title target:self action:@selector(back)];
    }

     [super pushViewController:viewController animated:animated];

}



@end
