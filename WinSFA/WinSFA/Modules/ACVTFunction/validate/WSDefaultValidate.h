//
//  WSDefaultValidate.h
//  WinSFA
//
//  Created by winchannel on 15/4/1.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSValidate.h"
#import "I_W_Validate.h"

@class WSWidget;

@protocol I_W_BuildInfo;

@interface WSDefaultValidate : WSValidate<I_W_Validate>


-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget;


@end
