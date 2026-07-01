//
//  AppConfig_InfoBK.m
//  WinChannelFrameWork
//
//  Created by ygs on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSAppConfig_InfoBK.h"
#import "WinSFA.h"
@implementation WSAppConfig_InfoBK
@synthesize SmsBK;
@synthesize empId;
@synthesize AppInfo;
@synthesize CallHist;
@synthesize AddrBook;
-(id)initWithObject:(id)object
{
            if (nil == object) {
            return nil;
        }
        self = [super init];
        
        if (self) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary *)object;
                //NSLog(@"%@",dic);
                SmsBK = [dic objectForKey:APPCONFIG_SMSBK];
                empId = [dic objectForKey:APPCONFIG_EMPID];
                AppInfo = [dic objectForKey:APPCONFIG_APPINFO];
                CallHist = [dic objectForKey:APPCONFIG_CALLHIST];
                AddrBook = [dic objectForKey:APPCONFIG_ADDRBOOK];
            }
        }
        
        return self;
}
@end
