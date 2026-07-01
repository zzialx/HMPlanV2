//
//  WSBaseRequest.h
//  WinSFA
//
//  Created by xiaotang.wang on 9/24/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import "MKNetworkOperation.h"


#define kHttpMethodGET @"GET"
#define kHttpMethodPOST @"POST"


@class WSBaseResponse;
typedef void (^WSRequestCompletionBlock)(MKNetworkOperation *completedOperation, WSBaseResponse *response);


@interface WSBaseRequest : MKNetworkOperation

-(id) initWithURLString:(NSString*) urlString params:(NSDictionary*) params httpMethod:(NSString*) method;

-(id) initWithURLString:(NSString*) urlString params:(NSDictionary*) params httpMethod:(NSString*) method fileData:(NSData*)fileData;

-(void)sendRequestWithCompletionBlock:(WSRequestCompletionBlock)completionBlock;

-(void)registerOperationSubclass:(Class) aClass;

@end
