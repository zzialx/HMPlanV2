//
//  WSVerificationValidate.m
//  WinSFA
//
//  Created by winchannel on 2017/9/21.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSVerificationValidate.h"
#import "WSVerificationCodePanel.h"
@implementation WSVerificationValidate

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo{
    
    
    
    return YES;
}

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withValue:(NSObject *)value{
    
    
    return YES;
}

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget{
    
    
    if ([super executeValidate:buildinfo withWidget:widget]==YES) {
        
        if ([widget isKindOfClass:[WSVerificationCodePanel class]]) {
            
            BOOL isValidate = YES;
            
            WSVerificationCodePanel *veificationCodePanel = (WSVerificationCodePanel *)widget;
            
            NSString *mobileNumber = veificationCodePanel.mobileTextField.text;
            NSString *currentRand =(NSString *)[widget getResultPresentation];
            
            NSString *randMobileNumber = [veificationCodePanel getVerificationCodeMobileNumber];
            NSString *sendRand = [veificationCodePanel getVerificationCodeSendRand];
            NSString *randTime = [veificationCodePanel getVerificationCodeRandTime];
            NSDate *sendDate = [veificationCodePanel getVerificationCodeSendDate];
            
            
            NSDate *currentDate = [NSDate date];
            
            NSString *title = nil;
            if ([currentDate timeIntervalSinceDate:sendDate]/1000.0>randTime.integerValue) {
                title = NSLocalizedString(@"Verification code has expired", nil);
                isValidate = NO;
            }else if(currentRand.length > 0 && sendRand.length > 0 && ![currentRand isEqualToString:sendRand]){
                title = NSLocalizedString(@"Verification code error", nil);
                isValidate = NO;
            }else if (randMobileNumber.length > 0 && ![mobileNumber isEqualToString:randMobileNumber]) {
                title = NSLocalizedString(@"The current phone does not match the phone number that received the verification code", nil);
                isValidate = NO;
            }
            if (isValidate == NO) {
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            }
            return isValidate;
        }
    }else{
        return NO;
    }
    return YES;
}

@end
