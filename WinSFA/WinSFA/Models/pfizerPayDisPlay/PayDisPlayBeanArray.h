//
//  PayDisPlayBeanArray.h
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-6-27.
//
//

#import <Foundation/Foundation.h>
#import "PayDisPlayBean.h"

@interface PayDisPlayBeanArray : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *beanArray;

- (id)initWithObject:(id)object;
- (id )initWithFilter:(NSString *)filter;

@end
