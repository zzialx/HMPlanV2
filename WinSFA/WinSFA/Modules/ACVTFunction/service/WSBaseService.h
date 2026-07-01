//
//  WSBaseService.h
//  WinSFA
//
//  Created by winchannel on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSBaseService;

@class WSInterAction;

@protocol WSBaseServiceDelegate <NSObject>

@optional

//服务开始执行
-(void)serviceExecuteBegin:(WSBaseService *)baseService  andResultObject:(NSObject *)object;

//服务执行成功
-(void)serviceExecuteSuccessed:(WSBaseService *)baseService andResultObject:(NSObject *)object;

//服务执行失败
-(void)serviceExecuteFailed:(WSBaseService *)baseService andResultObject:(NSObject *)object andError:(NSError *)error;

//服务执行中
-(void)serviceInExeute:(WSBaseService *)baseService andResultObject:(NSObject *)object;

@end

@interface WSBaseService : NSObject

@property (nonatomic,strong) WSAppData *appdata;

@property (nonatomic,weak) id<WSBaseServiceDelegate>  service_call_back_delegate;



@end
