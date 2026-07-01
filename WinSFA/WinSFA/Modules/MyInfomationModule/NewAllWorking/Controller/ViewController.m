//
//  ViewController.m
//  demo
//
//  Created by zhiqingPC on 15/10/20.
//  Copyright (c) 2015年 zhiqingPC. All rights reserved.
//

#import "ViewController.h"
#import "WSMyMsgViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.tabBarItem.image = [UIImage imageNamed:@"1234"];
    self.tabBarItem.title = @"焦点拜访";
    
    self.view.backgroundColor = [UIColor redColor];
    
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
    
    btn.backgroundColor = [UIColor blackColor];
    
    [btn addTarget:self action:@selector(pushTableView) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:btn];

}
// 跳转到  PopTableViewController
-(void)pushTableView{
    
    WSMyMsgViewController * tableViewCtrl = [[WSMyMsgViewController alloc]init];
    
    [self.navigationController pushViewController:tableViewCtrl animated:YES];


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
