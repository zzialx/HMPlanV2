//
//  SuggestListViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSuggestListViewController.h"
#import "WSAppData.h"
#import "WSRequestHelper.h"
#import "WSSuggestListBean.h"
#import "WSReplayViewController.h"
#import "WSContentCellView.h"

#define GETSUGGESTLIST          @"SUGGESTLIST"

@implementation WSSuggestListViewController

@synthesize m_suggestionListArray;
@synthesize m_HUD;


-(void)setCellColor:(UITableViewCell*)cell IndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row%2 == 0)
    {
        cell.contentView.backgroundColor = [UIColor colorWithRed:245/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
        
    }else
    {
//        cell.backgroundView.backgroundColor=[UIColor redColor];
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
        m_HUD.labelText = tmpString;
        [m_HUD hide:YES afterDelay:1.5];
        return;
    }
    else
    {
        WSSuggestionListArray* sla = [[WSSuggestionListArray alloc]initWithObject:[info objectFromJSONString]];
        self.m_suggestionListArray = sla;
        
        [m_HUD hide:YES afterDelay:1.5];
    }
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
       NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        m_HUD.labelText = tmpString;
        [m_HUD hide:YES afterDelay:1.5];
        return;
    }else{
        
        NSString *ObtainString = NSLocalizedString(@"obtained_success",nil);
        m_HUD.labelText = ObtainString;
        [m_HUD hide:YES afterDelay:1.5];
    }
    [self.tableView reloadData];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.tableView];
    
    self.ownParentViewController.navigationItem.rightBarButtonItem = nil;

    m_HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:m_HUD];


}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    NSString *ObtainedString = NSLocalizedString(@"obtaining",nil);
    m_HUD.labelText = ObtainedString;
    [m_HUD show:YES];
    WSRequestHelper* upload = [WSRequestHelper shareInstance];
    [upload getSuggestionList:GETSUGGESTLIST];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadFinished:)
                                                 name:GETSUGGESTLIST
                                               object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [self.m_suggestionListArray.m_suggestListArray count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WSContentCellView";
    WSContentCellView* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] lastObject];
    }
    
    
    int height = 0 ;
    WSSuggestListBean* l_slb = [self.m_suggestionListArray.m_suggestListArray objectAtIndex:indexPath.row];
    NSString *titleString = NSLocalizedString(@"header_title_label",nil);
    cell.m_title.text = [NSString stringWithFormat:titleString,l_slb.m_topic];
    [cell.m_title sizeToFit];
    height = cell.m_title.frame.origin.y;
    height = height+ cell.m_title.frame.size.height+5;
    
    cell.m_content.text = l_slb.m_memo;
    [self autoSizeLable:cell.m_content];
    cell.m_content.frame = CGRectMake(cell.m_content.frame.origin.x, height, cell.m_content.frame.size.width - cell.m_content.frame.origin.x, cell.m_content.frame.size.height);
    [cell.m_content sizeToFit];
    height += cell.m_content.frame.size.height;
    
    cell.m_replyTime.frame = CGRectMake(cell.m_replyTime.frame.origin.x, height, 320, cell.m_replyTime.frame.size.height);
    cell.m_replyTime.text = l_slb.m_biz_date;
    [cell.m_replyTime sizeToFit];
    
    cell.m_replyCount.frame = CGRectMake(cell.m_replyCount.frame.origin.x, height, cell.m_replyCount.frame.size.width, cell.m_replyCount.frame.size.height);
    NSString *ReplyString = NSLocalizedString(@"reply_count",nil);
    cell.m_replyCount.text = [NSString stringWithFormat:@"%@ %@",l_slb.m_replyCount,ReplyString];
    
    [cell.m_replyCount sizeToFit];
    
    height = height + cell.m_replyCount.frame.size.height;
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y,cell.frame.size.width,height+5);
    // Configure the cell...
    
    [self setCellColor:cell IndexPath:indexPath];
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    WSSuggestListBean* l_slb = [self.m_suggestionListArray.m_suggestListArray objectAtIndex:indexPath.row];

    WSReplayViewController* replayVC = [[WSReplayViewController alloc]initWithMsgId:l_slb.m_id];

    [self.ownParentViewController.navigationController pushViewController:replayVC animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}


@end
