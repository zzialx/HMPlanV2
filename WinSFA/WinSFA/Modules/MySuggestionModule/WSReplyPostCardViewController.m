//
//  ReplyPostCardViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSReplyPostCardViewController.h"
#import "WSSugReplyOptBean.h"
#import "WSNavigationBar.h"


@implementation WSReplyPostCardViewController
@synthesize m_MarkDictionary;
@synthesize m_CardArray = _m_CardArray;
@synthesize m_isReceiver = _m_isReceiver;

-(void)hasAddCardOk
{
    NSDictionary* userInfo = nil; 
    if(self.m_isReceiver) //如果是收件人 就使userinfo不为空
    {
        userInfo = [NSDictionary dictionaryWithObject:@"1" forKey:@"xxx"];//随便写的就是为不为空
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:POSTCARDRECEIVE object:self.m_MarkDictionary userInfo:userInfo ];
    
    NSInteger l_count = [self.navigationController.viewControllers count];
    if(l_count > 1)
    {
        id l_parentController = [self.navigationController.viewControllers objectAtIndex:l_count-2];
        [self.navigationController popToViewController:l_parentController animated:YES];
        
    }
    
}

-(id)initWithOptArray:(NSArray*)aArray;
{
    if([aArray count]<1)
        return nil;
    
    self = [super initWithStyle:UITableViewStylePlain];
    if(self != nil)
    {
        _m_CardArray = [[NSMutableArray alloc] init];
        [_m_CardArray addObjectsFromArray:aArray];
        m_MarkDictionary = [[NSMutableDictionary alloc]init];
        return self;
    }
    return nil;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSString *CompleteString = NSLocalizedString(@"complete",nil);
//    UIBarButtonItem *updata = [[UIBarButtonItem alloc]
//                               initWithTitle:CompleteString 
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
//        [self leftItemImage:@"nav_back_btn.png" target:self action:@selector(hasAddCardOk) title:CompleteString font:font buttonWidth:60 fontLeftWith:fontWidth];
       
        
        [self backItemAction:@selector(hasAddCardOk) target:self];
        //[self backItemAction:nil target:nil];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.m_CardArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    WSSugReplyOptBean* l_sugBean = [self.m_CardArray objectAtIndex:indexPath.row];
    cell.textLabel.text = l_sugBean.m_name;
    return cell;
    
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
    WSSugReplyOptBean* l_sugBean = [self.m_CardArray objectAtIndex:indexPath.row];
    
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
