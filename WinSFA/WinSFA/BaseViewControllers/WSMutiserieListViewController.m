//
//  WSMutiserieListViewController.m
//  WinSFA
//
//  Created by winchannel on 16/8/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSMutiserieListViewController.h"
#import "WSMutiserieTableView.h"
#import "WSRequestHelper.h"


@interface WSMutiserieListViewController ()

@property (nonatomic, strong)NSString *currentDate;

@property (nonatomic, strong)NSString *filter;

@property (nonatomic, strong)WSMutiserieTableView *mutiserieTableView;

@end

@implementation WSMutiserieListViewController


- (id)initWithStore:(WSStoreBean *)aStore withCurrentDate:(NSString *)currentDate withFilter:(NSString *)filter{
    
    self = [super init];
    
    if (self) {
        self.currentStore = aStore;
        self.currentDate = currentDate;
        self.filter = filter;
    }
    return self;
    
}
- (void)viewDidLoad{
    
    WSMutiserieTableView *mutiserieListView = [[WSMutiserieTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withCurrentStore:self.currentStore withCurrentDate:self.currentDate withFilter:self.filter];
    mutiserieListView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [mutiserieListView setSubViews];
    self.mutiserieTableView = mutiserieListView;
    [self.view addSubview:mutiserieListView];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.mutiserieTableView reloadSubViews];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)upload{
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.mutiserieTableView.allSelectedDoctors];
    
    [self.delegate resetStoreState:array withParentStore:self.currentStore];
    
    [self popToParentOrHome];
    
}
- (void) popToParentOrHome
{
  
    //[self.navigationController popToRootViewControllerAnimated:YES];

    [self backToParent];
        
    
    
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
