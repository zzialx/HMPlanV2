//
//  WSEmpInfoViewController.m
//  WinSFA
//
//  Created by yang on 14-5-14.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSEmpInfoViewController.h"
#import "WSAppData.h"
#import "WSEmpInfoBeanArray.h"
#import "WSEmpInfoBean.h"

@interface WSEmpInfoViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation WSEmpInfoViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    WSEmpInfoBeanArray *storeinfoBeanArray = [WSAppData getObjectbyKey:@"empInfo"];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (WSEmpInfoBean *empInfoBean in storeinfoBeanArray.empInfoBeanArray) {
        if ([empInfoBean.typ isEqualToString:self.currentFuncs.filter]) {
            [resultArray addObject:empInfoBean];
        }
    }
    self.dataArray = resultArray;
    
}



#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifer = @"EmpInfoCellReuseIdentifer";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifer];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifer];
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor lightGrayColor];
        view.tag = 888;
        [cell addSubview:view];
    }
    
    UIView *view = [cell viewWithTag:888];
    if (indexPath.row == [self.dataArray count] - 1) {
        view.frame = CGRectMake(0, cell.height - 1, tableView.width, 1);
    }
    else
    {
        view.frame = CGRectMake(15, cell.height - 1, tableView.width - 30, 1);
    }
    
    WSEmpInfoBean *storeInfoBean = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = storeInfoBean.col_name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
