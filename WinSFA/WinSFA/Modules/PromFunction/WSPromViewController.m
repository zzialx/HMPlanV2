//
//  PromViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-1-13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSPromViewController.h"
#import "WSPromBeanArray.h"
#import "WSPromBean.h"
#import "WSAppData.h"
#import "WSPromOptViewController.h"
//#import "ConfigFileController.h"
@implementation WSPromViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    UITableView* tv = [[UITableView alloc]initWithFrame:kPartOfTableViewFrame_value style:UITableViewStyleGrouped];
    tv.delegate = self;
    tv.dataSource = self;
    
    [self.view addSubview:tv];
    
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark tableview delegate


//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    WSPromBeanArray* promArray = [WSAppData getObjectbyKey:PROMS];
    return [promArray.promArray count];
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {  
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier: SimpleTableIdentifier];
    }
    WSPromBeanArray* promArray = [WSAppData getObjectbyKey:PROMS];
    WSPromBean* prom = [promArray.promArray objectAtIndex:indexPath.row];
    cell.textLabel.text = prom.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    WSPromOptViewController* povc = [[WSPromOptViewController alloc]initWithFuncs:self.currentFuncs Store:self.currentStore];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:povc animated:YES];
    }


@end
