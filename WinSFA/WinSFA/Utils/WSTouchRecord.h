//
//  WSTouchRecord.h
//  WinSFA
//
//  Created by zhangke on 14/6/30.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSTouchRecord : NSObject

@property (nonatomic,assign) BOOL login;

+(WSTouchRecord *) sharedManager;

-(void)resetTimer;
-(void)stopTimer;

@end
