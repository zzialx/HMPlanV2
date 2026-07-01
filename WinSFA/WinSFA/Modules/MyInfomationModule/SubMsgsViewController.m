//
//  SubMsgsViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SubMsgsViewController.h"
#import "WSMsgsBean.h"
#import "WSMsgsBean_msg.h"
#import "WSMsgContentController.h"
#import "FileManager.h"

@implementation SubMsgsViewController
@synthesize titlesTableView = _titlesTableView;
@synthesize msgs = _msgs;

-(void)allUsersKeys
{

}
-(void)StoreReadInfo:(WSMsgsBean_msg*)msg
{
    NSMutableArray* newArray = [[NSMutableArray alloc]init];
    NSArray* oldArray = (NSArray*)[FileManager getUserDefaults:msg.s];
    if( oldArray != nil)
    {
        for(NSString* oldObject in oldArray)
        {
            NSString* l_oldMsg = [NSString stringWithValue:oldObject];
            NSString* l_newMsg = [NSString stringWithValue:msg.Id];
            //已读的不添加
            if([l_oldMsg isEqualToString:l_newMsg])
            {
                return;
            }
            [newArray addObject:oldObject];
        }
    }
    [newArray addObject:msg.Id];
    [FileManager setUserDefaults:newArray forKey:msg.s];
}
-(id)init
{
    self = [super init];
    if(self != nil)
    {
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

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    UITableView* tv = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 420) style:UITableViewStyleGrouped];
    [tv setDelegate:self];
    [tv setDataSource:self];
    self.titlesTableView = tv;
    [self.view addSubview:self.titlesTableView];
    
}


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

#pragma mark -tabview delegate

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.msgs.msg count];
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {  
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier: SimpleTableIdentifier];
    }
    
    WSMsgsBean_msg* msgsB_msg = [self.msgs.msg objectAtIndex:indexPath.row]; 
    cell.textLabel.text = msgsB_msg.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    WSMsgsBean_msg* msgsB_msg = [self.msgs.msg objectAtIndex:indexPath.row]; 
    [self StoreReadInfo:msgsB_msg];
    
    WSMsgContentController* content = [[WSMsgContentController alloc]initWithNibName:@"WSMsgContentController" MSG:msgsB_msg];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:content animated:YES];
    
}

@end
