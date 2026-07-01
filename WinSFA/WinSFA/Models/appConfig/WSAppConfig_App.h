//
//  AppConfig_App.h
//  WinChannelFrameWork
//
//  Created by ygs on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAppConfig_App : NSObject
{
    NSString    *App_value;
    NSString    *App_empId;
}
@property (nonatomic, strong) NSString  *App_value;
@property (nonatomic, strong) NSString  *App_empId;
- (id)initWithObject:(id)object;
@end
