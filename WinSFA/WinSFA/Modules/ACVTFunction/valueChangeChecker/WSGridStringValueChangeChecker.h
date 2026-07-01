//
//  WSGridStringValueChangeChecker.h
//  WinSFA
//
//  Created by wangzhiwei on 2018/6/28.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSStringValueChangeChecker.h"

@interface WSGridStringValueChangeChecker : WSStringValueChangeChecker
- (BOOL)checkValueIsChange:(NSObject<I_W_ValueChangeObject> *)object;
@end
