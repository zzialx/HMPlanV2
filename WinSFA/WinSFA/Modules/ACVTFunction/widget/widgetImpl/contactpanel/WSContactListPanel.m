//
//  WSContactListPanel.m
//  WinSFA
//
//  Created by winchannel on 15/3/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSContactListPanel.h"
#import "I_W_ContactDisplay.h"
#import "WSContactWithInviteCell.h"

#define CONTACT_INDEX_KEY [[NSArray alloc]initWithObjects:@"#",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil]


@implementation WSContactListPanel
@synthesize tableview;
@synthesize userdict;
@synthesize allkey;
@synthesize delegate;
@synthesize invitearray;
@synthesize successinvitedarray;




- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        selectedict =[[NSMutableDictionary alloc] init];
        
 
        
        [self buildTableView];
    }
    return self;
}

- (void)buildTableView
{
    tableview = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    
    [self addSubview:tableview];
 
}

#pragma mark -- tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [CONTACT_INDEX_KEY count] ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSMutableArray  *array=[userdict valueForKey:[CONTACT_INDEX_KEY objectAtIndex:section]];
    
    return [array count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 24.5f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return cell.frame.size.height;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    NSString *sectionName=@"";
    
    sectionName = [CONTACT_INDEX_KEY objectAtIndex:section];
    
    UIView  *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 24.5)] ;
    
    view.backgroundColor = [UIColor colorWithHexString:@"#2bcfd5"];
    
    UILabel *label=[[UILabel alloc] initWithFrame: CGRectMake(15, 0, 320, 24.5)];
    
    label.backgroundColor=[UIColor clearColor];
    
    label.textColor=[UIColor whiteColor];
    
    label.font=[UIFont boldSystemFontOfSize:15.0f];
    
    label.text=sectionName;
    
    [view addSubview:label];
    
    
    
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId=@"contactcell";
    
    
    WSContactCell * cell=  [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if(cell==nil){
        
        cell =[[WSContactWithInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    cell.delegate = self;
    
    NSString *key =[CONTACT_INDEX_KEY objectAtIndex:indexPath.section];
    
    NSMutableArray   *subarray =[userdict valueForKey:key];
    
    NSObject<I_W_ContactDisplay> *contact =[subarray objectAtIndex:indexPath.row];
    
    [cell clearContent];
    
    [cell updateCell:contact];
    
    if ([selectedict valueForKey:[contact getContactMobile]]!=nil) {
        
        [cell updateCellStatus:NO];
        
    }
    
    if ([self isSuccessInvited:contact]) {
        
        [cell setNoSelectedForSuccessInvited];
        
    }
    return (UITableViewCell *)cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString  *key=[CONTACT_INDEX_KEY objectAtIndex:indexPath.section];
    
    NSObject<I_W_ContactDisplay>  *contact =[[userdict valueForKey:key] objectAtIndex:indexPath.row];
    
    
    if ([delegate respondsToSelector:@selector(chooseContact:)]) {
        
        [delegate chooseContact:contact];
    }
    
}



- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return CONTACT_INDEX_KEY;
}

-(void)loadContactInfo:(NSMutableDictionary *)dict{
    
 
    userdict = dict;
    
    allkey = [userdict allKeys];
    
    tableview.delegate = self;
    
    tableview.dataSource = self;
    
    [tableview reloadData];
    
}

-(void)refreshView{
    
    [selectedict removeAllObjects];
    
    tableview.delegate = self;
    
    tableview.dataSource = self;
    [tableview reloadData];
    
}

#pragma mark -
#pragma mark NewStarContactCellDelegate method

#pragma mark -
#pragma mark NewStarContactCellDelegate method


-(void)sendInviteContact:(NSObject<I_W_ContactDisplay> *)contract addOrRemove:(BOOL)isadd{
    
    if (isadd) {
        
        [selectedict setValue:contract forKey:[contract getContactMobile]];
        
        
    }else{
        
        [selectedict removeObjectForKey:[contract getContactMobile]];
    }
    
    if ([delegate respondsToSelector:@selector(addOrRemoveContract:isAdd:)]) {
        
        [delegate addOrRemoveContract:contract isAdd:isadd];
        
        
    }
    
    
}

-(BOOL)isSuccessInvited:(NSObject<I_W_ContactDisplay> *)contact{
    
    
    for (int i=0; i<[successinvitedarray count]; i++) {
        
        
        NSString *mobilenumber =[successinvitedarray objectAtIndex:i];
        
        if ([mobilenumber isEqualToString:[contact getContactMobile]]) {
            
            return YES;
            
        }
        
    }
    return NO;
}

@end
