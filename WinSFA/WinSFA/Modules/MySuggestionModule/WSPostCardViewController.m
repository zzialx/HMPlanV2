//
//  PostCardViewController.m
//  Suggestion
//
//  Created by winchannel on 12-2-18.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSPostCardViewController.h"
#import "WSAppData.h"
#import "WSSugBean.h"
#import "WSSugBeanArray.h"
#import "WSNavigationBar.h"


@implementation WSPostCardViewController
@synthesize m_MarkDictionary;
@synthesize m_CardArray = _m_CardArray;

-(void)goBack
{
    NSInteger l_count = [self.navigationController.viewControllers count];
    if(l_count > 1)
    {
        id l_parentController = [self.navigationController.viewControllers objectAtIndex:l_count-2];
        [self.navigationController popToViewController:l_parentController animated:YES];
        
    }
}

-(void)hasAddCardOk
{
    [[NSNotificationCenter defaultCenter] postNotificationName:POSTCARDRECEIVE object:self.m_MarkDictionary userInfo:nil ];
    [self goBack];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

        m_MarkDictionary = [[NSMutableDictionary alloc]init];
        _m_CardArray = [[NSMutableArray alloc]init];
        WSSugBeanArray* l_sugBeanArray = [WSAppData getObjectbyKey:SUG];
        [_m_CardArray addObjectsFromArray:l_sugBeanArray.sugArray];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSString *DoneString = NSLocalizedString(@"complete",nil);
//    UIBarButtonItem *updata = [[UIBarButtonItem alloc]
//                               initWithTitle:DoneString 
//                               style: UIBarButtonItemStylePlain
//                               target:self 
//                               action:@selector(hasAddCardOk)];
//    self.navigationItem.leftBarButtonItem = updata;
    if (self.navigationController.viewControllers.count>1) {
//        UIFont *font = nil;
//        CGFloat fontWidth = 0;
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
//            font = [UIFont systemFontOfSize:18];
//            fontWidth = 17;
//        }else {
//            font = [UIFont systemFontOfSize:16];
//            fontWidth = 8;
//        }
//        [self leftItemImage:@"nav_back_btn.png" target:self action:@selector(hasAddCardOk) title:DoneString font:font buttonWidth:60 fontLeftWith:fontWidth];
        [self backItemAction:@selector(hasAddCardOk) target:self];
    }
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.m_CardArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIdentifier = @"mycell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {  
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier: SimpleTableIdentifier];
    }
    
    // Configure the cell...
    WSSugBean* l_sugBean = [self.m_CardArray objectAtIndex:indexPath.row];
    cell.textLabel.text = l_sugBean.m_name;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    NSNumber* l_key = [NSNumber numberWithInteger:indexPath.row];
    WSSugBean* l_sugBean = [self.m_CardArray objectAtIndex:indexPath.row];

    id l_one = [self.m_MarkDictionary objectForKey:[l_key stringValue]];
    if(nil ==l_one)
    {
        //添加标记
        if (l_sugBean) {
            [self.m_MarkDictionary setObject:l_sugBean forKey:[l_key stringValue]];
        }
    }
    else
    {
        //移除标记
        [self.m_MarkDictionary removeObjectForKey:[l_key stringValue]];
    }
    [self.tableView reloadData];
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    NSNumber* l_key = [NSNumber numberWithInteger:indexPath.row];
    if([self.m_MarkDictionary objectForKey:[l_key stringValue]]==nil)
    {
        return UITableViewCellAccessoryNone;
    }
    else
    {
        return  UITableViewCellAccessoryCheckmark;
    }
    
}

@end
