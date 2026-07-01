//
//  WSTextView.m
//  WinSFA
//
//  Created by zhangke on 14-5-6.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSTextView.h"
#import "WSAcvtViewController.h"
#import "WSUpKeyBoardView.h"

@interface WSTextView ()

@property (nonatomic, strong) UIView *upKeyBoardView;

@end


@implementation WSTextView

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.editable=YES;
        self.userInteractionEnabled=YES;
        isloaded=NO;
        self.layer.cornerRadius=5;
        self.layer.borderWidth=5;
        self.layer.borderColor=[[UIColor colorWithRed:0.8 green:0.9 blue:0.9 alpha:1.0f] CGColor];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            self.font=[UIFont systemFontOfSize:18];
        }else{
            self.font=[UIFont systemFontOfSize:22];
        }
        if(IOS7_OR_LATER){
            self.textContainerInset=UIEdgeInsetsMake(5,5,5,5);
        }
        
//        self.upKeyBoardView=[[WSUpKeyBoardView alloc] initWithFrame:CGRectMake(0, 0, self.width, UI_KEYBOARD_VIEW_HEIGHT)];
//        
//        UIButton* cButton=(UIButton*)[self.upKeyBoardView viewWithTag:98];
//        
//        [cButton addTarget:self action:@selector(cancelButton:) forControlEvents:UIControlEventTouchUpInside];
//        
//        UIButton* oButton=(UIButton*)[self.upKeyBoardView viewWithTag:100];
//        
//        [oButton addTarget:self action:@selector(okButton:) forControlEvents:UIControlEventTouchUpInside];
//        
//        self.inputAccessoryView= self.upKeyBoardView;
//        
//        if ([[UIDevice getPreferredLanguage] isEqualToString:@"ja_JP"]) {
//            for(UIButton* button in self.upKeyBoardView.subviews){
//                switch (button.tag) {
//                    case 99:
//                        [button setTitle:NSLocalizedString(@"zoom_in", nil) forState:UIControlStateNormal];
//                        break;
//                    case 100:
//                        [button setTitle:NSLocalizedString(@"complete", nil) forState:UIControlStateNormal];
//                        break;
//                    default:
//                        break;
//                }
//            }
//        }
//        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    }
    return self;
}


- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    UIWindow *wc = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    
    UINavigationController* nav=(UINavigationController*)wc.rootViewController;
    UIView* view=nav.view;
    
    self.alpha=1.0;
    CGRect rect = CGRectZero;
    
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
	switch (orientation) {
            
		case UIDeviceOrientationPortrait:
		{
            rect= CGRectMake(0, 20, view.bounds.size.width, view.bounds.size.height-keyboardRect.size.height-20);

			break;
		}
            
		case UIDeviceOrientationPortraitUpsideDown:
		{
            rect= CGRectMake(0, 20, view.bounds.size.width, view.bounds.size.height-keyboardRect.size.height-20);

			break;
		}
            
		case UIDeviceOrientationLandscapeLeft:
		{
            rect= CGRectMake(0, 20, view.bounds.size.width, view.bounds.size.height-keyboardRect.size.width-20);

			break;
		}
            
		case UIDeviceOrientationLandscapeRight:
		{
            rect= CGRectMake(0, 20, view.bounds.size.width, view.bounds.size.height-keyboardRect.size.width-20);

			break;
		}
            
		default:
			break;
	}
    
    [UIView animateWithDuration:0.4 animations:^{
       
    
               self.frame=rect;
      
        
     
     
        
    }];
}


- (void)keyboardWillHide:(NSNotification *)notification
{

}

- (IBAction)cancelButton:(id)sender
{
    [self dismissTextView];
}

- (IBAction)okButton:(id)sender
{
    if (![self.text isEqual:self.hTextField.text]) {
        self.hTextField.isValueChange = YES;
    }
    self.hTextField.text=self.text;
    [self dismissTextView];
}

-(void)dismissTextView
{
    isloaded=NO;
    
    [self resignFirstResponder];
    
    [self.hTextField becomeFirstResponder];
    
    if (self.hTextField.isNotBecomeFirstResponder
        && [self.hTextField.m_type isEqualToString:COL_TYPTEXT]) {
        [self performSelector:@selector(textFieldResignFirstRes:) withObject:nil afterDelay:0.1];
        
//        NSString* qstId =[NSString stringWithFormat:@"%d",self.hTextField.tag];
//        [[(WSAcvtViewController*)self.hTextField.viewController markDictionary] setObject:self.hTextField.text forKey:qstId];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha=0;
    } completion:^(BOOL finish){
        self.frame=self.hTextField.frame;
        self.hidden=YES;
    }];
}

-(void)textFieldResignFirstRes:(id)sender{
    
    [self.hTextField resignFirstResponder];


}



@end
