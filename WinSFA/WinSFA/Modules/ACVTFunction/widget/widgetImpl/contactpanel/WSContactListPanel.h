//
//  WSContactListPanel.h
//  WinSFA
//
//  Created by winchannel on 15/3/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSContactCell.h"



@protocol I_W_ContactDisplay;

@protocol WSContactListPanelDelegate <NSObject>

@optional

-(void)chooseContact:(NSObject<I_W_ContactDisplay> *)contact;

-(void)addOrRemoveContract:(NSObject<I_W_ContactDisplay> *)contract isAdd:(BOOL)foradd;

@end

@interface WSContactListPanel : UIView<UITableViewDataSource,UITableViewDelegate,WSContactCellDelegate>{
    
    
    NSMutableDictionary   *userdict;
    
    UITableView           *tableview;
    
    NSArray        *allkey;
    
    __unsafe_unretained id<WSContactListPanelDelegate> delegate;
    
    NSMutableDictionary   *celldict;
    
    
    
    NSMutableDictionary  *selectedict;
    
    NSArray  *successinvitedarray;
    
}
@property (nonatomic,retain)   NSMutableDictionary   *userdict;

@property (nonatomic,retain)   UITableView           *tableview;

@property (nonatomic,retain)    NSArray        *allkey;

@property (nonatomic,assign)   id<WSContactListPanelDelegate> delegate;


@property (nonatomic,retain)     NSMutableArray *invitearray;

@property (nonatomic,retain)   NSArray  *successinvitedarray;


-(void)loadContactInfo:(NSMutableDictionary *)dict;


-(void)refreshView;


@end
