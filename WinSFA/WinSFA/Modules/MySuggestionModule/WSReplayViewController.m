//
//  ReplayViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSReplayViewController.h"
#import "WSRequestHelper.h"
#import "WSSugReplyBean.h"
#import "WSSendSuggestionViewController.h"
#import "WSCommentCellView.h"

#define GETSUGGESTREPLY         @"getSuggestReply"

@implementation WSReplayViewController
@synthesize m_ReplyArray;
@synthesize m_currentMsgId;
@synthesize m_sugReplyBeanArray;
@synthesize m_HUD;


-(void)setCellColor:(UITableViewCell*)cell IndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row%2 == 0)
    {
        cell.contentView.backgroundColor = [UIColor colorWithRed:245/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
        
    }else
    {
        cell.contentView.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
    }
}

-(void)autoSizeLable:(UILabel*)aLable
{
    aLable.numberOfLines = 0;
    aLable.frame = CGRectMake(aLable.frame.origin.x, 0, 320, 480);
//    [aLable sizeToFit];
}


-(void)uploadFinished:(id)sender
{
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    if(info == nil)
    {
       NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        m_HUD.labelText =tmpString;
        [m_HUD hide:YES afterDelay:1.5];
        return;
    }
    else
    {
       
    }
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        m_HUD.labelText = tmpString;
        [m_HUD hide:YES afterDelay:1.5];
        return;
    }else{
        
        WSSugReplyBeanArray* l_sugRBA = [[WSSugReplyBeanArray alloc]initWithObject:[info objectFromJSONString]];
        self.m_sugReplyBeanArray = l_sugRBA;
        m_ReplyArray = [[NSMutableArray alloc]init];
        [self.m_ReplyArray addObjectsFromArray:l_sugRBA.sugReplyArray];

        NSString *ObtainString = NSLocalizedString(@"obtained_success",nil);
        m_HUD.labelText = ObtainString;

        
//       m_HUD.labelText = @"obtained_success";

        [m_HUD hide:YES afterDelay:1.5];
    }
    [self.tableView reloadData];
}

-(id)initWithMsgId:(NSString*)aMsgId
{
    if(aMsgId == nil)
        return nil;
    
    self = [super initWithStyle:UITableViewStylePlain];
    if(self != nil)
    {
        m_currentMsgId = aMsgId;
         NSString *ReplyString = NSLocalizedString(@"topic_reply",nil);
        self.title = ReplyString;
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

-(void)reloadReplyData
{
   NSString *receiverString = NSLocalizedString(@"receiver",nil);
    NSArray* array = [NSArray arrayWithObjects:receiverString, nil];
    
    WSSendSuggestionViewController* ssvc = [[WSSendSuggestionViewController alloc] initWithTitles:array];
    ssvc.ownParentViewController = self;
    ssvc.m_sugReplyBeanArray = self.m_sugReplyBeanArray;
    ssvc.m_currentMsgId = self.m_currentMsgId;
    
    [self.navigationController pushViewController:ssvc animated:YES];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    m_HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:m_HUD];
   NSString *ReplyString = NSLocalizedString(@"topic_reply",nil);
    UIBarButtonItem *updata = [[UIBarButtonItem alloc]
                               initWithTitle:ReplyString
                               style:UIBarButtonItemStylePlain
                               target:self 
                               action:@selector(reloadReplyData)];
    self.navigationItem.rightBarButtonItem = updata;
    
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
    NSString *GetMString = NSLocalizedString(@"msg_obtaining",nil);
    m_HUD.labelText = GetMString;
    [m_HUD show:YES];
    
    WSRequestHelper* upload = [WSRequestHelper shareInstance];
    [upload getSuggestionReplyList:self.m_currentMsgId Notify:GETSUGGESTREPLY];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadFinished:)
                                                 name:GETSUGGESTREPLY 
                                               object:nil];
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
    return [self.m_ReplyArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WSCommentCellView";
    
    WSCommentCellView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] lastObject];
    }
    
    
    
    // Configure the cell...
    
    WSSugReplyBean* srb = [self.m_ReplyArray objectAtIndex:indexPath.row];
    NSString *SayString = NSLocalizedString(@"say",nil);
    cell.m_person.text = [NSString stringWithFormat:@"%@%@",srb.m_empName,SayString];
    [cell.m_person sizeToFit];
    
    int height = cell.m_person.frame.origin.y;
    height+= cell.m_person.frame.size.height;
    height+=5;
    
    cell.m_content.text = srb.m_REPLY;
    [self autoSizeLable:cell.m_content];
    
    cell.m_content.frame = CGRectMake(cell.m_content.frame.origin.x, height, cell.m_content.frame.size.width - cell.m_content.frame.origin.x, cell.m_content.frame.size.height);
    [cell.m_content sizeToFit];
    height = height+ cell.m_content.frame.size.height;
    
    cell.m_time.text = srb.m_uploadDate;
    cell.m_time.frame = CGRectMake(cell.m_time.frame.origin.x, height, cell.m_time.frame.size.width, cell.m_time.frame.size.height);
    height += cell.m_time.frame.size.height;
    
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y,cell.frame.size.width, height);
    
    
    [self setCellColor:cell IndexPath:indexPath];
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
    NSString *receiverString = NSLocalizedString(@"receiver",nil);
    NSArray* array = [NSArray arrayWithObjects:receiverString,nil];

    WSSendSuggestionViewController* ssvc = [[WSSendSuggestionViewController alloc] initWithTitles:array];
    ssvc.ownParentViewController = self;
    ssvc.m_sugReplyBeanArray = self.m_sugReplyBeanArray;
    ssvc.m_currentMsgId = self.m_currentMsgId;
    
    [self.navigationController pushViewController:ssvc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    int height = cell.frame.size.height;
    return height;
    
}


@end
