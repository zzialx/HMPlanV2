//
//  WSBaseResponse.h
//  WinSFA
//
//  Created by xiaotang.wang on 9/23/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCError;

@interface WSBaseResponse : NSObject

@property (nonatomic, strong)WCError *iError;

@property (nonatomic, strong)NSDictionary *iJsonResponse;

@property (nonatomic, strong) NSData *iResopnseData;


-(id)initWithResponseData:(NSData *)aData;


-(id)initWithError:(NSError *)aError;


-(void)parseResponseData;


-(void)parseJsonData;

@end


