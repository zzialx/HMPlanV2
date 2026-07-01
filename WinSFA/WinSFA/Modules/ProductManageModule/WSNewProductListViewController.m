//
//  NewProductListViewController.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 8/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSNewProductListViewController.h"
#import "WSAddProductTable.h"
#import "WSAddNewProductViewController.h"
#import "WSAddProductQstTable.h"


@interface WSNewProductListViewController()

@property (nonatomic, strong)NSMutableArray* iProductArray;
@property (nonatomic, strong)UITableView* iTableView;

@end

@implementation WSNewProductListViewController

@synthesize iProductArray = _iProductArray;
@synthesize iTableView = _iTableView;

#pragma mark - class init & dealloc

- (id)init
{
    self = [super init];
    return self;
}


#pragma mark - view lifecycle

- (void)loadView
{
    [super loadView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNewProduct:) name:NEWPRODUCT object:nil];
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    self.iProductArray = array;
    
    // add data to the array
    NSArray* productQstInfo = [[WSAddProductTable sharedTable] queryAllProduct];
    [self.iProductArray addObjectsFromArray:productQstInfo];
    
    UITableView* view = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64) style:UITableViewStylePlain];
    self.iTableView = view;
    self.iTableView.dataSource = self;
    self.iTableView.delegate = self;
    [self.view addSubview:self.iTableView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.iProductArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProductCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

//    WSAddProductObject* object= [self.iProductArray objectAtIndex:indexPath.row];
//    cell.textLabel.text = object.opt_val;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString* nid = [NSString stringWithFormat:@"%d",[[self.iProductArray objectAtIndex:indexPath.row] ID]];
    NSArray* productinfo = [[WSAddProductQstTable sharedTable] queryQstByAnsId:nid andQstId:nil];

    if (productinfo != nil) {
        WSAddNewProductViewController* vc = [[WSAddNewProductViewController alloc] initWithFuncs:self.currentFuncs 
                                                                               ProductInfoArray:productinfo];
        [self.ownParentViewController.navigationController pushViewController:vc animated:YES];
    }
}

-(void)receiveNewProduct:(id)sender
{
    [self.iProductArray removeAllObjects];
    NSArray* qstinfo = [[WSAddProductTable sharedTable] queryAllProduct];
    [self.iProductArray addObjectsFromArray:qstinfo];
    [self.iTableView reloadData];
}


@end
