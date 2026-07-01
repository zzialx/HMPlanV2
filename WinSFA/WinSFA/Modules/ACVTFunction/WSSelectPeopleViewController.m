//
//  WSSelectPeopleViewController.m
//  WinSFA
//
//  Created by zhangke on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSSelectPeopleViewController.h"
#import "WSTableView.h"
#import "WSPeopleListDatasource.h"

@interface WSSelectPeopleViewController ()<WSTableViewDelegate>{
    WSTableView* tableview;
}



@end

@implementation WSSelectPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tableview =[[WSTableView alloc] initWithFrame:self.view.bounds];
    
    tableview.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    tableview.tabledelegate = self;
    
    [self.view addSubview:tableview];
    
    [tableview loadBuildInfo:self.currentStore.Id];
    
    [tableview setAcvtType:@"DA"];

    [tableview buildDisplayContent];
    
    WSPeopleListDatasource* peopledata=[[WSPeopleListDatasource alloc] init];
    
    [tableview loadDataSource:peopledata];
    
}


-(void)sendSelectedCell:(WSTableViewCell *)mycell andSelectedItem:(NSObject *)item{
    
    

}


@end
