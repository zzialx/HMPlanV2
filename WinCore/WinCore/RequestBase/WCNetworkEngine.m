//
//  WCNetworkEngine.m
//  QuadCore
//
//  Created by Liyd on 13-2-23.
//  Copyright (c) 2013年 sam. All rights reserved.
//

#import "WCNetworkEngine.h"
#import "WCBaseRequest.h"
#import "WCError.h"

@implementation WCNetworkEngine

static WCNetworkEngine * _networkEngine;

+ (WCNetworkEngine *)sharedInstance
{
    if(!_networkEngine) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            
            _networkEngine = [[WCNetworkEngine alloc] init];
            
            _networkEngine.normalRequestManager = [WinAFHTTPRequestOperationManager manager];
            [_networkEngine.normalRequestManager.operationQueue setMaxConcurrentOperationCount:3];
            
            _networkEngine.uploadRequestManager = [WinAFHTTPRequestOperationManager manager];
            [_networkEngine.uploadRequestManager.operationQueue setMaxConcurrentOperationCount:1];
            
        });
    }
    
    return _networkEngine;

}

- (void)cancelNormalRequestQueue
{
    if ([_networkEngine.normalRequestManager.operationQueue operationCount] > 0) {
        [_networkEngine.normalRequestManager.operationQueue cancelAllOperations];
    }
}

- (void)cancelUploadRequestQueue
{
    if ([_networkEngine.uploadRequestManager.operationQueue operationCount] > 0) {
        [_networkEngine.uploadRequestManager.operationQueue cancelAllOperations];
    }
}

- (void) cancelAllRequest
{
    [self cancelNormalRequestQueue];
    [self cancelUploadRequestQueue];
    
}


@end
