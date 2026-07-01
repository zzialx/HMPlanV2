//
//  WSMultiMobileTextFieldPanel.m
//  WinSFA
//
//  Created by winchannel on 15/3/20.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMultiMobileTextFieldPanel.h"
#import "WidgetConstant.h"
#import "WSInterAction.h"
#import "I_W_BuildInfo.h"
#import "I_M_ViewDelegate.h"
#import "I_M_View.h"

#define Operation_CLASS @"WSContactViewController"



@implementation WSMultiMobileTextFieldPanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        
        return self;
    }
    return nil;
}

-(void)buildDisplayContent{
    
    [super buildDisplayContent];
    
    textField.frame = WSRect(textField.frame.origin.x, textField.frame.origin.y, textField.frame.size.width-30.0, textField.frame.size.height);
    
    contactBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    
    contactBtn.frame = WSRect(textField.frame.origin.x+textField.frame.size.width+2.0, textField.frame.origin.y, 28.0, textField.frame.size.height);
    
    UIImage  *contact_btn_img = WSImg(@"contactbtn.png");
    
    
    [contactBtn addTarget:self action:@selector(showContactView) forControlEvents:UIControlEventTouchUpInside];
    
    [contactBtn setImage:contact_btn_img forState:UIControlStateNormal];
    
    [self addSubview:contactBtn];
        
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    
    
}

-(void)showContactView{
    
    WSInterAction  *interaction =[[WSInterAction alloc] init];
    
    [interaction setAcvt_qust_id:[xbuildInfo  getAcvtQstId]];
    
    [interaction setExecute_class:@"WSContactViewController"];
    
    [interaction setDirect_type:DIRECT_TYPE_PRESENT];
    
    
    
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        
        [delegate executeInterAction:interaction];
        
    }
    
    
}

- (void)loadComputeResult:(WSInterAction *)interAction{
    
    [textField setText:(NSString *)[interAction execute_result]];
    
    [textField resignFirstResponder];
    
}

#pragma mark -
#pragma mark I_M_ViewDelegate mehtod

-(void)MessageView:(NSObject<I_M_View> *)messageView clickAtButtonIndex:(NSInteger)index{
    
    
}

@end
