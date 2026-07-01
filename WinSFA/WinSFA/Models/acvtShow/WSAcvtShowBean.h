//
//  WCAcvtShowBean.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 6/14/13.
//
//

#import <Foundation/Foundation.h>

@interface WSAcvtShowBean : NSObject

@property (nonatomic, readonly, strong)NSNumber *iId; //acvt id
@property (nonatomic, readonly, copy) NSString *iName; // content

- (id)initWithObject:(id) aObject;

@end
