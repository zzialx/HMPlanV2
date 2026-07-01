//
//  WSAddressSelectPanel.m
//  WinSFA
//
//  Created by xiajl on 15/3/24.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAddressSelectPanel.h"
#import "WSAddressSelectViewController.h"
#import "WSInterAction.h"
#import "I_W_BuildInfo.h"
#import "I_W_DisplayValue.h"
#import "I_Lua_Target_Operator.h"
#import "WSStringValueChangeChecker.h"

@interface WSAddressSelectPanel()<UITextFieldDelegate>
@property (nonatomic,strong) NSDictionary *addressDict;

@end

@implementation WSAddressSelectPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.xvalueChangeChecker = [[WSStringValueChangeChecker alloc] init];
        
        return self;
    }
    
    return nil;
}


-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];

}

-(void)buildDisplayContent{
    
    [super buildDisplayContent];
    self.addressDict = (NSDictionary *)_originalValue;
    textField.placeholder = @"单击选择";
    textField.delegate = self;

}



-(void)showContactView{
    
    WSInterAction  *interaction =[[WSInterAction alloc] init];
    [interaction setAcvt_qust_id:[xbuildInfo  getAcvtQstId]];
    [interaction setExecute_class:@"WSAddressSelectViewController"];
    NSObject *object = [xdisplayValue getDisplayValueFor:xbuildInfo];
    if ([object isKindOfClass:[NSString class]]) {
        NSString *string = [NSString stringWithFormat:@"%@" ,object];
        [interaction setExecute_class_param:[string objectFromJSONString]];
    }

    [interaction setDirect_type:DIRECT_TYPE_PRESENT];
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        [delegate executeInterAction:interaction];
    }
}

- (void)loadComputeResult:(WSInterAction *)interAction{
    
    if ([[interAction execute_result] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)[interAction execute_result];
        self.addressDict = dic;
//        [[xbuildInfo getCurrentMarkDictionary] setObject:dic forKey:[xbuildInfo getAcvtQstId]];
        NSString *address = [dic objectForKey:kAddress];
        if (address) {
            [textField setText:address];
            
            [self checkValueChange];
        }
    }
    
}


#pragma mark textfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self showContactView];
    return NO;
}

- (NSObject *)getResultDirectly{
    
    NSString *areaID = [_addressDict objectForKey:@"areaID"];
    return areaID;
}



@end
