//
//  WCGlobalSingleton.m
//  WinSFA
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "WCGlobalSingleton.h"
#import "UIDevice-Hardware.h"

//#import "WCPlistHelper.h"

static WCGlobalSingleton *sharedInstance;
@implementation WCGlobalSingleton

+ (void)initialize {
    NSAssert([WCGlobalSingleton class] == self, @"Incorrect use of singleton : %@, %@", [WCGlobalSingleton class], [self class]);
    sharedInstance = [[WCGlobalSingleton alloc] init];
}

+ (WCGlobalSingleton *)sharedInstance {
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}       

- (void)setup {
    // network
    _gToken = kCommonToken;
    _gIMEI = [UIDevice macaddress];
    _gPlatform = kCommonPlatform;
    //_gVer = [WCPlistHelper swVersionFromProjectPlist];
    _gVer = @"1.0.4";
    _gSw = kCommonSw;
    _gLang = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    _gSrc = kCommonSrc;
    
    // setup navi item
    _gNaviFileItem = [[WCNaviFile alloc] init];
    _gNaviFileItem.loadFinished = FALSE;
    _gNaviFileItem.salt = nil;
    _gNaviFileItem.query = nil;
    _gNaviFileItem.upload = nil;
    
}



@end
