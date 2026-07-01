//
//  WSVerificationCodePanel.m
//  WinSFA
//
//  Created by zhangke on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSVerificationCodePanel.h"
#import "WSRequestHelper.h"
#import "WSMessageCenter.h"


#define kNotifyNameRequestCode @"requestCode"

@interface WSVerificationCodePanel (){

    UIButton* requestCodeButton;
    WSHTextField* codeTextField;
    
    int second;
    
    NSString* randTime;
    NSString* sendRand;

    NSDate* sendDate;
    NSString *mobileStr;

}


@end

@implementation WSVerificationCodePanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        return self;
        
    }
    
    return nil;
}

-(void)buildDisplayContent{
    
    [super buildDisplayContent];
    
    UIFont *font = [UIFont systemFontOfSize:UI_Font];
    
    UILabel *codeLabel = [[UILabel alloc] init];
    codeLabel.text = NSLocalizedString(@"verification_code", nil);
    codeLabel.textColor = DETAIL_TEXT_COLOR;
    codeLabel.font = font;
    [codeLabel sizeToFit];
    codeLabel.frame = CGRectMake(MAIN_CELL_PADDING, (MAIN_CELL_HEIGHT - codeLabel.frame.size.height) / 2, codeLabel.frame.size.width, codeLabel.frame.size.height);
    [self addSubview:codeLabel];
    
    
    codeTextField=[[WSHTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(codeLabel.frame) + MAIN_PADDING, (MAIN_CELL_HEIGHT - MAIN_TEXTFIELD_HEIGHT) / 2, 150, MAIN_TEXTFIELD_HEIGHT)];
    codeTextField.font = font;
//    codeTextField.borderStyle=UITextBorderStyleRoundedRect;
    codeTextField.placeholder = NSLocalizedString(@"please_fill_in", nil);
    codeTextField.keyboardType=UIKeyboardTypeNumberPad;
    [self addSubview:codeTextField];
    
    requestCodeButton=[UIButton buttonWithType:UIButtonTypeSystem];
    [requestCodeButton setTitle:NSLocalizedString(@"testgetcode", nil) forState:UIControlStateNormal];
    [requestCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [requestCodeButton setBackgroundColor:[UIColor colorForKey:@"MainTintColor"]];
    [requestCodeButton addTarget:self action:@selector(requestCode:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat buttonWidth = 60;
    requestCodeButton.frame = CGRectMake(self.frame.size.width - (MAIN_CELL_PADDING + buttonWidth), (MAIN_CELL_HEIGHT - MAIN_BUTTON_WH) / 2, buttonWidth, MAIN_BUTTON_WH);
    [self addSubview:requestCodeButton];
    
//    UIButton* verificationCodeButton=[UIButton buttonWithType:UIButtonTypeSystem];
//    [verificationCodeButton setTitle:@"验证" forState:UIControlStateNormal];
//    [verificationCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [verificationCodeButton setBackgroundColor:[UIColor colorForKey:@"MainTintColor"]];
//    [verificationCodeButton addTarget:self action:@selector(verificationCode:) forControlEvents:UIControlEventTouchUpInside];
//    CGFloat verifyWidth = 60;
//    verificationCodeButton.frame = CGRectMake(self.frame.size.width - MAIN_CELL_PADDING - buttonWidth,(MAIN_CELL_HEIGHT - MAIN_BUTTON_WH) / 2, verifyWidth, MAIN_BUTTON_WH);
//    [self addSubview:verificationCodeButton];
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, MAIN_CELL_HEIGHT)];
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    
}


-(void)requestCode:(id)sender
{
    NSString *mobileNum = [self getMobileNum];
    if (mobileNum) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(finishRequest:)
                                                     name:kNotifyNameRequestCode
                                                   object:nil];
        WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
        
        [uploadMgr appRequestCode:mobileNum notifyName:kNotifyNameRequestCode];
        requestCodeButton.enabled=NO;
        [requestCodeButton setTitle:@"60秒" forState:UIControlStateNormal];
        second=60;
        
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(repeats:) userInfo:nil repeats:YES];

    }else{
         [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"请输入正确的手机号", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}

- (NSString *)getMobileNum
{
    if (!self.mobileTextField && !self.checkCode) {
        return nil;
    }
    
    NSString *mobileNum = nil;
    mobileNum =  [self.checkCode length ] == 11 ? self.checkCode:[self.mobileTextField getTextValue];
    if (!mobileNum || [mobileNum isEqualToString:@""]) {
        return nil;
    }
    
    //手机电话号码长度大于11位不许输入 跟随android规则
    if ([mobileNum length] != 11 ) {
        return nil;
    }
    return mobileNum;
}

-(void)repeats:(NSTimer*)timer
{
    second--;
    [requestCodeButton setTitle: [NSString stringWithFormat:@"%d秒",second] forState:UIControlStateNormal];
    
    if(second==0){
        [timer invalidate];
        timer=nil;
        
        [requestCodeButton setTitle:NSLocalizedString(@"testgetcode", nil) forState:UIControlStateNormal];
        
        requestCodeButton.enabled=YES;
    }
    
}

-(void)finishRequest:(NSNotification*)aNot
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyNameRequestCode object:nil];

    NSString* datas=[[aNot userInfo] objectForKey:DATAS];
    
    if ([datas rangeOfString:@"flag"].location != NSNotFound) {
        NSDictionary *infoDic = [datas objectFromJSONString];
        NSString *flag = [NSString stringWithValue: infoDic[@"flag"]];
        if ([flag isEqualToString:@"0"]) {
             [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"get_validate_code_failure", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
    }
    
    NSDictionary* message=[[[datas objectFromJSONString] objectForKey:@"mobilemessage"] firstObject];
    
    
    randTime=[message objectForKey:@"randTime"];
    sendRand=[NSString stringNotNilWithValue:[message objectForKey:@"sendRand"]];

    sendDate=[NSDate date];
    
    mobileStr = [message objectForKey:@"mobile"];
}

-(void)verificationCode:(id)sender
{
    // 收回键盘
    [codeTextField resignFirstResponder];
    
    NSDate* currentDate=[NSDate date];
    if([currentDate timeIntervalSinceDate:sendDate]/1000.0>randTime.integerValue){
        
        NSString *title = NSLocalizedString(@"验证码超时", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    if([codeTextField.text isEqualToString:sendRand]){
        
        if([self.verificationDelegate respondsToSelector:@selector(verSuccess)]){
            [self.verificationDelegate verSuccess];
        }
        
    }else{
        NSString *title = NSLocalizedString(@"验证码错误", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];

    }
}


-(instancetype)initWithFrame:(CGRect)frame acvtQstObject:(WSAcvtBean_qst*)qst
{
    self=[super initWithFrame:frame];
    if(self){

        NSString *title = nil;
        if ([qst.is_req isKindOfClass:[NSString class]] && [qst.is_req isEqualToString:@"1"]) {
            title = [NSString stringWithFormat:@"%@*",qst.qstName];
        }else{
            title = qst.qstName;
        }
        
        //创建名字Label
        UIFont *font = [UIFont systemFontOfSize:UI_Font];
        CGSize size = [title ws_sizeWithFont:font constrainedToWidth:frame.size.width lineBreakMode:NSLineBreakByWordWrapping];
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, size.height)];
        titleLabel.text = title;
        [titleLabel setTextColorWithHexStr:qst.color];
        [titleLabel setFont:font];
        titleLabel.numberOfLines=0;
        titleLabel.lineBreakMode=NSLineBreakByWordWrapping;
        [self addSubview:titleLabel];
        
        self.height+=size.height;
        
    }
    
    return self;
}

- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation{

    self.checkCode = valuePresentation;
}

- (NSObject *)getResultPresentation {
    
    NSString *value = [codeTextField text];
    return value;
}
- (NSObject *)getResultDirectly{
    
    NSString *value = [codeTextField text];
    return value;
}

- (NSString *)getVerificationCodeRandTime{

    return randTime;
}

- (NSString *)getVerificationCodeSendRand{
    
    return sendRand;
}

- (NSDate *)getVerificationCodeSendDate{

    return sendDate;
}
- (NSString *)getVerificationCodeMobileNumber{
    
    return mobileStr;
}
@end
