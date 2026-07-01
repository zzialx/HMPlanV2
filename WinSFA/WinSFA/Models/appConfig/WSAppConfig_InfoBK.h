//
//  AppConfig_InfoBK.h
//  WinChannelFrameWork
//
//  Created by ygs on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAppConfig_InfoBK : NSObject
{
    NSString    *empId;
    NSString    *AppInfo;
    NSString    *CallHist;
    NSString    *AddrBook;
    NSString    *SmsBK;
}
@property (nonatomic, strong) NSString  *empId;
@property (nonatomic, strong) NSString  *AppInfo;
@property (nonatomic, strong) NSString  *CallHist;
@property (nonatomic, strong) NSString  *AddrBook;
@property (nonatomic, strong) NSString  *SmsBK;
- (id)initWithObject:(id)object;
@end
