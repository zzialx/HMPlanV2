//
//  AppConfig.h
//  WinChannelFrameWork
//
//  Created by ygs on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAppConfig : NSObject
{
    NSString        *empId;
    NSMutableArray  *appConfigArr;
}
@property (nonatomic, strong) NSString          *empId;
@property (nonatomic, strong) NSMutableArray    *appConfigArr;
- (id)initWithObject:(id)object;

@end
