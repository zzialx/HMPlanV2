//
//  RoadsResultViewController.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSRoadsResultViewController.h"

@implementation WSRoadsResultViewController
@synthesize myResultArray,myTabView,currentFuncs;

-(void)loadView{

    [super loadView];
    myTabView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 460) style:UITableViewStylePlain];
    myTabView.delegate=self;
    myTabView.dataSource=self;
    [self.view addSubview:myTabView];
}


-(id)initWithFuncs:(WSFuncsBean*)funcs Result:(NSArray*)resultArray
{
    if(funcs==nil)
        return nil;
    
    if(self = [super init])
    {
        self.currentFuncs = funcs;
        self.title = funcs.name;
        self.myResultArray = resultArray;
    }
    return self;
}

#pragma mark tableViewDelegate
//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = [self.myResultArray    count];
    return count;
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {  
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier: SimpleTableIdentifier];
        UIImage* image = [UIImage imageNamed:@"point.png"];
        cell.imageView.image = image;
    }
    
    NSDictionary*searchResultData=[self.myResultArray objectAtIndex:indexPath.row];
    cell.textLabel.text=[searchResultData objectForKey:@"name"];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
    
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
//     StoreBean* store = [self.myResultArray objectAtIndex:indexPath.row];
    
//    NSDictionary *searchResultData=[self.myResultArray objectAtIndex:indexPath.row];
//    StoreBean *store = [[[StoreBean alloc] initStoreWithObject:searchResultData IsPlan:NO] autorelease];
//     if ([self.myResultArray count]<1&&[self.myResultArray count]>8) {
//       
//        return;
//    }
//  
//    resultSubinfoViewController *resultSubVC=[[resultSubinfoViewController alloc]initWithFuncs:self.currentFuncs Store:store];
//     [self.navigationController pushViewController:resultSubVC animated:YES];
//    [resultSubVC release];
    
}


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

@end
