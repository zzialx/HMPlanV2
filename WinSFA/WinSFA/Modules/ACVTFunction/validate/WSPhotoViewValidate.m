//
//  WSPhotoViewValidate.m
//  WinSFA
//
//  Created by mac on 17/9/20.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSPhotoViewValidate.h"
#import "WSPhotoViewPanel.h"
#import "WSMessageObject.h"
#import "WSMessageCenter.h"
@implementation WSPhotoViewValidate

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget{
    
    if (![super executeValidate:buildinfo withWidget:widget]) {
        return NO;
    }
    
    if ([widget isKindOfClass:[WSPhotoViewPanel class]]) {
        WSPhotoViewPanel * photoView = (WSPhotoViewPanel *)widget;
        if ([buildinfo getDlen].length > 0) {
            if (photoView.photoView.imageIDArray.count < [[buildinfo getDlen] integerValue]) {
                NSString  *message =[NSString stringWithFormat:NSLocalizedString(@"camera_min_capture_hint", nil),[buildinfo getDlen]];
                WSMessageObject *messageobject = [self getMessageObject:message AndTitle:@"" andButtons:nil andDelegate:nil messageId:@"" messageType:MESSAGE_TYPE_AUTO_HIDE_FAILED];
                [[WSMessageCenter shareInstance] showMessageView:messageobject];
                return NO;

            }
        }
    
    }
    
    return YES;
}

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo {
    return YES;
}
-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withValue:(NSObject *)value{
    return YES;
}
@end
