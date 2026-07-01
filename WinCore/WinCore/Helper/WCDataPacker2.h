//
//  WCDataPacker2.h
//  winCRM
//
//  Created by HZH on 16/9/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
extern const NSString *InitStreetCode2;

@interface WCDataPacker2 : NSObject
@property (nonatomic,copy) NSString *salt;
@property (nonatomic,copy) NSString *InitHttpCode2;

+ (WCDataPacker2 *)sharedInstance;

- (NSData *)packForURLParam01:(NSString *)aURLParam;
- (NSData *)packForURLParam01:(NSString *)aURLParam isTowPartKey:(BOOL)isTowPartKey;

- (NSString *)unpackForResponseData:(NSData*)responseData;
- (NSData *)unpackForNormalResponseData:(NSData*)responseData;

- (NSData *)unpackForNormalResponseData:(NSData*)responseData isTowPartKey:(BOOL)isTowPartKey;

@end
