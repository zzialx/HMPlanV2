//
//  WCbusiAcvtBean.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 6/26/13.
//
//

#import <Foundation/Foundation.h>

@interface WSBusiAcvtBean : NSObject

@property (nonatomic, strong, readonly) NSNumber *empId;
@property (nonatomic, strong, readonly) NSNumber *acvtId;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *isMyAcvt; // Y 或 N

- (id)initWithObject:(id)aObject;

@end
