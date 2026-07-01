//
//  WSScanListValidate.m
//  WinSFA
//
//  Created by winchannel on 16/4/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSScanListValidate.h"
#import "I_W_BuildInfo.h"
#import "I_W_Validate.h"
#import "WSWidget.h"
#import "WSMessageCenter.h"
#import "WSMessageObject.h"
#import "WSScanListPanel.h"

@implementation WSScanListValidate

- (BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget{
    
    [super executeValidate:buildinfo withWidget:widget];
    
    if ([[buildinfo getQstDescription] isEqualToString:@"PHOTO_R"]) {
        
        
        WSScanListPanel *scanlistPanel = (WSScanListPanel *)widget;
        NSString *directValue = (NSString *)[widget getResultDirectly];
        
        if (directValue== nil ) {
            
            return NO;
        }
        
        NSArray *qstValueArray = [directValue componentsSeparatedByString:@","];
        
        for (NSString *qst_Value_str in qstValueArray) {
            
            NSRange range = [qst_Value_str rangeOfString:@"@"];//现获取要截取的字符串位置
           
            if (range.length <1) {
                
                [self showMss:qst_Value_str];
                
                return NO;
            }else{
                //有进入相机生成imageIndex ，而没有拍照
                NSString *scanCode = [qst_Value_str substringToIndex:range.location];
                
                NSArray *obj =[scanlistPanel.addPhotoDict objectForKey:scanCode];
                if (obj.count <1) {
                    
                    [self showMss:scanCode];
                    
                    return NO;
                }

            }
        }
        
    }else{
        // 验证普通的扫码功能
        if ([[buildinfo getISRequire] isEqualToString:@"1"]) {
            
            NSString *directValue = (NSString *)[widget getResultDirectly];
            if (directValue && directValue.length > 0) {
                return YES;
            }
            
            return NO;
        }
    
    }
    return YES;
}

- (void)showMss:(NSString *)imeiStr{
    
    WSMessageObject *messageobject;
    
    NSString  *message =[NSString stringWithFormat:@"imei: %@ %@",imeiStr, NSLocalizedString(@"scan_no_photo", nil)];
    
    messageobject = [self getMessageObject:message AndTitle:@"" andButtons:nil andDelegate:nil messageId:@"" messageType:MESSAGE_TYPE_AUTO_HIDE_FAILED];
    
    [[WSMessageCenter shareInstance] showMessageView:messageobject];
    
}
@end
