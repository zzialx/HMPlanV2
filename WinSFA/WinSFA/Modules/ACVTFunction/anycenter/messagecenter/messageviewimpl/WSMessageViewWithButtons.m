//
//  WSMessageViewButton.m
//  WinSFA
//
//  Created by winchannel on 15/3/31.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMessageViewWithButtons.h"
#import "I_M_View.h"
#import "I_M_Display.h"
#import "I_M_ViewDelegate.h"
#import "BlockAlertView.h"
#import "MBProgressHUD.h"

@implementation WSMessageViewWithButtons

@synthesize opdelegate;

-(void)showCurrentMessageView:(NSObject<I_M_Display> *)messageobj{
    
    blockview = [[BlockAlertView alloc] initWithTitle:[messageobj getDisplayTitle] message:[messageobj getDisplayMessage]];
    
    if ([messageobj getDisplayButtons]!=nil) {
        
        for (int i=0; i<[[messageobj getDisplayButtons] count]; i++) {
            
        NSString *title = [[messageobj getDisplayButtons] objectAtIndex:i];
        [blockview addButtonWithTitle:title block:^{
            
        }];
            
        }
    }
    
    [blockview setOpdelegate:self];
    
    [blockview show];
    
}


-(void)hiddenMessageView{
    
    
    
    
}

-(void)setMessageDelegate:(NSObject<I_M_ViewDelegate> *)operationdelegate{
    
    opdelegate = operationdelegate;
    
}


#pragma mark -
#pragma mark I_OP_BlockAlertViewDelegate method

-(void)clickBtnAtIndex:(NSInteger)index inBlockView:(BlockAlertView *)blockview{
    
    if ([opdelegate respondsToSelector:@selector(MessageView:clickAtButtonIndex:)]) {
        
        [opdelegate MessageView:(NSObject <I_M_View>*)self clickAtButtonIndex:index];
        
    }
}
@end
