//
//  AppConfigArray.h
//  WinChannelFrameWork
//
//  Created by ygs on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAppConfigArray : NSObject
{
    NSMutableArray  *appConfigArray;
    NSString        *empID_;
}
@property (nonatomic, strong) NSMutableArray    *appConfigArray;
@property (nonatomic, copy) NSString            *empID;

- (id)initWithObject:(id)object;
@end
