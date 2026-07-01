//
//  WCSubMsgsViewController.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 10/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSSubMsgsViewController.h"
#import "WSMsgContentViewController.h"
#import "WSMsgsBean.h"
#import "WSMsgsBean_msg.h"
#import "WSAppData.h"
#import "WSChatViewController.h"
#import "WSReportFormController.h"

#define currentDeviceIsIphone  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

@interface WSSubMsgsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *iTableView;

- (void)settingCellImage:(UITableViewCell *)aCell withMsg:(WSMsgsBean_msg *)aMsg;

@end

@implementation WSSubMsgsViewController
@synthesize iMsgBean = _iMsgBean;
@synthesize iTableView = _iTableView;


#pragma mark - init and dealloc
- (id)init
{
    self = [super init];
    if (self) {
        // Do something
    }
    return  self;
}

- (id)initWithMsgsBean:(WSMsgsBean *)aMsgsBean
{
    self = [super init];
    if (self) {
        _iMsgBean = aMsgsBean;
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - view cycle
- (void)loadView
{
    UIView *mainview = [[UIView alloc] initWithFrame:CGRectZero];
    mainview.autoresizesSubviews = YES;
    mainview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view = mainview;
    
//    CGRect tvrect = [[UIScreen mainScreen] bounds];
//    if (!([[UIDevice currentDevice] systemVersionByFloat] < 7.0)) {
//        tvrect = CGRectMake(0,0, tvrect.size.width, tvrect.size.height + 35);
//    }
    _iTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _iTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _iTableView.backgroundColor = [UIColor whiteColor];
    _iTableView.backgroundView = nil;
    _iTableView.delegate = self;
    _iTableView.dataSource = self;
    [self.view addSubview:_iTableView];
    
    UIView* view = [[UIView alloc] init];
    self.iTableView.tableFooterView = view;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.iTableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)markMsgAsReaded:(WSMsgsBean_msg *)msg
{
    if (msg == nil || msg.s == nil || msg.Id == nil) {
        return;
    }
    
    NSNumber *value = [NSNumber numberWithBool:YES];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@#%@#%@", msg.s, msg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    if (value) {
        [dicInfo setObject:value forKey:key];
    }
    
    if (dicInfo) {
        [user setObject:dicInfo forKey:kWSMessageDomainName];
    }
    
    [user synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
}

#pragma mark - tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.iMsgBean.msg count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *subMsgIndentify = @"WSSubMsgsViewController";
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:subMsgIndentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:subMsgIndentify];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:UI_Font];
    cell.imageView.image = nil;
    WSMsgsBean_msg *submsg = (WSMsgsBean_msg *)[self.iMsgBean.msg objectAtIndex:indexPath.row];
    [self settingCellImage:cell withMsg:submsg];
    cell.textLabel.text = submsg.title;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WSMsgsBean_msg *msg = (WSMsgsBean_msg *)[self.iMsgBean.msg objectAtIndex:indexPath.row];
    if ([msg.visitAddress length] > 0) {
        NSURL *url = [[NSURL alloc] initWithString:msg.visitAddress];
        WSReportFormController *con = [[WSReportFormController alloc] initWithURL:url];
        LogInfo(@"Going to class WSReportFormController");
        [self.navigationController pushViewController:con animated:YES];
        [self markMsgAsReaded:msg];
    }else {
        WSMsgContentViewController *convc = [[WSMsgContentViewController alloc] initWithMessage:msg];
        LogInfo(@"Going to class WSMsgContentViewController");
        [self.navigationController pushViewController:convc animated:YES];
    }
}


#pragma mark - private message
- (void)settingCellImage:(UITableViewCell *)aCell withMsg:(WSMsgsBean_msg *)aMsg
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *dicInfo = [user dictionaryForKey:kWSMessageDomainName];
    NSString *key = [NSString stringWithFormat:@"%@#%@#%@", aMsg.s, aMsg.Id, [WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSNumber *number = [dicInfo objectForKey:key];
    if (number && [number boolValue]) {
        aCell.imageView.image = [UIImage imageNamed:@"bulletinboard_read_message.png"];
//        NSString *readStr = NSLocalizedString(@"readed", nil);
//        aCell.detailTextLabel.text = readStr;
    }else{
//        NSString *unreadStr = NSLocalizedString(@"unread", nil);
//        aCell.detailTextLabel.text = unreadStr;
        aCell.imageView.image = [UIImage imageNamed:@"bulletinboard_unread_message.png"];
    }
}

@end



