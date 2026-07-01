//
//  WSContactView.h
//  WinSFA
//
//  Created by winchannel on 15/3/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSBaseView.h"
#import "WSContactListPanel.h"
#import "I_W_ContactDisplay.h"
#import "WSSearchPanel.h"


@protocol WSContactViewDelegate <NSObject>

@optional

-(void)doBack;

-(void)executeInvite;

-(void)sendChooseContact:(NSObject<I_W_ContactDisplay> *)contact;

-(void)searchWithContact:(NSString *)contact;

-(void)doShareInstruction;

@end


@class WSSearchContactListPanel;


@interface WSContactView : WSBaseView<WSSearchPanelDelegate,WSContactListPanelDelegate>{
    
    
    WSSearchPanel   *searchbar;
    
    WSContactListPanel   *contactlistview;
    
    __unsafe_unretained id<WSContactViewDelegate> contact_delegate;
    
    WSSearchContactListPanel   *searchcontactlistview;
    
    BOOL   beginsearch;
    
    NSMutableArray *invitearray;
    
    NSArray *successinvitedarray;
    
    
}
@property (nonatomic, retain) WSSearchPanel *searchbar;

@property (nonatomic,retain) WSContactListPanel   *contactlistview;

@property (nonatomic,retain) WSSearchContactListPanel   *searchcontactlistview;

@property (nonatomic,assign) id<WSContactViewDelegate> contact_delegate;


@property (nonatomic,retain)  NSMutableArray *invitearray;

@property (nonatomic,retain)  NSArray *successinvitedarray;

@property (nonatomic,assign)  BOOL   beginsearch;

-(void)loadContactDict:(NSMutableDictionary *)dict;

-(void)loadSearchContent:(NSMutableArray *)array;

-(void)RefreshView;

@end
