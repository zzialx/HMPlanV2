//
//  EmpInfoBeanArray.h
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-6-25.
//
//

#import <Foundation/Foundation.h>
#import "WSEmpInfoBeanArray.h"

#define EMPINFO @"empInfo"

@interface WSEmpInfoBeanArray : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *empInfoBeanArray;

- (id)initWithObject:(id)object;

@end
