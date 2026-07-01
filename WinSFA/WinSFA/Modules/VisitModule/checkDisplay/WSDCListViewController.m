//
//  DCListViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSDCListViewController.h"
#import "WSDisplayCheckResultViewController.h"
#import "WSAppData.h"
#import "WSAcvtBean.h"
#import "WSBaseAcvtDBService.h"

@implementation WSDCListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

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


#pragma mark tableView delegate
//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray count];
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
    WSFuncsBean* fb = nil;
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if([object isKindOfClass:[WSFuncsBean class]])
    {
        fb = (WSFuncsBean*)object;
        cell.textLabel.text = fb.name;
    }
    return cell;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    WSFuncsBean* fb = [self.currentFuncs.funcsArray objectAtIndex:indexPath.row];
    if(fb==nil)
        return;
    
    if((fb.funcsArray== nil||[fb.funcsArray count]==0)&&fb.ds !=nil)
    {
        
        WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
        NSArray *array = [baseAcvtDBService queryAcvtsWithStoreId:self.currentStore.Id filter:fb.filter];
        
        WSDisplayCheckResultViewController* dcrvc = [[WSDisplayCheckResultViewController alloc]initWithArray:array Funcs:fb];

        self.hidesBottomBarWhenPushed= YES;
        [self.navigationController pushViewController:dcrvc animated:YES];
    }
    
    WSDCListViewController* dclvc = [[WSDCListViewController alloc]initWithArray:fb.funcsArray];
    dclvc.currentFuncs = fb;
    self.hidesBottomBarWhenPushed= YES;
    [self.navigationController pushViewController:dclvc animated:YES];
    
    }


@end
