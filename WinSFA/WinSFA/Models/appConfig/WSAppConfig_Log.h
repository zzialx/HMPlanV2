//
//  AppConfig_Log.h
//  WinChannelFrameWork
//
//  Created by ygs on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAppConfig_Log : NSObject
{
    NSString    *Log_value;
    NSString    *Log_empId;
}
@property (nonatomic, strong) NSString  *Log_value;
@property (nonatomic, strong) NSString  *Log_empId;
- (id)initWithObject:(id)object;
@end
