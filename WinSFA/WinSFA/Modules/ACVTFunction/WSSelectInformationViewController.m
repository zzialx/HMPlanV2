//
//  WSSelectPeopleViewController.m
//  WinSFA
//
//  Created by zhangke on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSSelectInformationViewController.h"
#import "WSTableView.h"
#import "WSPeopleListDatasource.h"
#import "WSInterAction.h"


@interface WSSelectInformationViewController ()<WSTableViewDelegate>{
    WSTableView* tableview;
}



@end

@implementation WSSelectInformationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    tableview =[[WSTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    
    tableview.tabledelegate = self;
    
    [self.view addSubview:tableview];
    
    [tableview setAcvtType:QST_TYPE_DA];
    
    [tableview buildDisplayContent];
    
    tableview.selectMode=mutableSelect;
    
    WSPeopleListDatasource* peopledata=[[WSPeopleListDatasource alloc] init];
    
    peopledata.currentStore =(WSStoreBean *)[self.executeParam execute_class_param];
    
    [tableview loadDataSource:peopledata];
    
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    
        WSInterAction  *interaction =[[WSInterAction alloc] init];
        
        interaction.execute_result=tableview.filterArray;
        
        [interaction setAcvt_qust_id:self.executeParam.acvt_qust_id];
        
        interaction.inner_param=@"select";
        
        [self.wcBaseViewdelegate callBackWhenFinishTask:interaction];
        

}


@end
