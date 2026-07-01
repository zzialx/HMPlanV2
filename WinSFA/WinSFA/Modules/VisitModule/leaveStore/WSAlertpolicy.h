//
//  WSAlertpolicy.h
//  WinSFA
//
//  Created by winchannel on 15/8/11.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSPolicyObject;

@protocol WSAlertpolicyDelegate <NSObject>

- (void)alertpolicyforUpload;

@end

@interface WSAlertpolicy : NSObject

@property (nonatomic ,weak) id<WSAlertpolicyDelegate>delegate;

- (BOOL)testInMiniDuration:(NSInteger)duration fromBegin:(NSString *)beginDate toEnd:(NSString *)endDate;

- (void)executePolicy:(NSDictionary *)pobj;

- (WSPolicyObject *)policyInfoMation4Dict:(NSDictionary *)policyDict;

@end
