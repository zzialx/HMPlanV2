//
//  resultSubinfoViewController.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSResultSubinfoViewController.h"

@implementation WSResultSubinfoViewController
@synthesize  storeArray,currentFuncs,col1DataArray,titles,filtedData,myTableView;

-(id)initWithFuncs:(WSFuncsBean*)funcs Store:(WSStoreBean *)store
{
   
    if (funcs==nil||store==nil) {
        return nil;
    }
    
    self = [super init];
    if(self != nil)
    {
        self.currentFuncs=funcs;
        self.title=funcs.name;
        storeArray=[[NSMutableArray alloc]init];
        [storeArray addObject:store];
        
        titles=[[NSMutableArray alloc]init];
        [titles addObjectsFromArray:self.currentFuncs.paramArray];
        
        return self;
    }
    return nil;
}

-(void)setColumnDatasOfTitles{

  
//    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 110, 30)];
//    titleLabel.backgroundColor=[UIColor clearColor];
    
//    if ([[titles objectAtIndex:0] name] == nil) {
//        titleLabel.text = name;
//    }else{
//       titleLabel.text=[[titles objectAtIndex:0]name];
//    }
    
//    titleLabel.text = name;
//    titleLabel.textAlignment=UITextAlignmentLeft;
//    [self.view addSubview:titleLabel];
//    [titleLabel release];
    
    //列标题
    if ([titles count] > 0) {
        UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 110, 30)];
        titleLabel.backgroundColor=[UIColor clearColor];
       
        WSFuncsBean_Param *param = [titles objectAtIndex:0];
        if (param && [param.name isKindOfClass:[NSString class]]) {
            titleLabel.text = param.name;
        }
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:titleLabel];
    }

}


-(void)loadView{

    [super loadView];
    
    [self setColumnDatasOfTitles];
    
    WSStoreInfoBeanArray *storeinfoBeans=[WSAppData getObjectbyKey:STOREINFOS];
    self.filtedData=[storeinfoBeans getStoreinfosWithFilter:@"remind"];
    
    self.myTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 30, 300, 340) style:UITableViewStylePlain];
    self.myTableView.delegate=self;
    self.myTableView.dataSource=self;
    self.myTableView.backgroundColor=[UIColor clearColor];
    self.myTableView.rowHeight=30;
    self.myTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.myTableView];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.filtedData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* str=@"cell";
    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:str];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
        cell.backgroundColor=[UIColor clearColor];
        UILabel*col2Data=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
        UILabel*col3Data=[[UILabel alloc]initWithFrame:CGRectMake(150, 0, 150, 30)];
        col2Data.backgroundColor=[UIColor clearColor];
        col3Data.backgroundColor=[UIColor clearColor];
        col2Data.tag=567;
        col3Data.tag=678;
        col2Data.textAlignment = NSTextAlignmentCenter;
        col3Data.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:col2Data];
        [cell.contentView addSubview:col3Data];
    }else{
        NSArray *subViews = [cell.contentView subviews];
        for (UIView *subView in subViews) {
            [subView removeFromSuperview];
        }
    }
    WSStoreInfoBean *storeinBean=[self.filtedData  objectAtIndex:indexPath.row];
    UILabel*col2Datas=(UILabel*)[cell.contentView viewWithTag:567];
    UILabel*col3Datas=(UILabel*)[cell.contentView viewWithTag:678];
    if ([storeinBean.col2 isKindOfClass:[NSString class]]) {
        col2Datas.text = storeinBean.col2;
    }
    if ([storeinBean.col3 isKindOfClass:[NSString class]]) {
        col3Datas.text=storeinBean.col3;
    }
    return cell;
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
