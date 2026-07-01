//
//  WSGetValueByServerExecutor.h
//  WinSFA
//
//  Created by winchannel on 16/1/5.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSLuaExecutor.h"
#import "I_W_BuildInfo.h"
#import "WSStoreAcvtDisByDateHttpService.h"
#import "WSBaseHttpService.h"
@interface WSGetValueByServerExecutor : WSLuaExecutor

@property (nonatomic, strong) WSStoreAcvtDisByDateHttpService *service;
@end
