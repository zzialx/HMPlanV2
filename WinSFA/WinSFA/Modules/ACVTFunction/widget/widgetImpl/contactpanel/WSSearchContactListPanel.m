//
//  NewStarSearchContactListPanel.m
//  LuckyBee
//
//  Created by 李 振杰 on 13-7-28.
//  Copyright (c) 2013年 新视星空. All rights reserved.
//

#import "WSSearchContactListPanel.h"
#import "WSContactListPanel.h"
#import "WSContactCell.h"
#import "I_W_ContactDisplay.h"
#import "WSContactWithInviteCell.h"

@interface WSSearchContactListPanel ()<WSContactCellDelegate>

@end

@implementation WSSearchContactListPanel

@synthesize contactlist;

@synthesize contactarray;

@synthesize invitearray;

@synthesize delegate;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        selectedict =[[NSMutableDictionary alloc] init];
        
     
        
        invitearray =[[NSMutableArray alloc] init];
        
        bgview=[[UIImageView alloc] initWithFrame:self.bounds];
        
        [self addSubview:bgview];
    
        [self buildTableView];
        
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return cell.frame.size.height;
}

- (void)buildTableView
{
    contactlist = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0,self.frame.size.height,self.frame.size.width) style:UITableViewStylePlain];
    
    contactlist.delegate = self;
    
    contactlist.dataSource = self;
    
    contactlist.backgroundColor = [UIColor clearColor];
    
    contactlist.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self addSubview:contactlist];
    
  
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (contactarray == nil) {
        
        return 0;
    }
    return [contactarray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId=@"anycell";
    
    WSContactCell * cell=  [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if(cell==nil){
        
        
        cell =[[WSContactWithInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    cell.delegate =self;
    
    NSObject<I_W_ContactDisplay>  *contact= [contactarray objectAtIndex:[indexPath row]];
    
    [cell clearContent];
    
    [cell updateCell:contact];
    
    if ([selectedict valueForKey:[contact getContactMobile]]!=nil) {
        
        [cell updateCellStatus:NO];
        
    }
    
    return (UITableViewCell *)cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject<I_W_ContactDisplay> *selectedcontact=[contactarray objectAtIndex:[indexPath row]];
    
    
    if ([delegate respondsToSelector:@selector(chooseContact:)]) {
        
        [delegate chooseContact:selectedcontact];
    
    }
    
    
}

-(void)loadContactList:(NSMutableArray *)data{
    
    
   
    contactarray = data;
    
    contactlist.dataSource=self;
    
    contactlist.delegate=self;
    
    [contactlist reloadData];
    
    
}


-(void)refreshView{
    
    [selectedict  removeAllObjects];
    contactlist.delegate = self;
    contactlist.dataSource = self;
    [contactlist reloadData];
    
}

-(void)clearContent{
    
    
    [contactarray removeAllObjects];
    contactlist.delegate=self;
    contactlist.dataSource=self;
    
    [contactlist reloadData];
}


#pragma mark -
#pragma mark NewStarContactCellDelegate method 
-(void)sendInviteContact:(NSObject<I_W_ContactDisplay> *)contract addOrRemove:(BOOL)isadd{
    
    
    [selectedict setValue:contract forKey:[contract getContactMobile]];
    
    if ([delegate respondsToSelector:@selector(addOrRemoveContract:isAdd:)]) {
        
        [delegate addOrRemoveContract:contract isAdd:isadd];
        
    }
    
}




@end
