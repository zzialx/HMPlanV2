//
//  WSInputTextFieldWithMagnify.m
//  WinSFA
//
//  Created by winchannel on 15/3/26.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSInputTextFieldWithMagnify.h"
#import "WidgetConstant.h"
#import "WSUpKeyBoardViewWithOperation.h"
#import "WCBaseViewController.h"
#import "WSInterAction.h"

@implementation WSInputTextFieldWithMagnify

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self setBackgroundColor:[UIColor colorWithRed:0.8 green:0.9 blue:0.9 alpha:1.0f]];
        
//        keyboard =[[WSUpKeyBoardViewWithOperation alloc] initWithFrame:WSRect(0, 0, self.width, 24)];
//        
//        keyboard.operationDelegate = self;
//        
//        
//    
//        textView.inputAccessoryView = keyboard;
        
        return self;
    }
    return nil;
    
}

-(NSObject *)getResultDirectly{

    return [textView text];
    
}


-(void)makeCurrentWidgetInactivity:(WSInterAction *)interaction{
    
    [super makeCurrentWidgetInactivity:interaction];

}


-(void)makeCurrentWidgetActivity:(WSInterAction *)interactionin{
    
    [super makeCurrentWidgetActivity:interactionin];
    
        
    UIWindow *wc = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    
    UINavigationController* nav=(UINavigationController*)wc.rootViewController;
    
    self.frame = WSRect(0, nav.view.frame.size.height, nav.view.frame.size.width, nav.view.frame.size.height);
    
    if (INTERFACE_IS_PAD) {
        
        textView.frame = CGRectMake(5, 5, self.bounds.size.width-10.0, self.bounds.size.height-10.0);
    
    }else{
        
        textView.frame = CGRectMake(5, IS_IPHONE5 ? 5 : 25.0, self.bounds.size.width-10.0, IS_IPHONE5 ?  self.bounds.size.height-10.0 : self.bounds.size.height-25.0);
        
    }
    
    
    [nav.view addSubview:self];
    
    if ([interactionin execute_class_param]!=nil) {
        
        NSString  *content = (NSString *)[interactionin execute_class_param];
        
        [textView setText:content];
    }
 
    
    [textView becomeFirstResponder];

    [self executeAnimation:WSRect(0.0, 0.0, self.bounds.size.width, self.bounds.size.height) andHidden:NO completion:^(BOOL finished) {
        
    } andView:self];
    
}

#pragma mark -
#pragma mark WSUpKeyBoardViewDelegate method

-(void)closeOperation:(id)sender{
    
    [self resignKeyBoard];
    
    if ([delegate respondsToSelector:@selector(sendResultInterAction:)]) {
        
        [delegate sendResultInterAction:currentInterAction];
        
    }
}


-(void)cancelOperation:(id)sender{
    
    
    [self resignKeyBoard];
    

}

-(void)executeAnimation:(CGRect)rect andHidden:(BOOL)hidden completion:(void (^)(BOOL finished))completion andView:(UIView *)view {
    
    [UIView animateWithDuration:0.5 animations:^{
        
        view.frame=rect;
        view.hidden=hidden;
        
    } completion:completion];
    
}

-(void)resignKeyBoard{
    
    [self resignFirstResponder];
    
    [self executeAnimation:WSRect(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height) andHidden:YES completion:^(BOOL finished) {
        
        if ([self.delegate isKindOfClass:[WCBaseViewController class]]) {
            
            WCBaseViewController  *controller = (WCBaseViewController *)self.delegate;
           
            //后面改成动态调节的
            CGRect  newframe = WSRect(0, INTERFACE_IS_PAD ? 60 :(IS_IPHONE5 ? 60 : 0), controller.view.frame.size.width, controller.view.frame.size.height);
            
            //后面改成动态调节的
            [self removeFromSuperview];
            
            [self executeAnimation:newframe andHidden:NO completion:^(BOOL finished) {
            
            } andView:controller.view];
            
            
        }
    } andView:self];
    
}


@end
