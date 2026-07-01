//
//  WCError.h
//  xiaonei
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

//TODO:错误码需要根据具体的项目定义 （王辉）

#import <Foundation/Foundation.h>

/**
 * 接口错误返回代码定义.
 */
typedef enum {
    WCErrorCodeParameterError = 1,

} WCErrorCode;

@interface WCError : NSError {
	
}

/**
 * 返回用于展现给用户的错误提示标题
 */
- (NSString*)titleForError;

/**
 * 返回用于展现给用户的错误提示子标题
 */
- (NSString*)subtitleForError;

/**
 * 返回由Rest接口错误信息构建的错误对象.
 */
+ (WCError *)errorWithRestInfo:(NSDictionary*)restInfo;


/**
 * 返回由NSError构建的错误对象.
 */
+ (WCError *)errorWithNSError:(NSError*)error;

/**
 * 构造RRError错误。
 *
 * @param code 错误代码
 * @param errorMessage 错误信息
 *
 * 返回错误对象.
 */
+ (WCError *)errorWithCode:(NSInteger)code errorMessage:(NSString*)errorMessage;

/**
 * 返回调用Rest Api 的 method字段的值.
 */
- (NSString*)methodForRestApi;

/**
 * 表示错误处理模式.
 */

@end
