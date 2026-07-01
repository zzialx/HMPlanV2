//
//  I_W_Group_Validate.h
//  WinSFA
//
//  Created by winchannel on 16/1/15.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#ifndef I_W_Group_Validate_h
#define I_W_Group_Validate_h

@class WSAcvtView;

@protocol I_W_BuildInfo;

@protocol I_W_Group_Validate <NSObject>

@optional

//执行验证

-(NSObject *)executeGroupValidate:(NSObject<I_W_BuildInfo> *)buildinfo withAcvtView:(WSAcvtView *)acvtView;


@end
#endif /* I_W_Group_Validate_h */
