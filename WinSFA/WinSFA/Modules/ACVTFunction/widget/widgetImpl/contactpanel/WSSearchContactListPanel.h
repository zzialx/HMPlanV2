//
//  NewStarSearchContactListPanel.h
//  LuckyBee
//
//  Created by 李 振杰 on 13-7-28.
//  Copyright (c) 2013年 新视星空. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSContactListPanel.h"


//需重构
@interface WSSearchContactListPanel : UIView<UITableViewDataSource,UITableViewDelegate>{
    
    
    UITableView *contactlist;
    
    NSMutableArray  *contactarray;
    
   __unsafe_unretained  id<WSContactListPanelDelegate> delegate;
    
    UIImageView  *bgview;
    
    NSMutableDictionary   *celldict;
    
    NSMutableArray *invitearray;
    
    NSMutableDictionary  *selectedict;
}

@property (nonatomic, retain) UITableView *contactlist;

@property (nonatomic,retain)  NSMutableArray  *contactarray;

@property (nonatomic,retain)  NSMutableArray *invitearray;

@property (nonatomic,assign) id<WSContactListPanelDelegate> delegate;

-(void)loadContactList:(NSMutableArray *)data;

-(void)clearContent;

-(void)refreshView;
@end
