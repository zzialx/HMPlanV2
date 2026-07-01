//
//  NewStarContactWithInviteCell.m
//  NewSolution
//
//  Created by 李振杰 on 14-8-10.
//  Copyright (c) 2014年 com.winchannel. All rights reserved.
//

#import "WSContactWithInviteCell.h"

#import "WidgetConstant.h"

#import "WSOpenCloseBtn.h"


@implementation WSContactWithInviteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
     
        UIImage  *normalimg = WSImg(@"checkbox-unchecked.png");
        
        UIImage  *highimg =WSImg(@"checkbox_select.png");
        
        invitebutton =[[WSOpenCloseBtn alloc] initWithFrame:WSRect(10.0, 10.0 , normalimg.size.width+10.0, normalimg.size.height+10.0) normalimg:normalimg hightlightimg:highimg];
        
        invitebutton.delegate = self;
        
        [self addSubview:invitebutton];
        
        
        contacname.frame =CGRectMake(invitebutton.frame.origin.x+invitebutton.frame.size.width+10.0,
                                 contacname.frame.origin.y, contacname.frame.size.width,
                                 contacname.frame.size.height);
        
        
        
        
    }
    return self;
}


-(void)clearContent{
    
    [super clearContent];
    
    [invitebutton setIsOpen:YES];
    
    [invitebutton setUserInteractionEnabled:YES];
    
}

-(void)updateCell:(NSObject<I_W_ContactDisplay> *)contactx{
    
    
    [super updateCell:contactx];
    
    
    
}


-(void)updateCellStatus:(BOOL)isuse{
    
     [invitebutton setIsOpen:isuse];
    
}

-(void)setNoSelectedForSuccessInvited{
    
    [invitebutton setIsOpen:NO];
    [invitebutton setUserInteractionEnabled:NO];
    
}

#pragma mark -
#pragma mark DropDownButton delegate method

-(void)forOperation:(BOOL)openornot{
    
    if ([delegate respondsToSelector:@selector(sendInviteContact:addOrRemove:)]) {
        
        [delegate sendInviteContact:contact addOrRemove:openornot];
        
    }
    
}


@end
