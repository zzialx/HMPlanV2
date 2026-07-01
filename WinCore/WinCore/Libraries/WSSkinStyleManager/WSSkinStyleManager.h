//
//  WSSkinStyleManager.h
//  WinSFA
//
//  Created by yang on 14-8-7.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSSkinStyleManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *skinStyleResourceCahche;

+ (WSSkinStyleManager*)sharedInstance;

@end
