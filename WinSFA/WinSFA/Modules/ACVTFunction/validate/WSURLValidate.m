//
//  WSURLValidate.m
//  WinSFA
//
//  Created by 董宏 on 2019/11/5.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSURLValidate.h"
#import "I_W_BuildInfo.h"
#import "I_W_Validate.h"
#import "WSWidget.h"
#import "WSSignaturepanel.h"
#import "WSMessageObject.h"
#import "WSMessageCenter.h"
#import "WSURLPanel.h"

@implementation WSURLValidate
-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget{
    WSURLPanel *url = (WSURLPanel*)widget;
    if ([[buildinfo getDefaultValue] rangeOfString:@"clickRequire=1"].location != NSNotFound && url.urlNeedValidate) {
        return YES;
    }
    return[super executeValidate:buildinfo withWidget:widget];
    
}
@end
