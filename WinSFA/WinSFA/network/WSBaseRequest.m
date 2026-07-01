//
//  WSBaseRequest.m
//  WinSFA
//
//  Created by xiaotang.wang on 9/24/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import "WSBaseRequest.h"
#import "WSBaseResponse.h"

@interface WSBaseRequest()

@property (nonatomic, assign)Class iCustomResponseSubclass;

@end

@implementation WSBaseRequest

@synthesize iCustomResponseSubclass = _iCustomResponseSubclass;


-(id) initWithURLString:(NSString*) urlString params:(NSDictionary*) params httpMethod:(NSString*) method
{
    self = [super initWithURLString:urlString params:params httpMethod:method];
    if (self != nil) {
        // Do something
    }
    return self;
}

-(id) initWithURLString:(NSString*) urlString params:(NSDictionary*) params httpMethod:(NSString*) method fileData:(NSData*)fileData
{
    self = [super initWithURLString:urlString params:params httpMethod:method];
    if (self != nil) {
        [self addData:fileData forKey:@"data"];
    }
    return self;
}

-(void)sendRequestWithCompletionBlock:(WSRequestCompletionBlock)completionBlock
{
    __block Class subClass = self.iCustomResponseSubclass;
    [self addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        WSBaseResponse *response = [[subClass alloc] initWithResponseData:completedOperation.responseData];
        completionBlock(completedOperation, response);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        WSBaseResponse *response = [[subClass alloc] initWithError:error];
        completionBlock(completedOperation, response);
    }];
    [[WCNetworkEngine sharedInstance] enqueueOperation:self];
}

-(void)registerOperationSubclass:(Class) aClass
{
    self.iCustomResponseSubclass = aClass;
}

@end



