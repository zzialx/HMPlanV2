//
//  WSContactView.m
//  WinSFA
//
//  Created by winchannel on 15/3/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSContactView.h"
#import "WSContactListPanel.h"
#import "WidgetConstant.h"
#import "WSSearchContactListPanel.h"
#import "WSSearchPanel.h"
#import "I_W_ContactDisplay.h"



@implementation WSContactView
@synthesize searchbar;
@synthesize contactlistview;
@synthesize contact_delegate;
@synthesize searchcontactlistview;
@synthesize beginsearch;
@synthesize invitearray;
@synthesize successinvitedarray;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        [self buildView];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
    }
    return self;
}

- (BOOL)buildView
{
    BOOL isbuild=NO;
    
    invitearray =[[NSMutableArray alloc] init];
    
    [self buildSearchPanel];
    
    [self createNavigationAndTableview];
    
    
    
    isbuild =YES;
    
    return isbuild;
    
}

- (void)createNavigationAndTableview
{
    
    
    contactlistview = [[WSContactListPanel alloc] initWithFrame:WSRect(searchbar.frame.origin.x,
                                                                            searchbar.frame.origin.y+searchbar.frame.size.height,
                                                                            self.frame.size.width, self.frame.size.height-searchbar.frame.size.height-70)];
    
    [contactlistview setBackgroundColor:[UIColor whiteColor]];
 
    contactlistview.delegate=self;
    
    
    [self addSubview:contactlistview];
    
    
    
    searchcontactlistview = [[WSSearchContactListPanel alloc] initWithFrame:WSRect(searchbar.frame.origin.x,
                                                                                        searchbar.frame.origin.y+searchbar.frame.size.height,
                                                                                        self.frame.size.width, self.frame.size.height-searchbar.frame.size.height-70)];
    
    searchcontactlistview.delegate=self;
    
    [self addSubview:searchcontactlistview];
    
    [searchcontactlistview setHidden:YES];
    
}

- (void)createNavgationWidget
{
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [left setFrame:WSRect(15, 5, 33, 34)];
}


-(void)buildSearchPanel{
    
    CGRect rect = WSRect(75.0, 10.0, 804, 64.0/2.0);
    
    searchbar =[[WSSearchPanel alloc] initWithFrame:WSRect(0.0, 70.0, self.frame.size.width
                                                                , 50.0) style:STYLE_CN searchRect:rect soundsoundSearc:NO];
    [searchbar buildDisplayContent];
    
    [searchbar setSearchPanelPlaceHolderText:@""];
    
    [searchbar setSearchPanelTextColor:[UIColor orangeColor]];
    
    [searchbar setSearchPanelTextAlignment:NSTextAlignmentCenter];
    
    [searchbar setSearchPanelTextFont:[UIFont systemFontOfSize:14.0]];
    
    searchbar.delegate=self;
    
    [self addSubview:searchbar];
    
    
}

-(void)loadContactDict:(NSMutableDictionary *)dict{
    
    [contactlistview setSuccessinvitedarray:successinvitedarray];
    
    
    [contactlistview loadContactInfo:dict];
    
}

#pragma mark -
#pragma mark NewStarNavigationBarDelegate method

-(void)leftbuttonAction{
    
    if ([contact_delegate respondsToSelector:@selector(doBack)]) {
        
        [contact_delegate doBack];
    }
}

#pragma mark -
#pragma mark NewStarContactListPanelDelegate method

-(void)chooseContact:(NSObject<I_W_ContactDisplay> *)contact{
    
    if ([contact_delegate respondsToSelector:@selector(sendChooseContact:)]) {
        
        [contact_delegate sendChooseContact:contact];
        
    }
    
}
#pragma mark -

#pragma mark NewStarSearchPanelDelegate method


-(void)doSearchWithContent:(NSString *)content {
    
    [searchcontactlistview setHidden:NO];
    
    if ([contact_delegate respondsToSelector:@selector(searchWithContact:)]) {
        
        [contact_delegate searchWithContact:content];
        
    }
    
}


-(void)searchBarBeginSearch:(WSSearchPanel *)panel
{
    
    beginsearch =YES;
    
    [searchbar setSearchPanelPlaceHolderText:@""];
    
}

-(void)searchBarEndSearch:(WSSearchPanel *)panel
{
    
    
    [searchbar setSearchPanelPlaceHolderText:@""];
    
    [searchbar setSearchPanelTextColor:[UIColor grayColor]];
    
    
    [searchbar setSearchPanelTextAlignment:NSTextAlignmentCenter];
    
    
    [searchcontactlistview  clearContent];
    
    [searchcontactlistview refreshView];
    
    [searchcontactlistview setHidden:YES];
    
    [contactlistview setHidden:NO];
    
    
    
    
}
-(void)searchWithSensitive:(NSString *)content{
    
    [searchcontactlistview setHidden:NO];
    
    if ([contact_delegate respondsToSelector:@selector(searchWithContact:)]) {
        
        [contact_delegate searchWithContact:content];
        
    }
}

-(void)allclearNotify{
    
    
    [searchcontactlistview clearContent];
    
    [searchcontactlistview setHidden:YES];
    
}

-(void)loadSearchContent:(NSMutableArray *)array{
    
    [searchcontactlistview loadContactList:array];
    
    [contactlistview setHidden:YES];
    
}




-(void)addOrRemoveContract:(NSObject<I_W_ContactDisplay> *)contract isAdd:(BOOL)foradd{
    
    
    if (foradd) {
        
        //添加
        if (![self isContainTheContract:contract]) {
            
            [invitearray addObject:contract];
            
        }
        
    }else{
        //移除
        
        
        [self removeContract:contract];
        
    }
    
    
}


-(BOOL)isContainTheContract:(NSObject<I_W_ContactDisplay> *)contract{
    
    for (int i=0; i<[invitearray count]; i++) {
        
        NSObject<I_W_ContactDisplay>  *ccontract =[invitearray objectAtIndex:i];
        
        if ([[ccontract getContactMobile] isEqualToString:[contract getContactMobile]]) {
            
            
            return YES;
            
        }
        
    }
    return NO;
    
}

-(void)removeContract:(NSObject<I_W_ContactDisplay> *)contract{
    
    for (int i=0; i<[invitearray count]; i++) {
        
        NSObject<I_W_ContactDisplay>  *ccontract =[invitearray objectAtIndex:i];
        
        if ([[ccontract getContactMobile] isEqualToString:[contract getContactMobile]]) {
            
            [invitearray removeObjectAtIndex:i];
        }
        
    }
    
}


-(void)RefreshView{
    
    
    [invitearray removeAllObjects] ;
    
    [contactlistview refreshView];
    
    [searchcontactlistview refreshView];
    
    
}



@end
