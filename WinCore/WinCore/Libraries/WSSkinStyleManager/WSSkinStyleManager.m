//
//  WSSkinStyleManager.m
//  WinSFA
//
//  Created by yang on 14-8-7.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSSkinStyleManager.h"
#import "WSPlistHelper.h"
#import "WSSkinStyleManagerKit.h"

static WSSkinStyleManager *sharedSkinStyleManager;

@interface WSSkinStyleManager ()



@end

@implementation WSSkinStyleManager

#pragma mark - about singleton and initialize

+ (WSSkinStyleManager*)sharedInstance
{
    if (!sharedSkinStyleManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedSkinStyleManager = [[super allocWithZone:NULL] init];
        });
    }
    
    return sharedSkinStyleManager;
}

+ (id) allocWithZone:(NSZone*) zone {
	return [self sharedInstance];
}

- (id) copyWithZone:(NSZone*) zone {
	return sharedSkinStyleManager;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _skinStyleResourceCahche = [NSMutableDictionary dictionaryWithDictionary:[WSPlistHelper allPropertiesWithPlistName:kSkinStyleFileName]];
    }
    
    return self;
}

#pragma mark - private methods

#pragma mark - public methods


@end
