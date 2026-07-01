//
//  WSBaseService.m
//  WinSFA
//
//  Created by winchannel on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSBaseService.h"

@implementation WSBaseService

-(id)init{
    self = [super init];
    if (self) {
        
        
        _appdata =[WSAppData sharedManager];
        
        return self;
    }
    return nil;
}

@end
