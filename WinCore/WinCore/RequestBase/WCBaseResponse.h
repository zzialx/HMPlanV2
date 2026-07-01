//
// Created by yang on 13-6-18.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class WCError;

@interface WCBaseResponse : NSObject {
}
/**
* 协议类型，类似于1xx,2xx等
*/
@property (nonatomic, assign,readonly) NSInteger protocolType;

/**
 * 异常信息（含协议返回及网络故障等）
 * 例外：导航文件不存在协议返回的错误码。
*/
@property(nonatomic, strong,readonly) WCError *error;

/**
* 返回的json数据
*/
@property(nonatomic, strong)NSDictionary *jsonResponse;
/***
* 由初始化时传入的data
*/
@property (nonatomic, strong,readonly) NSData *resopnseData;

@property (nonatomic, strong, readonly) NSString *requestIdentifer;

/**
* 初始化
* @data ,MK返回的responseData
*/
-(instancetype)initWithResponseData:(NSData *)data protocolType:(NSInteger)protocolType;
-(instancetype)initWithResponseData:(NSData *)data protocolType:(NSInteger)protocolType requestIdentifer:(NSString *)requestIdentifer;

/**
* 初始化
* @error ,一般是网络异常
*/
-(id)initWithError:(NSError *)error  protocolType:(NSInteger)protocolType;
/**
* 解析返回数据，用来被重写实现特殊的解析。
*/
-(void)parseResponseData;

/**
* 解析json数据，用来被重写实现实体字段填充。
*/
-(void)parseJsonData;

@end
