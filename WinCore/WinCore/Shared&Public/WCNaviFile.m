//
//  WCNaviFile.m
//  WinCore
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "WCNaviFile.h"

@implementation WCNaviFile

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        
        if (dic) {
            
            self.encode = [dic stringForKey:@"encode" withDefault:nil];
            self.ver = [dic stringForKey:@"ver" withDefault:nil];
            self.isAnonymous = [dic stringForKey:@"isAnonymous" withDefault:nil];
            self.salt = [dic stringForKey:@"salt" withDefault:nil];
            
            self.query = [dic stringForKey:@"query" withDefault:nil];
            self.upload = [dic stringForKey:@"upload" withDefault:nil];
            self.message = [dic stringForKey:@"message" withDefault:nil];
            self.login = [dic stringForKey:@"login" withDefault:nil];
            
            self.sync = [dic stringForKey:@"sync" withDefault:nil];
        }
        
    }
    
    return self;
}

@end
