//
//  WSNewSubMsgsViewController.m
//  WinSFA
//
//  Created by xiajl on 14-10-27.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSNewSubMsgsViewController.h"
#import "WSMsgContentViewController.h"
#import "WSMsgsBean.h"
#import "WSMsgsBean_msg.h"
#import "WSAppData.h"
#import "WSSubMsgTableViewCell.h"
#import "WSServerIPList.h"
#import "WSRequestHelper.h"
#import "NSString+ServerUrl.h"

@interface WSNewSubMsgsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *iTableView;
@property (nonatomic ,strong)NSMutableArray *msgArray;
@end

@implementation WSNewSubMsgsViewController
@synthesize iMsgBean = _iMsgBean;
@synthesize iTableView = _iTableView;


#pragma mark - init and dealloc

- (id)initWithMsgsBean:(WSMsgsBean *)aMsgsBean
{
    self = [super init];
    if (self) {
        _iMsgBean = aMsgsBean;
        
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
    self.msgArray = [NSMutableArray arrayWithArray:self.iMsgBean.msg];
    for (WSMsgsBean_msg *msg in self.msgArray) {
        msg.isViewed = [self checkReadStatusWithMsg:msg];
    }
    NSSortDescriptor* sortByA = [NSSortDescriptor sortDescriptorWithKey:@"isViewed" ascending:YES];
    NSSortDescriptor* sortByB = [NSSortDescriptor sortDescriptorWithKey:@"pubdate" ascending:NO];
    self.msgArray = [[NSMutableArray alloc]initWithArray:[self.msgArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortByA,sortByB, nil]]];
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

#pragma mark - tableview datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 116;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.msgArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *subMsgIndentify = @"WSSubMsgsViewController";
    WSSubMsgTableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:subMsgIndentify];
    if (!cell) {
        cell = [[WSSubMsgTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:subMsgIndentify];
    }
    [cell removeProgressView];
    [cell addProgressView];
    WSMsgsBean_msg *submsg = (WSMsgsBean_msg *)[self.msgArray objectAtIndex:indexPath.row];
    if (submsg.url && [submsg.url length] > 0) {
        cell.imageURLString = [submsg.url buildupUrl];
        
        [[WSRequestHelper shareInstance] downloadImageWithUrl:cell.imageURLString imageView:cell.msg_imageView placeholderImage:[UIImage imageNamed:@"place_holder"] progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            float percent = (float)receivedSize/(float)expectedSize;
            cell.progressView.progress = percent;
        } completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
            [cell.progressView removeFromSuperview];
            cell.progressView = nil;
        }];
    }else{
        cell.imageURLString = nil;
    }
    cell.msgTitle_label.text = submsg.title;
    cell.msgContent_label.text = submsg.cont && [submsg.cont length] > 48 ? [submsg.cont substringToIndex: 48] : submsg.cont ;
    cell.msgDate_label.text = [submsg.pubdate substringToIndex:10];
    [cell.navButton setTitle:self.categoryTitle forState:UIControlStateNormal];
    [cell.navButton setTitle:self.categoryTitle forState:UIControlStateSelected];
    [cell.navButton removeTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    [cell.navButton addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    cell.navButton.tag = submsg.categoryIndex;
    [cell setReadStatus:[self checkReadStatusWithMsg:submsg] ? ECELLTAGStatusRead : ECELLTAGStatusUnread];
    return cell;
}

- (void)select:(UIButton *)sender
{
    [self.iTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:MessageCellButtonClickedNotification object:[NSNumber numberWithInteger:sender.tag]];
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WSMsgsBean_msg *msg = (WSMsgsBean_msg *)[self.msgArray objectAtIndex:indexPath.row];
    if (msg) {
        WSMsgContentViewController *convc = [[WSMsgContentViewController alloc] initWithMessage:msg];
        [self.navigationController pushViewController:convc animated:YES];
    }
}


#pragma mark - private message
- (BOOL)checkReadStatusWithMsg:(WSMsgsBean_msg *)aMsg
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *dicInfo = [user dictionaryForKey:kWSMessageDomainName];
    NSString *key = [NSString stringWithFormat:@"%@#%@#%@", aMsg.s, aMsg.Id, [WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSNumber *number = [dicInfo objectForKey:key];
    if (number && [number boolValue]) {
        return YES;
    }else{
        return NO;
    }
}


- (BOOL) isScrolling
{
    if (self.iTableView
        && (self.iTableView.tracking
            || self.iTableView.dragging
            || self.iTableView.decelerating)) {
            return YES;
    }
    return NO;
}
@end
