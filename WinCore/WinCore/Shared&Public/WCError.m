//
//  WCError.m
//  xiaonei
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "WCError.h"
#import "WCLogger.h"


@implementation WCError


- (NSString*)description
{
    NSString* s = [self.userInfo objectForKey:@"error_msg"];
    if (s.length > 0) {
        return s;
    }
    else {
        return [super description];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (WCError *)errorWithRestInfo:(NSDictionary*)restInfo {
	
	NSNumber* errorCode = [restInfo objectForKey:@"error_code"];
	LogDebug(@"%ld=%@", (long)[errorCode intValue], [restInfo objectForKey:@"error_msg"]);
	WCError * error = [WCError errorWithDomain:@"WCService" code:[errorCode intValue] userInfo:restInfo];
	return error;
}	

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (WCError *)errorWithNSError:(NSError*)error {
    
	WCError * myError = [WCError errorWithDomain:error.domain code:error.code userInfo:error.userInfo];
	LogDebug(@"code=%ld", (long)myError.code);
	return myError;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (WCError *)errorWithCode:(NSInteger)code errorMessage:(NSString*)errorMessage {
	NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
	[userInfo setObject:[NSString stringWithFormat:@"%ld", (long)code] forKey:@"error_code"];
    if (errorMessage) {
        [userInfo setObject:errorMessage forKey:@"error_msg"];
    }
    else{
        [userInfo setObject:@"unknown error" forKey:@"error_msg"];
    }
	
	WCError * error = [WCError errorWithDomain:@"WCService" code:code userInfo:userInfo];
	return error;
	
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict {
	LogDebug(@"domain=%@,code=%ld,userInfo=%@", domain, (long)code, dict);
	if (self = [super initWithDomain:domain code:code userInfo:dict]) {
		NSString* method = [self methodForRestApi];
		
		// 以下几个method也有框架统一处理
		if (method && (NSOrderedSame == [method compare:@"photos.getComments"])) {
			//self.processMode = ErrorProcessModel;
		} else if (method && (NSOrderedSame == [method compare:@"gossip.postGossip"])) {
			//self.processMode = ErrorProcessModel;
		}
	}
	return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)methodForRestApi {
	NSDictionary* userInfo = self.userInfo;
	if (!userInfo) {
		return nil;
	}
	
	NSArray* requestArgs = [userInfo objectForKey:@"request_args"];
	if (!requestArgs) {
		return nil;
	}
	
	for (NSDictionary* pair in requestArgs) {
		if (NSOrderedSame == [@"method" compare:[pair objectForKey:@"key"]]) {
			return [pair objectForKey:@"value"];
		}
	}
	
	return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForError {
    NSString* title = nil;
	if (NSOrderedSame == [self.domain compare:@"NSURLErrorDomain"]) {
		switch (self.code) {
			case NSURLErrorNotConnectedToInternet:
                title = @"网络连接失败，请稍后再试";
                break;
            case NSURLErrorTimedOut:
                title = @"连接超时";
                break;
            case kCFURLErrorCancelled:
                title = @"您取消了网络连接";
                break;
			default:
				break;
		}
	} else if (NSOrderedSame == [self.domain compare:@"NSPOSIXErrorDomain"]) {
		title = @"网络连接失败，请稍后再试";
	}
    else {
        // 这里可以根据错误码，自己写一些错误提示，暂时还不需要，直接用服务端提供的错误信息
        // TODO
//        if (self.code == xxx) {
//            title = @"dsfsdf";
//        }
    }
	
    if (title == nil) {
        title = [self.userInfo objectForKey:@"error_msg"];
    }
    // 如果还没取到，就写死
    if (title == nil) {
        title = @"网络连接失败，请稍后再试";
    }
    
	return title;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForError {
	return nil;
}

@end
