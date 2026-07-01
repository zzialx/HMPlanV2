//
//  WCBusiAcvtBeanArray.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 6/26/13.
//
//

#import <Foundation/Foundation.h>

@interface WSBusiAcvtBeanArray : NSObject

@property (nonatomic, strong) NSMutableArray *busiAcvtBeanArray;

- (id)initWithObject:(id)aObject;

- (NSArray *)getBusiAcvtArrayByAcvtId:(int)aAcvtId;

@end
