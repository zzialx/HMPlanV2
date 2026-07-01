//
//  WSLoginProgressDefine.h
//  WinSFA
//
//  Created by Alicia on 2017/6/6.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#ifndef WSLoginProgressDefine_h
#define WSLoginProgressDefine_h

typedef NS_ENUM(NSInteger, WSLoginProgress) {
    WSLoginProgressRequestConfig = 10,
    WSLoginProgressRequestLogin = 20,
    WSLoginProgressProcessData = 60,
    WSLoginProgressSuccess = 100
};

#endif /* WSLoginProgressDefine_h */
