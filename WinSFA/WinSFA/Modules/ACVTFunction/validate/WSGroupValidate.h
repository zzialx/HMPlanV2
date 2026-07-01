//
//  WSGroupValidate.h
//  WinSFA
//
//  Created by winchannel on 16/1/15.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSValidate.h"
#import "I_W_Group_Validate.h"

@interface WSGroupValidate : WSValidate<I_W_Group_Validate>

-(NSObject *)executeGroupValidate:(NSObject<I_W_BuildInfo> *)buildinfo withAcvtView:(WSAcvtView *)acvtView;


@end
