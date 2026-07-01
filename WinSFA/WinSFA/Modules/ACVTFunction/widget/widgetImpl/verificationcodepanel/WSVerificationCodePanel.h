//
//  WSVerificationCodePanel.h
//  WinSFA
//
//  Created by zhangke on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSBasePanel.h"

@protocol WSVerificationCodePanelProtocol <NSObject>

-(void)verSuccess;

@end




@interface WSVerificationCodePanel : WSBasePanel

@property (nonatomic, weak) WSHTextField *mobileTextField;
@property (nonatomic, strong) NSString *checkCode;
@property (nonatomic, weak) id <WSVerificationCodePanelProtocol> verificationDelegate;


-(instancetype)initWithFrame:(CGRect)frame acvtQstObject:(WSAcvtBean_qst*)qst;


- (NSString *)getVerificationCodeRandTime;

- (NSString *)getVerificationCodeSendRand;

- (NSDate *)getVerificationCodeSendDate;

- (NSString *)getVerificationCodeMobileNumber;
@end
