//
//  WSHOrderRelationViewController.m
//  WinSFA
//
//  Created by HZH on 2017/7/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSHOrderRelationViewController.h"
#import "WSHOrderRelationView.h"
#import "WSProdGrideWithExpandableBrandsViewController.h"

@interface WSHOrderRelationViewController ()
{
    WSHOrderRelationView *_orderRelationView;
}
@end

@implementation WSHOrderRelationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.currentFuncs.name;
    
    [self setupSubviews];

    [self reloadAllSubviews];
}

- (void)setupSubviews
{
    
    _orderRelationView = [[WSHOrderRelationView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) andFuncsBean:self.currentFuncs andDataCache:_dataCacheDic];
    _orderRelationView.prodFirstLevelTypesArray = _prodFirstLevelTypesArray;
    
    [self.view addSubview:_orderRelationView];
}

- (void)reloadAllSubviews
{    
    
    [_orderRelationView resetTotalCount:_totalCountStr];
    [_orderRelationView resetDataSource];
}

- (void)doOrderAction
{
    if (_navPreViewController && [_navPreViewController isKindOfClass:[WSProdGrideWithExpandableBrandsViewController  class]]) {
        WSProdGrideWithExpandableBrandsViewController *vc = (WSProdGrideWithExpandableBrandsViewController *)_navPreViewController;
        [vc upload];
        
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
