//
//  ParentViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ParentViewController.h"
#import "WSFuncsBean.h"
//#import "ConfigFileController.h"
#import "WSPlistHelper.h"

@implementation ParentViewController
@synthesize subFuncsTableView = _subFuncsTableView;
@synthesize subFuncsArray = _subFuncsArray;
@synthesize currentFuncs = _currentFuncs;

#pragma mark 子类重写方法

-(void)valueChange:(id)sender
{
    
}

-(UITableViewCell *)decorateCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {  
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier: SimpleTableIdentifier];
    }
    
    //.....
    WSFuncsBean* fb = [self.subFuncsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = fb.name;
    return cell;
}

-(void)dealWithselect:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    
    self = [super init];
    if(self)
    {
        self.currentFuncs = funcs;
        self.title = funcs.name;
        return self;
    }
    return nil;
}

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
    //分段控件内容   
    NSMutableArray* segmentTitlesArray = [[NSMutableArray alloc]init];
    for(int i = 0 ; i < [self.currentFuncs.funcsArray count];i++)
    {
        WSFuncsBean* subfuncs = [self.currentFuncs.funcsArray objectAtIndex:i];
        [segmentTitlesArray addObject:subfuncs.name];
    }
    
    UISegmentedControl *segmentedcontrol = [[UISegmentedControl alloc] initWithItems:segmentTitlesArray];
    segmentedcontrol.frame = CGRectMake(0, 0, 280.0, 44.0);
    [segmentedcontrol addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    [segmentedcontrol setSelectedSegmentIndex:0];
    
    UITableView* tv = [[UITableView alloc]initWithFrame:kPartOfTableViewFrame_value style:UITableViewStyleGrouped];
    [tv setDelegate:self];
    [tv setDataSource:self];
    tv.tableHeaderView = segmentedcontrol;
    
    self.subFuncsTableView = tv;
    [self.view addSubview:self.subFuncsTableView];
    //数据
    NSMutableArray* array = [[NSMutableArray alloc]init];
    self.subFuncsArray = array;
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

#pragma mark tableViewDelegate
//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.subFuncsArray count];
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self decorateCell:tableView cellForRowAtIndexPath:indexPath];
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    [self dealWithselect:tableView didSelectRowAtIndexPath:indexPath];
    }



@end
