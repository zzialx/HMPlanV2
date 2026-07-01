//
//  SingleSelectViewController.m
//  WinChannelFrameWork
//
//  Created by Niu Zhaowang on 9/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSSingleSelectViewController.h"

@interface WSSingleSelectViewController ()

@end

@implementation WSSingleSelectViewController
//@synthesize naviItem = _naviItem;
@synthesize itemArray = _itemArray;
@synthesize itemIds = _itemIds;
@synthesize selectDelegate = _selectDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"back_label" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    // Do any additional setup after loading the view from its nib.
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}
-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.itemArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"singleSelect";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier ];
    if (!cell) 
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [self.itemArray objectAtIndex:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectDelegate != nil && [self.selectDelegate respondsToSelector:@selector(singleSelectView:itemSelected:)]) 
    {
        [self.selectDelegate performSelector:@selector(singleSelectView:itemSelected:) withObject:self withObject:[self.itemArray objectAtIndex:indexPath.row]];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
