//
//  WCAppContext.m
// Core
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "WCAppContext.h"

static WCAppContext *_appContext = nil;

@implementation WCAppContext

@synthesize
user = _user;

@synthesize navigationBarImage = _navigationBarImage;
// Network Public
@synthesize reachabilityObj = _reachabilityObj;

#pragma mark - Singeton
+ (WCAppContext *)getInstance {
    @synchronized (self) {
        if (!_appContext) {
            _appContext = [[self alloc] init];
        }
        return _appContext;
    }
}

#pragma mark - Public
// 登录成功后调用
- (void)resetForUserLogIn
{
    //TODO:实现持久化User

}

- (void)resetForUserLogout {
    
    // TODO: Service 和 DAO 层 所有group事件执行完毕
    
    // 释放Service
    
}
#pragma mark - Life Cycle
- (void)dealloc {
    [self resetForUserLogout];

    self.navigationBarImage = nil;
    
}


- (id)init {
    self = [super init];
    if (self) {
//        [PKResManager getInstance];
    }
    return self;
}
#pragma mark - Property

- (Reachability*)reachabilityObj{
    if(_reachabilityObj == nil){
        _reachabilityObj = [Reachability reachabilityForInternetConnection];
        [_reachabilityObj startNotifier];
    }
    return _reachabilityObj;
}


@end
