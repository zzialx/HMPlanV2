//
//  ListViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSListViewController.h"
#import "WSDictBean.h"
#import "WSDictBrand.h"
#import "WSProdBean.h"
#import "WSShowPriceViewController.h"


@implementation WSListViewController
@synthesize dataArray = _dataArray;
@synthesize currentFuncs;
@synthesize currentStore = _currentStore;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithArray:(NSArray*)array
{
    if(array == nil || [array count]==0)
        return nil;
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self != nil)
    {
        NSMutableArray* list = [[NSMutableArray alloc]initWithArray:array];
        self.dataArray = list;
        return self;
    }
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    id object = [self.dataArray objectAtIndex:indexPath.row];
    //NSLog(@"object class is %@",[object class]);
    if([object isKindOfClass:[WSProdBean class]])
    {
        WSProdBean* pb = (WSProdBean*)object;
        cell.textLabel.text = pb.name;
    }
    
    if([object isKindOfClass:[WSDictBrand class]])
    {
        WSDictBrand* db = (WSDictBrand*)object;
        cell.textLabel.text = db.dictBean.name;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
    WSListViewController* lvc;
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if([object isKindOfClass:[WSDictBrand class]])
    {
        WSDictBrand* db = (WSDictBrand*)object;
        lvc = [[WSListViewController alloc]initWithArray:db.subDictBrandsArray];
        if(self.currentFuncs.funcsArray != nil || [self.currentFuncs.funcsArray count]>0)
        {
            WSFuncsBean* fb = [self.currentFuncs.funcsArray objectAtIndex:0];
            lvc.currentFuncs = fb;
        }else
            lvc.currentFuncs =self.currentFuncs;
    }
    else //product
        {
            //do some thing
            WSFuncsBean* fb;
            if(self.currentFuncs.funcsArray != nil || [self.currentFuncs.funcsArray count]>0)
            {
                fb= [self.currentFuncs.funcsArray objectAtIndex:0];
            }else
            {
                fb = self.currentFuncs;
            }
            
            WSShowPriceViewController* spvc = [[WSShowPriceViewController alloc]initWithFuncs:fb Store:self.currentStore];
            WSDictBrand* db = [self.dataArray objectAtIndex:indexPath.row];
            spvc.brand = db.dictBean;
//            DictBrand* db = (DictBrand*)object;            
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:spvc animated:YES];
            self.hidesBottomBarWhenPushed = NO;
            return;
            
        }
        if (lvc ==nil) {
        WSFuncsBean* fb;
        if(self.currentFuncs.funcsArray != nil || [self.currentFuncs.funcsArray count]>0)
        {
            fb= [self.currentFuncs.funcsArray objectAtIndex:0];
        }else
        {
            fb = self.currentFuncs;
        }
        
        WSShowPriceViewController* spvc = [[WSShowPriceViewController alloc]initWithFuncs:fb Store:self.currentStore];
            WSDictBrand* db = [self.dataArray objectAtIndex:indexPath.row];
        spvc.brand = db.dictBean;

        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:spvc animated:YES];
        self.hidesBottomBarWhenPushed = NO;
        return;
    }
    
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lvc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

@end
