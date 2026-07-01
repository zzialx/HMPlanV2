//
//  WSUpKeyBoardViewWithOperation.m
//  WinSFA
//
//  Created by winchannel on 15/3/26.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSUpKeyBoardViewWithOperation.h"

@interface WSUpKeyBoardViewWithOperation (private)

-(void)okButton:(id)sender;

-(void)cancelButton:(id)sender;

@end


@implementation WSUpKeyBoardViewWithOperation

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton* cButton=(UIButton*)[self viewWithTag:98];
        [cButton addTarget:self action:@selector(cancelButton:) forControlEvents:UIControlEventTouchUpInside];
        UIButton* oButton=(UIButton*)[self viewWithTag:100];
        [oButton addTarget:self action:@selector(okButton:) forControlEvents:UIControlEventTouchUpInside];

        if ([[UIDevice getPreferredLanguage] isEqualToString:@"ja_JP"]) {
            for(UIButton* button in self.subviews){
                switch (button.tag) {
                    case 99:
                        [button setTitle:NSLocalizedString(@"zoom_in", nil) forState:UIControlStateNormal];
                        break;
                    case 100:
                        [button setTitle:NSLocalizedString(@"complete", nil) forState:UIControlStateNormal];
                        break;
                    default:
                        break;
                }
            }
        }
        return self;
    }
    return nil;
}


-(void)okButton:(id)sender{
    

    if ([operationDelegate respondsToSelector:@selector(closeOperation:)]) {
        
        [operationDelegate closeOperation:self];
        
    }
    
    
}

-(void)cancelButton:(id)sender{
    
    if ([operationDelegate respondsToSelector:@selector(cancelOperation:)]) {
        
        
        [operationDelegate cancelOperation:self];
        
        
    }
    
}

@end
