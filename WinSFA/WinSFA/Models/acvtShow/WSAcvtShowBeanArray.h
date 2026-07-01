//
//  WCAcvtShowBeanArray.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 6/14/13.
//
//

#import <Foundation/Foundation.h>

@interface WSAcvtShowBeanArray : NSObject

@property (nonatomic, strong) NSMutableArray *iAcvtShowBeans;


- (id)initWithObject:(id) aObject;

- (NSArray *)getAcvtshowbeansWithAcvtid:(int) aAcvtId;

@end
