//
//  WCSpbaInfoBeanArray.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 6/27/13.
//
//

#import <Foundation/Foundation.h>

@interface WSSpbaInfoBeanArray : NSObject

@property (nonatomic, strong) NSMutableArray *spbaInfoBeanArray;

- (id)initWithObject:(id)aObject;

- (NSArray *)getspbaInfoBeansByType:(NSString *)aType;

- (NSArray *)getspbaInfoBeansByType:(NSString *)aType andWithAcvtId:(int)aAcvtId;

@end
